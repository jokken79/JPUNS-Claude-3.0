"""Utilities for splitting Japanese addresses into structured components."""
from __future__ import annotations

import re
from typing import Dict


_PREFECTURES = [
    '北海道', '青森県', '岩手県', '宮城県', '秋田県', '山形県', '福島県',
    '茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県',
    '新潟県', '富山県', '石川県', '福井県', '山梨県', '長野県', '岐阜県',
    '静岡県', '愛知県', '三重県', '滋賀県', '京都府', '大阪府', '兵庫県',
    '奈良県', '和歌山県', '鳥取県', '島根県', '岡山県', '広島県', '山口県',
    '徳島県', '香川県', '愛媛県', '高知県', '福岡県', '佐賀県', '長崎県',
    '熊本県', '大分県', '宮崎県', '鹿児島県', '沖縄県',
]


def parse_japanese_address(address: str) -> Dict[str, str]:
    """Split a raw postal address into semantic parts."""
    result = {
        'postal_code': '',
        'prefecture': '',
        'city': '',
        'ward': '',
        'district': '',
        'banchi': '',
        'building': '',
    }

    if not address:
        return result

    postal_match = re.search(r'(\d{3}-\d{4})', address)
    if postal_match:
        result['postal_code'] = postal_match.group(1)

    remaining = address
    for prefecture in _PREFECTURES:
        if prefecture in remaining:
            result['prefecture'] = prefecture
            remaining = remaining.replace(prefecture, '', 1)
            break

    city_ward_pattern = r'([^0-9]+[市区町村])([^0-9]+[区郡]?[^0-9]*)([^0-9]+)?'
    match = re.search(city_ward_pattern, remaining)
    if match:
        result['city'] = match.group(1)
        result['ward'] = match.group(2) or ''
        result['district'] = match.group(3) or ''

    banchi_patterns = [
        r'(\d+)番地(\d+)の(\d+)',
        r'(\d+)[−\-\s](\d+)[−\-\s](\d+)',
        r'(\d+)[−\-\s]*(\d+)[−\-\s]*(\d*)',
    ]

    for pattern in banchi_patterns:
        banchi_match = re.search(pattern, remaining)
        if banchi_match:
            groups = banchi_match.groups()
            if len(groups) == 3 and groups[2]:
                result['banchi'] = f"{groups[0]}番地{groups[1]}の{groups[2]}"
            else:
                result['banchi'] = f"{groups[0]}番地{groups[1]}"
            break

    building_patterns = [
        r'(\d+[−\-\s]*\d+[−\-\s]*\d*\s*)([^0-9]+号室[^0-9]*)',
        r'(\d+[−\-\s]*\d+[−\-\s]*\d*\s*)([^0-9]+)',
    ]

    for pattern in building_patterns:
        building_match = re.search(pattern, remaining)
        if building_match and len(building_match.groups()) > 1:
            building_candidate = building_match.groups()[1].strip()
            if building_candidate != '番地':
                result['building'] = building_candidate
                break

    return result


__all__ = ["parse_japanese_address"]
