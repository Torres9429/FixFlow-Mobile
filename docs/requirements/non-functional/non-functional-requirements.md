# Requisitos no funcionales — FixFlow

Restricciones técnicas y atributos de calidad que aplican de forma transversal. Solo se registran como *Vigentes* los requisitos establecidos explícitamente para el proyecto; el resto se lista como pendiente, sin valores inventados.

## Vigentes

### RNF-01 — Sensores permitidos

**Tipo:** Restricción técnica

La aplicación móvil utiliza únicamente estos sensores del dispositivo:

- GPS
- Cámara
- Acelerómetro

No se utiliza el micrófono ni ninguna funcionalidad de voz (reconocimiento, dictado, comandos o notas de voz).

### RNF-02 — Requisitos del dispositivo

**Tipo:** Compatibilidad · **Relacionado con:** HU-04, HU-05, HU-06

Para registrar reportes, el dispositivo del ciudadano debe contar con cámara, GPS y acelerómetro.

### RNF-03 — Gestión de permisos del sistema operativo

**Tipo:** Usabilidad / Privacidad · **Relacionado con:** HU-04, HU-05

Toda funcionalidad que requiera un permiso del sistema operativo (cámara, ubicación) debe solicitarlo antes de usarlo y, si se rechaza, informar al usuario sin permitir que se envíe un reporte incompleto.

## Pendientes de definir

Categorías que el equipo debe decidir con el Product Owner. Mientras estén pendientes no se exigen en la DoD.

| Categoría | Pregunta abierta |
| --- | --- |
| Plataforma | ¿Sistemas operativos y versiones mínimas soportadas? ¿Las funciones de administración municipal (HU-17 a HU-21) son móviles, web o ambas? |
| Conectividad | ¿Qué ocurre si no hay conexión al enviar un reporte? |
| Rendimiento | ¿Tiempos de respuesta esperados para consultas y envío de reportes? |
| Almacenamiento de evidencia | ¿Tamaño, resolución o compresión de las fotografías? |
| Seguridad | ¿Mecanismo de almacenamiento de credenciales y de sesión? |
| Privacidad | ¿Quién puede ver la ubicación y evidencia de un reporte, además de los roles ya indicados en las HUs? |
| Notificaciones | ¿Canal de notificación (push, dentro de la app, ambos)? |
