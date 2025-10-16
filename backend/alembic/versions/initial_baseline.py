"""initial_baseline

Revision ID: initial_baseline
Revises:
Create Date: 2025-10-16

Esta es una migración baseline que marca el estado actual de la base de datos
sin aplicar ningún cambio. Se usa para bases de datos que ya existen.
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'initial_baseline'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # No hacemos cambios, solo marcamos el estado actual
    pass


def downgrade() -> None:
    # No hay nada que revertir
    pass
