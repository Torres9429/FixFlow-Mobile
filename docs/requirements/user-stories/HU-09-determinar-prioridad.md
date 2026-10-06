---
id: HU-09
titulo: Determinar prioridad de una incidencia
modulo: Priorización
actor: Administrador municipal
---

# HU-09 — Determinar prioridad de una incidencia

## Historia

**Como** administrador municipal
**Quiero** que las incidencias sean clasificadas de acuerdo con criterios de prioridad
**Para** identificar los problemas que requieren mayor atención.

## Criterios de aceptación

- [ ] Deben existir reglas previamente definidas para determinar los niveles de prioridad.
- [ ] La prioridad debe considerar las características y tipo de incidencia.
- [ ] Cuando una incidencia cumpla las condiciones establecidas para una prioridad determinada, el sistema debe asignarla automáticamente.
- [ ] Una incidencia clasificada como **Prioridad Alta** debe ser identificable visualmente en el panel administrativo.
- [ ] El cambio de prioridad debe quedar registrado en el historial de la incidencia.

## Dependencias

- **Depende de:** HU-03.
- **Relacionada con:** HU-14, HU-17 (panel administrativo), HU-20, HU-22 (historial).

## Notas funcionales

- La *prioridad* de esta HU es un atributo de la incidencia; no tiene relación con la prioridad de tablero en GitHub Projects.
- Reglas de negocio: RN-07 *(pendiente)*, RN-13 *(pendiente)*, RN-15.
- Requisitos funcionales: RF-10.
