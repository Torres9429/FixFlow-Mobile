---
id: HU-08
titulo: Validar evidencia del reporte
modulo: Captura y sensores
actor: Sistema
---

# HU-08 — Validar evidencia del reporte

## Historia

**Como** sistema
**Quiero** verificar que la evidencia requerida haya sido obtenida correctamente
**Para** evitar que se registren reportes incompletos o que no cumplan las condiciones establecidas.

## Criterios de aceptación

- [ ] El sistema debe verificar que el reporte cuente con evidencia fotográfica.
- [ ] La evidencia debe haber sido capturada mediante la cámara de la aplicación.
- [ ] El sistema debe verificar que exista información de ubicación asociada.
- [ ] Si el dispositivo cuenta con acelerómetro, el sistema debe verificar que se hayan obtenido sus datos; si no cuenta con él, el reporte se envía marcado como sin sensor.
- [ ] Si la evidencia no cumple las condiciones establecidas, el sistema debe solicitar al ciudadano realizar nuevamente la captura.
- [ ] El reporte no debe enviarse hasta cumplir con los requisitos establecidos.

## Dependencias

- **Depende de:** HU-04, HU-05, HU-06, HU-07.
- **Relacionada con:** HU-03.

## Notas funcionales

- Reglas de negocio: RN-09, RN-10, RN-11, RN-12.
- Requisitos funcionales: RF-09.
