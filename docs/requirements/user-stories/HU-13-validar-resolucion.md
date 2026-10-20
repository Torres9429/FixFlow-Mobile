---
id: HU-13
titulo: Validar resolución
modulo: Seguimiento ciudadano
actor: Ciudadano
---

# HU-13 — Validar resolución

## Historia

**Como** ciudadano
**Quiero** revisar la evidencia de la solución realizada
**Para** confirmar que la incidencia fue atendida.

## Criterios de aceptación

- [ ] El ciudadano debe poder consultar la evidencia proporcionada por el personal operativo.
- [ ] Debe visualizar el estado final de la incidencia.
- [ ] Debe existir una opción para confirmar que la solución fue recibida.
- [ ] Si el ciudadano considera que el problema continúa, debe poder indicarlo mediante el mecanismo definido por el sistema.

## Dependencias

- **Depende de:** HU-10, HU-16.
- **Relacionada con:** HU-23 (mecanismo para indicar que el problema continúa).

## Notas funcionales

- Al validar, la incidencia está en `RESUELTA`. Confirmar la lleva a `CERRADA`, que es el estado final (RN-14); si el ciudadano no responde en 7 días, el sistema la cierra solo (RF-29).
- Reglas de negocio: RN-14, RN-17.
- Requisitos funcionales: RF-14, RF-29.
