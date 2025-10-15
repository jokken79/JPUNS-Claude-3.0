"""Utility helpers for handling nationality detection in OCR flows."""
from __future__ import annotations

from typing import Dict


NATIONALITY_MAPPING: Dict[str, str] = {
    "VIETNAM": "ベトナム",
    "VIET NAM": "ベトナム",
    "VIETNAN": "ベトナム",
    "PHILIPPINES": "フィリピン",
    "CHINA": "中国",
    "KOREA": "韓国",
    "BRAZIL": "ブラジル",
    "PERU": "ペルー",
    "INDONESIA": "インドネシア",
    "THAILAND": "タイ",
    "MYANMAR": "ミャンマー",
    "CAMBODIA": "カンボジア",
    "NEPAL": "ネパール",
    "MONGOLIA": "モンゴル",
    "BANGLADESH": "バングラデシュ",
    "SRI LANKA": "スリランカ",
}


def normalize_nationality(raw_value: str) -> str:
    """Return the Japanese label for a detected nationality string."""
    if not raw_value:
        return raw_value

    normalized_key = raw_value.upper()
    if normalized_key in NATIONALITY_MAPPING:
        return NATIONALITY_MAPPING[normalized_key]

    for key, value in NATIONALITY_MAPPING.items():
        if key.lower() in raw_value.lower() or raw_value.lower() in key.lower():
            return value

    return raw_value


__all__ = ["normalize_nationality", "NATIONALITY_MAPPING"]
