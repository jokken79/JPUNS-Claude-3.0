"""Photo extraction utilities used by OCR services."""
from __future__ import annotations

import base64
import logging
from io import BytesIO
from pathlib import Path
from typing import Optional

from PIL import Image
import numpy as np

logger = logging.getLogger(__name__)

try:  # pragma: no cover - optional dependency
    import cv2  # type: ignore
except ImportError:  # pragma: no cover - optional dependency
    cv2 = None  # type: ignore


def _crop_region(img_array: np.ndarray, coordinates: tuple[int, int, int, int]) -> np.ndarray:
    x1, y1, x2, y2 = coordinates
    height, width = img_array.shape[:2]
    return img_array[max(0, y1):min(height, y2), max(0, x1):min(width, x2)]


def _fallback_crop(img_array: np.ndarray, document_type: str) -> np.ndarray:
    height, width = img_array.shape[:2]
    if document_type == "zairyu_card":
        return _crop_region(img_array, (
            int(width * 0.62),
            int(height * 0.22),
            int(width * 0.93),
            int(height * 0.80),
        ))
    if document_type == "license":
        return _crop_region(img_array, (
            int(width * 0.05),
            int(height * 0.20),
            int(width * 0.35),
            int(height * 0.78),
        ))
    return img_array


def extract_document_photo(image_data: bytes, document_type: str) -> Optional[str]:
    """Extract a face photo encoded as data URI from the provided document."""
    try:
        image = Image.open(BytesIO(image_data)).convert("RGB")
    except Exception:  # pragma: no cover - validated through integration tests
        logger.exception("Failed to load image bytes for %s", document_type)
        return None

    img_array = np.array(image)
    if img_array.ndim == 2:
        img_array = np.stack([img_array] * 3, axis=-1)

    face_region = None
    if cv2 is not None:
        try:
            cascade_path = Path(cv2.data.haarcascades) / "haarcascade_frontalface_default.xml"
            face_cascade = cv2.CascadeClassifier(str(cascade_path)) if cascade_path.exists() else None
            if face_cascade is not None and not face_cascade.empty():
                gray = cv2.cvtColor(img_array, cv2.COLOR_RGB2GRAY)
                faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(80, 80))
                if len(faces) > 0:
                    x, y, w, h = max(faces, key=lambda rect: rect[2] * rect[3])
                    margin_x = int(w * 0.25)
                    margin_y = int(h * 0.25)
                    face_region = _crop_region(
                        img_array,
                        (
                            x - margin_x,
                            y - margin_y,
                            x + w + margin_x,
                            y + h + margin_y,
                        ),
                    )
        except Exception:  # pragma: no cover - best effort logging
            logger.exception("Face detection failed for %s", document_type)

    if face_region is None:
        face_region = _fallback_crop(img_array, document_type)

    if face_region.size == 0:
        face_region = img_array

    photo_image = Image.fromarray(face_region)
    buffer = BytesIO()
    photo_image.save(buffer, format="JPEG", quality=90)
    base64_image = base64.b64encode(buffer.getvalue()).decode("utf-8")
    return f"data:image/jpeg;base64,{base64_image}"


__all__ = ["extract_document_photo"]
