# Guía de Inicio Rápido - UNS-ClaudeJP 3.0

Esta guía contiene todo lo que necesitas para instalar y empezar a usar el sistema en menos de 10 minutos.

## 1. Requisitos Previos

- **Sistema Operativo:** Windows 10/11
- **Software:** Docker Desktop (el instalador te ayudará si no lo tienes).
- **Hardware:** 8GB de RAM (16GB recomendados) y 10GB de espacio libre en disco.

## 2. Instalación por Primera Vez (Windows)

Si es tu primera vez, solo necesitas ejecutar un archivo:

```bash
INSTALAR.bat
```

Este script se encargará de todo:
1.  Verificará si Docker Desktop está instalado y corriendo.
2.  Construirá las imágenes de Docker para el backend, frontend y la base de datos. Este paso puede tardar entre 5 y 10 minutos.
3.  Iniciará todos los servicios.
4.  Abrirá el navegador en `http://localhost:3000` cuando el sistema esté listo.

## 3. Uso Diario

Una vez que el sistema está instalado, solo necesitas dos comandos para tu día a día:

-   **Para iniciar el sistema:**
    ```bash
    START.bat
    ```

-   **Para detener el sistema:**
    ```bash
    STOP.bat
    ```

### Acceso al Sistema
- **URL:** [http://localhost:3000](http://localhost:3000)
- **Usuario:** `admin`
- **Contraseña:** `admin123`

## 4. Comandos Esenciales

Estos son los scripts principales que necesitarás:

| Script | Propósito | Cuándo Usarlo |
|---|---|---|
| `INSTALAR.bat` | **Instala todo** desde cero. | Solo la primera vez. |
| `START.bat` | **Inicia** todos los servicios. | Para empezar a trabajar cada día. |
| `STOP.bat` | **Detiene** todos los servicios. | Al finalizar tu jornada. |
| `LOGS.bat` | **Muestra los logs** de los servicios. | Para ver qué está pasando si algo falla. |
| `BACKUP-BD.bat` | Crea un **backup** de la base de datos. | Antes de hacer cambios importantes. |
| `IMPORTAR-BD-ORIGINAL.bat` | **Importa una base de datos** desde un archivo `.sql`. | Para cargar tus datos reales en el sistema. |
| `REINSTALAR.bat` | **Reinstala todo** (borra los datos). | Como último recurso si el sistema está roto. |

## 5. Solución de Problemas Básicos

-   **¿El sistema no inicia?**
    1.  Asegúrate de que Docker Desktop esté corriendo.
    2.  Ejecuta `LOGS.bat` y selecciona la opción del servicio que falla para ver el error.

-   **¿No puedes iniciar sesión?**
    *   Ejecuta `fix-login-correcto.bat`. Este script restaura la contraseña del usuario `admin` a `admin123`.

-   **¿Quieres empezar de cero?**
    *   Ejecuta `REINSTALAR.bat`. **Atención:** Esto borrará todos los datos de la base de datos y reinstalará el sistema con los datos de demostración.
