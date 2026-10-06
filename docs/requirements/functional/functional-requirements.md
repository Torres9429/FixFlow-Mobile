# Requisitos funcionales — FixFlow

Catálogo de capacidades que el sistema debe ofrecer, con trazabilidad a la HU que las origina.

- Este archivo **no repite criterios de aceptación**: el detalle verificable de cada requisito está en la HU de origen.
- Las políticas que condicionan un requisito están en [business-rules.md](../business-rules/business-rules.md).
- Un RF nuevo debe originarse en una HU existente o en una nueva HU aprobada por el Product Owner.

## Autenticación y usuarios

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-01 | Registro de cuentas de ciudadano. | HU-01 | RN-01, RN-02, RN-03, RN-04 |
| RF-02 | Autenticación de usuarios mediante credenciales. | HU-02 | — |
| RF-03 | Presentación de funcionalidades según el rol del usuario. | HU-02 | RN-05 |

## Reportes e incidencias

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-04 | Creación de reportes de incidencia con tipo, descripción, evidencia, ubicación, revisión previa al envío e identificador único. | HU-03 | RN-07, RN-08, RN-12 |

## Captura y sensores

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-05 | Captura de fotografía en vivo con la cámara del dispositivo. | HU-04 | RN-09 |
| RF-06 | Obtención automática de la ubicación GPS durante la captura. | HU-05 | RN-10 |
| RF-07 | Lectura del acelerómetro durante la captura y validación de la orientación según el tipo de incidencia. | HU-06 | RN-11 |
| RF-08 | Vinculación de la evidencia con las coordenadas obtenidas en la captura. | HU-07 | RN-10 |
| RF-09 | Validación de la evidencia completa antes de permitir el envío. | HU-08 | RN-12 |

## Priorización

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-10 | Clasificación automática de la prioridad de las incidencias. | HU-09 | RN-13, RN-15 |

## Seguimiento ciudadano

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-11 | Consulta del listado y detalle de los reportes propios. | HU-10 | RN-06 |
| RF-12 | Consulta del estado actual de una incidencia y de sus cambios. | HU-11 | RN-14, RN-15 |
| RF-13 | Envío de notificaciones al ciudadano por cambio de estado. | HU-12 | RN-18 |
| RF-14 | Revisión de la evidencia de solución y confirmación por parte del ciudadano. | HU-13 | RN-14 |
| RF-15 | Reapertura de incidencias no resueltas. | HU-23 | RN-14, RN-15, RN-17 |

## Atención operativa

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-16 | Consulta de las incidencias asignadas al personal operativo. | HU-14 | RN-13 |
| RF-17 | Actualización del estado de una incidencia. | HU-15 | RN-14, RN-15 |
| RF-18 | Registro de la solución aplicada, con descripción y evidencia fotográfica. | HU-16 | RN-14, RN-15 |

## Administración municipal

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-19 | Visualización de las incidencias registradas en el municipio, con ubicación, estado y prioridad. | HU-17 | — |
| RF-20 | Filtrado de incidencias por estado, tipo, prioridad y zona. | HU-18 | RN-07, RN-13, RN-14 |
| RF-21 | Consulta de indicadores de atención. | HU-19 | — |
| RF-22 | Consulta de incidencias prioritarias y del motivo de su prioridad. | HU-20 | RN-13 |
| RF-23 | Asignación y reasignación de incidencias a personal operativo. | HU-21 | RN-15, RN-16 |
| RF-24 | Notificación al personal operativo de nuevas asignaciones. | HU-21 | RN-18 |

## Historial y trazabilidad

| ID | Requisito | Origen | Reglas |
| --- | --- | --- | --- |
| RF-25 | Registro y consulta cronológica del historial de una incidencia. | HU-22 | RN-15 |
