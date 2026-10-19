# Glosario — FixFlow

Términos del dominio tal como se usan en las HUs. Si un término cambia de significado, se actualiza aquí y no en cada HU.

| Término | Definición |
| --- | --- |
| **Administrador municipal** | Rol que supervisa las incidencias del municipio, las asigna al personal operativo y consulta indicadores. |
| **Asignación** | Acción por la que el administrador municipal designa a un miembro del personal operativo como responsable de atender una incidencia. Puede reasignarse (RN-16). |
| **Carga actual** | Número de incidencias de un operativo en estado `ASIGNADA`, `EN_PROCESO` o `REABIERTA`. El administrador la ve al asignar (RN-16). |
| **Cierre automático** | Paso de una incidencia `RESUELTA` a `CERRADA` que hace el sistema cuando el ciudadano no la confirma ni la reabre en 7 días (RN-14). |
| **Ciudadano** | Rol que registra incidencias, aporta evidencia, consulta su estado y valida su resolución. Es el rol asignado en el registro (RN-04). |
| **Contraseña temporal** | Contraseña que el administrador asigna al dar de alta a un operativo; el operativo la cambia desde su perfil (RN-19). |
| **Coordenadas** | Latitud y longitud obtenidas por GPS al capturar la evidencia (RN-10). |
| **Cuenta activa / inactiva** | Estado de una cuenta de usuario. Una cuenta inactiva no puede iniciar sesión ni recibir asignaciones (HU-24). |
| **Estado** | Situación de una incidencia dentro de su ciclo de vida. Catálogo y transiciones en RN-14. No confundir con el *Status* del tablero Kanban. |
| **Evidencia** | Fotografía asociada a una incidencia. La *evidencia del reporte* la captura el ciudadano en vivo (RN-09); la *evidencia de solución* la adjunta el personal operativo (HU-16). |
| **Folio** | Identificador legible de una incidencia con formato `FX-AAAA-NNNNNN`, generado por el servidor (RN-08). |
| **Historial** | Registro cronológico de las acciones realizadas sobre una incidencia, con autor, fecha y hora (RN-15). |
| **Incidencia** | Problema del entorno urbano registrado en FixFlow. Se identifica ante el usuario por su *folio*. |
| **Indicadores de atención** | Métricas sobre el volumen y la atención de incidencias: registradas, atendidas, pendientes, tiempos de resolución y distribución por prioridad (HU-19). |
| **Motivo de prioridad** | Texto que explica por qué una incidencia tiene su prioridad actual, por ejemplo «Tipo de incidencia: Bache» o «Sin resolver por más de 7 días» (RN-13). |
| **Orientación del dispositivo** | Posición del teléfono durante la captura (por ejemplo, hacia el suelo o hacia arriba), obtenida con el acelerómetro (RN-11). |
| **Personal operativo** | Rol (también llamado *inspector*) que atiende las incidencias asignadas, actualiza su estado y registra la solución. |
| **Prioridad** | Nivel de atención de una incidencia, asignado automáticamente según reglas predefinidas (RN-13). No confundir con la prioridad de tablero de GitHub Projects. |
| **Reapertura** | Acción por la que el ciudadano indica que una incidencia no fue solucionada, con justificación, para que vuelva a atenderse (RN-17). |
| **Reporte** | Registro que el ciudadano envía para dar de alta una incidencia. En las HUs, *reporte* e *incidencia* se usan con frecuencia como sinónimos. |
| **Tipo de incidencia** | Categoría de la incidencia (por ejemplo, bache o luminaria) seleccionada por el ciudadano. Tiene un código fijo y un nombre visible (RN-07). |
| **Usuario autorizado** | Usuario con permiso para consultar una incidencia y su historial (HU-22): el ciudadano que la reportó, el operativo asignado y cualquier administrador municipal (RNF-04). |
| **Validación de resolución** | Revisión por parte del ciudadano de la evidencia de solución para confirmar que la incidencia fue atendida (HU-13). |
| **Zona** | Área circular del mapa (centro y radio en km) que el administrador usa para filtrar incidencias (HU-18). |
