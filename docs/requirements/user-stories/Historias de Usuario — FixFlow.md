# Historias de Usuario — FixFlow

## Épica 1. Gestión de acceso y usuarios

### HU-01 — Registro de ciudadano

**Como** ciudadano
**Quiero** crear una cuenta en FixFlow
**Para** poder registrar incidencias y consultar el seguimiento de mis reportes.

**Criterios de aceptación:**

* El usuario debe proporcionar los datos requeridos para crear su cuenta.
* El sistema debe validar que los campos obligatorios estén completos.
* El sistema debe evitar el registro de un correo electrónico que ya exista.
* La contraseña debe cumplir con los requisitos mínimos de seguridad establecidos.
* Al completar correctamente el registro, el sistema debe crear el usuario con el rol **Ciudadano**.
* El usuario debe poder iniciar sesión posteriormente con sus credenciales.

---

### HU-02 — Inicio de sesión

**Como** usuario registrado
**Quiero** iniciar sesión en la aplicación
**Para** acceder a las funcionalidades correspondientes a mi rol.

**Criterios de aceptación:**

* El usuario debe ingresar sus credenciales.
* El sistema debe validar las credenciales contra la información registrada.
* Si son correctas, debe permitir el acceso.
* Si son incorrectas, debe mostrar un mensaje indicando que las credenciales no son válidas.
* El sistema debe mostrar únicamente las funcionalidades correspondientes al rol del usuario.

---

# Épica 2. Registro de incidencias

### HU-03 — Crear reporte de incidencia

**Como** ciudadano
**Quiero** registrar una incidencia desde mi teléfono
**Para** informar a las autoridades sobre un problema presente en el entorno urbano.

**Criterios de aceptación:**

* El ciudadano debe poder seleccionar el tipo de incidencia.
* El sistema debe permitir agregar una descripción del problema.
* El reporte debe incluir evidencia fotográfica.
* El sistema debe obtener la ubicación mediante GPS.
* El sistema debe asociar automáticamente la fecha y hora del reporte.
* El ciudadano debe poder revisar la información antes de enviarla.
* Al confirmar el envío, el sistema debe generar un identificador único para la incidencia.

---

### HU-04 — Capturar evidencia fotográfica en vivo

**Como** ciudadano
**Quiero** tomar la fotografía directamente desde la aplicación
**Para** proporcionar evidencia actual de la incidencia reportada.

**Criterios de aceptación:**

* La fotografía debe capturarse utilizando la cámara del dispositivo.
* El ciudadano no debe poder seleccionar una fotografía almacenada previamente en el dispositivo como evidencia principal.
* La aplicación debe solicitar permisos para utilizar la cámara.
* Si el permiso es rechazado, el sistema debe informar que no es posible continuar con la captura.
* La fotografía debe asociarse directamente con el reporte que se está creando.

---

### HU-05 — Registrar ubicación automáticamente

**Como** ciudadano
**Quiero** que la aplicación obtenga automáticamente mi ubicación al realizar un reporte
**Para** evitar tener que introducir manualmente dónde ocurrió la incidencia.

**Criterios de aceptación:**

* La aplicación debe solicitar acceso a la ubicación del dispositivo.
* Al capturar la evidencia, el sistema debe obtener las coordenadas GPS disponibles.
* La latitud y longitud deben asociarse al reporte.
* El ciudadano debe poder visualizar la ubicación obtenida antes de enviar el reporte.
* Si no es posible obtener la ubicación, el sistema debe informar al ciudadano y evitar enviar un reporte incompleto.

---

# Épica 3. Validación de evidencia

### HU-06 — Validar orientación del dispositivo

**Como** sistema
**Quiero** obtener información del acelerómetro durante la captura de evidencia
**Para** verificar que la orientación del dispositivo sea congruente con el tipo de incidencia reportada.

**Criterios de aceptación:**

* El sistema debe obtener los datos del acelerómetro durante la captura.
* La aplicación debe comparar la orientación registrada con las condiciones establecidas para el tipo de incidencia.
* Para incidencias que requieren una captura hacia el suelo, como un bache, la aplicación debe verificar la orientación correspondiente.
* Para incidencias que requieren una captura hacia arriba, como una luminaria, debe verificarse la orientación correspondiente.
* Si la orientación no cumple con las condiciones establecidas, el sistema debe solicitar al ciudadano realizar nuevamente la captura.

---

### HU-07 — Asociar coordenadas a la evidencia

**Como** sistema
**Quiero** asociar la ubicación GPS obtenida durante la captura con la evidencia
**Para** conservar información sobre el lugar donde fue registrada.

**Criterios de aceptación:**

* La evidencia debe quedar vinculada a las coordenadas obtenidas durante la captura.
* La ubicación debe almacenarse junto con la información del reporte.
* El sistema no debe permitir que el usuario introduzca manualmente unas coordenadas diferentes como sustitución de la ubicación obtenida durante la captura.
* La información de ubicación debe permanecer asociada al reporte durante su ciclo de vida.

---

### HU-08 — Validar evidencia del reporte

**Como** sistema
**Quiero** verificar que la evidencia requerida haya sido obtenida correctamente
**Para** evitar que se registren reportes incompletos o que no cumplan las condiciones establecidas.

**Criterios de aceptación:**

* El sistema debe verificar que el reporte cuente con evidencia fotográfica.
* La evidencia debe haber sido capturada mediante la cámara de la aplicación.
* El sistema debe verificar que exista información de ubicación asociada.
* El sistema debe verificar que se hayan obtenido los datos requeridos del acelerómetro.
* Si la evidencia no cumple las condiciones establecidas, el sistema debe solicitar al ciudadano realizar nuevamente la captura.
* El reporte no debe enviarse hasta cumplir con los requisitos establecidos.

---

### HU-09 — Determinar prioridad de una incidencia

**Como** administrador municipal
**Quiero** que las incidencias sean clasificadas de acuerdo con criterios de prioridad
**Para** identificar los problemas que requieren mayor atención.

**Criterios de aceptación:**

* Deben existir reglas previamente definidas para determinar los niveles de prioridad.
* La prioridad debe considerar las características y tipo de incidencia.
* Cuando una incidencia cumpla las condiciones establecidas para una prioridad determinada, el sistema debe asignarla automáticamente.
* Una incidencia clasificada como **Prioridad Alta** debe ser identificable visualmente en el panel administrativo.
* El cambio de prioridad debe quedar registrado en el historial de la incidencia.

---

# Épica 4. Seguimiento ciudadano

### HU-10 — Consultar mis reportes

**Como** ciudadano
**Quiero** consultar los reportes que he realizado
**Para** conocer el estado de las incidencias que he registrado.

**Criterios de aceptación:**

* El ciudadano debe visualizar únicamente sus propios reportes.
* Cada reporte debe mostrar información básica como identificador, tipo de incidencia, fecha, ubicación y estado.
* El sistema debe permitir consultar el detalle de cada reporte.
* Los reportes deben mostrar su estado actual.

---

### HU-11 — Consultar estado de una incidencia

**Como** ciudadano
**Quiero** conocer el estado de mi reporte
**Para** saber si ya fue revisado, atendido o solucionado.

**Criterios de aceptación:**

* El reporte debe mostrar un estado actualizado.
* El ciudadano debe poder consultar los cambios realizados.
* El sistema debe conservar un historial de los estados de la incidencia.
* Cuando el personal operativo actualice el reporte, el nuevo estado debe reflejarse en la aplicación.

---

### HU-12 — Recibir notificaciones

**Como** ciudadano
**Quiero** recibir notificaciones cuando cambie el estado de mi reporte
**Para** mantenerme informado sobre su atención.

**Criterios de aceptación:**

* El ciudadano debe recibir una notificación cuando su reporte cambie de estado.
* La notificación debe indicar el nuevo estado.
* Al seleccionar la notificación, el ciudadano debe poder acceder al reporte correspondiente.
* El sistema no debe enviar notificaciones duplicadas para un mismo cambio de estado.

---

### HU-13 — Validar resolución

**Como** ciudadano
**Quiero** revisar la evidencia de la solución realizada
**Para** confirmar que la incidencia fue atendida.

**Criterios de aceptación:**

* El ciudadano debe poder consultar la evidencia proporcionada por el personal operativo.
* Debe visualizar el estado final de la incidencia.
* Debe existir una opción para confirmar que la solución fue recibida.
* Si el ciudadano considera que el problema continúa, debe poder indicarlo mediante el mecanismo definido por el sistema.

---

# Épica 5. Atención de incidencias

### HU-14 — Consultar incidencias asignadas

**Como** personal operativo
**Quiero** visualizar las incidencias que debo atender
**Para** organizar mi trabajo y atender los problemas reportados.

**Criterios de aceptación:**

* El personal operativo debe visualizar las incidencias que le fueron asignadas.
* Cada incidencia debe mostrar su información relevante.
* Debe poder consultar la evidencia fotográfica.
* Debe poder consultar la ubicación.
* Debe poder identificar la prioridad de cada incidencia.
* Las incidencias de mayor prioridad deben poder distinguirse de las demás.

---

### HU-15 — Actualizar estado de una incidencia

**Como** personal operativo
**Quiero** actualizar el estado de una incidencia
**Para** informar el avance de su atención.

**Criterios de aceptación:**

* El personal operativo debe poder cambiar el estado de una incidencia.
* Cada cambio debe quedar registrado.
* El sistema debe almacenar la fecha y hora del cambio.
* El ciudadano debe poder consultar posteriormente el nuevo estado.
* El cambio debe respetar los estados y transiciones definidos por el sistema.

---

### HU-16 — Registrar solución de una incidencia

**Como** personal operativo
**Quiero** registrar la solución aplicada a una incidencia
**Para** documentar cómo fue atendido el problema.

**Criterios de aceptación:**

* El personal operativo debe poder agregar una descripción de la solución.
* Debe poder adjuntar evidencia fotográfica del trabajo realizado.
* La evidencia debe quedar asociada a la incidencia.
* El sistema debe registrar quién realizó la actualización.
* La incidencia debe poder pasar al estado correspondiente una vez registrada la solución.

---

# Épica 6. Administración municipal

### HU-17 — Visualizar incidencias municipales

**Como** administrador municipal
**Quiero** visualizar las incidencias registradas
**Para** conocer el estado general de los problemas reportados en el municipio.

**Criterios de aceptación:**

* El administrador debe poder consultar las incidencias registradas.
* Debe poder visualizar su ubicación.
* Debe poder consultar su estado.
* Debe poder consultar su prioridad.
* Debe poder acceder al detalle de cada incidencia.

---

### HU-18 — Filtrar incidencias

**Como** administrador municipal
**Quiero** filtrar las incidencias
**Para** localizar rápidamente los reportes que requieren atención específica.

**Criterios de aceptación:**

* El administrador debe poder filtrar por estado.
* Debe poder filtrar por tipo de incidencia.
* Debe poder filtrar por prioridad.
* Debe poder consultar incidencias dentro de una zona determinada.
* Los resultados deben actualizarse de acuerdo con los filtros seleccionados.

---

### HU-19 — Consultar indicadores de atención

**Como** administrador municipal
**Quiero** consultar métricas sobre las incidencias
**Para** conocer el comportamiento y desempeño de la atención de problemas urbanos.

**Criterios de aceptación:**

* El sistema debe mostrar la cantidad de incidencias registradas.
* Debe mostrar la cantidad de incidencias atendidas y pendientes.
* Debe permitir consultar los tiempos de resolución.
* Debe permitir identificar las incidencias según su prioridad.
* Los indicadores deben actualizarse conforme se registren nuevas incidencias y cambios de estado.

---

### HU-20 — Consultar incidencias prioritarias

**Como** administrador municipal
**Quiero** identificar las incidencias con mayor prioridad
**Para** facilitar la organización de las actividades de atención.

**Criterios de aceptación:**

* El sistema debe mostrar las incidencias clasificadas como prioritarias.
* Debe indicar el motivo o condición que determinó su prioridad cuando corresponda.
* Debe permitir acceder al detalle de cada incidencia.
* El administrador debe poder consultar su ubicación y evidencia.

---

### HU-21 — Asignar incidencia a personal operativo

**Como** administrador municipal
**Quiero** asignar una incidencia a un miembro del personal operativo
**Para** garantizar que el problema sea atendido por el personal correspondiente.

**Criterios de aceptación:**

* El administrador debe poder seleccionar una incidencia pendiente de atención.
* El sistema debe permitir seleccionar un miembro del personal operativo disponible.
* El sistema debe registrar la asignación de la incidencia.
* La incidencia debe aparecer en la lista de incidencias asignadas del personal operativo.
* El personal operativo debe recibir una notificación sobre la nueva asignación.
* El administrador debe poder consultar quién está encargado de atender cada incidencia.
* El sistema debe registrar la fecha y hora de la asignación.
* El administrador debe poder reasignar una incidencia cuando sea necesario.

---

# Épica 7. Historial y trazabilidad

### HU-22 — Consultar historial de una incidencia

**Como** usuario autorizado
**Quiero** consultar el historial de una incidencia
**Para** conocer las acciones realizadas desde su creación hasta su resolución.

**Criterios de aceptación:**

* El sistema debe registrar los cambios de estado.
* Debe registrar quién realizó cada modificación.
* Debe registrar la fecha y hora de cada acción.
* Debe conservar la evidencia asociada a las diferentes etapas.
* El historial debe presentarse en orden cronológico.

---

# Épica 8. Control y continuidad de incidencias

### HU-23 — Reabrir una incidencia no resuelta

**Como** ciudadano
**Quiero** indicar que una incidencia no fue solucionada correctamente
**Para** solicitar que vuelva a ser atendida.

**Criterios de aceptación:**

* El ciudadano debe poder indicar que la incidencia continúa.
* El sistema debe solicitar una justificación o descripción del problema persistente.
* La incidencia debe cambiar al estado correspondiente para continuar su atención.
* El personal operativo debe poder consultar el motivo de la reapertura.
* El administrador debe recibir o poder consultar la actualización.
* El sistema debe conservar la trazabilidad de la reapertura.

---
