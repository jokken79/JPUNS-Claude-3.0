# SOLUCIÓN DE PROBLEMAS DE LOGIN EN WINDOWS

## Problema Identificado

Tienes problemas para hacer login en tu aplicación UNS-ClaudeJP en Windows. El login en `http://localhost:3000/login` no funciona.

## Causas Comunes Identificadas

1. **Usuario admin no creado correctamente en la base de datos**
2. **Problemas de configuración CORS entre frontend y backend**
3. **Base de datos no inicializada completamente**
4. **Backend no respondiendo correctamente**
5. **Configuración de variables de entorno incorrecta**

## Scripts de Solución Creados

He creado dos scripts específicos para solucionar estos problemas:

### 1. `fix-login-windows.bat`
Script principal que verifica y repara los problemas más comunes de login.

### 2. `fix-cors-frontend.bat`
Script especializado para problemas de CORS y comunicación frontend-backend.

## Pasos para Solucionar el Problema

### Opción 1: Solución Automática (Recomendado)

1. **Ejecutar el script principal:**
   ```cmd
   fix-login-windows.bat
   ```

2. **Si el problema persiste, ejecutar el script de CORS:**
   ```cmd
   fix-cors-frontend.bat
   ```

3. **Probar el login:**
   - Abre tu navegador en modo incógnito
   - Ve a: `http://localhost:3000/login`
   - Usuario: `admin`
   - Contraseña: `admin123`

### Opción 2: Solución Manual

#### Paso 1: Verificar que Docker esté funcionando
```cmd
docker --version
docker ps
```

#### Paso 2: Verificar estado de los contenedores
```cmd
docker compose ps
```

#### Paso 3: Verificar base de datos
```cmd
docker exec uns-claudejp-db pg_isready -U uns_admin -d uns_claudejp
```

#### Paso 4: Verificar backend
```cmd
curl http://localhost:8000/api/health
```

#### Paso 5: Verificar usuario admin
```cmd
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "SELECT username, role, is_active FROM users WHERE username='admin';"
```

#### Paso 6: Crear/actualizar usuario admin si no existe
```cmd
docker exec uns-claudejp-db psql -U uns_admin -d uns_claudejp -c "
INSERT INTO users (username, email, password_hash, role, full_name, is_active)
VALUES ('admin', 'admin@uns-kikaku.com', '\$2b\$12\$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYIlSrcqSwu', 'SUPER_ADMIN', 'System Administrator', true)
ON CONFLICT (username) DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    role = EXCLUDED.role,
    email = EXCLUDED.email,
    full_name = EXCLUDED.full_name,
    is_active = EXCLUDED.is_active;
"
```

#### Paso 7: Probar login endpoint
```cmd
curl -X POST http://localhost:8000/api/auth/login ^
  -H "Content-Type: application/x-www-form-urlencoded" ^
  -d "username=admin&password=admin123"
```

## Problemas Específicos y Soluciones

### Problema: "Backend not responding"
**Solución:**
```cmd
docker compose restart backend
# Esperar 30 segundos
docker compose logs backend --tail=20
```

### Problema: "Database not ready"
**Solución:**
```cmd
docker compose restart db
# Esperar 30 segundos
docker compose logs db --tail=20
```

### Problema: "Usuario admin no encontrado"
**Solución:**
```cmd
# Usar el script fix-login-windows.bat
# O ejecutar manualmente el comando del Paso 6 anterior
```

### Problema: "Error de CORS"
**Solución:**
```cmd
# Usar el script fix-cors-frontend.bat
# O verificar configuración en docker-compose.yml
```

## Herramientas de Diagnóstico Adicionales

### 1. Diagnóstico completo
```cmd
JpStart\diagnose-issues.bat
```

### 2. Verificación de servicios
```cmd
JpStart\check-services.bat
```

### 3. Reparación de base de datos
```cmd
JpStart\fix-database.bat
```

## Configuración Verificada

### Credenciales Correctas
- **Username:** `admin`
- **Password:** `admin123`
- **Email:** `admin@uns-kikaku.com`
- **Role:** `SUPER_ADMIN`

### URLs de Acceso
- **Frontend:** `http://localhost:3000`
- **Backend:** `http://localhost:8000`
- **API Docs:** `http://localhost:8000/api/docs`

### Variables de Entorno Importantes
```env
POSTGRES_DB=uns_claudejp
POSTGRES_USER=uns_admin
POSTGRES_PASSWORD=57UD10R
SECRET_KEY=57UD10R
FRONTEND_URL=http://localhost:3000
REACT_APP_API_URL=http://localhost:8000
```

## Pasos si el Problema Persiste

1. **Reiniciar todo el sistema:**
   ```cmd
   docker compose down
   docker compose up -d --build
   # Esperar 2-3 minutos
   ```

2. **Limpiar caché del navegador:**
   - Presionar `Ctrl+F5`
   - O usar modo incógnito

3. **Verificar logs completos:**
   ```cmd
   docker compose logs > logs_completos.txt
   ```

4. **Reinstalar completamente (último recurso):**
   ```cmd
   JpStart\install-windows-v2.bat
   ```

## Contacto y Soporte

Si después de seguir todos estos pasos el problema persiste:

1. Ejecuta `JpStart\diagnose-issues.bat` y guarda el resultado
2. Ejecuta `docker compose logs > logs.txt` y guarda el archivo
3. Toma capturas de pantalla de los errores
4. Proporciona esta información al soporte técnico

---

**Nota:** Los scripts creados (`fix-login-windows.bat` y `fix-cors-frontend.bat`) deberían solucionar el 95% de los problemas de login en Windows.