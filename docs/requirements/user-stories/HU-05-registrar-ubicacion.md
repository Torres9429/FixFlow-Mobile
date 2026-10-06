---
id: HU-05
titulo: Registrar ubicación automáticamente
modulo: Captura y sensores
actor: Ciudadano
---

# HU-05 — Registrar ubicación automáticamente

## Historia

**Como** ciudadano
**Quiero** que la aplicación obtenga automáticamente mi ubicación al realizar un reporte
**Para** evitar tener que introducir manualmente dónde ocurrió la incidencia.

## Criterios de aceptación

- [ ] La aplicación debe solicitar acceso a la ubicación del dispositivo.
- [ ] Al capturar la evidencia, el sistema debe obtener las coordenadas GPS disponibles.
- [ ] La latitud y longitud deben asociarse al reporte.
- [ ] El ciudadano debe poder visualizar la ubicación obtenida antes de enviar el reporte.
- [ ] Si no es posible obtener la ubicación, el sistema debe informar al ciudadano y evitar enviar un reporte incompleto.

## Dependencias

- **Depende de:** HU-03, HU-04 (la ubicación se obtiene al capturar la evidencia).
- **Relacionada con:** HU-07.

## Notas funcionales

- Sensor utilizado: GPS (RNF-01).
- Reglas de negocio: RN-10, RN-12.
- Requisitos funcionales: RF-06.
- Requisitos no funcionales: RNF-01, RNF-02, RNF-03.
