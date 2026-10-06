---
id: HU-03
titulo: Crear reporte de incidencia
modulo: Reportes e incidencias
actor: Ciudadano
---

# HU-03 — Crear reporte de incidencia

## Historia

**Como** ciudadano
**Quiero** registrar una incidencia desde mi teléfono
**Para** informar a las autoridades sobre un problema presente en el entorno urbano.

## Criterios de aceptación

- [ ] El ciudadano debe poder seleccionar el tipo de incidencia.
- [ ] El sistema debe permitir agregar una descripción del problema.
- [ ] El reporte debe incluir evidencia fotográfica.
- [ ] El sistema debe obtener la ubicación mediante GPS.
- [ ] El sistema debe asociar automáticamente la fecha y hora del reporte.
- [ ] El ciudadano debe poder revisar la información antes de enviarla.
- [ ] Al confirmar el envío, el sistema debe generar un identificador único para la incidencia.

## Dependencias

- **Depende de:** HU-02.
- **Relacionada con:** HU-04, HU-05, HU-08. HU-03 define el flujo del reporte y HU-04/HU-05 implementan la captura dentro de él, por lo que la verificación completa de HU-03 requiere ambas.

## Notas funcionales

- Reglas de negocio: RN-07 *(pendiente)*, RN-08, RN-12.
- Requisitos funcionales: RF-04.
