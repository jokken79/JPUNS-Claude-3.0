# 🚀 Guía Rápida - UNS-ClaudeJP 3.0

## 📋 Comandos Esenciales

### 🆕 Primera Vez (Instalar Todo)
```bash
INSTALAR.bat
```
Solo la primera vez. Verifica Docker, construye todo e inicia el sistema.
**Tarda 5-10 minutos** la primera vez.

### Iniciar el Sistema
```bash
START.bat
```
Todo en uno: inicia BD, Backend y Frontend con verificaciones.
**Usa este después de la instalación inicial.**

### Detener el Sistema
```bash
STOP.bat
```
Detiene todos los servicios de forma segura.

### Ver Logs
```bash
LOGS.bat
```
Menú interactivo para ver logs de cualquier servicio.

### Reinstalar (⚠️ Borra todo)
```bash
REINSTALAR.bat
```
Solo en emergencias. Borra y reinstala todo desde cero.

---

## 🌐 URLs

| Servicio | URL |
|----------|-----|
| **Frontend** | http://localhost:3000 |
| **Backend** | http://localhost:8000 |
| **API Docs** | http://localhost:8000/api/docs |

---

## 👤 Credenciales

```
Usuario:  admin
Password: admin123
```

---

## 🐛 Solución Rápida de Problemas

### El login no funciona
```bash
fix-login-correcto.bat
```

### Ver qué está pasando
```bash
LOGS.bat
```
Selecciona opción 2 (Backend) o 1 (Todos)

### Nada funciona, quiero empezar de cero
```bash
REINSTALAR.bat
```
⚠️ Esto borrará todos los datos

---

## 📁 Estructura Simplificada

```
JPUNS-Claude-3.0/
│
├── 🎯 Scripts (5 archivos .bat)
│   ├── START.bat              ← Usar este para iniciar
│   ├── STOP.bat               ← Usar este para detener
│   ├── LOGS.bat               ← Ver logs
│   ├── REINSTALAR.bat         ← Emergencias
│   └── fix-login-correcto.bat ← Si login falla
│
├── 📚 Documentación (5 archivos .md)
│   ├── README.md              ← Guía completa
│   ├── GUIA_RAPIDA.md         ← Este archivo
│   ├── CHANGELOG.md           ← Historial
│   ├── LIMPIEZA_COMPLETADA.md ← Qué se limpió
│   └── SOLUCION_*.md          ← Soluciones específicas
│
├── 🐳 Configuración
│   └── docker-compose.yml
│
├── 🔧 Backend/
├── 🎨 Frontend/
├── 💾 base-datos/
└── 🗑️ LIXO/                  ← Archivos viejos (ignorar)
```

---

## ⚡ Flujo de Trabajo Típico

### 1. Primera vez
```bash
START.bat
# Espera 1-2 minutos
# Abre http://localhost:3000
# Login: admin / admin123
```

### 2. Día a día
```bash
START.bat       # Al comenzar
# ... trabajar ...
STOP.bat        # Al terminar
```

### 3. Si hay problemas
```bash
LOGS.bat        # Ver qué pasa
# o
REINSTALAR.bat  # Último recurso
```

---

## 🎓 Aprende Más

- **Guía completa:** [README.md](README.md)
- **Historial de cambios:** [CHANGELOG.md](CHANGELOG.md)
- **Problemas de login:** [SOLUCION_LOGIN_DEFINITIVA.md](SOLUCION_LOGIN_DEFINITIVA.md)
- **Problemas de empleados:** [SOLUCION_ERROR_EMPLEADOS.md](SOLUCION_ERROR_EMPLEADOS.md)

---

## ✅ Verificación Rápida

### ¿El sistema está corriendo?
```bash
docker-compose ps
```
Deberías ver 3 contenedores: `db`, `backend`, `frontend`

### ¿El backend funciona?
```bash
curl http://localhost:8000/api/health
```
Debe retornar: `{"status":"healthy",...}`

### ¿El frontend funciona?
Abre: http://localhost:3000
Deberías ver la página de login.

---

## 🆘 Ayuda

1. **Lee primero:** [README.md](README.md)
2. **Verifica logs:** `LOGS.bat`
3. **Consulta soluciones:** `SOLUCION_*.md`
4. **Último recurso:** `REINSTALAR.bat`

---

**¡Eso es todo! El sistema está listo para usar.** 🎉

Para más detalles, consulta [README.md](README.md)
