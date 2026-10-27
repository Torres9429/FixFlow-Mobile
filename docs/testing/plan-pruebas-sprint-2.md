# FixFlow

25 de octubre del 2026

## HU-03 — CREAR REPORTE DE INCIDENCIA

Como ciudadano quiero registrar una incidencia desde mi teléfono para informar a las autoridades sobre un problema presente en el entorno urbano.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-03 | Validadores de campos obligatorios del reporte (CA-1, CA-2) | Unitaria | Tipo de incidencia vacío → "Campo obligatorio"; descripción vacía → "Campo obligatorio"; tipo y descripción válidos → sin error | 3 |
| HU-03 | La fecha y hora se asignan automáticamente al crear el reporte (CA-5, RN-08) | Unitaria | Al construir el modelo del reporte, la fecha/hora se establece sin intervención del usuario y no es nula | 1 |
| HU-03 | Enviar formulario de reporte sin completar campos obligatorios (CA-1, CA-2) | Interfaz | Aparece error bajo cada campo vacío y el envío no se ejecuta | 1 |
| HU-03 | Pantalla de revisión previa al envío (CA-6) | Interfaz | Se muestran tipo, descripción, foto, ubicación y botón de confirmar antes de enviar | 1 |
| HU-03 | Flujo completo: crear y enviar un reporte (CA-1 a CA-7) | Integración | Seleccionar tipo → describir → capturar foto → obtener ubicación → revisar → confirmar → se genera un identificador y se muestra confirmación | 1 |
| | | | **Total HU-03** | **7** |

## HU-04 — CAPTURAR EVIDENCIA FOTOGRÁFICA EN VIVO

Como ciudadano quiero tomar la fotografía directamente desde la aplicación para proporcionar evidencia actual de la incidencia reportada.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-04 | La captura utiliza la cámara del dispositivo y no permite galería (CA-1, CA-2, RN-09) | Unitaria | El servicio de cámara invoca la cámara en vivo; la opción de galería no está habilitada | 2 |
| HU-04 | La fotografía queda asociada al reporte (CA-5) | Unitaria | Tras capturar, la entidad del reporte contiene la ruta de la imagen | 1 |
| HU-04 | Permiso de cámara concedido → se abre la cámara (CA-3) | Interfaz | Al conceder el permiso, aparece la vista previa de la cámara | 1 |
| HU-04 | Permiso de cámara rechazado → se muestra aviso (CA-4) | Interfaz | Si se rechaza, se muestra un mensaje indicando que no es posible continuar | 1 |
| | | | **Total HU-04** | **5** |

## HU-05 — REGISTRAR UBICACIÓN AUTOMÁTICAMENTE

Como ciudadano quiero que la aplicación obtenga automáticamente mi ubicación al realizar un reporte para evitar tener que introducir manualmente dónde ocurrió la incidencia.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-05 | El servicio de ubicación devuelve latitud y longitud (CA-2, CA-3) | Unitaria | Con un mock del GPS, se obtienen coordenadas válidas (no nulas, dentro de rango) | 2 |
| HU-05 | Sin ubicación disponible se impide el envío (CA-5, RN-12) | Unitaria | Si el GPS devuelve error, el resultado es un fallo y el reporte no se envía | 1 |
| HU-05 | Permiso de ubicación concedido → se obtienen coordenadas (CA-1) | Interfaz | Al conceder el permiso, la pantalla muestra la latitud y longitud obtenidas | 1 |
| HU-05 | Permiso de ubicación rechazado → se muestra aviso (CA-5) | Interfaz | Si se rechaza, se muestra un mensaje indicando que no es posible obtener la ubicación | 1 |
| HU-05 | El ciudadano visualiza la ubicación antes de enviar (CA-4) | Interfaz | En la pantalla de revisión, se muestran las coordenadas o un mapa con la ubicación | 1 |
| | | | **Total HU-05** | **6** |

## HU-06 — VALIDAR ORIENTACIÓN DEL DISPOSITIVO

Como sistema quiero obtener información del acelerómetro durante la captura de evidencia para verificar que la orientación del dispositivo sea congruente con el tipo de incidencia reportada.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-06 | El validador de orientación para "bache" (CA-3, RN-11) | Unitaria | Acelerómetro apuntando al suelo → orientación válida; apuntando al cielo → orientación inválida | 2 |
| HU-06 | El validador de orientación para "luminaria" (CA-4, RN-11) | Unitaria | Acelerómetro apuntando arriba → orientación válida; apuntando al suelo → orientación inválida | 2 |
| HU-06 | Se obtienen datos del acelerómetro durante la captura (CA-1) | Unitaria | El servicio del acelerómetro devuelve valores x, y, z no nulos al capturar | 1 |
| HU-06 | Orientación incorrecta → se solicita recaptura (CA-5) | Interfaz | Si la orientación no coincide con el tipo, se muestra un mensaje pidiendo volver a capturar | 1 |
| | | | **Total HU-06** | **6** |

## HU-07 — ASOCIAR COORDENADAS A LA EVIDENCIA

Como sistema quiero asociar la ubicación GPS obtenida durante la captura con la evidencia para conservar información sobre el lugar donde fue registrada.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-07 | La evidencia queda vinculada a las coordenadas (CA-1, CA-2) | Unitaria | Al capturar evidencia con ubicación, el modelo del reporte contiene foto + latitud + longitud asociados | 1 |
| HU-07 | El usuario no puede introducir coordenadas manualmente (CA-3, RN-10) | Unitaria | Si se intenta asignar coordenadas manuales, se ignoran o se produce un error | 1 |
| HU-07 | La ubicación permanece asociada al reporte (CA-4, RN-10) | Unitaria | Después de construir el reporte, modificar las coordenadas no es posible (inmutabilidad) | 1 |
| | | | **Total HU-07** | **3** |

## HU-08 — VALIDAR EVIDENCIA DEL REPORTE

Como sistema quiero verificar que la evidencia requerida haya sido obtenida correctamente para evitar que se registren reportes incompletos o que no cumplan las condiciones establecidas.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-08 | Reporte completo pasa la validación (CA-1, CA-2, CA-3, CA-4, RN-12) | Unitaria | Con foto, ubicación y acelerómetro válidos → la validación retorna éxito | 1 |
| HU-08 | Reporte sin foto falla la validación (CA-1, RN-09) | Unitaria | Sin evidencia fotográfica → error indicando que falta la foto | 1 |
| HU-08 | Reporte sin ubicación falla la validación (CA-3, RN-10) | Unitaria | Sin coordenadas GPS → error indicando que falta la ubicación | 1 |
| HU-08 | Reporte sin datos del acelerómetro falla la validación (CA-4, RN-11) | Unitaria | Sin datos del acelerómetro → error indicando que falta la orientación | 1 |
| HU-08 | Evidencia que no cumple condiciones → se solicita recaptura (CA-5) | Interfaz | El botón de enviar queda deshabilitado y se muestra un mensaje de evidencia incompleta | 1 |
| HU-08 | El reporte no se envía hasta cumplir todos los requisitos (CA-6, RN-12) | Interfaz | Sin evidencia completa, al intentar enviar aparece una alerta y no se llama al servicio de envío | 1 |
| | | | **Total HU-08** | **6** |

## Resumen del Sprint 2

| HU | Tests |
| --- | ---: |
| HU-03 — Crear reporte de incidencia | 7 |
| HU-04 — Capturar evidencia fotográfica en vivo | 5 |
| HU-05 — Registrar ubicación automáticamente | 6 |
| HU-06 — Validar orientación del dispositivo | 6 |
| HU-07 — Asociar coordenadas a la evidencia | 3 |
| HU-08 — Validar evidencia del reporte | 6 |
| **Total Sprint 2** | **33** |

## Correspondencia con tarjetas del tablero

| Issue | Tarjeta | HUs que cubre |
| --- | --- | --- |
| #20 | Cámara en vivo con permisos | HU-04 |
| #19 | Leer el acelerómetro en los teléfonos | HU-06 |
| #22 | Ubicación de la foto | HU-05, HU-07 |
| #23 | Guía de orientación en la cámara | HU-06 |
| #21 | Subir la foto a Cloudinary | HU-04, HU-08 |
| #18 | Enviar el reporte | HU-03 |
| #24 | Revisar y validar el reporte | HU-03, HU-08 |

## ¿Qué queda fuera?

- Pruebas del backend: almacenamiento de reportes en la BD, subida real de fotos a Cloudinary, validaciones del servidor y generación de identificadores únicos.
- Pruebas con el servidor real; todas las respuestas de red son simuladas.
- Pruebas con sensores físicos reales (cámara, GPS, acelerómetro); se usan mocks de los servicios del dispositivo.
- Pruebas del catálogo completo de tipos de incidencia (RN-07 pendiente de definir).
- Tolerancias exactas del acelerómetro (RN-11 parcial).

## ANEXOS

### Tipos

| Prueba | ¿Qué es? | Herramienta |
| --- | --- | --- |
| Unitaria | Una función o clase aislada | flutter_test + mocktail |
| Interfaz | Una pantalla: lo que se ve y se toca | testWidgets |
| Integración | Varias pantallas juntas (la app completa) con los servicios simulados | testWidgets levantando la app completa con los mocks inyectados |

### Reglas de negocio verificadas en este sprint

| ID | Regla | HUs |
| --- | --- | --- |
| RN-07 | Catálogo de tipos de incidencia | HU-03, HU-06 |
| RN-08 | Datos automáticos del reporte (fecha/hora, ID) | HU-03 |
| RN-09 | Evidencia principal capturada en vivo | HU-04, HU-08 |
| RN-10 | Ubicación obtenida en la captura | HU-05, HU-07 |
| RN-11 | Orientación esperada por tipo de incidencia | HU-06, HU-08 |
| RN-12 | Condiciones para enviar un reporte | HU-03, HU-05, HU-08 |
