"""
Hybrid OCR Service - UNS-ClaudeJP 3.0
Servicio híbrido que combina Azure OCR y EasyOCR para máxima precisión
"""
import os
import logging
import base64
from typing import Dict, Any, Optional, List
from io import BytesIO
from pathlib import Path

import numpy as np
from PIL import Image

logger = logging.getLogger(__name__)


class HybridOCRService:
    """Servicio híbrido OCR que combina múltiples métodos para máxima precisión"""
    
    def __init__(self):
        self.azure_available = False
        self.easyocr_available = False
        
        # Inicializar servicios disponibles
        self._init_services()
        
        logger.info(f"HybridOCRService inicializado - Azure: {self.azure_available}, EasyOCR: {self.easyocr_available}")
    
    def _init_services(self):
        """Inicializar servicios OCR disponibles"""
        # Inicializar Azure OCR
        try:
            from app.services.azure_ocr_service import azure_ocr_service
            self.azure_service = azure_ocr_service
            self.azure_available = True
            logger.info("Azure OCR service disponible")
        except ImportError as e:
            logger.warning(f"Azure OCR no disponible: {e}")
            self.azure_service = None
        
        # Inicializar EasyOCR
        try:
            from app.services.easyocr_service import easyocr_service
            self.easyocr_service = easyocr_service
            self.easyocr_available = easyocr_service.easyocr_available
            logger.info("EasyOCR service disponible")
        except ImportError as e:
            logger.warning(f"EasyOCR no disponible: {e}")
            self.easyocr_service = None
    
    def process_document_hybrid(self, image_data: bytes, document_type: str = "zairyu_card", 
                               preferred_method: str = "auto") -> Dict[str, Any]:
        """
        Procesar documento usando método híbrido inteligente
        
        Args:
            image_data: Bytes de la imagen
            document_type: Tipo de documento (zairyu_card, rirekisho, license)
            preferred_method: Método preferido (azure, easyocr, auto)
        
        Returns:
            Diccionario con resultados combinados
        """
        try:
            logger.info(f"Procesando documento con método híbrido: {document_type}, preferencia: {preferred_method}")
            
            results = {
                "document_type": document_type,
                "success": False,
                "method_used": "none",
                "confidence_score": 0.0,
                "azure_result": None,
                "easyocr_result": None,
                "combined_data": {}
            }
            
            # Estrategia de procesamiento según preferencia
            if preferred_method == "azure" and self.azure_available:
                # Azure primero, EasyOCR como fallback
                azure_result = self._process_with_azure(image_data, document_type)
                results["azure_result"] = azure_result
                
                if azure_result.get("success"):
                    results["success"] = True
                    results["method_used"] = "azure"
                    results["combined_data"] = azure_result
                    results["confidence_score"] = 0.8  # Confianza base para Azure
                    
                    # Intentar mejorar con EasyOCR si hay campos faltantes
                    if self.easyocr_available and self._has_missing_fields(azure_result, document_type):
                        logger.info("Campos faltantes detectados, complementando con EasyOCR")
                        easyocr_result = self._process_with_easyocr(image_data, document_type)
                        results["easyocr_result"] = easyocr_result
                        
                        if easyocr_result.get("success"):
                            combined = self._combine_results(azure_result, easyocr_result, "azure")
                            results["combined_data"] = combined
                            results["confidence_score"] = 0.9  # Mayor confianza con combinación
                else:
                    # Si Azure falla, probar con EasyOCR
                    if self.easyocr_available:
                        easyocr_result = self._process_with_easyocr(image_data, document_type)
                        results["easyocr_result"] = easyocr_result
                        
                        if easyocr_result.get("success"):
                            results["success"] = True
                            results["method_used"] = "easyocr"
                            results["combined_data"] = easyocr_result
                            results["confidence_score"] = 0.7
            
            elif preferred_method == "easyocr" and self.easyocr_available:
                # EasyOCR primero, Azure como fallback
                easyocr_result = self._process_with_easyocr(image_data, document_type)
                results["easyocr_result"] = easyocr_result
                
                if easyocr_result.get("success"):
                    results["success"] = True
                    results["method_used"] = "easyocr"
                    results["combined_data"] = easyocr_result
                    results["confidence_score"] = 0.8
                    
                    # Intentar mejorar con Azure si hay campos faltantes
                    if self.azure_available and self._has_missing_fields(easyocr_result, document_type):
                        logger.info("Campos faltantes detectados, complementando con Azure")
                        azure_result = self._process_with_azure(image_data, document_type)
                        results["azure_result"] = azure_result
                        
                        if azure_result.get("success"):
                            combined = self._combine_results(easyocr_result, azure_result, "easyocr")
                            results["combined_data"] = combined
                            results["confidence_score"] = 0.9
                else:
                    # Si EasyOCR falla, probar con Azure
                    if self.azure_available:
                        azure_result = self._process_with_azure(image_data, document_type)
                        results["azure_result"] = azure_result
                        
                        if azure_result.get("success"):
                            results["success"] = True
                            results["method_used"] = "azure"
                            results["combined_data"] = azure_result
                            results["confidence_score"] = 0.7
            
            else:  # auto
                # Estrategia automática: probar ambos y combinar los mejores resultados
                azure_result = None
                easyocr_result = None
                
                # Ejecutar ambos servicios en paralelo si es posible
                if self.azure_available:
                    azure_result = self._process_with_azure(image_data, document_type)
                    results["azure_result"] = azure_result
                
                if self.easyocr_available:
                    easyocr_result = self._process_with_easyocr(image_data, document_type)
                    results["easyocr_result"] = easyocr_result
                
                # Evaluar resultados y seleccionar el mejor
                azure_success = azure_result and azure_result.get("success")
                easyocr_success = easyocr_result and easyocr_result.get("success")
                
                if azure_success and easyocr_success:
                    # Ambos funcionaron, combinar resultados
                    logger.info("Ambos métodos funcionaron, combinando resultados")
                    combined = self._combine_results(azure_result, easyocr_result, "auto")
                    results["success"] = True
                    results["method_used"] = "hybrid"
                    results["combined_data"] = combined
                    results["confidence_score"] = 0.95  # Máxima confianza con híbrido
                    
                elif azure_success:
                    # Solo Azure funcionó
                    logger.info("Solo Azure funcionó")
                    results["success"] = True
                    results["method_used"] = "azure"
                    results["combined_data"] = azure_result
                    results["confidence_score"] = 0.8
                    
                elif easyocr_success:
                    # Solo EasyOCR funcionó
                    logger.info("Solo EasyOCR funcionó")
                    results["success"] = True
                    results["method_used"] = "easyocr"
                    results["combined_data"] = easyocr_result
                    results["confidence_score"] = 0.8
                    
                else:
                    # Ninguno funcionó
                    logger.error("Ningún método OCR funcionó")
                    results["success"] = False
                    results["method_used"] = "none"
                    results["confidence_score"] = 0.0
            
            # Extraer foto con el servicio mejorado de detección facial
            if results["success"]:
                try:
                    from app.services.face_detection_service import face_detection_service
                    photo_data = face_detection_service.extract_face_from_document(image_data, document_type)
                    if photo_data:
                        results["combined_data"]["photo"] = photo_data
                        logger.info("Foto extraída exitosamente con servicio mejorado")
                except Exception as e:
                    logger.warning(f"Error extrayendo foto: {e}")
                    # Usar método original como fallback
                    try:
                        if self.azure_available:
                            photo_data = self.azure_service._extract_photo_from_document(image_data, document_type)
                            if photo_data:
                                results["combined_data"]["photo"] = photo_data
                    except Exception as e2:
                        logger.error(f"Error extrayendo foto con método original: {e2}")
            
            logger.info(f"Procesamiento híbrido completado - Método: {results['method_used']}, Éxito: {results['success']}")
            return results
            
        except Exception as e:
            logger.error(f"Error en procesamiento híbrido: {e}", exc_info=True)
            return {
                "success": False,
                "error": str(e),
                "method_used": "error",
                "confidence_score": 0.0
            }
    
    def _process_with_azure(self, image_data: bytes, document_type: str) -> Optional[Dict[str, Any]]:
        """Procesar con Azure OCR"""
        if not self.azure_available:
            return None
            
        try:
            # Guardar imagen temporal para Azure
            temp_path = "/tmp/temp_azure_image.jpg"
            with open(temp_path, 'wb') as f:
                f.write(image_data)
            
            # Procesar con Azure
            result = self.azure_service.process_document(temp_path, document_type)
            
            # Limpiar archivo temporal
            if os.path.exists(temp_path):
                os.remove(temp_path)
            
            return result
            
        except Exception as e:
            logger.error(f"Error procesando con Azure: {e}")
            return {"success": False, "error": str(e)}
    
    def _process_with_easyocr(self, image_data: bytes, document_type: str) -> Optional[Dict[str, Any]]:
        """Procesar con EasyOCR"""
        if not self.easyocr_available:
            return None
            
        try:
            result = self.easyocr_service.process_document_with_easyocr(image_data, document_type)
            return result
            
        except Exception as e:
            logger.error(f"Error procesando con EasyOCR: {e}")
            return {"success": False, "error": str(e)}
    
    def _has_missing_fields(self, result: Dict[str, Any], document_type: str) -> bool:
        """Verificar si faltan campos importantes"""
        if not result or not result.get("success"):
            return True
        
        # Campos críticos por tipo de documento
        if document_type == "zairyu_card":
            critical_fields = ['name_kanji', 'birthday', 'nationality']
        elif document_type == "rirekisho":
            critical_fields = ['name_kanji', 'birthday']
        elif document_type == "license":
            critical_fields = ['name_kanji', 'license_number']
        else:
            critical_fields = ['name_kanji']
        
        missing_count = 0
        for field in critical_fields:
            if not result.get(field):
                missing_count += 1
        
        # Si faltan más del 50% de campos críticos
        return missing_count > len(critical_fields) // 2
    
    def _combine_results(self, primary_result: Dict[str, Any], secondary_result: Dict[str, Any], 
                        primary_method: str) -> Dict[str, Any]:
        """
        Combinar resultados de dos métodos OCR
        
        Args:
            primary_result: Resultado del método principal
            secondary_result: Resultado del método secundario
            primary_method: Método principal ('azure', 'easyocr', 'auto')
        
        Returns:
            Resultado combinado con los mejores campos de cada método
        """
        try:
            combined = primary_result.copy()
            
            # Campos a combinar, priorizando el método principal
            fields_to_combine = [
                'name_kanji', 'name_kana', 'name_roman',
                'birthday', 'date_of_birth',
                'nationality',
                'address', 'current_address',
                'visa_status', 'residence_status',
                'zairyu_card_number', 'residence_card_number',
                'license_number',
                'raw_text'
            ]
            
            # Para cada campo, seleccionar el mejor valor
            for field in fields_to_combine:
                primary_value = primary_result.get(field)
                secondary_value = secondary_result.get(field)
                
                if not primary_value and secondary_value:
                    # Si el principal no tiene valor, usar el secundario
                    combined[field] = secondary_value
                    logger.info(f"Campo '{field}' complementado con {secondary_method(primary_method)}")
                elif primary_value and secondary_value:
                    # Ambos tienen valores, seleccionar el mejor
                    better_value = self._select_best_field_value(
                        field, primary_value, secondary_value, primary_method
                    )
                    if better_value != primary_value:
                        combined[field] = better_value
                        logger.info(f"Campo '{field}' mejorado con {secondary_method(primary_method)}")
            
            # Agregar metadata del procesamiento híbrido
            combined['ocr_method'] = 'hybrid'
            combined['primary_method'] = primary_method
            combined['azure_available'] = self.azure_available
            combined['easyocr_available'] = self.easyocr_available
            
            return combined
            
        except Exception as e:
            logger.error(f"Error combinando resultados: {e}")
            return primary_result
    
    def _select_best_field_value(self, field: str, primary_value: str, secondary_value: str, 
                                primary_method: str) -> str:
        """
        Seleccionar el mejor valor para un campo específico
        """
        # Para nombres, preferir el más largo y completo
        if 'name' in field:
            if len(secondary_value) > len(primary_value):
                return secondary_value
        
        # Para fechas, validar formato
        elif 'birthday' in field or 'date' in field:
            # Preferir formato japonés completo (YYYY年MM月DD日)
            if '年' in secondary_value and '月' in secondary_value and '日' in secondary_value:
                if '年' not in primary_value or '月' not in primary_value or '日' not in primary_value:
                    return secondary_value
        
        # Para nacionalidad, usar mapeo normalizado
        elif 'nationality' in field:
            # EasyOCR usualmente tiene mejor normalización para japonés
            if primary_method == 'azure' and secondary_value:
                return secondary_value
        
        # Para números de tarjeta, validar formato
        elif 'card_number' in field or 'license_number' in field:
            # Preferir el que coincida con el patrón esperado
            import re
            
            if field == 'zairyu_card_number':
                zairyu_pattern = r'[A-Z]{2}\s?\d{8}\s?[A-Z]{2}'
                if re.search(zairyu_pattern, secondary_value) and not re.search(zairyu_pattern, primary_value):
                    return secondary_value
        
        # Para texto crudo, combinar ambos
        elif field == 'raw_text':
            # Combinar textos únicos
            primary_lines = set(primary_value.split('\n'))
            secondary_lines = set(secondary_value.split('\n'))
            combined_lines = primary_lines.union(secondary_lines)
            return '\n'.join(sorted(combined_lines, key=len, reverse=True))
        
        # Por defecto, mantener el valor principal
        return primary_value
    
    def _secondary_method(self, primary_method: str) -> str:
        """Obtener el nombre del método secundario"""
        if primary_method == "azure":
            return "EasyOCR"
        elif primary_method == "easyocr":
            return "Azure OCR"
        else:
            return "OCR secundario"


# Instancia global del servicio
hybrid_ocr_service = HybridOCRService()

__all__ = ["HybridOCRService", "hybrid_ocr_service"]