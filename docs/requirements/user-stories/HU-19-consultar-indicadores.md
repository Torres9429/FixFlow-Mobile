---
id: HU-19
titulo: Consultar indicadores de atención
modulo: Administración municipal
actor: Administrador municipal
---

# HU-19 — Consultar indicadores de atención

## Historia

**Como** administrador municipal
**Quiero** consultar métricas sobre las incidencias
**Para** conocer el comportamiento y desempeño de la atención de problemas urbanos.

## Criterios de aceptación

- [ ] El sistema debe mostrar la cantidad de incidencias registradas.
- [ ] Debe mostrar la cantidad de incidencias atendidas y pendientes.
- [ ] Debe permitir consultar los tiempos de resolución.
- [ ] Debe permitir identificar las incidencias según su prioridad.
- [ ] Los indicadores deben actualizarse conforme se registren nuevas incidencias y cambios de estado.

## Dependencias

- **Depende de:** HU-03, HU-15.
- **Relacionada con:** HU-09, HU-17.

## Notas funcionales

- **Pendientes:** incidencias en `PENDIENTE` (sin asignar). **En atención:** `ASIGNADA`, `EN_PROCESO` o `REABIERTA`. **Atendidas:** `RESUELTA` o `CERRADA` (RN-14).
- **Tiempo de resolución:** fecha en que pasó a `RESUELTA` − fecha de creación. Se muestran el promedio y el máximo, en horas.
- Reglas de negocio: RN-13, RN-14, RN-15.
- Requisitos funcionales: RF-21.
