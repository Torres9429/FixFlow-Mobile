---
id: HU-06
titulo: Validar orientación del dispositivo
modulo: Captura y sensores
actor: Sistema
---

# HU-06 — Validar orientación del dispositivo

## Historia

**Como** sistema
**Quiero** obtener información del acelerómetro durante la captura de evidencia
**Para** verificar que la orientación del dispositivo sea congruente con el tipo de incidencia reportada.

## Criterios de aceptación

- [ ] Antes de capturar, la aplicación debe detectar si el dispositivo cuenta con acelerómetro.
- [ ] Si el dispositivo cuenta con acelerómetro, el sistema debe obtener sus datos durante la captura.
- [ ] Si el dispositivo cuenta con acelerómetro, la aplicación debe comparar la orientación registrada con las condiciones establecidas para el tipo de incidencia.
- [ ] Para incidencias que requieren una captura hacia el suelo, como un bache, la aplicación debe verificar la orientación correspondiente.
- [ ] Para incidencias que requieren una captura hacia arriba, como una luminaria, debe verificarse la orientación correspondiente.
- [ ] Si la orientación no cumple con las condiciones establecidas, el sistema debe solicitar al ciudadano realizar nuevamente la captura.
- [ ] Si el dispositivo no cuenta con acelerómetro, la aplicación debe avisar al ciudadano y permitir la captura de cualquier tipo de incidencia sin validar la orientación; el reporte se envía marcado como sin sensor.

## Dependencias

- **Depende de:** HU-04.
- **Relacionada con:** HU-03 (tipo de incidencia seleccionado), HU-08.

## Notas funcionales

- Sensor utilizado: acelerómetro (RNF-01). Sin acelerómetro: aviso en B2 y cámara sin guía (B3e); la foto no se valida por inclinación (RN-11).
- Reglas de negocio: RN-07, RN-11.
- Requisitos funcionales: RF-07.
- Requisitos no funcionales: RNF-01, RNF-02.
