# 📚 JPUNS-CLAUDE2.0 - Documentación Completa del Sistema

**Versión:** 2.0
**Última Actualización:** 2025-10-10
**Estado:** ✅ Producción

---

## 📋 Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [Arquitectura del Sistema](#arquitectura-del-sistema)
3. [Sistema OCR](#sistema-ocr)
4. [Instalación y Configuración](#instalación-y-configuración)
5. [API y Endpoints](#api-y-endpoints)
6. [Frontend](#frontend)
7. [Base de Datos](#base-de-datos)
8. [Deployment](#deployment)
9. [Troubleshooting](#troubleshooting)
10. [Roadmap y Mejoras Futuras](#roadmap-y-mejoras-futuras)

---

## 🎯 Descripción General

**JPUNS-CLAUDE2.0** es un sistema integral de gestión de recursos humanos especializado en el mercado japonés, con capacidades avanzadas de OCR para procesamiento automático de documentos.

### Características Principales

- 🤖 **OCR Avanzado**: Azure Computer Vision para extracción de datos de documentos japoneses
- 👥 **Gestión de Personal**: Candidatos, empleados, fábricas
- 📊 **Nóminas**: Cálculo automatizado según normativa japonesa
- ⏰ **Control de Tiempo**: Sistema de tarjetas de tiempo
- 📧 **Notificaciones**: Email, LINE, WhatsApp
- 📈 **Dashboard**: Métricas y analytics en tiempo real

### Stack Tecnológico

**Backend:**
- FastAPI (Python 3.11)
- PostgreSQL 15
- Azure Computer Vision
- Docker & Docker Compose

**Frontend:**
- React + TypeScript
- Tailwind CSS
- Vanilla HTML/JS para templates

---

## 🏗️ Arquitectura del Sistema

### Estructura de Directorios

```
JPUNS-CLAUDE2.0/
├── backend/
│   ├── app/
│   │   ├── api/              # Endpoints REST
│   │   │   ├── azure_ocr.py  # ✅ OCR endpoints
│   │   │   ├── candidates.py
│   │   │   ├── employees.py
│   │   │   └── ...
│   │   ├── core/             # Configuración central
│   │   │   ├── config.py
│   │   │   ├── config_azure.py
│   │   │   └── database.py
│   │   ├── models/           # Modelos SQLAlchemy
│   │   ├── schemas/          # Schemas Pydantic
│   │   └── services/         # Lógica de negocio
│   │       └── azure_ocr_service.py  # ✅ Servicio OCR
│   ├── uploads/              # Archivos temporales
│   └── requirements.txt
├── frontend/
│   ├── src/                  # React app
│   └── public/
│       └── templates/
│           ├── rirekisho.html  # ✅ Formulario con OCR
│           └── index.html
├── database/
│   └── migrations/           # SQL migrations
├── docker/
│   ├── Dockerfile.backend
│   └── Dockerfile.frontend
├── .env                      # Variables de entorno
└── docker-compose.yml

```

### Flujo de Datos

```
┌─────────────┐
│   Usuario   │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  Frontend React │
│  rirekisho.html │
└────────┬────────┘
         │
         ▼
┌──────────────────────┐
│   Backend FastAPI    │
│  /api/azure-ocr/*    │
└──────────┬───────────┘
           │
           ▼
┌────────────────────────┐
│  Azure OCR Service     │
│  azure_ocr_service.py  │
└──────────┬─────────────┘
           │
           ▼
┌───────────────────────────┐
│  Azure Computer Vision    │
│  API (Cloud)              │
└───────────────────────────┘
```

---

## 🔍 Sistema OCR

### Estado Actual: ✅ FUNCIONANDO

El sistema OCR utiliza **Azure Computer Vision** para procesar documentos japoneses automáticamente.

### Documentos Soportados

1. **Zairyu Card (在留カード)** - Tarjeta de Residencia
2. **Menkyosho (免許証)** - Licencia de Conducir

### Campos Extraídos

#### Desde Zairyu Card:
- ✅ Nombre (氏名) → `name_kanji`
- ✅ Fecha de nacimiento (生年月日) → `birthday`
- ✅ Nacionalidad (国籍) → `nationality`
- ✅ Dirección (住所) → `address`
- ✅ Estatus de visa (在留資格) → `visa_status`
- ✅ Fecha de vencimiento (有効期限) → `zairyu_expire_date`
- ✅ Número de tarjeta (カード番号) → `zairyu_card_number`

#### Desde License (Menkyosho):
- ✅ Nombre (氏名) → `name_kanji`
- ✅ Fecha de nacimiento (生年月日) → `birthday`
- ✅ Dirección (住所) → `address`
- ✅ Número de licencia (免許証番号) → `license_number`
- ✅ Tipo de licencia (免許の種類) → `license_type`
- ✅ Fecha de vencimiento (有効期限) → `license_expire_date`
- ✅ Fecha de emisión (交付年月日) → `license_issue_date`

### Implementación Técnica

**Servicio:** `backend/app/services/azure_ocr_service.py`

```python
class AzureOCRService:
    def process_document(self, file_path: str, document_type: str):
        # Lee imagen
        with open(file_path, 'rb') as image:
            image_data = image.read()

        # Procesa con Azure
        result = self._process_with_azure(image_data, document_type)
        return result

    def _parse_zairyu_card(self, text: str):
        # Extrae campos específicos de zairyu card
        ...

    def _parse_license(self, text: str):
        # Extrae campos específicos de licencia
        ...
```

**Endpoints:** `backend/app/api/azure_ocr.py`

```python
@router.post("/process")
async def process_ocr_document(
    file: UploadFile,
    document_type: str
):
    result = azure_ocr_service.process_document(temp_file, document_type)
    return {"success": True, "data": result}
```

### Ejemplo de Respuesta

```json
{
    "success": true,
    "message": "Document processed successfully",
    "data": {
        "success": true,
        "raw_text": "Texto completo extraído...",
        "extracted_text": "Texto procesado...",
        "document_type": "zairyu_card",
        "name_kanji": "山田太郎",
        "birthday": "1990-01-15",
        "nationality": "中国",
        "visa_status": "技術・人文知識・国際業務",
        "zairyu_expire_date": "2026-12-31",
        "zairyu_card_number": "AB1234567890",
        "address": "東京都新宿区西新宿1-1-1"
    }
}
```

---

## 🚀 Instalación y Configuración

### Requisitos Previos

- Docker & Docker Compose
- Node.js 18+ (para desarrollo frontend)
- Python 3.11+ (para desarrollo backend)

### Configuración Rápida

1. **Clonar el repositorio**
```bash
git clone <repo-url>
cd JPUNS-CLAUDE2.0
```

2. **Configurar variables de entorno**
```bash
cp .env.example .env
```

Editar `.env` con tus credenciales:

```bash
# Database
DATABASE_URL=postgresql://uns_admin:password@db:5432/uns_claudejp

# Azure Computer Vision (REQUERIDO para OCR)
AZURE_COMPUTER_VISION_ENDPOINT=https://YOUR_RESOURCE.cognitiveservices.azure.com/
AZURE_COMPUTER_VISION_KEY=YOUR_AZURE_KEY_HERE
AZURE_COMPUTER_VISION_API_VERSION=2023-02-01-preview

# Seguridad
SECRET_KEY=your-secret-key-change-in-production
```

3. **Levantar servicios**
```bash
docker-compose up -d --build
```

4. **Verificar**
```bash
# Backend
curl http://localhost:8000/api/health

# OCR
curl http://localhost:8000/api/azure-ocr/health

# Frontend
curl http://localhost:3000
```

### Estructura de `.env`

```bash
# ============================================
# DATABASE CONFIGURATION
# ============================================
DB_PASSWORD=57UD10R
DATABASE_URL=postgresql://uns_admin:u57UD10R@db:5432/uns_claudejp

# ============================================
# SECURITY
# ============================================
SECRET_KEY=57UD10R
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# ============================================
# API CONFIGURATION
# ============================================
API_URL=http://localhost:8000
FRONTEND_URL=http://localhost:3000

# ============================================
# AZURE COMPUTER VISION (REQUIRED)
# ============================================
AZURE_COMPUTER_VISION_ENDPOINT=https://jpkken.cognitiveservices.azure.com/
AZURE_COMPUTER_VISION_KEY=YOUR_KEY_HERE
AZURE_COMPUTER_VISION_API_VERSION=2023-02-01-preview

# ============================================
# FILE UPLOAD
# ============================================
MAX_UPLOAD_SIZE=10485760
ALLOWED_EXTENSIONS=pdf,jpg,jpeg,png,xlsx,xls
UPLOAD_DIR=/app/uploads

# ============================================
# OCR CONFIGURATION
# ============================================
OCR_ENABLED=true
```

---

## 📡 API y Endpoints

### Base URL
```
http://localhost:8000/api
```

### Autenticación

**Login:**
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=secret"
```

**Respuesta:**
```json
{
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "token_type": "bearer"
}
```

### OCR Endpoints

#### 1. Health Check
```bash
GET /api/azure-ocr/health
```

**Respuesta:**
```json
{
    "status": "healthy",
    "service": "azure_ocr",
    "provider": "Azure Computer Vision",
    "api_version": "2023-02-01-preview"
}
```

#### 2. Procesar Documento
```bash
POST /api/azure-ocr/process
Content-Type: multipart/form-data

file: [imagen]
document_type: zairyu_card|license
```

**Ejemplo con curl:**
```bash
curl -X POST http://localhost:8000/api/azure-ocr/process \
  -F "file=@documento.jpg" \
  -F "document_type=zairyu_card"
```

#### 3. Procesar desde Base64
```bash
POST /api/azure-ocr/process-from-base64
Content-Type: application/x-www-form-urlencoded

image_base64: [base64_string]
mime_type: image/jpeg
document_type: zairyu_card|license
```

### Otros Endpoints Principales

- `GET /api/candidates` - Listar candidatos
- `POST /api/candidates` - Crear candidato
- `GET /api/employees` - Listar empleados
- `GET /api/factories` - Listar fábricas
- `GET /api/timer-cards` - Tarjetas de tiempo
- `GET /api/salary/calculate` - Calcular salario
- `GET /api/monitoring/health` - Health check general
- `GET /api/monitoring/metrics` - Métricas del sistema

### Documentación Interactiva

- **Swagger UI:** http://localhost:8000/api/docs
- **ReDoc:** http://localhost:8000/api/redoc

---

## 🎨 Frontend

### Templates HTML

#### rirekisho.html - Formulario con OCR

**URL:** `http://localhost:3000/templates/rirekisho.html`

**Características:**
- ✅ Upload de zairyu card o menkyosho
- ✅ Procesamiento OCR automático
- ✅ Llenado automático de campos
- ✅ Visualización de texto extraído
- ✅ Cálculo automático de edad
- ✅ Exportación a PDF

**Configuración OCR en Frontend:**

```javascript
const CONFIG = {
    API_BASE_URL: window.location.origin.replace(/:\d+$/, ':8000'),
    OCR_ENDPOINTS: [
        '/api/azure-ocr/process',
        '/api/azure-ocr/process-from-base64'
    ]
};

// Función de procesamiento
async function processOCR(event, type) {
    const file = event.target.files[0];
    const base64Image = await fileToBase64(file);

    // Intentar con todos los endpoints
    for (let i = 0; i < CONFIG.OCR_ENDPOINTS.length; i++) {
        try {
            const textData = await extractTextFromImage(
                base64Image,
                file.type,
                type,
                i
            );

            // Normalizar datos del backend
            if (textData.name_kanji && !textData.name) {
                textData.name = textData.name_kanji;
            }

            // Rellenar campos
            document.getElementById('name_kanji').value = textData.name_kanji || '';
            document.getElementById('birthday').value = textData.birthday || '';
            // ... más campos

            break;
        } catch (error) {
            console.error('Error OCR:', error);
        }
    }
}
```

### React App

**URL:** `http://localhost:3000`

**Componentes Principales:**
- Dashboard - Panel principal
- Candidates - Gestión de candidatos
- Employees - Gestión de empleados
- TimerCards - Control de tiempo
- Reports - Informes y reportes

---

## 🗄️ Base de Datos

### PostgreSQL Schema

**Tablas Principales:**

```sql
-- Candidatos
CREATE TABLE candidates (
    id SERIAL PRIMARY KEY,
    name_kanji VARCHAR(100),
    name_furigana VARCHAR(100),
    birthday DATE,
    nationality VARCHAR(50),
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    visa_type VARCHAR(50),
    visa_expiry DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Empleados
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    candidate_id INTEGER REFERENCES candidates(id),
    employee_number VARCHAR(20) UNIQUE,
    hire_date DATE,
    department VARCHAR(50),
    position VARCHAR(50),
    salary DECIMAL(10,2),
    status VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tarjetas de Tiempo
CREATE TABLE timer_cards (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(id),
    date DATE,
    clock_in TIME,
    clock_out TIME,
    break_minutes INTEGER,
    total_hours DECIMAL(4,2),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Fábricas
CREATE TABLE factories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    address TEXT,
    phone VARCHAR(20),
    contact_person VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Migrations

Las migraciones se encuentran en `database/migrations/` y se ejecutan automáticamente al iniciar el contenedor de PostgreSQL.

**Archivos:**
- `001_initial_schema.sql` - Schema inicial
- `002_add_employee_extended_fields.sql` - Campos extendidos

---

## 🚢 Deployment

### Desarrollo Local

```bash
# Iniciar todos los servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Reiniciar un servicio
docker-compose restart backend

# Detener todo
docker-compose down
```

### Producción

1. **Configurar variables de entorno**

```bash
# .env para producción
ENVIRONMENT=production
DEBUG=false

# Base de datos segura
DATABASE_URL=postgresql://user:strong_password@db:5432/jpuns_prod

# Secret key fuerte
SECRET_KEY=<generar-con-openssl-rand-base64-32>

# CORS específicos
BACKEND_CORS_ORIGINS=["https://yourdomain.com"]
```

2. **Build para producción**

```bash
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
```

3. **Nginx Reverse Proxy** (ejemplo)

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location /api {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

4. **SSL con Let's Encrypt**

```bash
certbot --nginx -d yourdomain.com
```

### Monitoreo

**Health Checks:**
```bash
# Backend
curl http://localhost:8000/api/health

# OCR
curl http://localhost:8000/api/azure-ocr/health

# Métricas
curl http://localhost:8000/api/monitoring/metrics
```

**Logs:**
```bash
# Todos los logs
docker-compose logs -f

# Solo backend
docker-compose logs -f backend

# Últimas 100 líneas
docker-compose logs --tail=100 backend
```

---

## 🔧 Troubleshooting

### Problema: OCR no funciona - "No disponible"

**Síntomas:**
- Frontend muestra "OCRエンドポイント: ❌ No disponible"
- No se pueden subir imágenes

**Solución:**
```bash
# 1. Verificar que el backend esté corriendo
docker ps | grep backend

# 2. Verificar logs
docker logs uns-claudejp-backend --tail 50

# 3. Verificar credenciales de Azure en .env
grep AZURE .env

# 4. Reiniciar backend
docker-compose restart backend

# 5. Verificar health check
curl http://localhost:8000/api/azure-ocr/health
```

### Problema: OCR devuelve datos vacíos/null

**Síntomas:**
- El procesamiento termina pero los campos quedan vacíos
- Respuesta tiene `data: null` o campos null

**Causas y Soluciones:**

1. **Imagen de mala calidad**
   - Usar imágenes con mínimo 300 DPI
   - Asegurar buena iluminación
   - Evitar reflejos y sombras

2. **Credenciales incorrectas**
   ```bash
   # Verificar en logs
   docker logs uns-claudejp-backend 2>&1 | grep -i azure

   # Debe mostrar:
   # "Azure Computer Vision credentials loaded successfully"
   ```

3. **Version de API incorrecta**
   ```bash
   # En .env debe ser:
   AZURE_COMPUTER_VISION_API_VERSION=2023-02-01-preview
   # NO usar fechas como 2025-10-10-preview
   ```

### Problema: Error de CORS

**Síntomas:**
- Error en consola del navegador: "blocked by CORS policy"
- Requests fallan desde el frontend

**Solución:**
```python
# backend/app/core/config.py
BACKEND_CORS_ORIGINS = [
    "http://localhost",
    "http://localhost:3000",
    "http://localhost:8000",
    "http://127.0.0.1:3000",
    # Agregar tu dominio aquí
]
```

### Problema: Base de datos no conecta

**Síntomas:**
- Backend no inicia
- Error: "could not connect to database"

**Solución:**
```bash
# 1. Verificar que PostgreSQL esté corriendo
docker ps | grep postgres

# 2. Verificar logs de PostgreSQL
docker logs uns-claudejp-db

# 3. Verificar URL en .env
grep DATABASE_URL .env

# 4. Reiniciar base de datos
docker-compose restart db

# 5. Recrear si es necesario
docker-compose down -v
docker-compose up -d
```

### Problema: Frontend no carga

**Síntomas:**
- Página en blanco en http://localhost:3000
- Error 502 Bad Gateway

**Solución:**
```bash
# 1. Verificar que el contenedor esté corriendo
docker ps | grep frontend

# 2. Ver logs
docker logs uns-claudejp-frontend

# 3. Verificar node_modules
docker exec uns-claudejp-frontend ls -la node_modules

# 4. Reinstalar dependencias si es necesario
docker-compose down
docker-compose up -d --build frontend
```

### Problema: Errores de encoding en Windows

**Síntomas:**
- `UnicodeEncodeError: 'cp932' codec can't encode character`
- Texto japonés no se muestra en terminal

**Solución:**
```bash
# Cambiar encoding de terminal a UTF-8
chcp 65001

# O usar PowerShell en lugar de CMD
```

---

## 📈 Roadmap y Mejoras Futuras

### Corto Plazo (1-3 meses)

- [ ] **OCR Mejorado**
  - Soporte para pasaportes japoneses
  - Soporte para My Number Card
  - Detección automática de tipo de documento
  - Validación de campos extraídos

- [ ] **UI/UX**
  - Sistema de diseño unificado
  - Modo oscuro
  - Responsive mejorado para móviles
  - Accesibilidad WCAG 2.1 AA

- [ ] **Testing**
  - Tests unitarios para servicios críticos
  - Tests de integración para APIs
  - Tests E2E con Playwright

### Mediano Plazo (3-6 meses)

- [ ] **Analytics Predictivo**
  - Predicción de rotación de empleados
  - Análisis de tendencias salariales
  - Recomendaciones de contratación

- [ ] **Automatización**
  - Generación automática de contratos
  - Notificaciones proactivas de vencimientos
  - Recordatorios de documentación

- [ ] **Integraciones**
  - API pública con OAuth2
  - Webhooks para eventos
  - Integración con sistemas ERP japoneses

### Largo Plazo (6-12 meses)

- [ ] **IA Conversacional**
  - Chatbot operativo con Claude
  - Procesamiento de lenguaje natural para consultas
  - Asistente virtual para empleados

- [ ] **Módulos Verticales**
  - Módulo para industria de manufactura
  - Módulo para retail
  - Módulo para healthcare

- [ ] **Escalabilidad**
  - Migración a microservicios
  - Kubernetes para orquestación
  - Auto-scaling basado en demanda

### Plan Estratégico vs SmartHR

Para competir con SmartHR, el sistema debe:

1. **Innovar en IA**: OCR avanzado + análisis predictivo
2. **Mejorar UX**: Diseño superior y accesibilidad
3. **Especializar**: Módulos verticales por industria
4. **Abrir**: API pública y marketplace de integraciones
5. **Asegurar**: Seguridad nivel bancario (ISO 27001, SOC 2)

---

## 📞 Soporte

### Recursos

- **Documentación API:** http://localhost:8000/api/docs
- **Repositorio:** [GitHub URL]
- **Issues:** [GitHub Issues URL]

### Contacto

- **Email:** support@uns-kikaku.com
- **Website:** https://www.uns-kikaku.com
- **Empresa:** UNS-Kikaku

---

## 📄 Licencia

Proprietary - UNS-Kikaku © 2025

---

## 🙏 Agradecimientos

- Azure Computer Vision por el OCR
- FastAPI por el framework backend
- React por el framework frontend
- Claude AI por el asistente de desarrollo

---

**Última actualización:** 2025-10-10
**Mantenedor:** UNS-Kikaku Development Team
**Versión del Sistema:** 2.0
