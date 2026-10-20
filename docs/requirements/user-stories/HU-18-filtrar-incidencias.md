---
id: HU-18
titulo: Filtrar incidencias
modulo: Administración municipal
actor: Administrador municipal
---

# HU-18 — Filtrar incidencias

## Historia

**Como** administrador municipal
**Quiero** filtrar las incidencias
**Para** localizar rápidamente los reportes que requieren atención específica.

## Criterios de aceptación

- [ ] El administrador debe poder filtrar por estado.
- [ ] Debe poder filtrar por tipo de incidencia.
- [ ] Debe poder filtrar por prioridad.
- [ ] Debe poder consultar incidencias dentro de una zona determinada.
- [ ] Los resultados deben actualizarse de acuerdo con los filtros seleccionados.

## Dependencias

- **Depende de:** HU-17.
- **Relacionada con:** HU-09.

## Notas funcionales

- **Zona = círculo:** el administrador elige un centro en el mapa y un radio en km (máximo 50). Se muestran las incidencias cuya ubicación cae dentro del círculo. Los filtros se combinan entre sí.
- El filtro por zona es una consulta del administrador; no implica detección de reportes duplicados por proximidad (fuera de alcance).
- Reglas de negocio: RN-07, RN-13, RN-14.
- Requisitos funcionales: RF-20.
