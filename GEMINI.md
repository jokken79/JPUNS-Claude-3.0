# Project Overview

This is a comprehensive HR management system for Japanese companies, named UNS-ClaudeJP 3.0. It's a full-stack web application built with a FastAPI (Python) backend and a React (TypeScript) frontend. The entire system is containerized using Docker.

## Key Technologies

*   **Backend:**
    *   Python 3.11
    *   FastAPI
    *   SQLAlchemy (ORM)
    *   PostgreSQL
    *   Pydantic
    *   JWT for authentication
    *   Tesseract and Azure Computer Vision for OCR
*   **Frontend:**
    *   React 18
    *   Vite
    *   TypeScript
    *   Tailwind CSS
    *   Vitest for testing
*   **DevOps:**
    *   Docker
    *   Docker Compose

# Building and Running

The project uses batch scripts for easy setup and execution on Windows.

*   **First-time setup:**
    ```bash
    INSTALAR.bat
    ```
    This script handles Docker installation, builds the necessary Docker images, and starts the application.

*   **Starting the application:**
    ```bash
    START.bat
    ```
    This command starts all the services (database, backend, frontend).

*   **Stopping the application:**
    ```bash
    STOP.bat
    ```
    This command stops all running Docker containers.

*   **Viewing logs:**
    ```bash
    LOGS.bat
    ```

## Development Conventions

*   The backend follows a standard FastAPI project structure, with separation of concerns for API endpoints, models, schemas, and services.
*   The frontend has been migrated from Create React App to Vite, indicating a preference for modern, faster build tools.
*   The project uses `npm` for frontend dependency management and `pip` with `requirements.txt` for the backend.
*   Testing on the frontend is done with Vitest.
*   The project encourages the use of a `.env` file for local environment variable configuration.
*   Contribution guidelines are present in the `README.md`, suggesting a standard Git workflow (feature branches, pull requests).
