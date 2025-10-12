# 🧪 Scripts de Prueba - UNS-ClaudeJP 2.0

**Última actualización:** 2025-10-10

---

## 📋 Scripts Disponibles

### 1️⃣ start-app.bat
**Propósito:** Iniciar la aplicación completa con verificaciones

**Características:**
- 🎨 Interfaz profesional con colores
- 🔄 Auto-inicio de Docker Desktop si no está corriendo
- ✅ 8 pasos de verificación progresivos
- ⏱️ Healthchecks con timeout de 60s
- 📱 Muestra URLs y credenciales al finalizar
- ❓ Opción de abrir navegador automáticamente

**Uso:**
```bash
start-app.bat
```

**Tiempo estimado:** 30-60 segundos

---

### 2️⃣ stop-app.bat
**Propósito:** Detener la aplicación de forma segura

**Características:**
- 🎯 3 opciones de detención:
  1. Solo detener (preservar todo)
  2. Detener y eliminar contenedores (preservar datos)
  3. Eliminar TODO (con doble confirmación)
- ⚠️ Warnings claros sobre pérdida de datos
- ✅ Confirmación de acciones destructivas

**Uso:**
```bash
stop-app.bat
```

**Opciones:**
- **Opción 1:** Detiene contenedores, preserva volúmenes e imágenes
- **Opción 2:** Detiene y elimina contenedores, preserva volúmenes
- **Opción 3:** ⚠️ Elimina TODO (contenedores, volúmenes, imágenes)

---

### 3️⃣ test-app.bat
**Propósito:** Verificación completa del sistema (interactivo)

**Características:**
- 🧪 12 pruebas exhaustivas
- 🎨 Interfaz con colores (verde=éxito, rojo=fallo, amarillo=advertencia)
- 📊 Reporte en pantalla con estadísticas
- 👁️ Opción de ver logs al finalizar
- 🌐 Opción de abrir navegador automáticamente

**Uso:**
```bash
test-app.bat
```

**Pruebas incluidas:**
1. ✅ Verificar Docker Desktop
2. ✅ Verificar Contenedores Docker
3. ✅ Healthcheck de PostgreSQL
4. ✅ Backend Health Endpoint
5. ✅ Azure OCR Service Health
6. ✅ Frontend Accessibility
7. ✅ Formulario OCR (rirekisho.html)
8. ✅ API Documentation (Swagger UI)
9. ✅ Archivos de Configuración
10. ✅ Variables de Entorno Críticas
11. ✅ Logo UNS Integrado
12. ✅ Conexión a Base de Datos

**Tiempo estimado:** 1-2 minutos

---

### 4️⃣ test-app-auto.bat
**Propósito:** Verificación automática sin interacción

**Características:**
- 🤖 Ejecución completamente automática
- 📄 Genera reporte en archivo `.txt`
- 🚀 Ideal para CI/CD o scripts automatizados
- 📊 Mismo conjunto de 12 pruebas que test-app.bat

**Uso:**
```bash
test-app-auto.bat
```

**Salida:** Genera archivo `test-report-YYYYMMDD-HHMMSS.txt`

**Ejemplo de nombre de archivo:**
```
test-report-20251010-080435.txt
```

---

## 🎯 Cuándo Usar Cada Script

### Escenario 1: Inicio de desarrollo
```bash
# 1. Iniciar aplicación
start-app.bat

# 2. Esperar a que termine (30-60s)

# 3. Verificar que todo está bien
test-app.bat
```

### Escenario 2: Fin de jornada
```bash
# Detener aplicación preservando datos
stop-app.bat
# Elegir opción 1
```

### Escenario 3: Limpiar todo y empezar de cero
```bash
# Detener y eliminar todo
stop-app.bat
# Elegir opción 3 y confirmar

# Iniciar de nuevo
start-app.bat
```

### Escenario 4: Verificación rápida después de cambios
```bash
# Reiniciar servicios
docker-compose restart backend

# Verificar que todo funciona
test-app-auto.bat

# Revisar el reporte generado
```

### Escenario 5: CI/CD Pipeline
```bash
# En tu script de CI/CD
start-app.bat
test-app-auto.bat

# Revisar código de salida
if %ERRORLEVEL% NEQ 0 exit /b 1
```

---

## 📊 Interpretación de Resultados

### test-app.bat / test-app-auto.bat

**Tasa de éxito 100%:**
```
╔════════════════════════════════════════════════════════════════╗
║          🎉 ¡PERFECTO! TODOS LOS TESTS PASARON                ║
║              Sistema 100% Operativo                           ║
╚════════════════════════════════════════════════════════════════╝
```
✅ **Acción:** Sistema listo para usar

**Tasa de éxito 80-99%:**
```
╔════════════════════════════════════════════════════════════════╗
║         ⚠️  SISTEMA OPERATIVO CON ADVERTENCIAS                ║
║     Tasa de éxito: XX% - Revisar advertencias                ║
╚════════════════════════════════════════════════════════════════╝
```
⚠️ **Acción:** Revisar advertencias, sistema probablemente usable

**Tasa de éxito < 80%:**
```
╔════════════════════════════════════════════════════════════════╗
║           ❌ SISTEMA CON PROBLEMAS CRÍTICOS                   ║
║     Tasa de éxito: XX% - Atención requerida                  ║
╚════════════════════════════════════════════════════════════════╝
```
❌ **Acción:** Revisar logs, solucionar problemas antes de usar

---

## 🔧 Troubleshooting

### Problema: "Docker no está instalado"
**Solución:**
1. Instalar Docker Desktop desde https://www.docker.com/products/docker-desktop
2. Reiniciar el sistema
3. Ejecutar `start-app.bat` nuevamente

---

### Problema: "Docker Desktop no está corriendo"
**Solución:**
El script `start-app.bat` intenta iniciarlo automáticamente. Si falla:
1. Abrir Docker Desktop manualmente
2. Esperar a que termine de iniciar (ícono en la bandeja de sistema)
3. Ejecutar `start-app.bat` nuevamente

---

### Problema: "Backend health endpoint no responde"
**Solución:**
```bash
# Ver logs del backend
docker logs uns-claudejp-backend --tail 50

# Verificar que el contenedor está corriendo
docker ps | findstr backend

# Reiniciar backend
docker-compose restart backend

# Esperar 30-40 segundos y probar de nuevo
test-app-auto.bat
```

---

### Problema: "Azure OCR endpoint no responde"
**Posibles causas:**
1. Credenciales de Azure no configuradas
2. Credenciales incorrectas
3. API version incorrecta

**Solución:**
```bash
# 1. Verificar variables en .env
findstr "AZURE" .env

# 2. Asegurar que estén configuradas:
AZURE_COMPUTER_VISION_ENDPOINT=https://YOUR_RESOURCE.cognitiveservices.azure.com/
AZURE_COMPUTER_VISION_KEY=YOUR_KEY_HERE
AZURE_COMPUTER_VISION_API_VERSION=2023-02-01-preview

# 3. Reiniciar backend
docker-compose restart backend

# 4. Verificar logs
docker logs uns-claudejp-backend --tail 50 | findstr -i azure
```

---

### Problema: "Frontend no responde en puerto 3000"
**Solución:**
```bash
# Verificar que el contenedor está corriendo
docker ps | findstr frontend

# Ver logs
docker logs uns-claudejp-frontend --tail 50

# Reiniciar frontend
docker-compose restart frontend

# Si el puerto está ocupado por otro proceso
netstat -ano | findstr :3000
# Cerrar el proceso o cambiar puerto en docker-compose.yml
```

---

### Problema: "Base de datos no conecta"
**Solución:**
```bash
# 1. Verificar contenedor DB
docker ps | findstr db

# 2. Ver logs de PostgreSQL
docker logs uns-claudejp-db --tail 50

# 3. Verificar credenciales en .env
findstr "DATABASE_URL" .env
findstr "POSTGRES" .env

# 4. Probar conexión manual
docker exec -it uns-claudejp-db psql -U uns_admin -d uns_claudejp

# 5. Si todo falla, recrear contenedores
docker-compose down
docker-compose up -d --build
```

---

## 📈 Logs y Diagnóstico

### Comandos útiles para debugging

**Ver logs en tiempo real:**
```bash
# Todos los servicios
docker-compose logs -f

# Solo backend
docker-compose logs -f backend

# Solo frontend
docker-compose logs -f frontend

# Solo base de datos
docker-compose logs -f db
```

**Ver últimas N líneas:**
```bash
docker logs uns-claudejp-backend --tail 100
docker logs uns-claudejp-frontend --tail 100
docker logs uns-claudejp-db --tail 100
```

**Buscar errores:**
```bash
docker logs uns-claudejp-backend 2>&1 | findstr -i "error"
docker logs uns-claudejp-backend 2>&1 | findstr -i "exception"
docker logs uns-claudejp-backend 2>&1 | findstr -i "fail"
```

**Estado de contenedores:**
```bash
# Ver todos los contenedores
docker ps -a

# Ver solo los corriendo
docker ps

# Ver uso de recursos
docker stats

# Ver detalles de un contenedor
docker inspect uns-claudejp-backend
```

---

## 🎯 Checklist Pre-Deployment

Antes de hacer deploy a producción, ejecutar:

- [ ] ✅ Ejecutar `test-app-auto.bat` - Debe pasar al 100%
- [ ] ✅ Verificar logs sin errores - `docker-compose logs`
- [ ] ✅ Probar login manual - http://localhost:3000/login
- [ ] ✅ Probar OCR manual - Subir zairyu card en rirekisho.html
- [ ] ✅ Verificar 348 empleados en BD
- [ ] ✅ Exportar PDF funciona
- [ ] ✅ Logo UNS visible en todas las páginas
- [ ] ✅ Credenciales de producción configuradas en `.env`
- [ ] ✅ `DEBUG=false` en `.env` de producción
- [ ] ✅ `SECRET_KEY` generada aleatoriamente para producción
- [ ] ✅ Backup de base de datos realizado

---

## 📚 Documentación Relacionada

- [README.md](README.md) - Inicio rápido
- [DOCUMENTACION_COMPLETA.md](DOCUMENTACION_COMPLETA.md) - Guía completa
- [CONFIGURACION_DOCKER_SOLUCIONADA.md](CONFIGURACION_DOCKER_SOLUCIONADA.md) - Solución Docker
- [REPORTE_PRUEBAS_SISTEMA.md](REPORTE_PRUEBAS_SISTEMA.md) - Último reporte de pruebas

---

## 🆘 Soporte

Si después de revisar esta documentación sigues teniendo problemas:

1. **Revisar logs:**
   ```bash
   docker-compose logs -f
   ```

2. **Consultar troubleshooting:**
   - [DOCUMENTACION_COMPLETA.md](DOCUMENTACION_COMPLETA.md) (Sección "Troubleshooting")

3. **Recrear todo desde cero:**
   ```bash
   stop-app.bat  # Opción 3
   start-app.bat
   test-app.bat
   ```

4. **Contactar soporte:**
   - Email: support@uns-kikaku.com
   - GitHub Issues: [Crear issue]

---

**Creado por:** UNS-Kikaku Development Team
**Última actualización:** 2025-10-10
**Versión:** 2.0
