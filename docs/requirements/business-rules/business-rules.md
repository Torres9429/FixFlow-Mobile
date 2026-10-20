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

No pueden existir dos cuentas registradas con el mismo correo electrónico. El correo se compara sin espacios al inicio o al final y sin distinguir mayúsculas de minúsculas.

### RN-02 — Política de contraseña

**Estado:** Vigente · **Origen:** HU-01

La contraseña debe tener **al menos 8 caracteres** e incluir **letras y números**. Aplica al registro (HU-01), a la contraseña temporal de un operativo (HU-24, RN-19) y al cambio de contraseña desde el perfil (HU-25).

### RN-03 — Datos obligatorios de registro

**Estado:** Vigente · **Origen:** HU-01

El registro exige **nombre**, **apellidos**, **correo electrónico** y **contraseña**. Nombre y apellidos admiten hasta 60 caracteres cada uno; el correo, hasta 254.

### RN-04 — Rol asignado en el registro

**Estado:** Vigente · **Origen:** HU-01

Todo usuario creado mediante el registro de HU-01 recibe el rol **Ciudadano**.

### RN-05 — Roles y acceso por rol

**Estado:** Vigente · **Origen:** HU-02

Los roles del sistema son **Ciudadano**, **Personal operativo** y **Administrador municipal**. Cada usuario accede únicamente a las funcionalidades correspondientes a su rol.

### RN-06 — Visibilidad de reportes del ciudadano

**Estado:** Vigente · **Origen:** HU-10

Un ciudadano solo puede consultar los reportes que él mismo registró.

### RN-19 — Contraseña temporal del personal operativo

**Estado:** Vigente · **Origen:** HU-24

- El administrador escribe o genera una contraseña temporal al dar de alta a un operativo; debe cumplir RN-02.
- El administrador se la comunica a la persona por fuera del sistema.
- El operativo puede cambiarla desde su perfil (HU-25). No se fuerza el cambio en el primer inicio de sesión.
- Una cuenta desactivada no puede iniciar sesión.

---

## Reporte y evidencia

### RN-07 — Catálogo de tipos de incidencia

**Estado:** Vigente · **Origen:** HU-03, HU-06, HU-09, HU-18, HU-26

Toda incidencia pertenece a un tipo seleccionado de este catálogo. Cada tipo define su orientación esperada (RN-11) y su prioridad base (RN-13). El catálogo vive como datos: el administrador puede editarlo o desactivar un tipo sin cambiar el código de la app (HU-26).

Cada tipo tiene un **código** único y fijo (la clave legible, por ejemplo `BACHE`: mayúsculas, números y guion bajo) y un **nombre** que ve el usuario. Al crear un tipo, el código es opcional: si no se indica se genera del nombre (sin acentos, en mayúsculas y con guion bajo; con sufijo `_2` si ya existe). El código no se modifica después de crear el tipo; el nombre, la orientación y la prioridad base sí.

| Código | Tipo | Orientación (RN-11) | Prioridad base (RN-13) |
| --- | --- | --- | --- |
| `BACHE` | Bache | Hacia el suelo | Media |
| `LUMINARIA` | Luminaria apagada o dañada | Hacia arriba | Media |
| `FUGA_AGUA` | Fuga de agua | Sin restricción | Alta |
| `COLADERA` | Coladera sin tapa u obstruida | Hacia el suelo | Alta |
| `ARBOL_CAIDO` | Árbol o rama caída | Sin restricción | Alta |
| `SENALAMIENTO` | Señalamiento vial dañado | Sin restricción | Media |
| `BANQUETA` | Banqueta dañada | Hacia el suelo | Baja |
| `BASURA` | Basura acumulada | Sin restricción | Baja |
| `OTRO` | Otro | Sin restricción | Baja |

Un tipo desactivado ya no se puede elegir en reportes nuevos; las incidencias existentes lo conservan.

### RN-08 — Datos automáticos del reporte

**Estado:** Vigente · **Origen:** HU-03

- La fecha y hora del reporte se asignan automáticamente.
- Al confirmar el envío se genera un identificador único para la incidencia.
- Para el usuario, el identificador es un **folio** con formato `FX-AAAA-NNNNNN` (prefijo, año y consecutivo de 6 dígitos), por ejemplo `FX-2026-000123`. Lo genera el servidor, nunca el teléfono.

### RN-09 — Evidencia principal capturada en vivo

**Estado:** Vigente · **Origen:** HU-04, HU-08

La evidencia fotográfica principal de un reporte se captura con la cámara desde la aplicación. No se admite como evidencia principal una fotografía almacenada previamente en el dispositivo.

### RN-10 — Ubicación obtenida en la captura

**Estado:** Vigente · **Origen:** HU-05, HU-07

- La ubicación del reporte son las coordenadas GPS (latitud y longitud) obtenidas al capturar la evidencia.
- El usuario no puede sustituirlas introduciendo coordenadas manualmente.
- La ubicación permanece asociada al reporte durante todo su ciclo de vida.

### RN-11 — Orientación esperada por tipo de incidencia

**Estado:** Vigente · **Origen:** HU-06

Cada tipo de incidencia define la orientación del dispositivo durante la captura (RN-07), verificada con el acelerómetro. La **inclinación de la cámara trasera** se mide en grados: +90° apunta al suelo, 0° al horizonte y −90° al cielo. Se usa el promedio de las lecturas de ~0.5 s antes de disparar y el valor se guarda con la evidencia.

| Orientación | Condición |
| --- | --- |
| Hacia el suelo | Inclinación **≥ +45°** |
| Hacia arriba | Inclinación **≤ −20°** |
| Sin restricción | Cualquier valor, pero la lectura del acelerómetro debe existir (HU-08) |

Los umbrales son ajustables: viven en la configuración del servidor (`fixflow.orientacion.*`) y se cambian sin tocar código. Si la prueba en los teléfonos del equipo (signo del eje Z) muestra otros valores, se actualizan aquí y en el servidor.

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

**Estado:** Vigente · **Origen:** HU-09, HU-14, HU-20

Niveles: **Alta**, **Media** y **Baja**. La prioridad se asigna automáticamente y siempre se guarda el motivo que la determinó:

1. **Prioridad base por tipo** (RN-07) al crear la incidencia. Motivo: «Tipo de incidencia: *nombre*».
2. **Escalamiento por antigüedad:** si una incidencia lleva **7 días** sin llegar a *Resuelta* desde su creación o su último cambio de prioridad, sube un nivel (máximo Alta). Lo revisa un proceso diario. Motivo: «Sin resolver por más de 7 días».
3. **Reapertura:** una incidencia reabierta (HU-23) pasa a **Alta**. Motivo: «Reabierta por el ciudadano».
4. **Sin cambio manual:** el administrador no modifica la prioridad. Cada cambio automático queda en el historial (RN-15).

Fuera de alcance: duplicados por proximidad y votos de urgencia.

---

## Ciclo de vida de la incidencia

### RN-14 — Estados y transiciones

**Estado:** Vigente · **Origen:** HU-11, HU-13, HU-15, HU-16, HU-21, HU-23

| Estado | Significado |
| --- | --- |
| `PENDIENTE` | Creada, sin asignar |
| `ASIGNADA` | Tiene operativo responsable |
| `EN_PROCESO` | El operativo está trabajando en ella |
| `RESUELTA` | El operativo registró la solución |
| `REABIERTA` | El ciudadano indicó que el problema sigue |
| `CERRADA` | **Estado final** |

| De | A | Quién | HU |
| --- | --- | --- | --- |
| PENDIENTE | ASIGNADA | Administrador | HU-21 (asignar) |
| ASIGNADA / EN_PROCESO / REABIERTA | *(mismo estado)* | Administrador | HU-21 (reasignar: cambia el responsable, no el estado) |
| ASIGNADA | EN_PROCESO | Operativo asignado | HU-15 |
| REABIERTA | EN_PROCESO | Operativo asignado | HU-15 |
| EN_PROCESO | RESUELTA | Operativo asignado | HU-16 (solo registrando la solución) |
| RESUELTA | CERRADA | Ciudadano dueño | HU-13 (confirmar) |
| RESUELTA | CERRADA | Sistema | Cierre automático a los **7 días** sin respuesta del ciudadano |
| RESUELTA | REABIERTA | Ciudadano dueño | HU-23 |

```
PENDIENTE → ASIGNADA → EN_PROCESO → RESUELTA → CERRADA
                            ↑            │
                            └─ REABIERTA ←┘
```

- Cualquier otra transición se rechaza.
- La app solo muestra las acciones válidas para el rol y el estado actuales.
- Cada transición crea un registro en el historial (RN-15).

### RN-15 — Registro de cambios (trazabilidad)

**Estado:** Vigente · **Origen:** HU-09, HU-15, HU-16, HU-21, HU-22, HU-23

Toda acción sobre una incidencia queda registrada en su historial con **quién** la realizó y **fecha y hora**. Esto incluye: cambios de estado, cambios de prioridad, asignaciones y reasignaciones, registro de solución y reaperturas. El historial conserva la evidencia asociada a cada etapa y se presenta en orden cronológico. Las acciones automáticas se registran como hechas por el sistema.

### RN-16 — Asignación de incidencias

**Estado:** Vigente · **Origen:** HU-21

- Una incidencia se asigna a un miembro del personal operativo.
- Solo pueden asignarse incidencias pendientes de atención.
- Una incidencia puede reasignarse mientras esté asignada, en proceso o reabierta.
- **Personal operativo disponible** = cuenta **activa** (HU-24). Al asignar, el administrador ve la **carga actual** de cada operativo: número de incidencias en ASIGNADA, EN_PROCESO o REABIERTA. No hay límite máximo por operativo.

### RN-17 — Reapertura de incidencias

**Estado:** Vigente · **Origen:** HU-13, HU-23

- Solo el **ciudadano que creó el reporte** puede reabrirlo.
- Solo desde **RESUELTA**, es decir, antes del cierre automático (RN-14).
- La reapertura exige una **justificación de 10 a 500 caracteres**.
- Máximo **2 reaperturas** por incidencia; después, el ciudadano debe crear un reporte nuevo.
- Al reabrir: estado REABIERTA, prioridad Alta (RN-13), aviso al administrador y al operativo (RN-18) y registro en el historial (RN-15).

---

## Notificaciones

### RN-18 — Notificaciones de eventos

**Estado:** Vigente · **Origen:** HU-12, HU-21

- El ciudadano recibe una notificación por cada cambio de estado de su reporte, nunca duplicada para un mismo cambio.
- El personal operativo recibe una notificación cuando se le asigna una incidencia.
- Nadie recibe aviso de una acción que él mismo realizó.

| Evento | Destinatario |
| --- | --- |
| Asignación | Operativo asignado y ciudadano (cambió el estado) |
| Reasignación | Operativo nuevo |
| Cambio de estado, solución y cierre automático | Ciudadano dueño |
| Reapertura | Administradores y operativo asignado |

El canal se define en el requisito no funcional de notificaciones (RNF-06).
