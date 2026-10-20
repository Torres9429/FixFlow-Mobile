# Contrato de API — FixFlow

Cómo habla la app con el back (`FixFlow-Backend`). Úsalo al conectar cada pantalla: dice qué endpoint llamar, qué mandar y qué llega. Las reglas de negocio citadas están en [business-rules.md](../requirements/business-rules/business-rules.md).

## Acuerdos

| Tema | Acuerdo |
| --- | --- |
| URL base | `http://10.0.2.2:8080/api` en el emulador de Android; `http://<IP de la PC>:8080/api` en un celular físico. Todas las rutas cuelgan de `/api` |
| Formato | Todas las respuestas vienen envueltas en `{ "text": "...", "type": "SUCCESS" \| "WARNING" \| "ERROR", "result": ... }`. Los datos están en `result`; en un error, `text` es el mensaje para mostrar |
| Códigos | `200`/`201` éxito · `400` dato inválido · `401` sin sesión o credenciales malas · `403` el rol no puede · `404` no existe · `409` conflicto (correo duplicado, transición de estado inválida) · `422` evidencia inválida (RN-12) · `503` Cloudinary no configurado. **Todos los errores vienen en `Message`**, incluidos los 401 y 403 de la capa de seguridad; la app decide qué hacer por el **código HTTP** y muestra `text` |
| Sesión (RNF-09) | Toda petición que no sea pública manda `Authorization: Bearer <jwt>`. El `jwt` dura **15 minutos** y el `refreshToken`, **7 días**; la app guarda los dos en `flutter_secure_storage`. Son públicos solo `/auth/login`, `/auth/refresh`, `/auth/logout` y `/usuarios/registro` |
| Renovar la sesión | Si una petición responde **401**, la app llama a `POST /auth/refresh` con el `refreshToken`, guarda el `jwt` y el `refreshToken` nuevos y repite la petición. Si el refresh también responde 401 (venció, se revocó o la cuenta se desactivó), borra la sesión y manda al login (A1). Cada refresh token sirve **una sola vez** |
| Paginación | `?page=0&size=20` (máximo 50). `result` = `{ "content": [...], "page": { "size", "number", "totalElements", "totalPages" } }` |
| Fechas | ISO-8601 en UTC (`2026-10-19T06:07:54.530Z`) |
| Estados | `PENDIENTE`, `ASIGNADA`, `EN_PROCESO`, `RESUELTA`, `REABIERTA`, `CERRADA` (RN-14). Prioridades: `ALTA`, `MEDIA`, `BAJA` |

### Cambios pendientes en el código de mobile

Se corrigen al integrar cada pantalla con el back:

- **Login (HU-02):** `LoginResponseModel.fromJson` debe leer `json['result']`, con los campos `jwt`, `refreshToken`, `userId`, `nombre` y `role` (hoy lee `token`, `rol` y `nombre` en la raíz). `SessionStorage` debe guardar también el `refreshToken`.
- **Registro (HU-01):** el datasource llama a `/auth/registro`; la ruta correcta es **`/usuarios/registro`**. `RegistroResponseModel` espera `{token, rol, nombre}` en la raíz, pero el back responde el usuario creado dentro de `result` y **sin token**: después de registrarse, el usuario va al login (A1 con el aviso «Cuenta creada»).
- **Sesión:** el interceptor de `ApiClient` agrega `Authorization: Bearer <jwt>` (ya lo hace con `token`) y, ante un 401, intenta `POST /auth/refresh` una vez antes de mandar al login.
- **Cerrar sesión (A3c):** llamar a `POST /auth/logout` con el `refreshToken` y después borrar la sesión local.

## Fotos (RNF-05)

1. `POST /evidencias/firma` con `{"tipo": "REPORTE"}` (ciudadano) o `{"tipo": "SOLUCION"}` (operativo) → `{cloudName, apiKey, timestamp, folder, signature}`.
2. Subir la foto (JPEG 1600 px, calidad 80) con `dio` y `FormData` a `https://api.cloudinary.com/v1_1/<cloudName>/image/upload` con los campos `file`, `api_key`, `timestamp`, `folder` y `signature`.
3. De la respuesta de Cloudinary tomar `secure_url` y mandarla como `fotoUrl`.

## Endpoints por pantalla

| Pantalla | Método y ruta | Body | `result` |
| --- | --- | --- | --- |
| A1 Login | `POST /auth/login` | `{correo, password}` | `{jwt, refreshToken, userId, username, nombre, role, expiration}` · 401 credenciales malas o cuenta inactiva |
| A2 Registro | `POST /usuarios/registro` | `{nombre, apellidos, correo, password}` | Usuario creado · 409 correo existe |
| Inicio de la app | `GET /usuarios/me` | — | `{id, nombre, apellidos, correo, rol, activo}` · 401 → refresh o login |
| Renovar sesión (interceptor) | `POST /auth/refresh` | `{refreshToken}` | Igual que el login · 401 → login |
| A3c Cerrar sesión | `POST /auth/logout` | `{refreshToken}` | Mensaje |
| A3 Perfil · A3a Editar datos · A3b Contraseña (HU-25) | `PUT /usuarios/me` · `PATCH /usuarios/me/password` | `{nombre, apellidos}` · `{actual, nueva}` | Usuario · mensaje |
| Catálogo de tipos (HU-26, sin pantalla aún) | `GET /admin/tipos-incidencia` · `POST /admin/tipos-incidencia` · `PUT /admin/tipos-incidencia/{id}` · `PATCH /admin/tipos-incidencia/{id}/estatus` | `{codigo?, nombre, orientacion, prioridadBase}` (`codigo` opcional al crear, se genera del nombre; se ignora en el PUT) · `{activo}` | Tipo, con `incidencias`: cuántas lo usan (E12) |
| B2 Nuevo reporte / B3 Cámara | `GET /tipos-incidencia` | — | `[{id, codigo, nombre, orientacion, prioridadBase, anguloMin, anguloMax}]`. La cámara pinta la zona verde y activa el botón cuando la inclinación queda entre `anguloMin` y `anguloMax` (RN-11); son los mismos valores con los que el servidor valida |
| B3/B4 Enviar | `POST /evidencias/firma` → Cloudinary → `POST /incidencias` | `{tipoId, descripcion, latitud, longitud, inclinacion, fotoUrl}` | Detalle con `folio` (B5) · 422 → repetir captura (B3b, B7) |
| B1 Mis reportes | `GET /incidencias/mias` | — | Página de resúmenes `{id, folio, tipo, tipoCodigo, estado, prioridad, motivoPrioridad, latitud, longitud, operativo, fechaCreacion, ultimaActualizacion, fotoUrl}`; `fotoUrl` es la miniatura de la foto del reporte |
| C2 / D2 / E4 Detalle | `GET /incidencias/{id}` | — | Detalle (el operativo recibe `ciudadano: null`) |
| Historial | `GET /incidencias/{id}/historial` | — | Lista cronológica |
| C2 Confirmar | `POST /incidencias/{id}/confirmacion` | — | Detalle en `CERRADA` |
| C3 Reabrir | `POST /incidencias/{id}/reapertura` | `{justificacion}` (10–500) | Detalle en `REABIERTA` · 409 si ya van 2 |
| D1 / D5 Asignadas | `GET /operativo/incidencias` | — | Página de resúmenes (con `fotoUrl` para la miniatura), prioridad alta primero. La distancia la calcula la app con su GPS y `latitud`/`longitud` |
| D2 Iniciar atención | `PATCH /incidencias/{id}/estado` | `{"estado": "EN_PROCESO"}` | Detalle |
| D3 Solución | `POST /evidencias/firma` (SOLUCION) → Cloudinary → `POST /incidencias/{id}/solucion` | `{descripcion, fotoUrl, latitud?, longitud?}` | Detalle en `RESUELTA` |
| E1 Panel | `GET /admin/indicadores` · `GET /admin/incidencias?prioridad=ALTA&estado=PENDIENTE` | — | Indicadores · prioritarias |
| E2 / E3 Incidencias | `GET /admin/incidencias?estado&tipoId&prioridad&q&lat&lng&radioKm` | — | Página de resúmenes (con `fotoUrl`); zona = círculo (HU-18) |
| E5 / E6 Asignar | `GET /operativos?activos=true` · `POST /incidencias/{id}/asignacion` | `{operativoId}` | Operativos con `cargaActual` · detalle |
| E8 Personal | `GET /operativos` · `PATCH /admin/operativos/{id}/estatus` | `{activo}` | Lista · operativo |
| E9 Alta operativo | `POST /admin/operativos` | `{nombre, apellidos, correo, passwordTemporal}` | Usuario creado |
| C1 / D6 / E7 Avisos | `GET /notificaciones` · `GET /notificaciones/no-leidas` · `PATCH /notificaciones/{id}/leida` · `PATCH /notificaciones/leidas` | — | Página (`incidenciaId` para abrir el detalle) · `{total}` |

La tabla completa y la forma de probar cada endpoint están en el README del back y en su colección de Postman.
