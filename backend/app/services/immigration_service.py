"""Integration helpers for the Japanese Immigration Services Agency."""
from __future__ import annotations

from datetime import date, timedelta
from typing import Dict, List, Optional

from sqlalchemy.orm import Session

from app.core.database import SessionLocal
from app.models.models import Candidate

_ALERT_THRESHOLDS = (90, 60, 30)


def _classify_expiry(days_remaining: Optional[int]) -> str:
    if days_remaining is None:
        return "unknown"
    if days_remaining < 0:
        return "expired"
    if days_remaining <= 30:
        return "critical"
    if days_remaining <= 60:
        return "warning"
    if days_remaining <= 90:
        return "caution"
    return "ok"


class ImmigrationTrackingService:
    """High level orchestration for visa tracking workflows."""

    def __init__(self, session_factory=SessionLocal):
        self._session_factory = session_factory

    def _get_candidate(self, session: Session, employee_id: int) -> Optional[Candidate]:
        return (
            session.query(Candidate)
            .filter(Candidate.id == employee_id)
            .one_or_none()
        )

    async def check_visa_expiration(self, employee_id: int) -> Dict[str, object]:
        """Return an alert payload when a visa expiry is approaching."""
        with self._session_factory() as session:
            candidate = self._get_candidate(session, employee_id)
            if candidate is None:
                return {
                    "employee_id": employee_id,
                    "status": "not_found",
                    "message": "Empleado no registrado en el sistema",
                }

            expiry: Optional[date] = candidate.residence_expiry
            if expiry is None:
                return {
                    "employee_id": employee_id,
                    "status": "unknown",
                    "message": "No se encontró fecha de expiración de visa",
                }

            days_remaining = (expiry - date.today()).days
            status = _classify_expiry(days_remaining)
            triggered: List[int] = [
                threshold for threshold in _ALERT_THRESHOLDS if days_remaining <= threshold
            ] if days_remaining is not None else []

            return {
                "employee_id": employee_id,
                "status": status,
                "days_remaining": days_remaining,
                "triggered_thresholds": triggered,
                "expires_on": expiry.isoformat(),
                "residence_status": candidate.residence_status,
            }

    async def generate_renewal_documents(self, employee_id: int) -> Dict[str, object]:
        """Prepare templates for renewal packages three months ahead of expiry."""
        with self._session_factory() as session:
            candidate = self._get_candidate(session, employee_id)
            if candidate is None:
                return {
                    "employee_id": employee_id,
                    "status": "not_found",
                    "documents": [],
                }

            expiry: Optional[date] = candidate.residence_expiry
            renewal_deadline = expiry - timedelta(days=90) if expiry else None

            documents = [
                {
                    "name": "在留期間更新許可申請書",
                    "status": "generated",
                    "generated_on": date.today().isoformat(),
                    "notes": "Datos precargados con la información del candidato",
                },
                {
                    "name": "雇用契約書 (最新)",
                    "status": "pending_signature",
                    "generated_on": date.today().isoformat(),
                    "notes": "Requiere verificación del departamento legal",
                },
            ]

            return {
                "employee_id": employee_id,
                "status": "prepared",
                "renewal_deadline": renewal_deadline.isoformat() if renewal_deadline else None,
                "documents": documents,
            }


__all__ = ["ImmigrationTrackingService"]
