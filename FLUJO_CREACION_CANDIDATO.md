# Flujo Completo: Creación de un Candidato

Este documento describe el flujo de la aplicación desde que un usuario rellena el formulario de un nuevo candidato hasta que los datos se guardan en la base de datos.

## Parte 1: Frontend (Lo que pasa en el navegador)

1.  **Llenado del Formulario:** El usuario navega a la sección de candidatos, que carga la página `rirekisho.html` dentro de un `iframe`. Aquí se introduce toda la información del nuevo candidato.

2.  **Clic en "Guardar" (保存):** Al presionar este botón, se activa la función `saveData()` en el código JavaScript de la página `rirekisho.html`.

3.  **Recopilación de Datos:** La función `saveData()` lee los valores de todos los campos del formulario (nombre, dirección, etc.) y los agrupa en un solo objeto de JavaScript.

4.  **Envío a la API:** El navegador del usuario envía estos datos a través de una petición `POST` a la API del backend. Específicamente, los envía a la URL: `/api/candidates/`.

## Parte 2: Backend (Lo que pasa en el servidor)

5.  **Recepción de Datos:** El servidor (backend con FastAPI) recibe la petición en el archivo `backend/app/api/candidates.py`. La función que maneja la petición es `create_candidate`.

6.  **Generación de ID:** La función `create_candidate` llama a `generate_rirekisho_id()` para crear un ID único para el nuevo candidato (ej. `UNS-2001`, `UNS-2002`, etc.).

7.  **Creación del Registro:** Se crea un objeto del modelo `Candidate` de SQLAlchemy con la información recibida del formulario y el nuevo ID generado.

8.  **Guardado en Base de Datos:** Este objeto `Candidate` se añade a la sesión de la base de datos y se ejecuta un `commit`. En este momento, **toda la información del candidato se guarda permanentemente como una nueva fila en la tabla `candidates`** de la base de datos.

9.  **Respuesta al Frontend:** Una vez guardado, el servidor responde al navegador con un código de éxito (`201 Created`) y devuelve el registro completo del candidato que acaba de crear en formato JSON.

## Parte 3: De Vuelta al Frontend

10. **Confirmación y Limpieza:** El código JavaScript en `rirekisho.html` recibe la respuesta exitosa del servidor.
    *   Muestra una ventana de alerta que dice: **"¡Datos guardados en la base de datos correctamente!"**.
    *   Limpia los campos del formulario para que el usuario pueda registrar a otra persona si lo necesita.

---

## Flujo de Vista Previa e Impresión

Es importante destacar que la vista previa y la impresión son flujos separados que no guardan datos:

*   **Sin Redirección:** El flujo de guardado **no redirige** a una página de vista previa. Termina con el formulario limpio en la misma página.
*   **Acciones Locales:** La vista previa (**Preview**) y la impresión (**Imprimir PDF**) son acciones que se ejecutan completamente en el navegador. Toman los datos que están *actualmente* en los campos del formulario y los muestran en un formato de currículum para verlos o imprimirlos, pero no interactúan con la base de datos en ese momento.
