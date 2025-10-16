# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

UNS-ClaudeJP 3.0 is a comprehensive HR management system for Japanese staffing agencies (人材派遣会社), built with:
- **Backend**: FastAPI (Python 3.11+) with SQLAlchemy ORM and PostgreSQL 15
- **Frontend**: React 18 with TypeScript, Vite, and Tailwind CSS
- **DevOps**: Docker Compose for orchestration

The system manages the complete lifecycle of temporary workers: candidates (履歴書/Rirekisho), employees (派遣社員), contract workers (請負), staff (スタッフ), factories (派遣先), apartments (社宅), attendance (タイムカード), payroll (給与), and requests (申請). It includes hybrid OCR processing (Azure + Tesseract) for Japanese document handling.

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

# Run tests (using Vitest)
npm test

# Run tests with coverage
npm run coverage

# Build for production
npm run build

# Preview production build
npm run preview

# Development server (already running in container)
npm run dev
```

### Database Management

```bash
# Access PostgreSQL directly
docker exec -it uns-claudejp-db psql -U uns_admin -d uns_claudejp

# Reset database (WARNING: destroys all data)
REINSTALAR.bat

# Run database verification
docker exec -it uns-claudejp-backend python scripts/verify_data.py

# Fix admin password if login fails
docker exec -it uns-claudejp-backend python fix_admin_password.py

# View Adminer web interface
# Navigate to http://localhost:8080
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

The database uses a comprehensive schema designed for Japanese staffing agencies:

**Core Personnel Tables:**
- `users` - System users with role hierarchy (SUPER_ADMIN → ADMIN → COORDINATOR → KANRININSHA → EMPLOYEE → CONTRACT_WORKER)
- `candidates` - Candidate records (履歴書/Rirekisho) with 100+ fields for comprehensive Japanese resume data, approval workflow, OCR data storage
- `employees` - Dispatch workers (派遣社員) converted from approved candidates, linked via `rirekisho_id`
- `contract_workers` - Contract workers (請負社員/Ukeoi) with similar structure to employees
- `staff` - Office/HR personnel (スタッフ/管理人者) with fixed monthly salary instead of hourly

**Business Tables:**
- `factories` - Client companies (派遣先) where workers are assigned, stores JSON config for factory-specific settings
- `apartments` - Employee housing (社宅) with rent and capacity tracking
- `documents` - File storage for uploaded documents (photos, residence cards, contracts) with OCR data

**Operations Tables:**
- `timer_cards` - Attendance records (タイムカード) with shift types (朝番/昼番/夜番), overtime, night, and holiday hours
- `salary_calculations` - Monthly payroll with detailed breakdowns of base, overtime, night, holiday pay, deductions, and company profit
- `requests` - Employee requests (申請) for vacation (有給), half-day leave (半休), temporary return home (一時帰国), resignation (退社)
- `contracts` - Employment contracts with PDF storage and digital signatures
- `audit_log` - Complete audit trail of all system changes

**Key Relationships:**
- Candidates → Employees via `rirekisho_id` (履歴書ID)
- Employees → Factories via `factory_id`
- Employees → Apartments via `apartment_id`
- All personnel tables link back to Candidates for historical tracking

### Authentication & Authorization

- **JWT-based authentication** with bcrypt password hashing
- **Role hierarchy**: SUPER_ADMIN → ADMIN → COORDINATOR → KANRININSHA → EMPLOYEE → CONTRACT_WORKER
- Access tokens stored in localStorage (frontend)
- Protected routes via `ProtectedRoute` component
- Backend validates JWT on each request via custom middleware
- Page visibility controlled by `VisibilityGuard` component with `PageVisibilityContext`
- Login endpoint: `POST /api/auth/login`
- Default credentials: `admin` / `admin123`

### State Management (Frontend)

- **Zustand**: Global state management for user authentication and settings
  - Lightweight alternative to Redux
  - Store typically in `src/store/` (check for auth store)

- **React Query (@tanstack/react-query)**: Server state management
  - API queries and mutations with intelligent caching
  - Auto-refetching and background updates
  - Used in page components for data fetching

- **Context API**: Cross-cutting concerns
  - `PageVisibilityContext` - Controls which pages are visible to which roles
  - `ThemeContext` - Manages theme switching (5 themes available, designed by Gemini)

- **React Router v6**: Client-side routing with nested protected routes

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

The system uses a **hybrid OCR approach** for processing Japanese documents:

- **Azure Computer Vision** (primary) - Best for Japanese text recognition
- **Tesseract OCR** (fallback) - Open-source alternative when Azure is unavailable
- Service layer: `backend/app/services/azure_ocr_service.py`
- API endpoint: `POST /api/azure-ocr/process`

**OCR Workflow:**
1. User uploads Rirekisho (履歴書) image via `OCRUploader` component
2. Image sent to backend `/api/azure-ocr/process` endpoint
3. Azure Computer Vision API processes Japanese text (or Tesseract if Azure unavailable)
4. Extracted data normalized and validated
5. Candidate record auto-created/updated with OCR data
6. OCR results stored in `documents.ocr_data` JSON field for audit

**Supported Documents:**
- 履歴書 (Rirekisho/Resume) - Full Japanese CV with 100+ fields
- 在留カード (Zairyu Card/Residence Card) - Foreign worker permit
- 運転免許証 (Driver's License)

**Configuration:**
- Set `AZURE_COMPUTER_VISION_ENDPOINT` and `AZURE_COMPUTER_VISION_KEY` in environment
- Falls back to Tesseract if Azure credentials not provided
- OCR can be disabled with `OCR_ENABLED=false`

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

**Logs and Monitoring:**
- Check logs: `LOGS.bat` (options: all services, backend only, frontend only, database only)
- View real-time logs: `docker logs -f uns-claudejp-backend` (or -frontend, -db)
- API documentation: http://localhost:8000/api/docs (Swagger UI with live testing)
- Database admin: http://localhost:8080 (Adminer)

**Common Issues:**

1. **Login fails**:
   - Reset admin password: `docker exec -it uns-claudejp-backend python fix_admin_password.py`
   - Default credentials: `admin` / `admin123`
   - Check JWT secret key is set in environment

2. **Database errors**:
   - Verify PostgreSQL is running: `docker ps | findstr uns-claudejp-db`
   - Check connection: `docker exec -it uns-claudejp-db psql -U uns_admin -d uns_claudejp`
   - Run migrations: `docker exec -it uns-claudejp-backend alembic upgrade head`
   - Check data integrity: `docker exec -it uns-claudejp-backend python scripts/verify_data.py`

3. **Frontend doesn't load**:
   - Vite compilation can take 1-2 minutes on first run
   - Check frontend logs: `docker logs uns-claudejp-frontend`
   - Verify backend is accessible: http://localhost:8000/api/health
   - Clear browser cache and localStorage

4. **OCR failures**:
   - Check if Azure credentials are set: `AZURE_COMPUTER_VISION_ENDPOINT`, `AZURE_COMPUTER_VISION_KEY`
   - System automatically falls back to Tesseract if Azure unavailable
   - View OCR diagnostics: `docker exec -it uns-claudejp-backend python diagnostico_ocr.py`

5. **Port conflicts**:
   - Check ports 3000, 8000, 5432, 8080 are free
   - Windows: `netstat -ano | findstr "3000"` (replace with other ports)
   - Kill process: `taskkill /PID <pid> /F`

6. **Docker issues**:
   - Ensure Docker Desktop is running
   - Check container status: `docker ps -a`
   - Restart containers: `STOP.bat` then `START.bat`
   - Nuclear option: `REINSTALAR.bat` (destroys all data)

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

- **Testing Framework**: Vitest (Vite's native testing tool, not Jest)
- **Location**: `frontend/src/__tests__/` (if exists)
- **Run tests**: `npm test` (inside container or locally)
- **Coverage report**: `npm run coverage`
- **Test environment**: jsdom for DOM simulation

Example test:
```typescript
// Example test for Login component (using Vitest)
import { describe, it, expect } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import Login from '../pages/Login';

describe('Login', () => {
  it('submits login form correctly', async () => {
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
  });
});
```

## Important Notes

- **LIXO folder**: Contains obsolete files, can be ignored completely - safe to delete
- **JpStart folder**: Legacy scripts, use the main .bat files in root instead
- **Default credentials**: `admin` / `admin123` (CHANGE IN PRODUCTION!)
- **Docker required**: All services run in containers, Docker Desktop must be installed
- **Port requirements**:
  - 3000 (frontend)
  - 8000 (backend API)
  - 5432 (PostgreSQL)
  - 8080 (Adminer)
- **Japanese terminology**: The codebase extensively uses Japanese HR terms:
  - 履歴書 (Rirekisho) = Resume/CV
  - 派遣社員 (Haken Shain) = Dispatch/Temporary workers
  - 請負 (Ukeoi) = Contract workers
  - タイムカード (Timer Card) = Attendance/timesheet
  - 申請 (Shinsei) = Requests/applications
  - 有給 (Yukyu) = Paid leave
  - 在留カード (Zairyu Card) = Residence card
- **Data initialization**: Demo data loaded automatically on first start via `importer` service
- **Vite migration**: Frontend migrated from Create React App to Vite in October 2025
- **Theme system**: 5 themes available (designed by Gemini), managed via `ThemeContext`
- **MCP Integration**: Chrome DevTools MCP server available for browser automation

## URLs

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://localhost:3000 | Main React application (Vite dev server) |
| **Backend API** | http://localhost:8000 | FastAPI REST API |
| **API Docs** | http://localhost:8000/api/docs | Interactive Swagger UI documentation |
| **ReDoc** | http://localhost:8000/api/redoc | Alternative API documentation |
| **Adminer** | http://localhost:8080 | Database management interface |
| **Health Check** | http://localhost:8000/api/health | Backend health status |
| **Database** | localhost:5432 | PostgreSQL (direct connection, internal) |

**Database Credentials for Adminer:**
- System: PostgreSQL
- Server: db (or localhost from host machine)
- Username: uns_admin
- Password: 57UD10R
- Database: uns_claudejp

## Docker Services

The application runs 5 services orchestrated by Docker Compose:

1. **db** (`uns-claudejp-db`) - PostgreSQL 15 database
   - Persistent data in `postgres_data` volume
   - Initialized with `base-datos/01_init_database.sql`

2. **importer** (`uns-claudejp-importer`) - One-time data initialization service
   - Runs `scripts/create_admin_user.py` to create admin user
   - Runs `scripts/import_data.py` to load demo data
   - Exits after completion (restart: 'no')

3. **backend** (`uns-claudejp-backend`) - FastAPI application
   - Python 3.11+ with FastAPI
   - Depends on db and importer services
   - Auto-reload enabled for development
   - Command: `uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload`

4. **frontend** (`uns-claudejp-frontend`) - React application
   - Node.js with Vite dev server
   - Hot Module Replacement (HMR) enabled
   - Command: `npm run dev`

5. **adminer** (`uns-claudejp-adminer`) - Database management UI
   - Lightweight alternative to pgAdmin
   - Accessible at port 8080

All services are on the `uns-network` bridge network for inter-container communication.