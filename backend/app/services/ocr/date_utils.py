"""Utilities for extracting date information from OCR results."""
from __future__ import annotations

import re
from typing import Dict, Iterable, List


DATE_PATTERNS = [
    r"(\d{4})[年/\-.](\d{1,2})[月/\-.](\d{1,2})日?",
    r"(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2})",
]


def _iter_lines(lines: Iterable[str]) -> List[str]:
    """Normalise incoming lines into a clean list of stripped strings."""
    return [line.strip() for line in lines if line and line.strip()]


def extract_primary_dates(lines: Iterable[str]) -> Dict[str, str]:
    """Return key date fields detected inside the provided OCR lines.

    Parameters
    ----------
    lines:
        Iterable with each textual line extracted from a document.

    Returns
    -------
    Dict[str, str]
        Potentially contains ``birthday`` and ``zairyu_expire_date`` fields
        formatted as ``YYYY-MM-DD`` strings.
    """
    cleaned_lines = _iter_lines(lines)
    all_dates: List[str] = []

    for line in cleaned_lines:
        for pattern in DATE_PATTERNS:
            for match in re.finditer(pattern, line):
                try:
                    year, month, day = [int(group) for group in match.groups()]
                except (TypeError, ValueError):
                    continue
                if 1 <= month <= 12 and 1 <= day <= 31:
                    all_dates.append(f"{year}-{month:02d}-{day:02d}")

    result: Dict[str, str] = {}
    if all_dates:
        result["birthday"] = all_dates[0]
        if len(all_dates) > 1:
            result["zairyu_expire_date"] = all_dates[-1]

    return result


__all__ = ["extract_primary_dates"]
