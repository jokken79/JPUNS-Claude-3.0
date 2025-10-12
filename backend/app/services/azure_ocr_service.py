"""
Azure Computer Vision OCR Service - UNS-ClaudeJP 2.0
Service for processing documents using Azure Computer Vision API
"""
import os
import base64
import logging
from typing import Dict, Any, Optional
from pathlib import Path

from azure.cognitiveservices.vision.computervision import ComputerVisionClient
from azure.cognitiveservices.vision.computervision.models import VisualFeatureTypes
from msrest.authentication import CognitiveServicesCredentials

from app.core.config_azure import AZURE_ENDPOINT, AZURE_KEY, AZURE_API_VERSION

logger = logging.getLogger(__name__)

# Initialize Azure Computer Vision client
credentials = CognitiveServicesCredentials(AZURE_KEY)
client = ComputerVisionClient(AZURE_ENDPOINT, credentials)
logger.info(f"Azure Computer Vision client initialized successfully with endpoint: {AZURE_ENDPOINT}")


class AzureOCRService:
    """Azure Computer Vision OCR service"""

    def __init__(self):
        self.api_version = AZURE_API_VERSION
        logger.info(f"AzureOCRService initialized with API version: {self.api_version}")

    def process_document(self, file_path: str, document_type: str = "zairyu_card") -> Dict[str, Any]:
        """
        Process document image with Azure Computer Vision OCR

        Args:
            file_path: Path to image file
            document_type: Type of document (zairyu_card, rirekisho, license, etc.)

        Returns:
            Dictionary with extracted data
        """
        try:
            logger.info(f"Processing document: {file_path}, type: {document_type}")

            # Read image file
            with open(file_path, 'rb') as image:
                image_data = image.read()

            # Process with Azure Computer Vision
            result = self._process_with_azure(image_data, document_type)

            logger.info(f"Document processed successfully: {document_type}")
            return result

        except Exception as e:
            logger.error(f"Error processing document: {e}", exc_info=True)
            return {
                "success": False,
                "error": str(e),
                "raw_text": f"Error: {str(e)}"
            }

    def _process_with_azure(self, image_data: bytes, document_type: str) -> Dict[str, Any]:
        """Process image with Azure Computer Vision API"""
        try:
            # Use Read API for OCR
            logger.info("Calling Azure Computer Vision Read API")

            # Convert bytes to file-like object
            from io import BytesIO
            image_stream = BytesIO(image_data)

            # Send image for OCR processing
            read_response = client.read_in_stream(image_stream, raw=True)
            operation_location = read_response.headers["Operation-Location"]
            operation_id = operation_location.split("/")[-1]
            
            # Poll for result
            while True:
                read_result = client.get_read_result(operation_id)
                if read_result.status.lower() == 'succeeded':
                    break
                elif read_result.status.lower() == 'failed':
                    raise Exception(f"OCR processing failed: {read_result.status}")
                
                # Wait before polling again
                import time
                time.sleep(1)
            
            # Extract text from results
            raw_text = ""
            if read_result.analyze_result.read_results:
                for text_result in read_result.analyze_result.read_results:
                    for line in text_result.lines:
                        raw_text += line.text + "\n"

            logger.info(f"Azure Computer Vision API response received")
            logger.info(f"Raw text length: {len(raw_text)}")
            logger.info(f"Raw text preview: {raw_text[:200] if raw_text else 'EMPTY'}")

            # Parse structured data based on document type
            parsed_data = self._parse_response(raw_text, document_type)

            return {
                "success": True,
                "raw_text": raw_text,
                **parsed_data
            }

        except Exception as e:
            logger.error(f"Azure Computer Vision API error: {e}", exc_info=True)
            raise

    def _parse_response(self, raw_text: str, document_type: str) -> Dict[str, Any]:
        """Parse Azure response into structured data"""
        import re

        data = {
            "document_type": document_type,
            "extracted_text": raw_text
        }

        # Parse based on document type
        if document_type == "zairyu_card":
            data.update(self._parse_zairyu_card(raw_text))
        elif document_type == "license":
            data.update(self._parse_license(raw_text))

        return data

    def _parse_zairyu_card(self, text: str) -> Dict[str, Any]:
        """Parse Zairyu Card (Residence Card) data"""
        import re

        result = {}
        lines = text.split('\n')

        for i, line in enumerate(lines):
            line_clean = line.strip()

            # Extract name (氏名)
            if '氏名' in line or 'Name' in line:
                # Try next line or same line
                name_match = re.search(r'氏名[：:\s]*(.+)', line)
                if name_match:
                    result['name_kanji'] = name_match.group(1).strip()
                elif i + 1 < len(lines):
                    result['name_kanji'] = lines[i + 1].strip()

            # Extract date of birth (生年月日)
            if '生年月日' in line or 'Date of birth' in line:
                date_pattern = r'(\d{4})[年/\-.](\d{1,2})[月/\-.](\d{1,2})'
                match = re.search(date_pattern, line)
                if match:
                    year, month, day = match.groups()
                    result['birthday'] = f"{year}-{month.zfill(2)}-{day.zfill(2)}"

            # Extract nationality (国籍・地域)
            if '国籍' in line or 'Nationality' in line:
                nat_match = re.search(r'国籍[・：:\s]*(.+)', line)
                if nat_match:
                    result['nationality'] = nat_match.group(1).strip()

            # Extract residence status (在留資格)
            if '在留資格' in line or 'Status of residence' in line:
                status_match = re.search(r'在留資格[：:\s]*(.+)', line)
                if status_match:
                    result['visa_status'] = status_match.group(1).strip()

            # Extract expiry date (有効期限)
            if '有効期限' in line or '満了日' in line or 'expiry' in line.lower():
                date_pattern = r'(\d{4})[年/\-.](\d{1,2})[月/\-.](\d{1,2})'
                match = re.search(date_pattern, line)
                if match:
                    year, month, day = match.groups()
                    result['zairyu_expire_date'] = f"{year}-{month.zfill(2)}-{day.zfill(2)}"

            # Extract card number (カード番号)
            if 'カード番号' in line or 'Card No' in line or 'Number' in line:
                # Residence card numbers: AB1234567890
                number_pattern = r'([A-Z]{2}\d{10,})'
                match = re.search(number_pattern, line)
                if match:
                    result['zairyu_card_number'] = match.group(1)

            # Extract address (住居地)
            if '住居地' in line or 'Address' in line:
                addr_match = re.search(r'住居地[：:\s]*(.+)', line)
                if addr_match:
                    result['address'] = addr_match.group(1).strip()
                elif i + 1 < len(lines):
                    # Address might be on next lines
                    address_parts = []
                    for j in range(i + 1, min(i + 4, len(lines))):
                        if lines[j].strip() and not any(key in lines[j] for key in ['氏名', '生年月日', '国籍']):
                            address_parts.append(lines[j].strip())
                        else:
                            break
                    if address_parts:
                        result['address'] = ' '.join(address_parts)

        return result

    def _parse_license(self, text: str) -> Dict[str, Any]:
        """Parse Driver's License (Menkyosho) data"""
        import re

        result = {}
        lines = text.split('\n')

        for i, line in enumerate(lines):
            line_clean = line.strip()

            # Extract name (氏名)
            if '氏名' in line or 'Name' in line:
                name_match = re.search(r'氏名[：:\s]*(.+)', line)
                if name_match:
                    result['name_kanji'] = name_match.group(1).strip()
                elif i + 1 < len(lines):
                    result['name_kanji'] = lines[i + 1].strip()

            # Extract date of birth (生年月日)
            if '生年月日' in line or '生年月日' in line:
                date_pattern = r'(\d{4})[年/\-.](\d{1,2})[月/\-.](\d{1,2})'
                match = re.search(date_pattern, line)
                if match:
                    year, month, day = match.groups()
                    result['birthday'] = f"{year}-{month.zfill(2)}-{day.zfill(2)}"

            # Extract license number (免許証番号)
            if '免許証番号' in line or '第' in line:
                # License numbers: 第1234567890123号
                number_pattern = r'第?(\d{12,13})号?'
                match = re.search(number_pattern, line)
                if match:
                    result['license_number'] = match.group(1)

            # Extract license type (免許の種類)
            if '免許の種類' in line or '種類' in line:
                # Common types: 普通, 大型, 中型, 準中型, 大特, 大自二, 普自二, 小特, 原付
                types = []
                for license_type in ['大型', '中型', '準中型', '普通', '大特', '大自二', '普自二', '小特', '原付']:
                    if license_type in line or (i + 1 < len(lines) and license_type in lines[i + 1]):
                        types.append(license_type)
                if types:
                    result['license_type'] = ', '.join(types)

            # Extract expiry date (有効期限)
            if '有効期限' in line or '期限' in line:
                date_pattern = r'(\d{4})[年/\-.](\d{1,2})[月/\-.](\d{1,2})'
                match = re.search(date_pattern, line)
                if match:
                    year, month, day = match.groups()
                    result['license_expire_date'] = f"{year}-{month.zfill(2)}-{day.zfill(2)}"

            # Extract address (住所)
            if '住所' in line or 'Address' in line:
                addr_match = re.search(r'住所[：:\s]*(.+)', line)
                if addr_match:
                    result['address'] = addr_match.group(1).strip()
                elif i + 1 < len(lines):
                    # Address might be on next lines
                    address_parts = []
                    for j in range(i + 1, min(i + 4, len(lines))):
                        if lines[j].strip() and not any(key in lines[j] for key in ['氏名', '生年月日', '交付']):
                            address_parts.append(lines[j].strip())
                        else:
                            break
                    if address_parts:
                        result['address'] = ' '.join(address_parts)

            # Extract issuing date (交付年月日)
            if '交付' in line:
                date_pattern = r'(\d{4})[年/\-.](\d{1,2})[月/\-.](\d{1,2})'
                match = re.search(date_pattern, line)
                if match:
                    year, month, day = match.groups()
                    result['license_issue_date'] = f"{year}-{month.zfill(2)}-{day.zfill(2)}"

        return result


# Create singleton instance
azure_ocr_service = AzureOCRService()

__all__ = ["AzureOCRService", "azure_ocr_service"]