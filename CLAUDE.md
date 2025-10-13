# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

UNS-ClaudeJP 3.0 is a comprehensive HR management system for Japanese companies, built with:
- **Backend**: FastAPI (Python 3.11) with SQLAlchemy ORM and PostgreSQL
- **Frontend**: React 18 with TypeScript and Tailwind CSS
- **DevOps**: Docker Compose for orchestration

The system manages candidates (履歴書/Rirekisho), employees, factories, attendance (タイムカード), payroll, requests (申請), and includes OCR processing for document handling.

## Quick Start Guide

```bash
# First time installation (includes Docker Desktop setup)
INSTALAR.bat

# Start all services (DB, Backend, Frontend)
START.bat
# Wait for the progress bar to complete and browser to open

# Stop all services when done
STOP.bat

# Check status and logs
LOGS.bat
# Select the service you want to monitor (backend, frontend, db)
```

Default credentials: admin/admin123

## Development Commands

### Backend Development

```bash
# Access backend container
docker exec -it uns-claudejp-backend bash

# Run database migrations (inside container)
cd /app
alembic upgrade head

# Create new migration
alembic revision --autogenerate -m "description"

# Run tests
pytest

# Run a single test
pytest tests/test_module.py::test_function -v

# Fix admin password
docker exec -it uns-claudejp-backend python fix_admin_password.py

# Install a new dependency
pip install package-name
# Then add it to requirements.txt
```

### Frontend Development

```bash
# Access frontend container
docker exec -it uns-claudejp-frontend bash

# Install new dependency (inside container)
npm install <package-name>

# Run tests
npm test

# Run a specific test
npm test -- -t "test name pattern"

# Build for production
npm run build

# Check TypeScript types
npm run typecheck
```

### Database Management

```bash
# Import database from SQL file
IMPORTAR-BD-ORIGINAL.bat

# Create database backup
BACKUP-BD.bat

# Access PostgreSQL directly
docker exec -it uns-claudejp-db psql -U uns_admin -d uns_claudejp

# Reset database (WARNING: destroys all data)
REINSTALAR.bat

# Run database verification
docker exec -it uns-claudejp-backend python scripts/verify_data.py
```

## System Architecture

### Backend Structure

```
backend/
├── app/
│   ├── main.py                 # Entry point, FastAPI config
│   ├── api/                    # REST API endpoints
│   │   ├── auth.py            # Authentication
│   │   ├── candidates.py      # Candidate management
│   │   ├── employees.py       # Employee management
│   │   ├── factories.py       # Client factories
│   │   ├── timer_cards.py     # Attendance
│   │   ├── salary.py          # Payroll
│   │   ├── requests.py        # Employee requests
│   │   ├── azure_ocr.py       # OCR processing
│   │   └── [other endpoints]
│   ├── models/
│   │   └── models.py          # SQLAlchemy models
│   ├── schemas/               # Pydantic schemas
│   ├── services/              # Business logic
│   │   ├── auth_service.py
│   │   ├── azure_ocr_service.py
│   │   ├── import_service.py
│   │   └── [other services]
│   ├── core/                  # Configuration
│   │   ├── config.py         # Settings
│   │   ├── database.py       # DB connection
│   │   └── middleware.py     # Custom middleware
│   └── utils/                # Utilities
├── scripts/                  # Maintenance scripts
└── tests/                    # pytest tests
```

### Frontend Structure

```
frontend/
├── src/
│   ├── App.tsx               # Router setup
│   ├── pages/                # Main pages
│   │   ├── Login.tsx
│   │   ├── Dashboard.tsx
│   │   ├── Candidates.tsx
│   │   ├── Employees.tsx
│   │   ├── Factories.tsx
│   │   └── [other pages]
│   ├── components/           # Reusable components
│   │   ├── Layout.tsx       # Main layout
│   │   ├── ProtectedRoute.tsx
│   │   └── [other components]
│   ├── services/             # API client
│   ├── context/              # React Context
│   ├── hooks/                # Custom hooks
│   └── __tests__/            # Frontend tests
└── public/
```

### Database Schema Key Points

- `users` - System users with role-based permissions
- `candidates` - Candidate records with approval workflow
- `employees` - Active employees (can be converted from candidates)
- `factories` - Client companies where employees are assigned
- `apartments` - Housing management for employees
- `timer_cards` - Attendance tracking (入退勤)
- `payrolls` - Salary calculations and payment records
- `requests` - Employee requests (vacation, leave, resignation)

### Authentication Flow

- JWT-based authentication with role hierarchy (SUPER_ADMIN → ADMIN → COORDINATOR → USER)
- Tokens stored in localStorage
- Protected routes via React Router
- Backend validates JWT on each request via middleware

### State Management (Frontend)

- **Zustand**: Used for global state (user auth, app settings)
  - Store defined in `src/store/`
  - Simple but powerful state management

- **React Query**: Used for server state management
  - API queries and mutations with caching
  - Defined in respective page components
  - Auto-refetching and optimistic updates

- **Context API**: Used for specific cross-cutting concerns
  - `PageVisibilityContext` for tracking active views

## Key Technical Details

### Environment Variables

Key variables in `.env` or `docker-compose.yml`:

**Required variables:**
- `POSTGRES_*` - Database credentials (user, password, db, host, port)
- `SECRET_KEY` - JWT signing key
- `FRONTEND_URL` - For CORS configuration

**Optional variables:**
- `AZURE_COMPUTER_VISION_*` - OCR service credentials (falls back to Tesseract)
- `SMTP_*` - Email service configuration
- `LINE_NOTIFY_TOKEN` - For LINE notifications
- `DEBUG` - Enable debug mode (default: false)
- `LOG_LEVEL` - Logging level (default: INFO)

See `.env.example` for a complete list of 90+ available configuration options.

### OCR Integration

- Two OCR services: Azure Computer Vision (primary) and Tesseract (fallback)
- Processes Rirekisho (Japanese resume) images
- API key configured via environment variables
- Service layer: `app/services/azure_ocr_service.py`
- OCR workflow:
  1. Image upload via API
  2. Processing by OCR service
  3. Data extraction and normalization
  4. Candidate record creation/update

### Date Handling

- Backend uses `datetime` with timezone awareness (pytz)
- Frontend uses `date-fns` for date formatting
- Japanese calendar considerations for fiscal year calculations
- Important date formats:
  - Database: ISO-8601 with timezone
  - API: ISO-8601
  - UI: Localized JP format (YYYY年MM月DD日)

### File Processing

- Candidate documents: OCR processing pipeline (upload → Azure/Tesseract → data extraction)
- Excel/CSV import: `app/services/import_service.py` with pandas
- PDF generation: reportlab for payroll reports
- Supported formats:
  - Images: JPG, PNG (for OCR)
  - Documents: PDF, XLSX, CSV
  - Reports: PDF

### API Documentation

- Swagger UI available at http://localhost:8000/api/docs
- All endpoints documented with FastAPI automatic docs
- Authentication required for most endpoints (Bearer token)

## Common Development Workflows

### Adding a New API Endpoint

1. Define Pydantic schema in `app/schemas/`
```python
# Example: app/schemas/new_entity.py
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class NewEntityBase(BaseModel):
    name: str
    description: Optional[str] = None

class NewEntityCreate(NewEntityBase):
    pass

class NewEntityResponse(NewEntityBase):
    id: int
    created_at: datetime

    class Config:
        orm_mode = True
```

2. Create endpoint in appropriate `app/api/*.py` file
```python
# Example: app/api/new_entity.py
from fastapi import APIRouter, Depends, HTTPException
from app.schemas.new_entity import NewEntityCreate, NewEntityResponse
from app.models.models import NewEntity
from app.core.database import get_db
from sqlalchemy.orm import Session
from typing import List

router = APIRouter(prefix="/new-entities", tags=["new-entities"])

@router.post("/", response_model=NewEntityResponse)
def create_new_entity(
    entity: NewEntityCreate,
    db: Session = Depends(get_db)
):
    db_entity = NewEntity(**entity.dict())
    db.add(db_entity)
    db.commit()
    db.refresh(db_entity)
    return db_entity

@router.get("/", response_model=List[NewEntityResponse])
def get_all_new_entities(db: Session = Depends(get_db)):
    return db.query(NewEntity).all()

# Add the router to main.py
# from app.api import new_entity
# app.include_router(new_entity.router)
```

3. Implement business logic in `app/services/` if complex
4. Update frontend service in `src/services/api.ts`
5. Create/update React component to consume endpoint

### Adding a New Database Table

1. Add SQLAlchemy model to `app/models/models.py`
```python
# Example: new model in app/models/models.py
class NewEntity(Base):
    __tablename__ = "new_entities"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.now)

    # Relationships if needed
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("User", back_populates="new_entities")
```

2. Create migration: `alembic revision --autogenerate -m "add_new_entity"`
3. Review and edit migration file in `backend/alembic/versions/`
4. Apply migration: `alembic upgrade head`
5. Create corresponding Pydantic schemas (see example above)

### Debugging Issues

- Check logs: `LOGS.bat` (options for backend/frontend/database)
- Login issues: Run `fix-login-correcto.bat` to reset admin password
- Database issues: Check `base-datos/` for migration scripts
- Port conflicts: Verify ports 3000, 8000, 5432 are free
- Container issues: Check Docker with `docker ps` and `docker logs`

Common errors and solutions:

1. **Login fails**: Reset admin password with `fix-login-correcto.bat`
2. **Database errors**: Check PostgreSQL service is running, verify connection details
3. **Frontend connection issues**: Ensure backend is running and CORS is properly configured
4. **OCR failures**: Check Azure credentials or fall back to Tesseract

## Testing

### Backend Tests

- Located in `backend/tests/`
- Run with `pytest` inside backend container
- Use `pytest-asyncio` for async endpoint testing
- To debug tests: `pytest -vs` for verbose output

Example test:
```python
# Example test for candidate API
async def test_create_candidate(client, test_db):
    # Create test data
    candidate_data = {
        "name": "Test Candidate",
        "email": "test@example.com",
        # Other required fields
    }

    # Get auth token
    auth_response = await client.post("/api/auth/login", json={
        "username": "admin",
        "password": "admin123"
    })
    token = auth_response.json()["access_token"]

    # Test API call
    response = await client.post(
        "/api/candidates",
        json=candidate_data,
        headers={"Authorization": f"Bearer {token}"}
    )

    assert response.status_code == 201
    result = response.json()
    assert result["name"] == candidate_data["name"]
    assert "id" in result
```

### Frontend Tests

- Located in `frontend/src/__tests__/`
- Run with `npm test`
- Coverage report: `npm run test:coverage`

Example test:
```typescript
// Example test for Login component
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { Login } from '../pages/Login';

test('login form submits correctly', async () => {
  render(<Login />);

  // Find form elements
  const usernameInput = screen.getByLabelText(/username/i);
  const passwordInput = screen.getByLabelText(/password/i);
  const submitButton = screen.getByRole('button', { name: /login/i });

  // Fill form
  fireEvent.change(usernameInput, { target: { value: 'admin' } });
  fireEvent.change(passwordInput, { target: { value: 'admin123' } });

  // Submit form
  fireEvent.click(submitButton);

  // Check loading state
  await waitFor(() => {
    expect(screen.getByText(/logging in/i)).toBeInTheDocument();
  });

  // Mocked success would be tested here
});
```

## Important Notes

- **LIXO folder**: Contains obsolete files, can be ignored completely
- **JpStart folder**: Legacy scripts, use the main .bat files in root instead
- **Default credentials**: admin/admin123 (change in production!)
- **Docker required**: All services run in containers
- **Port requirements**: 3000 (frontend), 8000 (backend), 5432 (database)
- **Japanese terms**: The codebase uses Japanese HR terminology (履歴書, タイムカード, 申請, etc.)
- **Data separation**: Demo data by default; use import scripts for real data

## URLs

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | Main UI |
| Backend API | http://localhost:8000 | REST API |
| API Docs | http://localhost:8000/api/docs | Swagger documentation |
| Database | localhost:5432 | PostgreSQL (internal) |