---
id: HU-22
titulo: Consultar historial de una incidencia
modulo: Historial y trazabilidad
actor: Usuario autorizado
---

# HU-22 — Consultar historial de una incidencia

## Historia

**Como** usuario autorizado
**Quiero** consultar el historial de una incidencia
**Para** conocer las acciones realizadas desde su creación hasta su resolución.

## Criterios de aceptación

- [ ] El sistema debe registrar los cambios de estado.
- [ ] Debe registrar quién realizó cada modificación.
- [ ] Debe registrar la fecha y hora de cada acción.
- [ ] Debe conservar la evidencia asociada a las diferentes etapas.
- [ ] El historial debe presentarse en orden cronológico.

## Dependencias

- **Depende de:** HU-15.
- **Relacionada con:** HU-09, HU-11, HU-16, HU-21, HU-23 (generan eventos del historial).

## Notas funcionales

- Los roles que se consideran *usuario autorizado* están pendientes de definir (ver glosario).
- Reglas de negocio: RN-15.
- Requisitos funcionales: RF-25.
