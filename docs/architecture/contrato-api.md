# Contrato de API — FixFlow

Cómo habla la app con el back (`FixFlow-Backend`). Úsalo al conectar cada pantalla: dice qué endpoint llamar, qué mandar y qué llega. Las reglas de negocio citadas están en [business-rules.md](../requirements/business-rules/business-rules.md).

## Acuerdos

| Tema | Acuerdo |
| --- | --- |
| URL base | `http://10.0.2.2:8080/api` en el emulador de Android; `http://<IP de la PC>:8080/api` en un celular físico. Todas las rutas cuelgan de `/api` |
| Formato | Todas las respuestas vienen envueltas en `{ "text": "...", "type": "SUCCESS" \| "WARNING" \| "ERROR", "result": ... }`. Los datos están en `result`; en un error, `text` es el mensaje para mostrar |
| Códigos | `200`/`201` éxito · `400` dato inválido · `401` sin sesión o credenciales malas · `403` el rol no puede · `404` no existe · `409` conflicto (correo duplicado, transición de estado inválida) · `422` evidencia inválida (RN-12) · `503` Cloudinary no configurado |
| Sesión (temporal) | Mientras no exista JWT, cada petición con sesión manda el header `X-Usuario-Id: <id>`. El login devuelve `token: "dev-<id>"`; la app guarda token e id en `flutter_secure_storage`. Al entrar Security (RNF-09) cambia a `Authorization: Bearer <access token>` (15 min) más un refresh token de 7 días con su endpoint de renovación; el resto del contrato no cambia |
| Paginación | `?page=0&size=20` (máximo 50). `result` = `{ "content": [...], "page": { "size", "number", "totalElements", "totalPages" } }` |
| Fechas | ISO-8601 en UTC (`2026-10-19T06:07:54.530Z`) |
| Estados | `PENDIENTE`, `ASIGNADA`, `EN_PROCESO`, `RESUELTA`, `REABIERTA`, `CERRADA` (RN-14). Prioridades: `ALTA`, `MEDIA`, `BAJA` |

### Cambios pendientes en el código de mobile

Se corrigen al integrar cada pantalla con el back:

- **Login (HU-02):** `LoginResponseModel.fromJson` debe leer `json['result']` y guardar también `id`.
- **Registro (HU-01):** el datasource llama a `/auth/registro`; la ruta correcta es `/auth/register`. Además, `RegistroResponseModel` espera `{token, rol, nombre}` en la raíz, pero el back responde el usuario creado dentro de `result` y **sin token**: después de registrarse, el usuario va al login (A1 con el aviso «Cuenta creada»).
- **Sesión:** el interceptor de `ApiClient` debe agregar `X-Usuario-Id` con el id guardado.

## Fotos (RNF-05)

1. `POST /evidencias/firma` con `{"tipo": "REPORTE"}` (ciudadano) o `{"tipo": "SOLUCION"}` (operativo) → `{cloudName, apiKey, timestamp, folder, signature}`.
2. Subir la foto (JPEG 1600 px, calidad 80) con `dio` y `FormData` a `https://api.cloudinary.com/v1_1/<cloudName>/image/upload` con los campos `file`, `api_key`, `timestamp`, `folder` y `signature`.
3. De la respuesta de Cloudinary tomar `secure_url` y mandarla como `fotoUrl`.

## Endpoints por pantalla

| Pantalla | Método y ruta | Body | `result` |
| --- | --- | --- | --- |
| A1 Login | `POST /auth/login` | `{correo, password}` | `{token, id, rol, nombre}` |
| A2 Registro | `POST /auth/register` | `{nombre, apellidos, correo, password}` | Usuario creado · 409 correo existe |
| Inicio de la app | `GET /auth/me` | — | `{id, nombre, apellidos, correo, rol, activo}` · 401 → login |
| A3 Perfil (HU-25) | `PUT /usuarios/me` · `PATCH /usuarios/me/password` | `{nombre, apellidos}` · `{actual, nueva}` | Usuario · mensaje |
| Catálogo de tipos (HU-26, sin pantalla aún) | `GET /admin/tipos-incidencia` · `POST /admin/tipos-incidencia` · `PUT /admin/tipos-incidencia/{id}` · `PATCH /admin/tipos-incidencia/{id}/estatus` | `{codigo, nombre, orientacion, prioridadBase}` (el código no cambia en el PUT) · `{activo}` | Tipo |
| B2 Nuevo reporte | `GET /tipos-incidencia` | — | `[{id, codigo, nombre, orientacion, prioridadBase}]` |
| B3/B4 Enviar | `POST /evidencias/firma` → Cloudinary → `POST /incidencias` | `{tipoId, descripcion, latitud, longitud, inclinacion, fotoUrl}` | Detalle con `folio` (B5) · 422 → repetir captura (B3b, B7) |
| B1 Mis reportes | `GET /incidencias/mias` | — | Página de resúmenes |
| C2 / D2 / E4 Detalle | `GET /incidencias/{id}` | — | Detalle (el operativo recibe `ciudadano: null`) |
| Historial | `GET /incidencias/{id}/historial` | — | Lista cronológica |
| C2 Confirmar | `POST /incidencias/{id}/confirmacion` | — | Detalle en `CERRADA` |
| C3 Reabrir | `POST /incidencias/{id}/reapertura` | `{justificacion}` (10–500) | Detalle en `REABIERTA` · 409 si ya van 2 |
| D1 / D5 Asignadas | `GET /operativo/incidencias` | — | Página, prioridad alta primero |
| D2 Iniciar atención | `PATCH /incidencias/{id}/estado` | `{"estado": "EN_PROCESO"}` | Detalle |
| D3 Solución | `POST /evidencias/firma` (SOLUCION) → Cloudinary → `POST /incidencias/{id}/solucion` | `{descripcion, fotoUrl, latitud?, longitud?}` | Detalle en `RESUELTA` |
| E1 Panel | `GET /admin/indicadores` · `GET /admin/incidencias?prioridad=ALTA&estado=PENDIENTE` | — | Indicadores · prioritarias |
| E2 / E3 Incidencias | `GET /admin/incidencias?estado&tipoId&prioridad&q&lat&lng&radioKm` | — | Página; zona = círculo (HU-18) |
| E5 / E6 Asignar | `GET /operativos?activos=true` · `POST /incidencias/{id}/asignacion` | `{operativoId}` | Operativos con `cargaActual` · detalle |
| E8 Personal | `GET /operativos` · `PATCH /admin/operativos/{id}/estatus` | `{activo}` | Lista · operativo |
| E9 Alta operativo | `POST /admin/operativos` | `{nombre, apellidos, correo, passwordTemporal}` | Usuario creado |
| C1 / D6 / E7 Avisos | `GET /notificaciones` · `GET /notificaciones/no-leidas` · `PATCH /notificaciones/{id}/leida` · `PATCH /notificaciones/leidas` | — | Página (`incidenciaId` para abrir el detalle) · `{total}` |

La tabla completa y la forma de probar cada endpoint están en el README del back y en su colección de Postman.
