# Reglas de negocio — FixFlow

Políticas del dominio que el sistema debe respetar independientemente de la pantalla o plataforma. Cada regla se define **una sola vez** aquí; las HUs la referencian por ID.

**Estado de la regla** (propiedad del documento, no del tablero):

- **Vigente:** definida completamente a partir de las HUs.
- **Parcial:** las HUs la exigen pero solo aportan ejemplos; falta completar la definición.
- **Pendiente de definir:** las HUs la exigen pero no la especifican. Una HU que dependa de una regla pendiente no cumple la DoR (ver [definition-of-ready.md](../../methodology/definition-of-ready.md)).

> Las reglas *Parcial* y *Pendiente* no contienen valores inventados; deben decidirse con el Product Owner.

---

## Usuarios y acceso

### RN-01 — Correo electrónico único

**Estado:** Vigente · **Origen:** HU-01

No pueden existir dos cuentas registradas con el mismo correo electrónico.

### RN-02 — Política de contraseña

**Estado:** Pendiente de definir · **Origen:** HU-01

La contraseña debe cumplir requisitos mínimos de seguridad. **Por definir:** longitud mínima y composición exigida.

### RN-03 — Datos obligatorios de registro

**Estado:** Pendiente de definir · **Origen:** HU-01

El registro exige un conjunto de datos obligatorios, entre ellos el correo electrónico y la contraseña. **Por definir:** lista completa de campos.

### RN-04 — Rol asignado en el registro

**Estado:** Vigente · **Origen:** HU-01

Todo usuario creado mediante el registro de HU-01 recibe el rol **Ciudadano**.

### RN-05 — Roles y acceso por rol

**Estado:** Vigente · **Origen:** HU-02

Los roles del sistema son **Ciudadano**, **Personal operativo** y **Administrador municipal**. Cada usuario accede únicamente a las funcionalidades correspondientes a su rol.

### RN-06 — Visibilidad de reportes del ciudadano

**Estado:** Vigente · **Origen:** HU-10

Un ciudadano solo puede consultar los reportes que él mismo registró.

---

## Reporte y evidencia

### RN-07 — Catálogo de tipos de incidencia

**Estado:** Pendiente de definir · **Origen:** HU-03, HU-06, HU-09, HU-18

Toda incidencia pertenece a un tipo seleccionado de un catálogo. Tipos mencionados en las HUs: *bache*, *luminaria*. **Por definir:** catálogo completo.

### RN-08 — Datos automáticos del reporte

**Estado:** Vigente · **Origen:** HU-03

- La fecha y hora del reporte se asignan automáticamente.
- Al confirmar el envío se genera un identificador único para la incidencia.

### RN-09 — Evidencia principal capturada en vivo

**Estado:** Vigente · **Origen:** HU-04, HU-08

La evidencia fotográfica principal de un reporte se captura con la cámara desde la aplicación. No se admite como evidencia principal una fotografía almacenada previamente en el dispositivo.

### RN-10 — Ubicación obtenida en la captura

**Estado:** Vigente · **Origen:** HU-05, HU-07

- La ubicación del reporte son las coordenadas GPS (latitud y longitud) obtenidas al capturar la evidencia.
- El usuario no puede sustituirlas introduciendo coordenadas manualmente.
- La ubicación permanece asociada al reporte durante todo su ciclo de vida.

### RN-11 — Orientación esperada por tipo de incidencia

**Estado:** Parcial · **Origen:** HU-06

Cada tipo de incidencia puede exigir una orientación del dispositivo durante la captura, verificada con el acelerómetro.

| Tipo de incidencia | Orientación esperada |
| --- | --- |
| Bache | Hacia el suelo |
| Luminaria | Hacia arriba |
| *Resto del catálogo (RN-07)* | **Por definir** |

**Por definir:** orientación para cada tipo, tolerancias aceptadas y si existen tipos sin restricción de orientación.

### RN-12 — Condiciones para enviar un reporte

**Estado:** Vigente · **Origen:** HU-03, HU-05, HU-08

Un reporte solo puede enviarse si cumple todas las condiciones:

1. Tiene evidencia fotográfica capturada en vivo (RN-09).
2. Tiene ubicación GPS asociada (RN-10).
3. Se obtuvieron los datos requeridos del acelerómetro y la orientación es válida para su tipo (RN-11).

Si alguna condición no se cumple, se solicita al ciudadano repetir la captura y el reporte no se envía.

---

## Priorización

### RN-13 — Reglas de prioridad

**Estado:** Pendiente de definir · **Origen:** HU-09, HU-14, HU-20

- La prioridad se asigna automáticamente aplicando reglas previamente definidas que consideran el tipo y las características de la incidencia.
- Nivel mencionado en las HUs: **Prioridad Alta**.
- Cuando corresponda, debe poder mostrarse el motivo o condición que determinó la prioridad.

**Por definir:** niveles de prioridad, condiciones de cada nivel y si la prioridad puede modificarse manualmente (HU-09 exige registrar *cambios* de prioridad en el historial).

---

## Ciclo de vida de la incidencia

### RN-14 — Estados y transiciones

**Estado:** Pendiente de definir · **Origen:** HU-11, HU-13, HU-15, HU-16, HU-21, HU-23

Los cambios de estado deben respetar los estados y transiciones definidos por el sistema.

Situaciones mencionadas en las HUs (**no constituyen el catálogo oficial**): revisado, atendido, solucionado (HU-11), pendiente de atención (HU-21), estado tras registrar la solución (HU-16), estado final (HU-13), estado tras la reapertura (HU-23).

**Por definir:** lista de estados, transiciones permitidas, qué rol puede ejecutar cada transición y cuál es el estado final.

### RN-15 — Registro de cambios (trazabilidad)

**Estado:** Vigente · **Origen:** HU-09, HU-15, HU-16, HU-21, HU-22, HU-23

Toda acción sobre una incidencia queda registrada en su historial con **quién** la realizó y **fecha y hora**. Esto incluye: cambios de estado, cambios de prioridad, asignaciones y reasignaciones, registro de solución y reaperturas. El historial conserva la evidencia asociada a cada etapa y se presenta en orden cronológico.

### RN-16 — Asignación de incidencias

**Estado:** Parcial · **Origen:** HU-21

- Una incidencia se asigna a un miembro del personal operativo.
- Solo pueden asignarse incidencias pendientes de atención.
- Una incidencia puede reasignarse.

**Por definir:** criterio de "personal operativo disponible".

### RN-17 — Reapertura de incidencias

**Estado:** Parcial · **Origen:** HU-13, HU-23

- El ciudadano puede indicar que una incidencia no fue solucionada.
- La reapertura exige una justificación o descripción del problema persistente.

**Por definir:** desde qué estados se permite reabrir, si solo puede hacerlo el ciudadano que creó el reporte y si existe un límite de reaperturas o de tiempo.

---

## Notificaciones

### RN-18 — Notificaciones de eventos

**Estado:** Vigente · **Origen:** HU-12, HU-21

- El ciudadano recibe una notificación por cada cambio de estado de su reporte, nunca duplicada para un mismo cambio.
- El personal operativo recibe una notificación cuando se le asigna una incidencia.
