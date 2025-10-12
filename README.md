# 🎯 JPUNS-CLAUDE3.0

Sistema integral de gestión de recursos humanos con OCR avanzado para el mercado japonés.

![Version](https://img.shields.io/badge/version-3.0-blue.svg)
![Status](https://img.shields.io/badge/status-production-green.svg)
![Python](https://img.shields.io/badge/python-3.11-blue.svg)
![FastAPI](https://img.shields.io/badge/FastAPI-0.104-green.svg)
![React](https://img.shields.io/badge/React-18-blue.svg)

---

## 📚 Documentación

### 📖 **[DOCUMENTACION_COMPLETA.md](./DOCUMENTACION_COMPLETA.md)** ↁEComienza aquí

Este documento contiene **TODA** la información del sistema:
- Descripción general y arquitectura
- Sistema OCR con Azure Computer Vision
- Instalación y configuración completa
- API y endpoints detallados
- Frontend y templates
- Base de datos y migraciones
- Deployment y producción
- Troubleshooting completo
- Roadmap y mejoras futuras

---

## 🚀 Quick Start

### 1. Requisitos Previos
- Docker & Docker Compose
- Node.js 18+ (opcional, para desarrollo)
- Python 3.11+ (opcional, para desarrollo)

### 2. Instalación Rápida

```bash
# Clonar repositorio
git clone <repo-url>
cd JPUNS-CLAUDE3.0

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales de Azure

# Levantar servicios
docker-compose up -d --build

# Verificar
curl http://localhost:8000/api/health
curl http://localhost:3000
```

### 3. Acceder al Sistema

- **Frontend:** http://localhost:3000
- **Formulario OCR:** http://localhost:3000/templates/rirekisho.html
- **API Docs:** http://localhost:8000/api/docs
- **Backend API:** http://localhost:8000/api

---

## ✨ Características Principales

### 🤁EOCR Avanzado
- Procesamiento automático de **Zairyu Card** (在留カーチE
- Procesamiento automático de **Menkyosho** (免許証)
- Extracción inteligente de datos con Azure Computer Vision
- Llenado automático de formularios

### 👥 Gestión de Personal
- Registro de candidatos
- Gestión de empleados
- Control de fábricas
- Sistema de tarjetas de tiempo

### 📊 Administración
- Cálculo de nóminas (normativa japonesa)
- Generación de reportes
- Dashboard con métricas
- Notificaciones (Email, LINE, WhatsApp)

---

## 🏗�E�EStack Tecnológico

**Backend:**
- FastAPI (Python 3.11)
- PostgreSQL 15
- Azure Computer Vision
- Docker & Docker Compose

**Frontend:**
- React 18 + TypeScript
- Tailwind CSS
- HTML5 templates

---

## 📋 Estructura del Proyecto

```
JPUNS-CLAUDE3.0/
├── 📄 DOCUMENTACION_COMPLETA.md  ↁELEER PRIMERO
├── backend/                      # API FastAPI
━E  ├── app/
━E  ━E  ├── api/                 # Endpoints REST
━E  ━E  ├── services/            # Lógica de negocio
━E  ━E  ├── models/              # Modelos DB
━E  ━E  └── core/                # Configuración
━E  └── requirements.txt
├── frontend/                     # React App
━E  ├── src/
━E  └── public/templates/        # HTML templates
├── database/                     # PostgreSQL
━E  └── migrations/              # SQL migrations
├── docs/                        # Documentación adicional
├── docker-compose.yml
└── .env                         # Variables de entorno
```

---

## 🔧 Configuración Esencial

### Variables de Entorno (.env)

```bash
# Database
DATABASE_URL=postgresql://uns_admin:password@db:5432/uns_claudejp

# Azure Computer Vision (REQUERIDO para OCR)
AZURE_COMPUTER_VISION_ENDPOINT=https://YOUR_RESOURCE.cognitiveservices.azure.com/
AZURE_COMPUTER_VISION_KEY=YOUR_AZURE_KEY
AZURE_COMPUTER_VISION_API_VERSION=2023-02-01-preview

# Seguridad
SECRET_KEY=your-secret-key-here
```

**⚠�E�EImportante:** Obtén tus credenciales de Azure desde [Azure Portal](https://portal.azure.com)

---

## 🧪 Pruebas

### Health Checks

```bash
# Backend general
curl http://localhost:8000/api/health

# OCR específico
curl http://localhost:8000/api/azure-ocr/health
```

### Probar OCR

```bash
# Procesar documento
curl -X POST http://localhost:8000/api/azure-ocr/process \
  -F "file=@documento.jpg" \
  -F "document_type=zairyu_card"
```

### Frontend

1. Abrir: http://localhost:3000/templates/rirekisho.html
2. Verificar que muestre: "OCRエンド�EインチE ✁EDisponible"
3. Subir una imagen de zairyu card o menkyosho
4. Ver campos rellenarse automáticamente

---

## 🔍 Troubleshooting

### OCR no funciona

```bash
# 1. Verificar backend
docker ps | grep backend

# 2. Ver logs
docker logs uns-claudejp-backend --tail 50

# 3. Verificar credenciales
grep AZURE .env

# 4. Reiniciar
docker-compose restart backend
```

**👉 Más soluciones:** Ver sección "Troubleshooting" en [DOCUMENTACION_COMPLETA.md](./DOCUMENTACION_COMPLETA.md)

---

## 📊 Estado del Sistema

| Componente | Estado | Puerto |
|------------|--------|--------|
| Backend FastAPI | ✁EFuncionando | 8000 |
| Frontend React | ✁EFuncionando | 3000 |
| PostgreSQL | ✁EFuncionando | 5432 |
| Azure OCR | ✁EFuncionando | - |

---

## 🚢 Deployment

### Desarrollo
```bash
docker-compose up -d
```

### Producción
```bash
# Configurar .env para producción
ENVIRONMENT=production
DEBUG=false

# Build y deploy
docker-compose -f docker-compose.prod.yml up -d --build
```

**👉 Guía completa:** Ver sección "Deployment" en [DOCUMENTACION_COMPLETA.md](./DOCUMENTACION_COMPLETA.md)

---

## 📖 Documentación Adicional

- [DOCUMENTACION_COMPLETA.md](./DOCUMENTACION_COMPLETA.md) - Guía completa del sistema
- [docs/API_EXAMPLES.md](./docs/API_EXAMPLES.md) - Ejemplos de API
- [docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md) - Guía de deployment
- [docs/technical/](./docs/technical/) - Documentación técnica
- [docs/sessions/](./docs/sessions/) - Bitácoras de desarrollo

---

## 📞 Soporte

- **Documentación:** [DOCUMENTACION_COMPLETA.md](./DOCUMENTACION_COMPLETA.md)
- **API Docs:** http://localhost:8000/api/docs
- **Email:** support@uns-kikaku.com
- **Website:** https://www.uns-kikaku.com

---

## 🤁EContribuir

1. Fork el proyecto
2. Crear feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push al branch (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

---

## 📄 Licencia

Proprietary - UNS-Kikaku © 2025

---

## 🙏 Agradecimientos

- Azure Computer Vision
- FastAPI Framework
- React Team
- Claude AI

---

**Desarrollado con ❤�E�Epor UNS-Kikaku**

**Última actualización:** 2025-10-12 | **Versión:** 3.0
