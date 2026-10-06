---
id: HU-07
titulo: Asociar coordenadas a la evidencia
modulo: Captura y sensores
actor: Sistema
---

# HU-07 — Asociar coordenadas a la evidencia

## Historia

**Como** sistema
**Quiero** asociar la ubicación GPS obtenida durante la captura con la evidencia
**Para** conservar información sobre el lugar donde fue registrada.

## Criterios de aceptación

- [ ] La evidencia debe quedar vinculada a las coordenadas obtenidas durante la captura.
- [ ] La ubicación debe almacenarse junto con la información del reporte.
- [ ] El sistema no debe permitir que el usuario introduzca manualmente unas coordenadas diferentes como sustitución de la ubicación obtenida durante la captura.
- [ ] La información de ubicación debe permanecer asociada al reporte durante su ciclo de vida.

## Dependencias

- **Depende de:** HU-04, HU-05.

## Notas funcionales

- Reglas de negocio: RN-10.
- Requisitos funcionales: RF-08.
