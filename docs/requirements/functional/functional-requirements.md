# Requisitos funcionales — FixFlow

Catálogo de capacidades que el sistema debe ofrecer, con trazabilidad a la HU que las origina.

- Este archivo **no repite criterios de aceptación**: el detalle verificable de cada requisito está en la HU de origen.
- Las políticas que condicionan un requisito están en [business-rules.md](../business-rules/business-rules.md).
- Un RF nuevo debe originarse en una HU existente o en una nueva HU aprobada por el Product Owner.

## Autenticación y usuarios

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-01 | Registro de cuentas de ciudadano. | HU-01 | RN-01, RN-02, RN-03, RN-04 |
| RF-02 | Autenticación de usuarios mediante credenciales y cierre de sesión. Las cuentas inactivas no pueden iniciar sesión. | HU-02 | RN-05, RN-19 |
| RF-03 | Presentación de funcionalidades según el rol del usuario. | HU-02 | RN-05 |
| RF-26 | Alta, consulta, desactivación y reactivación de cuentas del personal operativo. | HU-24 | RN-01, RN-02, RN-05, RN-16, RN-19 |
| RF-27 | Consulta y edición de los datos propios y cambio de contraseña. | HU-25 | RN-02, RN-03, RN-19 |

## Reportes e incidencias

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-04 | Creación de reportes de incidencia con tipo, descripción, evidencia, ubicación, revisión previa al envío e identificador único. | HU-03 | RN-07, RN-08, RN-12 |

## Captura y sensores

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-05 | Captura de fotografía en vivo con la cámara del dispositivo. | HU-04 | RN-09 |
| RF-06 | Obtención automática de la ubicación GPS durante la captura. | HU-05 | RN-10, RN-12 |
| RF-07 | Lectura del acelerómetro durante la captura y validación de la orientación según el tipo de incidencia. | HU-06 | RN-07, RN-11 |
| RF-08 | Vinculación de la evidencia con las coordenadas obtenidas en la captura. | HU-07 | RN-10 |
| RF-09 | Validación de la evidencia completa antes de permitir el envío. | HU-08 | RN-09, RN-10, RN-11, RN-12 |

## Priorización

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-10 | Clasificación automática de la prioridad de las incidencias, incluido el escalamiento diario por antigüedad. | HU-09 | RN-07, RN-13, RN-15 |

## Seguimiento ciudadano

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-11 | Consulta del listado y detalle de los reportes propios. | HU-10 | RN-06, RN-14 |
| RF-12 | Consulta del estado actual de una incidencia y de sus cambios. | HU-11 | RN-14, RN-15 |
| RF-13 | Envío de notificaciones al ciudadano por cambio de estado. | HU-12 | RN-18 |
| RF-14 | Revisión de la evidencia de solución y confirmación por parte del ciudadano. | HU-13 | RN-14, RN-17 |
| RF-29 | Cierre automático de las incidencias resueltas que el ciudadano no confirma ni reabre en el plazo establecido. | HU-13 | RN-14, RN-15, RN-18 |
| RF-15 | Reapertura de incidencias no resueltas. | HU-23 | RN-14, RN-15, RN-17 |
| RF-30 | Notificación al administrador y al personal operativo asignado cuando se reabre una incidencia. | HU-23 | RN-17, RN-18 |

## Atención operativa

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-16 | Consulta de las incidencias asignadas al personal operativo. | HU-14 | RN-13, RN-16 |
| RF-17 | Actualización del estado de una incidencia. | HU-15 | RN-14, RN-15 |
| RF-18 | Registro de la solución aplicada, con descripción y evidencia fotográfica. | HU-16 | RN-14, RN-15 |

## Administración municipal

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-19 | Visualización de las incidencias registradas en el municipio, con ubicación, estado y prioridad. | HU-17 | RN-05, RN-13, RN-14 |
| RF-20 | Filtrado de incidencias por estado, tipo, prioridad y zona. | HU-18 | RN-07, RN-13, RN-14 |
| RF-21 | Consulta de indicadores de atención. | HU-19 | RN-13, RN-14, RN-15 |
| RF-22 | Consulta de incidencias prioritarias y del motivo de su prioridad. | HU-20 | RN-13 |
| RF-23 | Asignación y reasignación de incidencias a personal operativo. | HU-21 | RN-14, RN-15, RN-16 |
| RF-24 | Notificación al personal operativo de nuevas asignaciones. | HU-21 | RN-18 |
| RF-28 | Alta, edición, desactivación y reactivación de los tipos de incidencia del catálogo. | HU-26 | RN-05, RN-07, RN-11, RN-13 |

## Historial y trazabilidad

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-25 | Registro y consulta cronológica del historial de una incidencia. | HU-22 | RN-15 |
