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

- [ ] El sistema debe obtener los datos del acelerómetro durante la captura.
- [ ] La aplicación debe comparar la orientación registrada con las condiciones establecidas para el tipo de incidencia.
- [ ] Para incidencias que requieren una captura hacia el suelo, como un bache, la aplicación debe verificar la orientación correspondiente.
- [ ] Para incidencias que requieren una captura hacia arriba, como una luminaria, debe verificarse la orientación correspondiente.
- [ ] Si la orientación no cumple con las condiciones establecidas, el sistema debe solicitar al ciudadano realizar nuevamente la captura.

## Dependencias

- **Depende de:** HU-04.
- **Relacionada con:** HU-03 (tipo de incidencia seleccionado), HU-08.

## Notas funcionales

- Sensor utilizado: acelerómetro (RNF-01).
- Reglas de negocio: RN-07, RN-11.
- Requisitos funcionales: RF-07.
- Requisitos no funcionales: RNF-01, RNF-02.
