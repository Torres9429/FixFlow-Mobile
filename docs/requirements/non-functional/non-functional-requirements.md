# Requisitos no funcionales — FixFlow

Restricciones técnicas y atributos de calidad que aplican de forma transversal. Solo se registran como *Vigentes* los requisitos establecidos explícitamente para el proyecto; el resto se lista como pendiente, sin valores inventados.

## Vigentes

### RNF-01 — Sensores permitidos

**Tipo:** Restricción técnica

La aplicación móvil utiliza únicamente estos sensores del dispositivo:

- GPS
- Cámara
- Acelerómetro

No se utiliza el micrófono ni ninguna funcionalidad de voz (reconocimiento, dictado, comandos o notas de voz).

### RNF-02 — Requisitos del dispositivo

**Tipo:** Compatibilidad · **Relacionado con:** HU-04, HU-05, HU-06

Para registrar reportes, el dispositivo del ciudadano debe contar con cámara, GPS y acelerómetro.

### RNF-03 — Gestión de permisos del sistema operativo

**Tipo:** Usabilidad / Privacidad · **Relacionado con:** HU-04, HU-05

Toda funcionalidad que requiera un permiso del sistema operativo (cámara, ubicación) debe solicitarlo antes de usarlo y, si se rechaza, informar al usuario sin permitir que se envíe un reporte incompleto.

### RNF-04 — Privacidad: quién ve qué

**Tipo:** Privacidad · **Relacionado con:** HU-10, HU-14, HU-17, HU-22

| Rol | Ve |
| --- | --- |
| Ciudadano | Solo sus reportes (RN-06), con foto, ubicación, estado, historial y evidencia de la solución |
| Personal operativo | Solo las incidencias asignadas a él, con foto, ubicación y descripción; **no ve los datos personales** del ciudadano (en el historial aparece como «Ciudadano») |
| Administrador municipal | Todas las incidencias, con el nombre del ciudadano y del operativo |

No hay vista pública ni anónima.

### RNF-05 — Almacenamiento de la evidencia fotográfica

**Tipo:** Restricción técnica · **Relacionado con:** HU-04, HU-16

- **Formato:** JPEG, lado mayor de 1600 px, calidad 80 (≈ 300–500 KB por foto). La app comprime antes de subir.
- **Cantidad:** 1 foto principal por reporte (HU-04) y 1 foto por cada solución registrada (HU-16).
- **Almacenamiento:** servicio externo de imágenes (Cloudinary) con **subida firmada desde la app**: la app pide una firma al servidor, sube la foto directo a Cloudinary y envía la URL resultante. La llave secreta solo vive en el servidor; nunca en la app.
- El servidor rechaza URLs que no pertenezcan a la cuenta propia de Cloudinary.

### RNF-06 — Canal de notificaciones

**Tipo:** Usabilidad · **Relacionado con:** HU-12, HU-21, HU-23

- **Bandeja dentro de la app** con badge de no leídas; tocar una notificación abre la incidencia (HU-12). Las notificaciones se guardan en el servidor y no se duplican (RN-18).
- La app consulta la bandeja al abrirla y al entrar a la pantalla de avisos. **No hay consultas periódicas** (polling).
- **Push con Firebase Cloud Messaging:** canal definido para avisar con la app cerrada; se integra en un sprint posterior. Mientras tanto aplica solo la bandeja.

### RNF-07 — Plataforma

**Tipo:** Compatibilidad · **Relacionado con:** todas las HU

- La app se distribuye **solo para Android 8.0 (API 26) o superior**.
- Los tres roles, incluido el administrador municipal (HU-17 a HU-21 y HU-24), usan la misma app móvil. No hay versión web ni iOS.

### RNF-08 — Conectividad

**Tipo:** Disponibilidad · **Relacionado con:** HU-03, HU-04, HU-16

- **No hay modo offline.** Si no hay conexión al llamar al servidor, la app muestra el aviso de sin conexión y permite reintentar.
- Un reporte que no se pudo enviar se **conserva en memoria** (foto, ubicación, inclinación y datos) para reintentar mientras la app siga abierta.
- **No se guardan borradores en el teléfono:** una foto vieja reenviada más tarde rompería la idea de evidencia actual (RN-09).

### RNF-09 — Seguridad de credenciales y sesión

**Tipo:** Seguridad · **Relacionado con:** HU-01, HU-02, HU-24

- Las contraseñas se guardan con **BCrypt**; nunca en texto plano ni en las respuestas de la API.
- El inicio de sesión entrega un **access token JWT de 15 minutos** (con id, correo y rol) y un **refresh token de 7 días**.
- Cuando el access token vence, la app pide uno nuevo con el refresh token sin que el usuario lo note. Si el refresh token venció o se revocó, la app regresa al inicio de sesión.
- Cerrar sesión revoca el refresh token en el servidor. Desactivar una cuenta (HU-24) también revoca sus refresh tokens.
- Los tokens se guardan en el almacenamiento seguro del teléfono (`flutter_secure_storage`).
- Mientras no exista esta capa, el servidor identifica al usuario con un header temporal (ver el contrato de API).

