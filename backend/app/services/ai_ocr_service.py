"""Augmented OCR flows for Japanese HR documentation."""
from __future__ import annotations

import asyncio
import re
from typing import Awaitable, Callable, Iterable, List, Optional

from app.services.ocr import extract_primary_dates

TextExtractor = Callable[[bytes, str], Awaitable[str] | str]


def _ensure_awaitable(result: Awaitable[str] | str) -> Awaitable[str]:
    if asyncio.iscoroutine(result) or isinstance(result, asyncio.Future):
        return result  # type: ignore[return-value]

    async def _wrapper() -> str:
        return result  # type: ignore[misc]

    return _wrapper()


class EnhancedOCRService:
    """Provides high level routines that enrich the base Azure OCR service."""

    def __init__(self, text_extractor: Optional[TextExtractor] = None) -> None:
        self._text_extractor = text_extractor

    async def _obtain_text(self, payload: bytes, document_type: str) -> str:
        if self._text_extractor is not None:
            text = await _ensure_awaitable(self._text_extractor(payload, document_type))
            return text

        # Fallback best-effort decoding for pre-parsed fixtures (tests, offline mode)
        try:
            return payload.decode("utf-8")
        except UnicodeDecodeError as exc:  # pragma: no cover - requires binary payload
            raise RuntimeError(
                "No hay extractor OCR configurado y no se pudo decodificar el documento"
            ) from exc

    @staticmethod
    def _clean_lines(text: str) -> List[str]:
        return [line.strip() for line in text.splitlines() if line.strip()]

    async def process_zairyu_card(self, image: bytes) -> dict:
        """Procesa在留カード y extrae: visa type, expiration, work restrictions"""
        text = await self._obtain_text(image, "zairyu_card")
        lines = self._clean_lines(text)
        data = extract_primary_dates(lines)

        visa_type = self._search_by_keywords(lines, ["在留資格", "STATUS OF RESIDENCE"])
        work_restrictions = self._search_by_keywords(
            lines,
            ["就労制限", "WORK RESTRICTIONS", "就労資格外活動"],
        )
        if work_restrictions and "なし" in work_restrictions:
            work_restrictions = "制限なし"

        expiry = data.get("zairyu_expire_date") or self._search_date(
            lines,
            ["有効期限", "在留期間満了日"],
        )

        return {
            "success": True,
            "raw_text": text,
            "visa_type": visa_type,
            "expiration": expiry,
            "work_restrictions": work_restrictions,
        }

    async def validate_rirekisho(self, pdf: bytes) -> dict:
        """Valida履歴書 y extrae educación, experiencia relevante"""
        text = await self._obtain_text(pdf, "rirekisho")
        lines = self._clean_lines(text)

        education = [
            line
            for line in lines
            if any(keyword in line for keyword in ["大学", "高校", "専門学校", "学科"])
        ]
        experience = [
            line
            for line in lines
            if any(keyword in line for keyword in ["株式会社", "有限会社", "勤務", "経験"])
        ]

        return {
            "success": bool(education and experience),
            "raw_text": text,
            "education": education,
            "experience": experience,
        }

    @staticmethod
    def _search_by_keywords(lines: Iterable[str], keywords: List[str]) -> Optional[str]:
        for line in lines:
            for keyword in keywords:
                if keyword.lower() in line.lower():
                    cleaned = re.sub(r"^.*?[：:]\s*", "", line)
                    return cleaned or line
        return None

    @staticmethod
    def _search_date(lines: Iterable[str], keywords: List[str]) -> Optional[str]:
        pattern = re.compile(r"(\d{4})[年/\-.](\d{1,2})[月/\-.](\d{1,2})")
        for line in lines:
            if any(keyword.lower() in line.lower() for keyword in keywords):
                match = pattern.search(line)
                if match:
                    year, month, day = match.groups()
                    return f"{int(year):04d}-{int(month):02d}-{int(day):02d}"
        return None


__all__ = ["EnhancedOCRService"]
