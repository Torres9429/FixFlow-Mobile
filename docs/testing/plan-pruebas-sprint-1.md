# FixFlow

4 de octubre del 2026

## HU-01 — REGISTRO DE CIUDADANO

Como ciudadano quiero crear una cuenta en FixFlow para poder registrar incidencias y consultar el seguimiento de mis reportes.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-01 | El validador de contraseña (CA-4) | Unitaria | abc12345 → sin error<br>abcdefgh, 12345678 y abc123 → mensaje de error | 4 |
| HU-01 | Los validadores de campos obligatorios y del correo (CA-2) | Unitaria | Vacío → "Campo obligatorio"; ana@ → "Correo no válido"; ana@mail.com → sin error | 3 |
| HU-01 | Enviar el formulario vacío (CA-2) | Interfaz | Aparece un error bajo cada campo y MockAuthService.registrar() no se llama | 1 |
| HU-01 | Registro exitoso de punta a punta (CA-1, CA-6) | Integración | Llenar el formulario → Crear cuenta → la app llega al login y muestra "Cuenta creada" | 1 |
| | | | **Total HU-01** | **9** |

## HU-02 — INICIO DE SESIÓN

Como usuario registrado quiero iniciar sesión en la aplicación para acceder a las funcionalidades correspondientes a mi rol.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-02 | AuthService.login() interpreta la respuesta (simulada) | Unitaria | 200 → devuelve token y rol; 401 → error de tipo "credenciales no válidas" | 2 |
| HU-02 | SessionStorage guarda y borra el token (con MockSecureStorage o similar) | Unitaria | Después de guardar, leer devuelve el token; después de borrar, devuelve null | 2 |
| HU-02 | La función que elige la home según el rol (CA-5) | Unitaria | CIUDADANO, OPERATIVO y ADMIN → su home; rol desconocido | 4 |
| HU-02 | El mock responde "credenciales no válidas" (CA-4) | Interfaz | Se muestra "Correo o contraseña no válidos" y el usuario sigue en el login | 1 |
| HU-02 | Login y cierre de sesión de punta a punta | Integración | Login → home del rol → Cerrar sesión → regresa al login y el token queda borrado | 3 |
| | | | **Total HU-02** | **12** |

## ¿Qué queda fuera?

- Pruebas del backend: validaciones del servidor, correo duplicado en la BD y cifrado de la contraseña, generación y validación del token, y protección de rutas por rol.
- Pruebas con el servidor real; todas las respuestas son simuladas.

## ANEXOS

### Tipos

| Prueba | ¿Qué es? | Herramienta |
| --- | --- | --- |
| Unitaria | Una función o clase aislada | flutter_test + mocktail |
| Interfaz | Una pantalla: lo que se ve y se toca | testWidgets |
| Integración | Varias pantallas juntas (la app completa) con los servicios simulados | testWidgets levantando la app completa con los mocks inyectados |
