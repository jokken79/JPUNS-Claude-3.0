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

            # Extract photo from document
            photo_data = self._extract_photo_from_document(image_data, document_type)
            if photo_data:
                parsed_data['photo'] = photo_data

            parsed_data = self._apply_common_aliases(parsed_data)

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

    def _apply_common_aliases(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Add form-friendly aliases for extracted OCR data."""
        if not isinstance(data, dict):
            return data

        # Names
        if data.get('name_kanji') and not data.get('full_name_kanji'):
            data['full_name_kanji'] = data['name_kanji']
        if data.get('name_kana') and not data.get('full_name_kana'):
            data['full_name_kana'] = data['name_kana']
        if data.get('name_roman') and not data.get('full_name_roman'):
            data['full_name_roman'] = data['name_roman']

        # Dates
        if data.get('birthday') and not data.get('date_of_birth'):
            data['date_of_birth'] = data['birthday']
        if data.get('zairyu_expire_date') and not data.get('residence_expiry'):
            data['residence_expiry'] = data['zairyu_expire_date']
        if data.get('license_expire_date') and not data.get('license_expiry'):
            data['license_expiry'] = data['license_expire_date']

        # Identification numbers
        if data.get('zairyu_card_number') and not data.get('residence_card_number'):
            data['residence_card_number'] = data['zairyu_card_number']

        # Status fields
        if data.get('visa_status') and not data.get('residence_status'):
            data['residence_status'] = data['visa_status']

        # Address aliases
        if data.get('address'):
            data.setdefault('current_address', data['address'])
        if data.get('banchi') and not data.get('address_banchi'):
            data['address_banchi'] = data['banchi']
        if data.get('building') and not data.get('address_building'):
            data['address_building'] = data['building']

        # Photo
        if data.get('photo') and not data.get('photo_url'):
            data['photo_url'] = data['photo']

        return data

    def _parse_zairyu_card(self, text: str) -> Dict[str, Any]:
        """Parse Zairyu Card (Residence Card) data"""
        import re
        result = {}
        raw_lines = [line.replace('\u3000', ' ') for line in text.split('\n')]
        lines = [line.strip() for line in raw_lines if line.strip()]
        normalized_lines = [re.sub(r'\s+', '', line) for line in lines]
        
        # --- DATE PARSING ---
        date_patterns = [
            r'(\d{4})[年/\-\.](\d{1,2})[月/\-\.](\d{1,2})日?',
            r'(\d{4})[/\-\.](\d{1,2})[/\-\.](\d{1,2})'
        ]
        all_dates = []
        for line in lines:
            for pattern in date_patterns:
                for match in re.finditer(pattern, line):
                    try:
                        year, month, day = [int(g) for g in match.groups()]
                        if 1 <= month <= 12 and 1 <= day <= 31:
                            all_dates.append(f"{year}-{month:02d}-{day:02d}")
                    except (ValueError, IndexError):
                        continue
        
        if all_dates:
            result['birthday'] = all_dates[0]
            if len(all_dates) > 1:
                result['zairyu_expire_date'] = all_dates[-1]

        # --- MAIN PARSING LOOP ---
        for i, line in enumerate(lines):
            normalized_line = normalized_lines[i]
            normalized_upper = normalized_line.upper()
            # Name (detect both Kanji and Roman)
            if 'name_kanji' not in result and any(keyword in line for keyword in ['氏名', 'Name']):
                name_match = re.search(r'氏名[：:\s]*(.+)', line)
                if name_match and len(name_match.group(1).strip()) > 1:
                    name_text = name_match.group(1).strip()
                    # Check if it's Roman letters (all uppercase or mixed case English)
                    if re.match(r'^[A-Z][A-Z\s]+$', name_text):
                        result['name_roman'] = name_text
                        # AUTO-CONVERT to Katakana
                        result['name_kana'] = self._convert_to_katakana(name_text)
                        # ALSO set name_kanji so frontend displays the name
                        result['name_kanji'] = name_text
                        logger.info(f"OCR - Detected Roman name: {name_text}, converted to: {result['name_kana']}")
                    else:
                        result['name_kanji'] = name_text
                elif i + 1 < len(lines) and not any(k in lines[i+1] for k in ['生年月日', '国籍', '性別']):
                    name_text = lines[i+1].strip()
                    # Check if it's Roman letters
                    if re.match(r'^[A-Z][A-Z\s]+$', name_text):
                        result['name_roman'] = name_text
                        result['name_kana'] = self._convert_to_katakana(name_text)
                        # ALSO set name_kanji so frontend displays the name
                        result['name_kanji'] = name_text
                        logger.info(f"OCR - Detected Roman name: {name_text}, converted to: {result['name_kana']}")
                    else:
                        result['name_kanji'] = name_text

            # Gender
            if 'gender' not in result and any(keyword in line for keyword in ['性別', 'Gender']):
                if '男' in line or 'Male' in line: result['gender'] = '男性'
                elif '女' in line or 'Female' in line: result['gender'] = '女性'

            # Nationality
            if 'nationality' not in result and (
                '国籍' in normalized_line or 'NATIONALITY' in normalized_upper or '地域' in normalized_line
            ):
                nat_match = re.search(r'国籍[・：:\s]*(.+)', line)
                if nat_match and nat_match.group(1).strip():
                    result['nationality'] = self._normalize_nationality(nat_match.group(1).strip())

            # Address
            if 'address' not in result and any(keyword in line for keyword in ['住居地', 'Address']):
                addr_match = re.search(r'住居地[：:\s]*(.+)', line)
                if addr_match and addr_match.group(1).strip():
                    result['address'] = addr_match.group(1).strip()
                elif i + 1 < len(lines):
                    result['address'] = lines[i+1].strip()

            # Visa Status - IMPROVED DETECTION
            if 'visa_status' not in result and (
                '在留資格' in normalized_line or 'STATUSOFRESIDENCE' in normalized_upper or '資格' in normalized_line
            ):
                status_match = re.search(r'在留資格[：:\s]*(.+)', line)
                if status_match and status_match.group(1).strip():
                    visa_text = status_match.group(1).strip()
                    # Clean up visa status (remove dates, numbers at end)
                    visa_text = re.sub(r'\d{4}[年/\-].*$', '', visa_text).strip()
                    if visa_text and len(visa_text) > 2:
                        result['visa_status'] = visa_text
                        logger.info(f"OCR - Detected visa status: {visa_text}")
                elif i + 1 < len(lines):
                    visa_text = lines[i+1].strip()
                    # Clean up and validate
                    visa_text = re.sub(r'\d{4}[年/\-].*$', '', visa_text).strip()
                    if visa_text and len(visa_text) > 2 and not any(skip in visa_text for skip in ['Address', '住所', '番号']):
                        result['visa_status'] = visa_text
                        logger.info(f"OCR - Detected visa status (next line): {visa_text}")

            # Residence Period (在留期間) - NEW DETECTION
            if 'visa_period' not in result and any(keyword in line for keyword in ['在留期間', 'Period of stay', 'PERIOD OF STAY']):
                # Try to extract period from same line first
                period_match = re.search(r'在留期間[：:\s(（]*(.+)', line)
                if period_match and period_match.group(1).strip():
                    period_text = period_match.group(1).strip()
                    # Common periods: 3年, 5年, 1年, 6ヶ月, etc.
                    if re.search(r'\d+[年ヶか月]', period_text):
                        # Extract just the period part (e.g., "3年" from "3年(2028年05月19日)")
                        clean_period = re.search(r'(\d+[年ヶか月]+)', period_text)
                        if clean_period:
                            result['visa_period'] = clean_period.group(1)
                            logger.info(f"OCR - Detected residence period: {result['visa_period']}")
                # If not found, check next line
                elif i + 1 < len(lines):
                    period_text = lines[i+1].strip()
                    # Skip if it's just English translation
                    if 'PERIOD' in period_text.upper():
                        # Try next line after that
                        if i + 2 < len(lines):
                            period_text = lines[i+2].strip()
                    # Validate it looks like a period (e.g., "3年" or "5 years")
                    if re.search(r'\d+[年ヶか月]', period_text):
                        # Extract just the period part
                        clean_period = re.search(r'(\d+[年ヶか月]+)', period_text)
                        if clean_period:
                            result['visa_period'] = clean_period.group(1)
                            logger.info(f"OCR - Detected residence period (next line): {result['visa_period']}")

            # Card Number
            if 'zairyu_card_number' not in result and any(keyword in line for keyword in ['カード番号', '番号', 'Card No']):
                pattern = r'([A-Z]{2}\s?\d{8}\s?[A-Z]{2})'
                match = re.search(pattern, line.replace(' ', ''))
                if match:
                    result['zairyu_card_number'] = match.group(1)

        # --- FALLBACKS & POST-PROCESSING ---

        # Additional Visa Status fallback scanning entire text
        if 'visa_status' not in result:
            combined_text = '\n'.join(lines)
            combined_text_clean = combined_text.replace('\u3000', ' ')
            status_pattern = re.compile(r'(?:在留資格|Status of residence|STATUS OF RESIDENCE)[：:\s]*([^\n]+)', re.IGNORECASE)
            status_match = status_pattern.search(combined_text_clean)
            if status_match:
                candidate_status = re.sub(r'\d{4}[年/\-].*$', '', status_match.group(1)).strip()
                if candidate_status:
                    result['visa_status'] = candidate_status
                    logger.info(f"OCR - Visa status fallback extraction: {candidate_status}")
            else:
                for idx, line in enumerate(lines):
                    if any(keyword in line for keyword in ['在留資格', 'Status of residence', 'STATUS OF RESIDENCE']):
                        for offset in range(1, 4):
                            if idx + offset >= len(lines):
                                break
                            candidate_line = lines[idx + offset].strip()
                            if not candidate_line:
                                continue
                            if re.search(r'(在留期間|PERIOD OF STAY)', candidate_line, re.IGNORECASE):
                                continue
                            clean_candidate = re.sub(r'\d{4}[年/\-].*$', '', candidate_line).strip()
                            if clean_candidate:
                                result['visa_status'] = clean_candidate
                                logger.info(f"OCR - Visa status fallback (next lines): {clean_candidate}")
                                break
                        if 'visa_status' in result:
                            break

        # Nationality Fallback
        if 'nationality' not in result:
            normalized_nat = self._normalize_nationality(text)
            if normalized_nat != text: result['nationality'] = normalized_nat
        
        # Address Component Parsing
        if 'address' in result:
            address_components = self._parse_japanese_address(result['address'])
            result.update(address_components)
            main_address_parts = [
                address_components.get('prefecture', ''),
                address_components.get('city', ''),
                address_components.get('ward', ''),
                address_components.get('district', '')
            ]
            # Overwrite full address with just the main parts, before banchi
            if any(main_address_parts):
                result['address'] = ''.join(main_address_parts).strip()

        if result.get('visa_status') and 'residence_status' not in result:
            result['residence_status'] = result['visa_status']
        if result.get('birthday') and 'date_of_birth' not in result:
            result['date_of_birth'] = result['birthday']
        if result.get('zairyu_expire_date') and 'residence_expiry' not in result:
            result['residence_expiry'] = result['zairyu_expire_date']
        if result.get('zairyu_card_number') and 'residence_card_number' not in result:
            result['residence_card_number'] = result['zairyu_card_number']

        if result.get('name_kanji') and 'full_name_kanji' not in result:
            result['full_name_kanji'] = result['name_kanji']
        if result.get('name_kana') and 'full_name_kana' not in result:
            result['full_name_kana'] = result['name_kana']
        if result.get('name_roman') and 'full_name_roman' not in result:
            result['full_name_roman'] = result['name_roman']

        if result.get('address'):
            result.setdefault('current_address', result['address'])

        return result

    def _parse_license(self, text: str) -> Dict[str, Any]:
        """Parse Driver's License (Menkyosho) data"""
        import re

        result = {}
        raw_lines = [line.replace('\u3000', ' ') for line in text.split('\n')]
        lines = [line.strip() for line in raw_lines if line.strip()]

        for i, line in enumerate(lines):
            line_clean = line.strip()
            line_normalized = re.sub(r'\s+', '', line_clean)
            line_upper = line_clean.upper()

            # Extract name (氏名)
            if '氏名' in line or 'Name' in line:
                name_match = re.search(r'氏名[：:\s]*(.+)', line)
                if name_match:
                    result['name_kanji'] = name_match.group(1).strip()
                elif i + 1 < len(lines):
                    result['name_kanji'] = lines[i + 1].strip()

            # Extract name kana (フリガナ)
            if 'フリガナ' in line or '振り仮名' in line_normalized or 'FURIGANA' in line_upper:
                kana_match = re.search(r'(?:フリガナ|ふりがな|FURIGANA)[：:\s]*(.+)', line)
                if kana_match:
                    result['name_kana'] = kana_match.group(1).strip()
                elif i + 1 < len(lines):
                    result['name_kana'] = lines[i + 1].strip()

            # Extract date of birth (生年月日)
            if '生年月日' in line or 'BIRTH' in line_upper:
                date_pattern = r'(\d{4})[年/\-.](\d{1,2})[月/\-.](\d{1,2})'
                match = re.search(date_pattern, line)
                if match:
                    year, month, day = match.groups()
                    result['birthday'] = f"{year}-{month.zfill(2)}-{day.zfill(2)}"

            # Extract license number (免許証番号)
            if '免許証番号' in line or line_normalized.startswith('第'):
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
            if '有効期限' in line or 'EXPIRY' in line_upper or '期限' in line:
                date_pattern = r'(\d{4})[年/\-.](\d{1,2})[月/\-.](\d{1,2})'
                match = re.search(date_pattern, line)
                if match:
                    year, month, day = match.groups()
                    result['license_expire_date'] = f"{year}-{month.zfill(2)}-{day.zfill(2)}"

            # Extract address (住所)
            if '住所' in line or 'ADDRESS' in line_upper:
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
            if '交付' in line or 'ISSUED' in line_upper:
                date_pattern = r'(\d{4})[年/\-.](\d{1,2})[月/\-.](\d{1,2})'
                match = re.search(date_pattern, line)
                if match:
                    year, month, day = match.groups()
                    result['license_issue_date'] = f"{year}-{month.zfill(2)}-{day.zfill(2)}"

        # Fallbacks using entire text
        if 'license_number' not in result:
            number_pattern = re.compile(r'第\s?(\d{12,13})号?')
            number_match = number_pattern.search(''.join(lines))
            if number_match:
                result['license_number'] = number_match.group(1)

        if 'license_expire_date' not in result:
            date_pattern = re.compile(r'有効期限[：:\s]*(\d{4})[年/\-.](\d{1,2})[月/\-.](\d{1,2})')
            date_match = date_pattern.search(' '.join(lines))
            if date_match:
                year, month, day = date_match.groups()
                result['license_expire_date'] = f"{year}-{int(month):02d}-{int(day):02d}"

        if 'address' in result:
            address_components = self._parse_japanese_address(result['address'])
            result.update(address_components)
            result.setdefault('current_address', result['address'])

        if result.get('birthday') and 'date_of_birth' not in result:
            result['date_of_birth'] = result['birthday']
        if result.get('name_kanji') and 'full_name_kanji' not in result:
            result['full_name_kanji'] = result['name_kanji']
        if result.get('name_kana') and 'full_name_kana' not in result:
            result['full_name_kana'] = result['name_kana']
        if result.get('license_expire_date') and 'license_expiry' not in result:
            result['license_expiry'] = result['license_expire_date']

        return result

    def _convert_to_katakana(self, text: str) -> str:
        """Convert text to Katakana using basic patterns"""
        import re
        
        # Extended conversion patterns for Vietnamese names and common Japanese names
        # This is a simplified version - in production you'd use a proper library
        conversion_map = {
            # Vietnamese names (from your examples)
            'MAI': 'マイ',
            'TU': 'トゥ',
            'ANH': 'アン',
            'NGUYEN': 'グエン',
            'VAN': 'ヴァン',
            'QUY': 'クイ',
            'VU': 'ヴゥ',
            'THI': 'ティ',
            'SAU': 'サウ',
            'TUAN': 'トゥアン',
            'VIET': 'ヴィエット',
            'CUONG': 'クオン',
            'LUU': 'ルウ',
            'PHUONG': 'フォン',
            'HOAI': 'ホアイ',
            
            # Common Vietnamese name components
            'MINH': 'ミン',
            'THANH': 'タン',
            'HUY': 'フイ',
            'DUC': 'ドゥック',
            'HOANG': 'ホアン',
            'TRUNG': 'チュン',
            'AN': 'アン',
            'BINH': 'ビン',
            'NAM': 'ナム',
            'NU': 'ヌ',
            'HA': 'ハ',
            'LINH': 'リン',
            'GIANG': 'ジャン',
            'QUYNH': 'クイン',
            'TRANG': 'チャン',
            'PHUC': 'フック',
            'SON': 'ソン',
            'LAM': 'ラム',
            'TAM': 'タム',
            'NGOC': 'ゴック',
            'THAO': 'タオ',
            'THUY': 'トゥイ',
            'MY': 'ミー',
            'LY': 'リー',
            
            # Common Japanese names
            'YAMADA': 'ヤマダ',
            'TARO': 'タロウ',
            'HANAKO': 'ハナコ',
            'SUZUKI': 'スズキ',
            'SATOU': 'サトウ',
            'TANAKA': 'タナカ',
            'WATANABE': 'ワタナベ',
            'ITO': 'イトウ',
            'YAMAMOTO': 'ヤマモト',
            'NAKAMURA': 'ナカムラ',
            'KOBAYASHI': 'コバヤシ',
            'SAITOU': 'サイトウ',
            'KATO': 'カトウ',
            'YOSHIDA': 'ヨシダ',
            'YAMASHITA': 'ヤマシタ',
            'HASHIMOTO': 'ハシモト',
            'FUJITA': 'フジタ',
            'OGAWA': 'オガワ',
            'MORI': 'モリ',
            'ISHIDA': 'イシダ',
            'MATSUMOTO': 'マツモト',
            'HAYASHI': 'ハヤシ',
            'KIMURA': 'キムラ',
            
            # Special character combinations
            'PH': 'フ',
            'TH': 'ト',
            'QU': 'ク',
            'NG': 'ング',
            'NH': 'ニ',
            'CH': 'チ'
        }
        
        # Try to convert known patterns
        result = text.upper()  # Convert to uppercase for matching
        
        # Handle special Vietnamese combinations first
        for romaji, katakana in conversion_map.items():
            result = result.replace(romaji, katakana)
        
        # Handle individual character conversions for remaining text
        char_map = {
            'A': 'ア', 'B': 'ビ', 'C': 'シ', 'D': 'ド', 'E': 'エ',
            'F': 'フ', 'G': 'グ', 'H': 'ハ', 'I': 'イ', 'J': 'ジ',
            'K': 'ク', 'L': 'ル', 'M': 'ム', 'N': 'ン', 'O': 'オ',
            'P': 'プ', 'Q': 'ク', 'R': 'ル', 'S': 'ス', 'T': 'ト',
            'U': 'ウ', 'V': 'ヴ', 'W': 'ワ', 'X': 'クス', 'Y': 'ヤ',
            'Z': 'ズ'
        }
        
        # Convert any remaining characters
        final_result = ''
        for char in result:
            if char in char_map:
                final_result += char_map[char]
            else:
                final_result += char
        
        return final_result

    def _normalize_nationality(self, nationality: str) -> str:
        """Normalize nationality to Japanese format"""
        nationality_mapping = {
            'VIETNAM': 'ベトナム',
            'VIET NAM': 'ベトナム',
            'Vietnam': 'ベトナム',
            'Viet Nam': 'ベトナム',
            'vietnan': 'ベトナム',  # Common OCR error
            'VIETNAN': 'ベトナム',
            'PHILIPPINES': 'フィリピン',
            'Philippines': 'フィリピン',
            'CHINA': '中国',
            'China': '中国',
            'KOREA': '韓国',
            'Korea': '韓国',
            'BRAZIL': 'ブラジル',
            'Brazil': 'ブラジル',
            'PERU': 'ペルー',
            'Peru': 'ペルー',
            'INDONESIA': 'インドネシア',
            'Indonesia': 'インドネシア',
            'THAILAND': 'タイ',
            'Thailand': 'タイ',
            'MYANMAR': 'ミャンマー',
            'Myanmar': 'ミャンマー',
            'CAMBODIA': 'カンボジア',
            'Cambodia': 'カンボジア',
            'NEPAL': 'ネパール',
            'Nepal': 'ネパール',
            'MONGOLIA': 'モンゴル',
            'Mongolia': 'モンゴル',
            'BANGLADESH': 'バングラデシュ',
            'Bangladesh': 'バングラデシュ',
            'SRI LANKA': 'スリランカ',
            'Sri Lanka': 'スリランカ'
        }
        
        # Try exact match first
        normalized = nationality_mapping.get(nationality.upper())
        if normalized:
            return normalized
        
        # Try partial match
        for key, value in nationality_mapping.items():
            if key.lower() in nationality.lower() or nationality.lower() in key.lower():
                return value
        
        # Return original if no mapping found
        return nationality

    def _parse_japanese_address(self, address: str) -> Dict[str, str]:
        """Parse Japanese address into components"""
        import re
        
        result = {
            'postal_code': '',
            'prefecture': '',
            'city': '',
            'ward': '',
            'district': '',
            'banchi': '',
            'building': ''
        }
        
        # Extract postal code if present
        postal_match = re.search(r'(\d{3}-\d{4})', address)
        if postal_match:
            result['postal_code'] = postal_match.group(1)
        
        # Extract prefecture
        prefectures = ['北海道', '青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県',
                      '茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県',
                      '新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県',
                      '静岡県', '愛知県', '三重県', '滋賀県', '京都府', '大阪府', '兵庫県',
                      '奈良県', '和歌山県', '鳥取県', '島根県', '岡山県', '広島県', '山口県',
                      '徳島県', '香川県', '愛媛県', '高知県', '福岡県', '佐賀県', '長崎県',
                      '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県']
        
        for prefecture in prefectures:
            if prefecture in address:
                result['prefecture'] = prefecture
                # Remove prefecture from address for further processing
                address = address.replace(prefecture, '', 1)
                break
        
        # Split remaining address by common delimiters
        # Pattern: 市区町村 + 番地 + 建物名
        # Example: 名古屋市東区徳川2-18-18
        #          city  ward district banchi
        
        # Match patterns like "名古屋市東区徳川"
        city_ward_pattern = r'([^0-9]+[市区町村])([^0-9]+[区郡]?[^0-9]*)([^0-9]+)?'
        match = re.search(city_ward_pattern, address)
        if match:
            result['city'] = match.group(1)
            result['ward'] = match.group(2) if match.group(2) else ''
            result['district'] = match.group(3) if match.group(3) else ''
        
        # Extract banchi (番地) - numbers after district
        # Handle patterns like "908番地1の2" or "908-1-2"
        banchi_patterns = [
            r'(\d+)番地(\d+)の(\d+)',  # 908番地1の2
            r'(\d+)[−\-\s](\d+)[−\-\s](\d+)',  # 908-1-2
            r'(\d+)[−\-\s]*(\d+)[−\-\s]*(\d*)',  # More flexible
        ]
        
        for pattern in banchi_patterns:
            banchi_match = re.search(pattern, address)
            if banchi_match:
                groups = banchi_match.groups()
                # Format as XXX番地XのX
                if groups[2]:  # Third group exists
                    result['banchi'] = f"{groups[0]}番地{groups[1]}の{groups[2]}"
                else:
                    result['banchi'] = f"{groups[0]}番地{groups[1]}"
                logger.info(f"OCR - Parsed banchi: {result['banchi']}")
                break
        
        # Extract building name (if any) - usually after numbers
        # Look for patterns like "メゾン徳川101号室"
        building_patterns = [
            r'(\d+[−\-\s]*\d+[−\-\s]*\d*\s*)([^0-9]+号室[^0-9]*)',  # Building with room number
            r'(\d+[−\-\s]*\d+[−\-\s]*\d*\s*)([^0-9]+)',  # Building name after numbers
        ]
        
        for pattern in building_patterns:
            building_match = re.search(pattern, address)
            if building_match:
                building_parts = building_match.groups()
                if len(building_parts) > 1:
                    building_name = building_parts[1].strip()
                    if building_name != "番地":
                        result['building'] = building_name
                        logger.info(f"OCR - Parsed building: {result['building']}")
                        break
        
        return result

    def _extract_photo_from_document(self, image_data: bytes, document_type: str) -> Optional[str]:
        """Extract photo from document image"""
        try:
            # Import required libraries
            import base64
            from io import BytesIO
            from PIL import Image
            import numpy as np
            try:  # OpenCV is optional for face detection
                import cv2  # type: ignore
            except ImportError:  # pragma: no cover - optional dependency at runtime
                cv2 = None  # type: ignore

            # Convert bytes to PIL Image
            image = Image.open(BytesIO(image_data)).convert("RGB")

            # Convert to numpy array for processing
            img_array = np.array(image)
            if img_array.ndim == 2:  # grayscale to RGB
                img_array = np.stack([img_array] * 3, axis=-1)

            height, width = img_array.shape[:2]

            # Prepare face detector
            face_region = None
            try:
                if cv2 is not None:
                    cascade_path = Path(cv2.data.haarcascades) / "haarcascade_frontalface_default.xml"
                    face_cascade = cv2.CascadeClassifier(str(cascade_path)) if cascade_path.exists() else None
                    if face_cascade is not None and not face_cascade.empty():
                        gray = cv2.cvtColor(img_array, cv2.COLOR_RGB2GRAY)
                        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(80, 80))
                        if len(faces) > 0:
                            # Pick the largest detected face
                            x, y, w, h = max(faces, key=lambda rect: rect[2] * rect[3])
                            margin_x = int(w * 0.25)
                            margin_y = int(h * 0.25)
                            x1 = max(0, x - margin_x)
                            y1 = max(0, y - margin_y)
                            x2 = min(width, x + w + margin_x)
                            y2 = min(height, y + h + margin_y)
                            if x2 > x1 and y2 > y1:
                                face_region = img_array[y1:y2, x1:x2]
                                logger.info(
                                    "OCR - Face detected for %s (x1=%s, y1=%s, x2=%s, y2=%s)",
                                    document_type, x1, y1, x2, y2,
                                )
            except Exception as face_error:  # pragma: no cover - best effort logging
                logger.warning(
                    "OCR - Face detection failed, using heuristic crop: %s",
                    face_error,
                    exc_info=True,
                )

            if face_region is None:
                # Heuristic fallback by document type
                if document_type == "zairyu_card":
                    y1 = int(height * 0.22)
                    y2 = int(height * 0.80)
                    x1 = int(width * 0.62)
                    x2 = int(width * 0.93)
                    face_region = img_array[max(0, y1):min(height, y2), max(0, x1):min(width, x2)]
                    logger.info("OCR - Fallback zairyu photo crop applied")
                elif document_type == "license":
                    y1 = int(height * 0.20)
                    y2 = int(height * 0.78)
                    x1 = int(width * 0.05)
                    x2 = int(width * 0.35)
                    face_region = img_array[max(0, y1):min(height, y2), max(0, x1):min(width, x2)]
                    logger.info("OCR - Fallback license photo crop applied")
                else:
                    face_region = img_array
                    logger.info("OCR - Returning full image for %s", document_type)

            if face_region.size == 0:
                face_region = img_array

            # Convert back to PIL Image
            photo_image = Image.fromarray(face_region)

            # Convert to base64
            buffered = BytesIO()
            photo_image.save(buffered, format="JPEG", quality=90)
            base64_image = base64.b64encode(buffered.getvalue()).decode('utf-8')

            photo_data_uri = f"data:image/jpeg;base64,{base64_image}"
            return photo_data_uri

        except ImportError:
            # If PIL is not available, return full image
            import base64
            from io import BytesIO
            base64_image = base64.b64encode(image_data).decode('utf-8')
            photo_data_uri = f"data:image/jpeg;base64,{base64_image}"
            logger.warning(f"OCR - PIL not available, returning full image from {document_type}")
            return photo_data_uri
            
        except Exception as e:
            logger.error(f"Error extracting photo: {e}")
            # Fallback: return full image
            import base64
            from io import BytesIO
            base64_image = base64.b64encode(image_data).decode('utf-8')
            photo_data_uri = f"data:image/jpeg;base64,{base64_image}"
            return photo_data_uri


# Create singleton instance
azure_ocr_service = AzureOCRService()

__all__ = ["AzureOCRService", "azure_ocr_service"]