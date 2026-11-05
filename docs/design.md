# Diseño — FixFlow

Guía completa para diseñar todas las pantallas de FixFlow. Este documento se basta solo: no hace falta consultar ningún otro archivo.

---

## 1. El producto

FixFlow es una app **Android** (teléfono de **390 × 844**) para reportar problemas urbanos como baches, luminarias apagadas o fugas. Hay tres roles en la misma app:

| Rol | Qué hace en la app |
| --- | --- |
| **Ciudadano** | Reporta un problema con foto tomada en el momento, GPS e inclinación del teléfono. Sigue su reporte, confirma la solución o lo reabre |
| **Personal operativo** | Ve solo las incidencias que le asignaron, las atiende y registra la solución con foto |
| **Administrador** | Ve todas las incidencias, las asigna al personal, da de alta operativos, administra los tipos de incidencia y consulta indicadores |

**Tres principios de diseño:**

1. **Una idea por bloque.** Cada tarjeta o sección responde una sola pregunta: «¿cómo va?», «¿dónde fue?», «¿qué pasó?».
2. **El texto y el color informan; los iconos solo navegan.** Si quitas el icono y la línea se sigue entendiendo, el icono sobra.
3. **Aire antes que bordes.** Los grupos se separan con espacio. Los bordes y divisores se usan solo cuando el espacio no alcanza.

**Tono visual:** moderno, minimalista, claro y sobrio. Sin degradados, sombras decorativas, círculos de fondo ni emoji.

---

## 2. Reglas del negocio que se ven en pantalla

### Estados de una incidencia

| Estado | Significa |
| --- | --- |
| Pendiente | Creada, todavía sin responsable |
| Asignada | Ya tiene un operativo responsable |
| En proceso | El operativo la está atendiendo |
| Resuelta | El operativo registró la solución |
| Reabierta | El ciudadano dijo que el problema sigue |
| Cerrada | Estado final |

### Quién puede hacer qué

| Estado actual | Acción | Quién | Pasa a |
| --- | --- | --- | --- |
| Pendiente | Asignar | Administrador | Asignada |
| Asignada, En proceso o Reabierta | Reasignar (cambia el responsable, no el estado) | Administrador | El mismo |
| Asignada o Reabierta | Iniciar atención | Operativo asignado | En proceso |
| En proceso | Registrar solución (con foto y descripción) | Operativo asignado | Resuelta |
| Resuelta | Confirmar resolución | Ciudadano que la reportó | Cerrada |
| Resuelta | Reabrir (con justificación) | Ciudadano que la reportó | Reabierta |
| Resuelta | Pasan 7 días sin respuesta del ciudadano | Sistema | Cerrada |

**Cada pantalla muestra solo las acciones válidas para el rol y el estado.** Si no hay ninguna, no hay botón de acción.

### Prioridad

- Tiene tres niveles: alta, media y baja. Es automática y el administrador no la cambia.
- Siempre se muestra con su **motivo**:
  - «Tipo de incidencia: Bache». Es la prioridad inicial, que depende del tipo.
  - «Sin resolver por más de 7 días». La prioridad sube un nivel.
  - «Reabierta por el ciudadano». Pasa a alta.

### Reporte y evidencia

- **Foto:** se toma siempre con la cámara en ese momento. **Nunca se elige de la galería.**
- **Ubicación:** es el GPS del momento de la foto. No se puede escribir ni editar.
  - Se muestra como dirección («Av. Juárez 1045, Centro»), con un minimapa.
  - Si no se consigue la dirección: «Dirección no disponible».
- **Inclinación:** según el tipo de incidencia, el teléfono debe apuntar de cierta forma.
  - Hacia el suelo: inclinación de +45° o más.
  - Hacia arriba: −20° o menos.
  - Sin restricción: cualquier ángulo, pero se mide igual.
  - Escala: +90° es el suelo, 0° el horizonte y −90° el cielo.
- **Descripción:** obligatoria, hasta 500 caracteres.
- **Datos que pone el servidor:** la fecha y hora se asignan solas. El folio lo genera el servidor con el formato `FX-AAAA-NNNNNN`, por ejemplo `FX-2026-000142`.
- **Sin modo offline:** no se guardan borradores en el teléfono. Si falla la conexión al enviar, los datos se conservan mientras la app siga abierta.

### Reapertura

- Solo la puede hacer el ciudadano que creó el reporte, y solo cuando está en Resuelta.
- Requiere una justificación de 10 a 500 caracteres. **No lleva foto.**
- Se permiten como máximo 2 reaperturas por reporte.

### Solución

El operativo registra **una sola foto** y una descripción obligatoria de hasta 500 caracteres.

### Privacidad

| Rol | Ve |
| --- | --- |
| Ciudadano | Solo sus propios reportes |
| Operativo | Solo sus incidencias asignadas, **sin el nombre ni los datos del ciudadano**. En el historial, el ciudadano aparece como «Ciudadano» |
| Administrador | Todo, incluidos los nombres |

### Cuentas

- **Contraseña:** mínimo 8 caracteres, con letras y números. Al cambiarla, debe ser distinta de la actual.
- **Alta de operativos:** el administrador los da de alta con una contraseña temporal. Una cuenta desactivada no puede entrar ni recibir asignaciones.
- **Datos que no se editan:** el correo y el rol no se pueden cambiar desde la app.

### Avisos

- Solo hay bandeja dentro de la app. No hay notificaciones push.
- Un punto naranja marca que hay avisos no leídos.
- Estos son los únicos avisos que existen, con el texto que manda el servidor:

| Recibe | Título | Mensaje |
| --- | --- | --- |
| Ciudadano | Tu reporte cambió de estado | Tu reporte FX-2026-000123 ahora está En proceso |
| Ciudadano | Tu reporte fue resuelto | Revisa la solución de FX-2026-000097 y confírmala o reábrela |
| Operativo | Nueva incidencia asignada | Se te asignó la incidencia FX-2026-000131 (Bache) |
| Operativo y administrador | Incidencia reabierta | El ciudadano reabrió FX-2026-000097: «motivo» |

**El administrador solo recibe avisos de reapertura.**

### Tipos de incidencia (catálogo)

| Tipo | Código | Orientación de la foto | Prioridad base |
| --- | --- | --- | --- |
| Bache | BACHE | Hacia el suelo | Media |
| Luminaria apagada o dañada | LUMINARIA | Hacia arriba | Media |
| Fuga de agua | FUGA_AGUA | Sin restricción | Alta |
| Coladera sin tapa u obstruida | COLADERA | Hacia el suelo | Alta |
| Árbol o rama caída | ARBOL_CAIDO | Sin restricción | Alta |
| Señalamiento vial dañado | SENALAMIENTO | Sin restricción | Media |
| Banqueta dañada | BANQUETA | Hacia el suelo | Baja |
| Basura acumulada | BASURA | Sin restricción | Baja |
| Otro | OTRO | Sin restricción | Baja |

- **Código:** es fijo. Al crear un tipo es opcional: si se deja vacío, se genera del nombre («Fuga de agua» → FUGA_DE_AGUA). No se puede cambiar después.
- **Lo editable:** el nombre (hasta 80 caracteres), la orientación y la prioridad base.
- **Tipo desactivado:** ya no aparece al crear reportes, pero las incidencias que ya lo usan lo conservan.

### Fuera de alcance: no lo dibujes

- Micrófono, voz o dictado.
- Fotos de galería.
- Detección de reportes duplicados y votos.
- Rechazar reportes.
- Escribir coordenadas a mano.
- Cambiar la prioridad a mano.
- Notificaciones push.
- Modo offline.
- Botón «Cómo llegar».

---

## 3. Color

| Uso | Nombre | Valor |
| --- | --- | --- |
| Fondo de todas las pantallas | background | `#FFFFFF` (blanco; nunca gris, crema ni amarillento) |
| Tarjetas, hojas, campos, barra inferior | surface | `#FFFFFF`. Se separan del fondo con sombra, no con color |
| Sombra de tarjetas, hojas y grupos de filas | shadow | `0 1px 2px rgba(16,24,40,0.06), 0 4px 12px rgba(16,24,40,0.08)` |
| Divisores, línea del historial, barras de prioridad vacías | borderSubtle | `#E4E8EC` |
| Campos bloqueados, esqueletos de carga, minimapa cargando, miniatura sin foto | surfaceMuted | `#F2F4F7` |
| Borde de campos de formulario | border | `#C2C8D1` |
| Marca, botón primario, enlaces, pestaña activa, chip de filtro activo | primary | `#0B3C5D` |
| Acento: solo el botón Reportar y el punto de no leídos | accent | `#FF5A1F` |
| Texto sobre el acento | onAccent | `#1B1F24`. Nunca texto blanco sobre naranja: da 3.1:1 y no pasa la norma de accesibilidad |
| Texto principal | textPrimary | `#1B1F24` |
| Texto secundario | textSecondary | `#3D4652` |
| Fechas, folio, ayudas | textMuted | `#59616C` |
| Textos de ejemplo dentro de campos | placeholder | `#6B7380` |
| Error | error | `#B3261E` |
| Guía de inclinación válida en la cámara | guiaValida | `#7ED69A` |

**Estado y prioridad** (fondo / texto). Un color de estado nunca se usa para otra cosa:

| Etiqueta | Fondo | Texto |
| --- | --- | --- |
| Pendiente | `#ECEDEF` | `#4A5059` |
| Asignada | `#E7E9FB` | `#3341A6` |
| En proceso | `#E0F0FB` | `#0B5F94` |
| Resuelta | `#E2F3E5` | `#1E6B2C` |
| Reabierta | `#F3E5F7` | `#7B1F96` |
| Cerrada | `#E3E7EA` | `#37474F` |
| Prioridad alta | `#FDE4E1` | `#B3261E` |
| Prioridad media | `#FFEFD1` | `#8A5300` |
| Prioridad baja | `#E6ECEF` | `#45555E` |

**Proporción:**

- Casi todo es fondo, blanco y texto oscuro.
- El azul marino aparece en una acción por pantalla.
- El naranja aparece como mucho en un elemento.
- El fondo y las tarjetas son blancos: las tarjetas se separan con su sombra suave y con espacio.

---

## 4. Tipografía

**Plus Jakarta Sans** (Google Fonts). Mayúscula solo al inicio de cada texto, también en títulos.

| Estilo | Tamaño / interlineado | Peso | Uso |
| --- | --- | --- | --- |
| Título de pantalla | 24 / 30 | 800 | Saludo, título del detalle, cifras del panel |
| Título de sección | 17 / 24 | 700 | «Ubicación», «Fotos», «Historial» |
| Título de tarjeta | 16 / 22 | 700 | Nombre del tipo de incidencia |
| Cuerpo | 15 / 22 | 400 | Descripciones, comentarios |
| Meta | 13 / 18 | 500, `#59616C` | Folio, fechas, motivo de prioridad |
| Chip | 12 / 16 | 600 | Estado, prioridad, filtros |
| Botón | 17 / 22 | 700 | Botones |

- El folio y las cifras usan **números tabulares** de la misma fuente, no una fuente monoespaciada.
- No se usan etiquetas en mayúsculas como «ESTADO DEL REPORTE».
- Las descripciones largas se cortan con «…» a 1 línea en las tarjetas y se muestran completas en el detalle.

---

## 5. Espaciado, forma y profundidad

- **Base de 4:** 4 · 8 · 12 · 16 · 24 · 32.
- **Margen lateral de pantalla:** 20.
- **Tarjeta:** 16 de padding. 12 entre tarjetas. 32 entre secciones del detalle, con 12 entre el título de sección y su contenido.
- **Radios:**
  - 14 en tarjetas, botones, campos, minimapa y fotos.
  - 10 en miniaturas.
  - Píldora completa en chips.
- **Profundidad con sombras, no con bordes.** Tarjetas, hojas inferiores, grupos de filas, barra inferior y barra de acciones son blancas, sin borde, con la sombra de la sección 3 (la barra inferior y la de acciones, hacia arriba). Nunca borde y sombra en el mismo elemento. Los campos de formulario sí llevan borde y no llevan sombra.
- **Áreas táctiles** de al menos 48 × 48.

---

## 6. Logo e iconos

### Logo

- Un solo logo, básico: un cuadro `#0B3C5D` con esquinas redondeadas (radio de 25 % del lado) y, al centro, una **llave inglesa blanca** de trazo simple, que ocupa el 55 % del cuadro. Es el icono `build` de Material Symbols Rounded, outline.
- Sin degradados, sombras, naranja ni otros elementos.
- **Dónde va:**
  - Grande en A1 y A2.
  - A 32 px junto a «FixFlow» (16/800) en la barra superior de B1, D1 y E1.
- No se usa ningún otro símbolo de marca, como un pin de ubicación o una palomita.

### Iconos

- **Set:** Material Symbols Rounded, outline, 24 px, color `#3D4652` y el mismo grosor de trazo que la llave del logo. Nada de iconos rellenos, emoji ni de otros sets.
- **El mismo concepto lleva el mismo icono en los tres roles:**

| Concepto | Icono |
| --- | --- |
| Mis reportes, Asignadas, Incidencias | assignment |
| Inicio | home |
| Personal | group |
| Perfil | person |
| Avisos | notifications |
| Mapa | map |
| Reportar | add |
| Regresar | arrow_back |
| Cerrar cámara | close |
| Fila que navega | chevron_right |
| Mostrar contraseña | visibility |
| Sin conexión | wifi_off |
| Sin permiso de cámara | no_photography |
| Ubicación no disponible | location_off |
| Sin reportes | inbox |

**Solo hay iconos en:**

- Barra inferior.
- Barra superior: regresar, perfil y campana.
- Botón Reportar.
- Cerrar la cámara y mostrar la contraseña.
- Pantallas de estado A4, B6, B7 y C4, a 48 px.
- Chevron de las listas A3, E8 y E10.

**Nunca** delante de fechas, direcciones, tipos o folios, ni en títulos de sección, chips o botones con texto. Máximo un icono por fila de texto.

---

## 7. Componentes

### Barra superior

- Fondo blanco, sin elevación y sin cambio de color al desplazarse. Nunca azul.
- **Pantallas principales** (B1, D1, E1): logo + «FixFlow» a la izquierda. A la derecha, un círculo de 40 con borde `#E4E8EC`:
  - Ciudadano y operativo: botón de perfil.
  - Admin: campana que abre Avisos, con el punto naranja si hay no leídos.
- **Pantallas interiores:** flecha de regresar y título de 17/700. Una acción menor, como «Marcar todo como leído», va como botón de texto a la derecha.

### Barra de navegación inferior

| Rol | Pestañas |
| --- | --- |
| Ciudadano | Mis reportes · **Reportar** (botón central naranja de 56) · Avisos |
| Personal operativo | Asignadas · Mapa · Avisos |
| Administrador | Inicio · Personal · Incidencias · Perfil |

- Fondo blanco con la sombra hacia arriba.
- La pestaña activa va en `#0B3C5D` con su etiqueta en 600; las inactivas, en `#59616C`.
- Si hay avisos no leídos, la pestaña Avisos lleva un punto naranja de 8 px sin número.
- **Solo aparece en las pantallas que son pestañas:** B1, C1, C4, D1, D5, D6, E1, E2, E8 y A3 cuando la ve el administrador. Todas las demás llevan flecha de regresar y no tienen barra.

### Estado y prioridad: dos indicadores distintos

- **Estado = píldora con texto:** 24 de alto, 10 de padding horizontal, 12/600, con el par de colores de la sección 3. Sin punto y sin icono. Textos: Pendiente · Asignada · En proceso · Resuelta · Reabierta · Cerrada.
- **Prioridad = símbolo, nunca píldora:** 3 barras verticales de 4 px de ancho y 6, 10 y 14 px de alto, separadas 2 px, con esquinas de 2 px.
  - Alta: 3 llenas en `#B3261E`.
  - Media: 2 llenas en `#8A5300` y 1 en `#E4E8EC`.
  - Baja: 1 llena en `#45555E` y 2 en `#E4E8EC`.
  - Lleva la etiqueta accesible «Prioridad alta», «Prioridad media» o «Prioridad baja».
- **En tarjetas:** la píldora de estado a la izquierda y el símbolo de prioridad a la derecha, en la misma fila.
- **En detalles:** el símbolo seguido del texto «Prioridad alta» (15/600, sin fondo) y, debajo, el motivo en meta.

### Chips de filtro (B1, D1, E2)

- **Activo:** fondo `#0B3C5D` y texto blanco. **Inactivo:** fondo blanco, borde `#E4E8EC` y texto `#3D4652`.
- Fila con desplazamiento horizontal. El primero es «Todas». Sin números dentro.

### Tarjeta de incidencia (B1, D1, E2)

```text
┌─────────────────────────────────────────────┐
│ Resuelta   Prioridad alta                   │  chips
│                                             │  12
│ ┌───────┐  Fuga de agua                     │  título de tarjeta
│ │ foto  │  Calle Morelos 892, Centro        │  cuerpo, 1 línea
│ │  64   │  FX-2026-000097 · hoy, 11:30      │  meta
│ └───────┘                                   │
│                                             │  16
│ ┌─────────────────────────────────────────┐ │
│ │          Confirmar resolución           │ │  solo si hay acción
│ └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

- **Toda la tarjeta abre el detalle**, así que no hay enlaces del tipo «Ver folio ›».
- **Miniatura:** 64 × 64 con radio 10. Sin foto, se muestra `#EEF1F4`.
- **Contenido:** título con el tipo, dirección en 1 línea y meta con «folio · última actualización». El motivo de prioridad aparece como otra línea de meta, solo si no es el del tipo.
- **Botón de acción**, solo si quien ve la tarjeta puede actuar:
  - Ciudadano con su reporte en Resuelta: «Confirmar resolución».
  - Operativo con la incidencia en Asignada o Reabierta: «Iniciar atención».
- **En D1:** se agrega la distancia al final de la meta («a 1.2 km»).

### Secciones del detalle (C2, D2, D4, E4)

De arriba hacia abajo, sobre el fondo y sin envolver todo en una tarjeta:

1. **Encabezado:** chips de estado y prioridad, el tipo como Título de pantalla, la meta «FX-2026-000123 · Reportado el 28 oct 2026, 09:15» y la descripción en cuerpo.
2. **Ubicación:** la dirección en cuerpo y, debajo, un minimapa de 160 de alto con el punto de la captura.
3. **Fotos:**
   - Dos columnas en proporción 4:3, «Reporte» y «Solución», con la etiqueta en una píldora blanca sobre la esquina superior izquierda.
   - Debajo de cada una, solo la fecha.
   - Si todavía no hay solución, la foto del reporte va a todo el ancho.
4. **Historial:**
   - Línea vertical de 2 px `#E4E8EC`, con un punto de 10 del color del estado nuevo.
   - Cada evento lleva un título en 15/600 («Pasó a En proceso», «Solución registrada»), el comentario en `#3D4652` y la meta «29 oct, 14:00 · Luis Ramírez». Las acciones automáticas van firmadas por «Sistema».
   - Con más de 4 eventos se muestran los 3 más recientes y «Ver todo».
5. **Barra de acciones:**
   - Fija abajo, fondo blanco, borde superior `#E4E8EC` y 16 de padding.
   - Lleva un botón primario y, si aplica, uno secundario con contorno.
   - Si no hay acción válida, no hay barra.

### Botones

| Tipo | Estilo | Uso |
| --- | --- | --- |
| Primario | Relleno `#0B3C5D`, texto blanco, 54 de alto, radio 14 | Una sola por pantalla |
| Secundario | Contorno de 1.5 px `#0B3C5D`, texto azul marino, 54 de alto | Alternativa a la primaria |
| Texto | Texto `#0B3C5D` en 700, sin fondo | Acciones menores: «Ver todo», «Marcar todo como leído», «Cancelar» en diálogos |
| Destructivo | Relleno `#B3261E`, texto blanco, 54 de alto, radio 14 | «Cerrar sesión» en A3 y la confirmación de A3c, E8a y E12a. En E12, «Desactivar» va como botón de texto rojo que abre E12a |
| Reportar | Círculo naranja de 56 con «+» y la etiqueta «Reportar» debajo | Solo en la barra del ciudadano |

Los botones no llevan iconos ni flechas junto al texto.

### Formularios

- La etiqueta va encima del campo (14/600), no flotante.
- **Campos:** blancos, con borde de 1.5 px `#C2C8D1`, radio 14 y 54 de alto. Al tener el foco, el borde pasa a 2 px `#0B3C5D`.
- 16 entre campos. El botón primario va al final, a todo el ancho.
- **Ayuda y error:** debajo del campo, en 13. El error va en `#B3261E` y reemplaza a la ayuda.
- **Contador de caracteres:** a la derecha de la ayuda, solo en descripción (0/500) y justificación (10 a 500).
- **Campo bloqueado:** fondo `#EEF1F4`, texto `#59616C` y sin icono de candado.
- **Selección de una opción:**
  - Hasta 4 opciones: chips grandes de 40 de alto. Es el caso de la orientación y la prioridad base.
  - Más opciones: una hoja inferior con lista. Es el caso de los 9 tipos.

### Avisos (C1, D6, E7)

- Filas sin tarjeta, con un divisor `#E4E8EC` entre ellas, agrupadas en «Hoy» y «Esta semana».
- Cada fila lleva un título en 15/600, el mensaje en 1–2 líneas y la meta con «hace 2 h».
- **No leído:** punto naranja de 8 a la izquierda y título en 700. **Leído:** sin punto y título en 500.
- «Marcar todo como leído» va como botón de texto en la barra superior.

### Panel del admin (E1)

- Arriba, 4 cifras en una cuadrícula de 2 × 2: Registradas · Pendientes · En atención · Atendidas. Cada cifra en Título de pantalla, con su etiqueta en meta, en tarjetas blancas sin color.
- Debajo:
  - Tiempo de resolución: promedio y máximo, en horas.
  - Conteo por prioridad: una barra apilada horizontal con los 3 colores de prioridad y su leyenda.
- Al final, «Prioridad alta sin atender»: hasta 5 tarjetas, cada una con «Asignar», y «Ver todas».
- Acceso «Catálogo de tipos» como fila con chevron.

### Cámara (B3, B3b, B3c, B3d, D3a)

- Es la única pantalla oscura, con texto blanco. La imagen de la cámara cubre toda la pantalla, todo el alto y todo el ancho, sin un alto fijo, marcos, bordes redondeados, padding ni barras blancas. Los controles van encima de la imagen.
- **No lleva:** galería, miniatura de la última foto, voltear cámara, flash, zoom, modos, marcas de agua ni datos técnicos (coordenadas, precisión, azimut).
- **Arriba:** botón de cerrar (×) y una píldora con el tipo y la instrucción: «Bache · apunta hacia el suelo».
- **Abajo, la guía de inclinación:**
  - Barra horizontal de Cielo a Suelo, con la zona válida marcada y el ángulo actual en grande.
  - La zona se pinta de `#7ED69A` cuando la inclinación está en rango.
- **Disparador:** blanco de 72. Fuera de rango, desactivado al 40 % de opacidad.
- **Bajo el disparador:** una línea de texto blanco con la instrucción. Además, «GPS listo» como texto, sin icono.

### Diálogos de confirmación (A3c, E8a, E12a, iniciar atención)

- Hoja inferior blanca con título (17/700), una línea de explicación y dos botones: «Cancelar» como texto y la acción.
- Si la acción es destructiva, va en `#B3261E`.
- Sin icono grande.

### Estados de carga y mensajes

- **Primera carga:** 3 tarjetas esqueleto en `#EEF1F4`.
- **Acción en curso:** su botón se desactiva y muestra un indicador circular de 20.
- **Confirmaciones y errores que no bloquean:** un snackbar con el texto del servidor.

---

## 8. Textos

- Español de México, tuteo y frases cortas. Sin emoji y sin signos de exclamación.
- El ciudadano dice **«reporte»**; el operativo y el administrador dicen **«incidencia»**.
- **Nunca uses:** caso, ticket, solicitud, cuadrilla, inspector, «Verificado», «Vecina activa», etapas, «Rastrear», zonas con nombre ni «Actualizado hace…».
- **Fechas en 24 h:** «hoy, 11:30», «ayer, 18:05», «28 oct 2026, 09:15». En avisos: «hace 20 min», «hace 2 h».
- **Folio** siempre completo: `FX-2026-000123`. Nunca «#2026-…».
- **Dirección:** «Calle y número, Colonia».
- **Carga de un operativo:** «3 incidencias activas».
- Nunca muestres números de reglas, textos entre corchetes ni notas de prototipo.
- **Botones, con el mismo texto en todas las pantallas:** Iniciar sesión · Crear cuenta · Guardar cambios · Cambiar contraseña · Cerrar sesión · Cancelar · Reportar · Tomar foto · Volver a capturar · Revisar y enviar · Enviar reporte · Ver mi reporte · Hacer un reporte · Confirmar resolución · El problema sigue · Reabrir reporte · Iniciar atención · Registrar solución · Enviar solución · Asignar · Reasignar · Dar de alta · Agregar tipo · Guardar tipo · Desactivar · Reintentar · Dar permiso · Ver todas · Ver detalle · Marcar todo como leído.
- No se usa «Aceptar», «OK», «Sí, confirmar» ni «No, sigue igual».

---

## 9. Datos de ejemplo (iguales en todas las pantallas)

- **Ciudadana:** Ana López Ruiz · ana@mail.com
- **Operativos:** Luis Ramírez, Diana Ortega y Jorge Salas (activos); Raúl Medina (inactivo)
- **Administradora:** Marta
- **Indicadores:**
  - 128 registradas = 23 pendientes + 8 en atención + 97 atendidas.
  - Por prioridad: alta 12 · media 58 · baja 58.
  - Tiempo de resolución: promedio 77 h · máximo 312 h.

| Folio | Tipo | Estado | Prioridad · motivo | Responsable |
| --- | --- | --- | --- | --- |
| FX-2026-000142 | Bache | Pendiente | Media · Tipo de incidencia: Bache | — (la que Ana envía en B2 → B5) |
| FX-2026-000123 | Bache | En proceso | Media · Tipo de incidencia: Bache | Luis Ramírez |
| FX-2026-000118 | Luminaria apagada o dañada | Asignada | Media · Tipo de incidencia: Luminaria apagada o dañada | Luis Ramírez |
| FX-2026-000097 | Fuga de agua | Resuelta en C2; Reabierta en C3, D4 y E7 | Alta · Tipo de incidencia: Fuga de agua (al reabrir: Reabierta por el ciudadano) | Luis Ramírez |
| FX-2026-000131 | Bache | Asignada | Alta · Sin resolver por más de 7 días | Luis Ramírez |
| FX-2026-000140 | Bache | Pendiente | Alta · Sin resolver por más de 7 días | — |
| FX-2026-000137 | Fuga de agua | Pendiente | Alta · Tipo de incidencia: Fuga de agua | — |

Cada folio tiene su propia dirección y descripción; no repitas una descripción en dos folios.

---

## 10. Pantallas (43)

Cada pantalla es un tablero de 390 × 844 con su código y nombre en el título, por ejemplo «B3c · Cámara: hacia arriba». Van en filas por grupo: A, B, C, D y E.

### A · Acceso y perfil (todos los roles)

- **A1 Login:**
  - Muestra: logo grande, «Hola de nuevo», correo, contraseña con botón de mostrar, «Iniciar sesión» y «¿No tienes cuenta? Crea una».
  - Acciones: Iniciar sesión → B1, D1 o E1 según el rol; Crea una → A2.
- **A1b Login con error:** A1 con los dos campos en borde de 2 px `#B3261E` y, debajo del campo de contraseña, el texto rojo de 13 px «Correo o contraseña incorrectos». Sin banner. Variante: «Tu cuenta está desactivada. Habla con el administrador.»
- En A1 y A1b no hay «¿Olvidaste tu contraseña?»: la recuperación de contraseña no existe en la v1.
- **A2 Registro:**
  - Muestra: nombre y apellidos, correo, contraseña (con la ayuda «Mínimo 8 caracteres, con letras y números»), confirmar contraseña (con el error de ejemplo «Las contraseñas no coinciden»), «Crear cuenta» y «¿Ya tienes cuenta? Inicia sesión».
  - Acciones: Crear cuenta → A1 con el snackbar «Cuenta creada. Inicia sesión.».
- **A3 Perfil:**
  - Muestra: iniciales en un círculo, nombre, correo, chip de rol; filas «Editar mis datos» y «Cambiar contraseña» con chevron; versión de la app; «Cerrar sesión» destructivo al final.
  - Para el ciudadano y el operativo se abre desde el botón de perfil, con flecha de regresar. Para el admin es una pestaña, con barra.
- **A3a Editar mis datos:**
  - Muestra: nombre, apellidos, correo bloqueado y la nota «El correo y el rol no se pueden cambiar desde la app».
  - Acciones: Guardar cambios → A3; Cancelar → A3.
- **A3b Cambiar contraseña:**
  - Muestra: contraseña actual, nueva y confirmar; requisitos sin iconos («Al menos 8 caracteres», «Letras y números», «Distinta de la actual»), con los cumplidos en verde.
  - Acciones: Cambiar contraseña → A3.
- **A3c Confirmar cierre de sesión:**
  - Muestra: diálogo «¿Cerrar sesión?» con «Tendrás que escribir tu correo y contraseña para volver a entrar.».
  - Acciones: Cancelar → A3; Cerrar sesión → A1.
- **A4 Sin conexión:**
  - Muestra: icono wifi_off, «Sin conexión» y «No pudimos comunicarnos con FixFlow. Revisa tu internet; lo que capturaste no se perdió.».
  - Acciones: Reintentar → repite la acción.

### B · Ciudadano: crear reporte

- **B1 Mis reportes (pestaña):**
  - Muestra: «Hola, Ana», chips Todas · Pendiente · Asignada · En proceso · Resuelta · Reabierta · Cerrada, y tarjetas 000097 (Resuelta, primero, con «Confirmar resolución»), 000142, 000123 y 000118.
  - Acciones: tarjeta → C2; Reportar → B2; Avisos → C1; perfil → A3.
- **B2 Nuevo reporte:**
  - Muestra: «Paso 1 de 2», tipo de incidencia (abre una hoja inferior con los 9 tipos), foto con «Tomar foto» o, ya tomada, con «Volver a capturar» y la fecha, y descripción con contador 0/500. Debajo de la foto, una sola línea gris: «La cámara te guiará para inclinar el teléfono». Sin tarjetas de ayuda sobre la captura ni listas de sensores.
  - Acciones: Tomar foto → B3, B3c o B3d según el tipo; Revisar y enviar → B4.
- **B3 Cámara: ángulo correcto:** Bache, apunta hacia el suelo, 62° en zona válida, disparador activo. Tomar foto → B2 con la foto.
- **B3b Cámara: ajustar el ángulo:** la misma cámara con 18° y «Faltan 27°. Inclina el teléfono hacia el suelo». Disparador desactivado.
- **B3c Cámara: hacia arriba:** Luminaria apagada o dañada, −35° en zona válida, «Puedes tomarla de lejos: basta con apuntar hacia arriba».
- **B3d Cámara: sin restricción:** Fuga de agua, cualquier ángulo (5°), «Encuadra el problema como mejor se vea. La inclinación se guarda con la foto».
- **B4 Revisar y enviar:**
  - Muestra: «Paso 2 de 2», foto, tipo, descripción, «Fecha y hora: se asignan al enviar», dirección con minimapa y la nota «La ubicación se toma del GPS y no se puede editar».
  - Acciones: Enviar reporte → B5; Editar (botón de texto) → B2.
- **B5 Reporte enviado:**
  - Muestra, centrado: «Reporte enviado», el folio FX-2026-000142 en grande, «Bache · hoy, 10:48» y «Te avisaremos cada vez que cambie de estado».
  - Acciones: Ver mi reporte → C2; botón de texto «Ir a Mis reportes» → B1.
- **B6 Sin permiso de cámara:**
  - Muestra: icono no_photography, «No podemos usar la cámara» y «La foto debe tomarse en este momento; no se puede elegir de la galería.».
  - Acciones: Dar permiso → B3; Cancelar → B1.
- **B7 Ubicación no disponible:**
  - Muestra: B2 con «GPS no disponible» y «Activa el GPS y vuelve a tomar la foto. Sin ubicación el reporte no se puede enviar.».
  - Acciones: Volver a capturar → B3; «Revisar y enviar» desactivado.

### C · Ciudadano: seguimiento

- **C1 Avisos (pestaña):**
  - Muestra: avisos del ciudadano agrupados en Hoy / Esta semana, con «Marcar todo como leído».
  - Acciones: aviso → C2.
- **C2 Detalle del reporte:**
  - Muestra: secciones del detalle para 000097 en Resuelta, con la foto del reporte y la de la solución, y la solución registrada (descripción, Luis Ramírez y fecha). Pregunta «¿Se solucionó el problema?».
  - Barra fija: «Confirmar resolución» → C2 en Cerrada; «El problema sigue» → C3.
- **C3 Reabrir reporte:**
  - Muestra: título «El problema sigue», la solución anterior, el campo obligatorio «¿Qué sigue mal?» (10 a 500, con contador), «Puedes reabrir un reporte hasta 2 veces» y «Tu reporte pasará a Reabierta y el personal operativo verá tu motivo». Sin foto.
  - Acciones: Reabrir reporte → C2 en Reabierta; Cancelar → C2.
- **C4 Sin reportes (pestaña):**
  - Muestra: B1 vacío, con icono inbox, «Aún no tienes reportes» y «¿Viste un bache, una luminaria apagada o una fuga? Repórtalo con una foto y aquí verás su avance.».
  - Acciones: Hacer un reporte → B2.

### D · Personal operativo

- **D1 Mis asignadas (pestaña):**
  - Muestra: «Hola, Luis», resumen en texto (4 activas · 1 de prioridad alta · 1 reabierta), chips de estado y tarjetas con distancia, prioridad alta primero: 000131, 000097 (Reabierta), 000123 y 000118.
  - Acciones: tarjeta → D2, o D4 si está Reabierta; Mapa → D5; Avisos → D6; perfil → A3.
- **D2 Detalle de la incidencia:**
  - Muestra: secciones del detalle para 000131 en Asignada, con la línea de estados Asignada · En proceso · Resuelta y la descripción del reporte sin nombre del ciudadano.
  - Barra con una sola acción válida: en Asignada, «Iniciar atención» → diálogo «¿Iniciar atención?» → D2 en En proceso; en En proceso, «Registrar solución» → D3.
- **D3 Registrar solución:**
  - Muestra: un espacio para **una** foto con «Tomar foto», la descripción de la solución obligatoria (contador 0/500), «Se registrará a nombre de Luis Ramírez» y «La incidencia pasará a Resuelta».
  - Acciones: Tomar foto → D3a; Enviar solución → D1.
- **D3a Cámara de la solución:** la cámara oscura **sin guía de inclinación** ni restricción de ángulo, con la instrucción «Toma una foto del trabajo terminado». Tomar foto → D3 con la foto.
- **D4 Reabierta: motivo:**
  - Muestra: chips Reabierta y Prioridad alta («Reabierta por el ciudadano»), el motivo de la reapertura firmado por «Ciudadano» y la fecha, y la solución anterior.
  - Acciones: Iniciar atención → D2 en En proceso.
- **D5 Mapa de asignadas (pestaña):**
  - Muestra: mapa con puntos por color de prioridad y una ficha inferior del punto elegido (tipo, folio, prioridad, distancia).
  - Acciones: Ver detalle → D2.
- **D6 Avisos (pestaña):**
  - Muestra: «Nueva incidencia asignada» e «Incidencia reabierta», con «Marcar todo como leído».
  - Acciones: aviso → D2, o D4 si es reapertura.

### E · Administrador

- **E1 Panel (pestaña Inicio):**
  - Muestra: «Hola, Marta», el panel del admin con los datos de ejemplo y la campana.
  - Acciones: Asignar → E5; Ver todas → E2; Catálogo de tipos → E10; campana → E7.
- **E2 Incidencias (pestaña):**
  - Muestra: buscador «Buscar por folio o tipo», filtros Estado · Tipo · Prioridad · Zona y tarjetas de varios estados.
  - Acciones: Zona → E3; tarjeta Pendiente → E5; tarjeta en otro estado → E4.
- **E3 Filtrar por zona:**
  - Muestra: mapa con un círculo cuyo centro se mueve tocando el mapa, control de radio de 0.5 a 10 km y «8 incidencias dentro de la zona».
  - Acciones: Aplicar zona → E2; Borrar zona → E2 sin zona.
- **E4 Detalle con historial:**
  - Muestra: secciones del detalle para 000123 en En proceso, con el motivo de prioridad, el nombre del ciudadano (el admin sí lo ve) y el responsable Luis Ramírez.
  - Acciones: Reasignar → E6.
- **E5 Asignar:**
  - Muestra: resumen de 000140 (Pendiente, Prioridad alta, «Sin resolver por más de 7 días», dirección con minimapa), lista de operativos activos con «N incidencias activas» (Luis 3, Diana 1, Jorge 2) e historial corto.
  - Acciones: «Asignar a Diana Ortega» → E4 en Asignada.
- **E6 Reasignar:**
  - Muestra: el responsable actual y la lista para elegir al nuevo responsable con su carga. Nota: «Diana Ortega recibirá un aviso y el cambio quedará en el historial». Sin campo de motivo.
  - Acciones: «Reasignar a Diana Ortega» → E4.
- **E7 Avisos:**
  - Muestra: solo avisos «Incidencia reabierta», con «Marcar todo como leído».
  - Acciones: aviso → E4.
- **E8 Personal operativo (pestaña):**
  - Muestra: «3 activos · 1 inactivo» y la lista de operativos (iniciales, nombre, correo, «N incidencias activas» y un switch de activo). Raúl Medina aparece inactivo. Nota: «Una cuenta inactiva no puede iniciar sesión ni recibe asignaciones».
  - Acciones: Dar de alta → E9; apagar el switch → E8a.
- **E8a Desactivar operativo:**
  - Muestra: diálogo «¿Desactivar a Jorge Salas?» con «No podrá iniciar sesión ni recibir asignaciones. Sus incidencias actuales se pueden reasignar.».
  - Acciones: Cancelar → E8; Desactivar → E8.
- **E9 Alta de operativo:**
  - Muestra: nombre, apellidos, correo y contraseña temporal, con la ayuda «Mínimo 8 caracteres, con letras y números. Compártela con la persona; podrá cambiarla desde su perfil.».
  - Acciones: Dar de alta → E8; Cancelar → E8.
- **E10 Catálogo de tipos:**
  - Muestra: «9 activos · 1 inactivo» y la lista de los 9 tipos del catálogo más uno inactivo de ejemplo (Grafiti, que se ve inactivo). Cada fila lleva el nombre, código, orientación, prioridad base, cuántas incidencias lo usan y chevron. Arriba va «Agregar tipo». Se abre desde E1, así que no tiene barra inferior.
  - Acciones: Agregar tipo → E11; tipo → E12.
- **E11 Nuevo tipo:**
  - Muestra: nombre; código opcional, con la ayuda «Si lo dejas vacío se usará FUGA_DE_AGUA. No se puede cambiar después»; orientación de la foto (Hacia el suelo · Hacia arriba · Sin restricción); prioridad base (Alta · Media · Baja).
  - Acciones: Guardar tipo → E10; Cancelar → E10.
- **E12 Editar tipo:**
  - Muestra: «142 incidencias usan este tipo», el código bloqueado, nombre, orientación, prioridad base y la nota «Los cambios aplican a los reportes nuevos; los existentes conservan su prioridad».
  - Acciones: Guardar cambios → E10; Desactivar (destructivo) → E12a.
- **E12a Desactivar tipo:**
  - Muestra: diálogo «¿Desactivar Bache?» con «Ya no aparecerá en reportes nuevos; las incidencias existentes lo conservan.».
  - Acciones: Cancelar → E12; Desactivar → E10.

---

## 11. Recorridos completos

- **Acceso:** A1 → B1, D1 o E1 según el rol. A1 → A2 → A1. Perfil (A3) → A3a, A3b o A3c → A3 o A1.
- **Reporte:** B1 → B2 → B3 (B3b si el ángulo no es válido; B3c o B3d según el tipo) → B2 → B4 → B5 → C2. Sin permiso de cámara → B6. Sin GPS → B7.
- **Asignación:** E1 o E2 → E5 → E4. El operativo recibe «Nueva incidencia asignada» en D6.
- **Atención:** D1 → D2 → Iniciar atención → Registrar solución → D3 → D3a → D3 → D1. El ciudadano recibe «Tu reporte fue resuelto» en C1.
- **Cierre:** C1 o B1 → C2 → Confirmar resolución → Cerrada. O bien: El problema sigue → C3 → Reabierta. El operativo y el admin reciben «Incidencia reabierta» (D6 → D4, E7 → E4).
- **Personal:** E8 → E9 → E8. E8 → E8a → E8.
- **Catálogo:** E1 → E10 → E11 o E12 → E10. E12 → E12a → E10.
