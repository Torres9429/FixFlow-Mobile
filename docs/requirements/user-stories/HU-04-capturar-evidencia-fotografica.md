---
id: HU-04
titulo: Capturar evidencia fotográfica en vivo
modulo: Captura y sensores
actor: Ciudadano
---

# HU-04 — Capturar evidencia fotográfica en vivo

## Historia

**Como** ciudadano
**Quiero** tomar la fotografía directamente desde la aplicación
**Para** proporcionar evidencia actual de la incidencia reportada.

## Criterios de aceptación

- [ ] La fotografía debe capturarse utilizando la cámara del dispositivo.
- [ ] El ciudadano no debe poder seleccionar una fotografía almacenada previamente en el dispositivo como evidencia principal.
- [ ] La aplicación debe solicitar permisos para utilizar la cámara.
- [ ] Si el permiso es rechazado, el sistema debe informar que no es posible continuar con la captura.
- [ ] La fotografía debe asociarse directamente con el reporte que se está creando.

## Dependencias

- **Depende de:** HU-03.

## Notas funcionales

- Sensor utilizado: cámara (RNF-01).
- Reglas de negocio: RN-09.
- Requisitos funcionales: RF-05.
- Requisitos no funcionales: RNF-01, RNF-02, RNF-03.
