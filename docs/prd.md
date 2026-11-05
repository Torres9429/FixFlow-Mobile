# PRD — FixFlow v1

Guía interna del equipo para construir la primera versión. Resume **qué** se entrega y **cómo se acepta**. El detalle está en [requirements/](requirements/README.md): cada HU, RN y RNF se cita por su ID y no se repite aquí.

- **Entrega:** 1 de diciembre de 2026.
- **Equipo:** 5 personas, todas en mobile. El back está completo.
- **Éxito de la v1:** las 26 HU completas con todos sus criterios de aceptación y la [DoD](methodology/definition-of-done.md). No hay recorte posible.
- Lo marcado como **[SUPUESTO]** no lo ha confirmado el PO.

---

## 1. Problema y usuario

Hoy un bache, una luminaria apagada o una fuga se reportan sin evidencia confiable y sin ubicación exacta. Además, el ciudadano no sabe qué pasó con su reporte. Por su parte, el municipio no tiene cómo priorizar ni repartir el trabajo.

FixFlow es una app Android con la que el ciudadano reporta el problema con foto en vivo, GPS e inclinación. El municipio lo asigna, lo atiende y lo cierra, y cada paso queda en el historial.

| Usuario | Necesita | FixFlow le da |
| --- | --- | --- |
| **Ciudadano** | Reportar rápido y saber si se atendió | Reporte con evidencia que no se puede falsear, folio, estado, avisos, confirmar o reabrir |
| **Personal operativo** | Saber qué atender primero y dejar constancia | Solo sus asignadas, ordenadas por prioridad, y solución con foto. No ve datos personales del ciudadano (RNF-04) |
| **Administrador municipal** | Ver todo, priorizar y repartir | Todas las incidencias con prioridad automática y motivo, asignación según la carga de cada operativo, indicadores, personal y catálogo de tipos |

Los tres roles usan la misma app (RNF-07). La v1 se valida **solo con el equipo**, en sus propios teléfonos.

---

## 2. MVP

### Sí entra (las 26 HU)

| Módulo | Qué hace | HU |
| --- | --- | --- |
| Acceso | Registro de ciudadano, login por rol, sesión que se renueva sola (RNF-09), perfil y cambio de contraseña | 01, 02, 25 |
| Reporte | Tipo del catálogo, descripción, foto en vivo, GPS e inclinación válida según el tipo; folio `FX-AAAA-NNNNNN` (RN-08, RN-12) | 03–08 |
| Prioridad | Automática por tipo, escalamiento cada 7 días, Alta al reabrir; siempre con motivo (RN-13) | 09, 20 |
| Atención | Asignar y reasignar con la carga visible; el operativo inicia y registra la solución con foto | 14, 15, 16, 21 |
| Seguimiento | Mis reportes, estado, historial, bandeja de avisos, confirmar, reabrir (máx. 2) y cierre automático a 7 días | 10–13, 22, 23 |
| Administración | Vista municipal, filtros (estado, tipo, prioridad, zona), indicadores, personal operativo y catálogo de tipos | 17–19, 24, 26 |

### No entra

| Fuera de v1 (puede revisarse) | Descartado (no entra nunca) |
| --- | --- |
| Rechazar con comentario un reporte que no procede (candidato a v2) | Micrófono, voz o dictado |
| Push con Firebase con la app cerrada; v1 solo tiene bandeja interna (RNF-06) | Detección de duplicados por cercanía |
| iOS, versión web y metas de rendimiento | Votos de urgencia |
| Modo offline y borradores en el teléfono (RNF-08) | Fotos de galería como evidencia principal (RN-09) |
| Cambio manual de prioridad por el admin (RN-13) | Coordenadas escritas a mano (RN-10) |

---

## 3. Pantallas

Códigos del lienzo de diseño. Los endpoints de cada pantalla están en [contrato-api.md](architecture/contrato-api.md).

### Comunes

| Código | Pantalla | HU |
| --- | --- | --- |
| A1 | Inicio de sesión | 02 |
| A2 | Registro de ciudadano | 01 |
| A3 | Perfil | 25 |
| A3a | Editar mis datos | 25 |
| A3b | Cambiar contraseña | 25 |
| A3c | Confirmar cierre de sesión | 02 |
| A4 | Sin conexión, con reintento (RNF-08) | — |

### Ciudadano

| Código | Pantalla | HU |
| --- | --- | --- |
| B1 | Mis reportes, paginado y con filtros por estado | 10 |
| B2 | Nuevo reporte: tipo y descripción | 03 |
| B3 | Cámara en vivo, sin galería, con guía de inclinación | 04, 06 |
| B3b | Cámara: guía para ajustar el ángulo (fuera de rango) | 06, 08 |
| B3c | Cámara: tipo que apunta hacia arriba (luminaria) | 06 |
| B3d | Cámara: tipo sin restricción | 06, 08 |
| B4 | Revisar y enviar, con minimapa | 03, 05, 07, 08 |
| B5 | Reporte enviado, con folio | 03 |
| B6 | Sin permiso de cámara | 04 |
| B7 | Ubicación no disponible | 05 |
| C1 | Avisos, con badge de no leídas | 12 |
| C2 | Detalle de mi reporte: estado, historial, evidencia de la solución y confirmar | 11, 13, 22 |
| C3 | Reabrir con justificación | 23 |
| C4 | Mis reportes vacío | 10 |

### Personal operativo

| Código | Pantalla | HU |
| --- | --- | --- |
| D1 | Incidencias asignadas, prioridad alta primero | 14 |
| D2 | Detalle con solo las acciones válidas e iniciar atención | 14, 15 |
| D3 | Registrar solución con foto y descripción | 16 |
| D4 | Motivo de la reapertura | 23 |
| D5 | Mapa de asignadas | 14 |
| D6 | Avisos | 21 |

### Administrador

| Código | Pantalla | HU |
| --- | --- | --- |
| E1 | Panel: indicadores y prioritarias | 19, 20 |
| E2 | Incidencias del municipio con buscador y filtros | 17, 18 |
| E3 | Filtro por zona (círculo de lat, lng, radio en km) | 18 |
| E4 | Detalle con historial | 17, 22 |
| E5 | Asignar, con la carga de cada operativo | 21 |
| E6 | Reasignar | 21 |
| E7 | Avisos | 23 |
| E8 | Personal operativo: lista, activar y desactivar | 24 |
| E9 | Alta de operativo con contraseña temporal | 24 |
| E10 | Catálogo de tipos | 26 |
| E11 | Nuevo tipo | 26 |
| E12 | Editar tipo | 26 |

### Definición de las pantallas nuevas (HU-26)

Usan `GET`, `POST`, `PUT` y `PATCH` en `/admin/tipos-incidencia` (ya están en el back).

**E10 — Catálogo de tipos**

- Entrada: botón «Catálogo de tipos» en el Panel (E1). No agrega una pestaña a la barra del admin. [SUPUESTO]
- Lista **todos** los tipos, activos e inactivos. Cada fila muestra el nombre, el código, la orientación, la prioridad base, cuántas incidencias lo usan y un switch Activo.
- Al desactivar un tipo se pide confirmación con el aviso «Ya no aparecerá en reportes nuevos; las incidencias existentes lo conservan». [SUPUESTO: el diálogo]
- Tocar una fila abre E12 (Editar tipo). El botón «+» abre E11 (Nuevo tipo).

**E11 — Nuevo tipo · E12 — Editar tipo**

| Campo | Alta | Edición | Regla |
| --- | --- | --- | --- |
| Nombre | Obligatorio | Editable | Hasta 80 caracteres |
| Código | Opcional; si se deja vacío se genera del nombre | Solo lectura | 2–30 caracteres: mayúsculas, números y `_` (RN-07) |
| Orientación | Obligatoria | Editable | Hacia el suelo · Hacia arriba · Sin restricción (RN-11) |
| Prioridad base | Obligatoria | Editable | Alta · Media · Baja (RN-13) |

- Si el back responde `409` (código repetido), el aviso se muestra debajo del campo Código.
- Al guardar se regresa a E10 con la lista actualizada.

---

## 4. Datos

El modelo vive en el back (MySQL). La app no guarda nada en el teléfono salvo la sesión, que va en `flutter_secure_storage` (RNF-08, RNF-09).

| Entidad | Campos clave | Notas |
| --- | --- | --- |
| Usuario | nombre, apellidos, correo (único), password (BCrypt), rol, estatus (activo) | Roles: `CIUDADANO`, `OPERATIVO`, `ADMIN` (RN-05) |
| TipoIncidencia | codigo (fijo), nombre, orientacion, prioridadBase, estatus | Catálogo editable (RN-07). `anguloMin` y `anguloMax` los calcula el server (RN-11) |
| Incidencia | folio, ciudadano, tipo, operativo, descripcion (≤ 500), latitud, longitud, estado, prioridad, motivoPrioridad, numReaperturas, fechaCreacion, fechaResolucion | Estados y transiciones en RN-14 |
| Evidencia | incidencia, subidaPor, tipo (`REPORTE` o `SOLUCION`), url de Cloudinary, latitud, longitud, inclinacion, fechaCaptura | Una por reporte y una por cada solución (RNF-05) |
| HistorialIncidencia | incidencia, usuario (o sistema), accion, estado anterior y nuevo, prioridad anterior y nueva, operativo, evidencia, comentario, fecha | Acciones: creada, asignación, reasignación, cambio de estado, solución, reapertura, cambio de prioridad (RN-15) |
| Notificacion | usuario, historial, titulo, mensaje, leida, fecha | Bandeja interna, sin duplicados (RN-18) |
| RefreshToken | token, usuario, expiracion, revocado | 7 días; se revoca al cerrar sesión o desactivar la cuenta |

**Quién ve qué (RNF-04):**

- El ciudadano ve solo sus reportes.
- El operativo ve solo sus asignadas, sin datos del ciudadano (`ciudadano: null`).
- El admin ve todo.
- No hay vista pública.

**Fotos:** JPEG de 1600 px y calidad 80. Se suben firmadas desde la app directo a Cloudinary y el back solo guarda la URL (RNF-05).

---

## 5. Criterios de aceptación por flujo

Cada flujo se acepta probándolo en teléfonos reales contra el back. Además, cada HU que toca debe cumplir sus propios criterios y la DoD.

### F1 — Entrar y mantener la sesión · HU-01, 02, 25

- [ ] Un ciudadano se registra en A2 y, tras el aviso «Cuenta creada», entra en A1 con esas credenciales.
- [ ] Cada rol llega a su propio home y no ve opciones de otro rol.
- [ ] Una cuenta inactiva no puede entrar.
- [ ] Al vencer el token de 15 minutos, la app lo renueva sin que el usuario lo note. Si el refresh también vence, la app regresa a A1.
- [ ] Al cerrar sesión (A3c), el refresh token queda revocado.
- [ ] En A3a y A3b el usuario edita su nombre y apellidos y cambia su contraseña (RN-02).

### F2 — Reportar con evidencia válida · HU-03 a 09

- [ ] En B2 solo aparecen los tipos activos. La descripción es obligatoria (máximo 500 caracteres).
- [ ] B3 no ofrece la galería. El botón de captura solo se activa con la inclinación dentro del rango del tipo.
- [ ] Sin permiso de cámara se muestra B6. Sin GPS se muestra B7. En ninguno de los dos casos se puede enviar el reporte (RNF-03).
- [ ] B4 muestra la foto, el minimapa con las coordenadas de la captura y los datos, todo antes de enviar.
- [ ] Al enviar, B5 muestra el folio. El back guarda la prioridad base con su motivo y la primera entrada del historial.
- [ ] Si el back responde `422`, la app manda a repetir la captura (B3b).
- [ ] Si se pierde la conexión al enviar, se muestra A4 y el reintento conserva la foto y los datos mientras la app siga abierta.

### F3 — Priorizar y asignar · HU-17, 18, 20, 21, 24

- [ ] El admin da de alta a un operativo en E9 con una contraseña temporal. El operativo aparece en E8 y puede entrar.
- [ ] Al desactivar a un operativo, este pierde la sesión en su siguiente petición.
- [ ] E1 lista las prioritarias (Alta y Pendiente) con su motivo.
- [ ] E2 filtra por estado, tipo y prioridad. E3 filtra por zona.
- [ ] En E5 el admin ve la carga actual de cada operativo activo y asigna. La incidencia pasa a ASIGNADA.
- [ ] Al asignar, tanto el operativo (D6) como el ciudadano (C1) reciben aviso.
- [ ] En E6 el admin reasigna. Cambia el responsable, no el estado, y solo el operativo nuevo recibe aviso.

### F4 — Atender · HU-14, 15, 16

- [ ] D1 muestra solo las asignadas al operativo, con la prioridad alta primero. D5 las muestra en el mapa.
- [ ] D2 ofrece solo las acciones válidas para el estado (RN-14).
- [ ] D2 nunca muestra datos del ciudadano.
- [ ] «Iniciar atención» pasa la incidencia a EN_PROCESO y el ciudadano recibe aviso.
- [ ] En D3 el operativo registra la solución con foto en vivo y descripción. La incidencia pasa a RESUELTA.

### F5 — Cerrar o reabrir · HU-10 a 13, 22, 23

- [ ] B1 lista solo los reportes del ciudadano. Si no tiene ninguno, se muestra C4.
- [ ] B1 filtra por estado. Para eso, el back tiene que aceptar `estado` en `GET /incidencias/mias`, que todavía está pendiente ([contrato-api](architecture/contrato-api.md#cambios-pendientes-en-el-back)).
- [ ] Tocar un aviso de C1 abre el detalle de la incidencia. El badge baja al marcarlo como leído.
- [ ] C2 muestra el estado, el historial cronológico y la evidencia de la solución. Ahí el ciudadano puede confirmar, y la incidencia pasa a CERRADA.
- [ ] En C3 el ciudadano reabre con una justificación de 10 a 500 caracteres. La incidencia pasa a REABIERTA con prioridad Alta, y el admin (E7) y el operativo (D4) reciben aviso.
- [ ] Una tercera reapertura se rechaza con un mensaje.
- [ ] Al correr el job (`POST /admin/jobs/ejecutar?dias=0`), una RESUELTA sin respuesta del ciudadano se cierra. El historial lo registra como acción del sistema.
- [ ] En el mismo job, una incidencia sin resolver sube un nivel de prioridad con su motivo.

### F6 — Administrar el catálogo · HU-26

- [ ] E10 lista los tipos activos e inactivos con cuántas incidencias usa cada uno.
- [ ] Al crear un tipo sin código, el código se genera del nombre. Un código repetido muestra el error.
- [ ] Al editar, el código no cambia.
- [ ] Un tipo desactivado desaparece de B2, pero las incidencias que ya tiene conservan su tipo.

### F7 — Indicadores · HU-19

- [ ] E1 muestra el total registrado, las pendientes, las que están en atención y las atendidas, el conteo por prioridad y el tiempo de resolución promedio y máximo en horas.
- [ ] Los indicadores cambian después de crear, asignar o resolver una incidencia y volver a abrir E1.

### Recorrido de aceptación final

Un ciudadano reporta un bache. El admin lo asigna, el operativo lo resuelve con foto y el ciudadano lo reabre una vez. El operativo lo resuelve de nuevo y el ciudadano lo confirma. Todo con los 3 roles en 3 teléfonos distintos y sin tocar Postman, salvo para correr el job.

---

## 6. Riesgos

Fotografía al 3 de noviembre de 2026.

| Riesgo | Impacto | Mitigación |
| --- | --- | --- |
| **Calendario.** El sprint 2 va una semana atrasado y cierra esta semana [SUPUESTO: 6 nov]. Quedan unas 3 semanas para 18 HU (09 a 26) y 27 pantallas, sin recorte | Alto | Desde el 9 de noviembre, 5 líneas en paralelo, una por persona: seguimiento del ciudadano, operativo, asignación y personal, panel y catálogo, y sesión y avisos. Primero los widgets compartidos (`EstadoBadge`, `IncidenciaCard`, `MiniMapa`). Congelar el código el miércoles 25 de noviembre [SUPUESTO] |
| **Dependencias en cadena.** HU-21 → 14 → 15 → 16 → 13 → 23: si una se atora, frena a las demás | Alto | Mientras tanto, cada línea trabaja en modo mock con fakes. Integrar contra el back apenas exista la pieza anterior |
| **Sesión pendiente en mobile.** Faltan el refresh en el interceptor, `refreshToken` y el logout que revoca ([contrato-api](architecture/contrato-api.md#cambios-pendientes-en-el-código-de-mobile)) | Alto | Hacerlo antes que nada, porque lo usan todas las pantallas |
| **5 personas en un repo, aprendiendo Flutter.** Habrá conflictos en `router.dart`, en la inyección de dependencias y en el theme | Medio | Una persona dueña de los archivos compartidos. PRs pequeños y diarios. Seguir la [guía de arquitectura](architecture/arquitectura-mobile.md) |
| **Sensores distintos entre teléfonos.** El signo del eje Z o un GPS lento bajo techo | Medio | Los umbrales viven en el server (RN-11). Probar en todos los teléfonos del equipo |
| **Red en desarrollo.** Back en la laptop: cambia la IP, el firewall bloquea el 8080 o la Wi-Fi de la escuela aísla los equipos [SUPUESTO] | Medio | `config/dev.json` por persona. Usar el hotspot de un teléfono como plan B |
| **Despliegue en AWS sin decidir.** Contenedores, MySQL y costo | Medio | Decidir antes del 17 de noviembre [SUPUESTO]. Si no está listo, la demo corre en la laptop, que es suficiente para el criterio de éxito |
| **Procesos de 7 días que no se pueden esperar** | Bajo | Usar `POST /admin/jobs/ejecutar?dias=0`. Antes de la demo, cargar datos en todos los estados |
| **Llaves de Cloudinary** en el `.env` de cada laptop | Bajo | El `.env` está en el `.gitignore`. La llave secreta nunca va en `config/*.json` |
| **Validación solo con el equipo.** No hay mirada externa sobre la usabilidad | Bajo | Cada flujo lo prueba alguien que no lo programó |

---

## Supuestos para confirmar

- El sprint 2 cierra el 6 de noviembre y el código se congela el miércoles 25 de noviembre.
- E10 se abre desde el Panel, sin pestaña propia, y desactivar un tipo pide confirmación.
- La decisión sobre AWS se toma antes del 17 de noviembre. Si no hay despliegue, la demo se hace con la laptop.
- La Wi-Fi de la escuela puede aislar los dispositivos.
