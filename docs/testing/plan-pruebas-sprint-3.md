# FixFlow

19 de noviembre del 2026

## HU-04 — CAPTURAR EVIDENCIA FOTOGRÁFICA EN VIVO

Como ciudadano quiero tomar la fotografía directamente desde la aplicación para proporcionar evidencia actual de la incidencia reportada.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-04 | La captura utiliza la cámara del dispositivo y no permite galería (CA-1, CA-2, RN-09) | Unitaria | El servicio de cámara invoca la cámara en vivo (`ImageSource.camera`); la opción de galería no está habilitada | 2 |
| HU-04 | La fotografía queda asociada al reporte (CA-5) | Unitaria | Tras capturar, la entidad del reporte contiene la ruta local del archivo de imagen | 1 |
| HU-04 | Al continuar se abre la cámara en vivo de la app, no la galería (CA-1, CA-3) | Interfaz | En Nuevo reporte, seleccionar tipo + descripción → tap «Continuar a captura» → se abre la cámara en vivo (B3), no la galería | 1 |
| HU-04 | Cámara sin permiso o no disponible → se muestra aviso (CA-4) | Interfaz | Si el permiso de cámara es rechazado o el sensor falla, se muestra la pantalla informativa B6 y no se permite continuar | 1 |
| | | | **Total HU-04** | **5** |

## HU-06 — VALIDAR ORIENTACIÓN DEL DISPOSITIVO

Como sistema quiero obtener información del acelerómetro durante la captura de evidencia para verificar que la orientación del dispositivo sea congruente con el tipo de incidencia reportada.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-06 | El validador de orientación para "bache" (CA-3, RN-11) | Unitaria | Acelerómetro apuntando al suelo (≥ 45°) → orientación válida; apuntando al cielo (< 45°) → orientación inválida | 2 |
| HU-06 | El validador de orientación para "luminaria" (CA-4, RN-11) | Unitaria | Acelerómetro apuntando arriba (≤ -20°) → orientación válida; apuntando al suelo (> -20°) → orientación inválida | 2 |
| HU-06 | Se obtienen datos del acelerómetro durante la captura (CA-1) | Unitaria | El servicio del acelerómetro devuelve valores x, y, z no nulos y calcula el ángulo de inclinación | 1 |
| HU-06 | Guía angular en cámara para "bache" (Issue #23) | Unitaria | A 18° → fuera de rango, faltan 27° hacia el suelo y disparador inactivo; a 62° → dentro de rango verde y disparador activo | 2 |
| HU-06 | Guía angular en cámara para "luminaria" (Issue #23) | Unitaria | A -35° → dentro de rango verde y disparador activo; a 10° → fuera de rango, faltan 30° hacia arriba y disparador inactivo | 2 |
| HU-06 | Incidencia sin restricción de ángulo (Issue #23) | Unitaria | En tipos como "Fuga de agua", cualquier ángulo mantiene sensores listos y el disparador activo | 1 |
| HU-06 | Movimiento del acelerómetro en tiempo real | Unitaria | Al inclinar el dispositivo en tiempo real, el stream del sensor actualiza inmediatamente el ángulo y el estado del disparador | 1 |
| HU-06 | Disparador se desactiva durante la captura | Unitaria | Al disparar la foto, el botón queda temporalmente deshabilitado para evitar tomas duplicadas | 1 |
| HU-06 | Teléfono sin acelerómetro o sensor no disponible (CA-7, RN-11, B3e) | Unitaria | Sin sensor desde B2 o con fallo del sensor en B3 → disparador activo con cualquier tipo, inclinación null y reporte marcado sin sensor | 3 |
| HU-06 | Pantalla: sin acelerómetro muestra aviso y tipo sin guía (CA-1, CA-7, B3e) | Interfaz | En teléfono sin sensor, B2 muestra el aviso informativo y la cámara B3e no dibuja la guía de inclinación | 1 |
| HU-06 | Pantalla: con acelerómetro no aparece el aviso (CA-1) | Interfaz | En teléfono con sensor disponible, el aviso de ausencia de acelerómetro no aparece en pantalla | 1 |
| | | | **Total HU-06** | **17** |

## HU-07 — ASOCIAR COORDENADAS A LA EVIDENCIA

Como sistema quiero asociar la ubicación GPS obtenida durante la captura con la evidencia para conservar información sobre el lugar donde fue registrada.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-07 | La evidencia queda vinculada a las coordenadas (CA-1, CA-2) | Unitaria | Al capturar evidencia con ubicación, el modelo contiene la ruta de foto, latitud y longitud asociados | 1 |
| HU-07 | El usuario no puede introducir coordenadas manualmente (CA-3, RN-10) | Unitaria | Las coordenadas son inmutables en la entidad y no existe campo ni método para editarlas manualmente | 1 |
| HU-07 | La ubicación permanece asociada al reporte (CA-4, RN-10) | Unitaria | Las coordenadas se mantienen inalteradas a lo largo de las consultas y el ciclo de vida del modelo | 1 |
| | | | **Total HU-07** | **3** |

## HU-09 — DETERMINAR PRIORIDAD DE UNA INCIDENCIA

Como administrador municipal quiero que las incidencias sean clasificadas de acuerdo con criterios de prioridad para identificar los problemas que requieren mayor atención.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-09 | Convierte estado y prioridad del back a los enums (RN-13) | Unitaria | JSON con estado, prioridad (`ALTA`, `MEDIA`, `BAJA`) y motivo se mapean a sus enums correspondientes | 1 |
| HU-09 | Incidencia Pendiente llega sin operativo ni foto | Unitaria | Mapeo de incidencia sin asignar verifica campos `operativo == null` y `fotoUrl == null` | 1 |
| HU-09 | Formato de fecha en tarjetas de incidencia (design.md §8) | Unitaria | Mismo día → «hoy, HH:mm»; día anterior → «ayer, HH:mm»; más antigua → «DD mes AAAA, HH:mm» | 3 |
| HU-09 | Tarjeta muestra estado, prioridad como símbolo, datos y acción (CA-4) | Interfaz | `IncidenciaCard` renderiza chip de estado, icono/color de prioridad alta e información de la incidencia | 1 |
| HU-09 | Tarjeta de incidencia: tocarla abre el detalle | Interfaz | Pulsar sobre la tarjeta ejecuta la acción de navegación hacia el detalle correspondiente | 1 |
| | | | **Total HU-09** | **7** |

## HU-10 — CONSULTAR MIS REPORTES

Como ciudadano quiero consultar los reportes que he realizado para conocer el estado de las incidencias que he registrado.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-10 | Con reportes: carga nombre, lista y el filtro deja solo ese estado (CA-1, CA-2, CA-4) | Unitaria | `MisReportesViewModel` carga el nombre del usuario, la lista de reportes propios y filtra localmente por estado | 1 |
| HU-10 | Sin ningún reporte → se activa C4 (CA-1) | Unitaria | Con lista vacía de reportes, el ViewModel activa la bandera `sinReportes == true` | 1 |
| HU-10 | Paginación incremental de mis reportes | Unitaria | `cargarMas()` solicita la página siguiente, concatena nuevos reportes y actualiza el contador de página | 1 |
| HU-10 | Sin reportes (C4): mensaje y «Hacer un reporte», sin saludo ni chips | Interfaz | Pantalla muestra estado vacío C4 con mensaje informativo y botón de acción, ocultando chips y saludo | 1 |
| | | | **Total HU-10** | **4** |

## HU-11 — CONSULTAR ESTADO DE UNA INCIDENCIA

Como ciudadano quiero conocer el estado de mi reporte para saber si ya fue revisado, atendido o solucionado.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-11 | Carga paralela de detalle e historial con geocodificación de dirección (CA-1, CA-2) | Unitaria | `iniciar()` carga detalle e historial simultáneamente y resuelve la dirección legible mediante el servicio de ubicación | 1 |
| HU-11 | Protección de datos del ciudadano según el rol (RNF-04) | Unitaria | `mostrarCiudadano` es `true` solo para la vista del administrador; para el operativo los datos del ciudadano quedan ocultos | 1 |
| HU-11 | Manejo de fallo de red en consulta de detalle | Unitaria | Error en repositorio de incidencias cambia el estado a `ConError` con mensaje traducido | 1 |
| HU-11 | Ficha informativa de detalle en pantalla C2 (CA-1, CA-4) | Interfaz | Pantalla renderiza folio, chip de estado actual, miniatura de foto de evidencia y dirección geocodificada | 1 |
| | | | **Total HU-11** | **4** |

## HU-14 — CONSULTAR INCIDENCIAS ASIGNADAS

Como personal operativo quiero visualizar las incidencias que debo atender para organizar mi trabajo y atender los problemas reportados.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-14 | Resumen en texto y distancia desde el GPS (CA-1, CA-5, CA-6) | Unitaria | `AsignadasViewModel` calcula resumen de carga («X activas · Y de prioridad alta · Z reabiertas») y distancia formateada («a X.X km») | 1 |
| HU-14 | Distancia en línea recta entre dos puntos geográficos | Unitaria | `Coordenada.distanciaKm` calcula distancia precisa entre coordenadas sin bloquear la lista si el GPS tarda | 1 |
| HU-14 | Cambio de filtro actualiza estado y recarga lista | Unitaria | Cambiar el filtro de estado en asignadas reinicia a estado de carga y consulta las incidencias filtradas | 1 |
| | | | **Total HU-14** | **3** |

## HU-15 — ACTUALIZAR ESTADO DE UNA INCIDENCIA

Como personal operativo quiero actualizar el estado de una incidencia para informar el avance de su atención.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-15 | OperativoRepositoryImpl envía PATCH con EN_PROCESO (CA-1, RN-14) | Unitaria | Repositorio envía `PATCH /incidencias/{id}/estado` con `data: {'estado': 'EN_PROCESO'}` y resuelve `Ok<void>()` | 1 |
| HU-15 | FakeOperativoRepository transita la incidencia a EN_PROCESO | Unitaria | En modo simulado, la incidencia cambia de `asignada` a `enProceso` tras ejecutar `iniciarAtencion` | 1 |
| HU-15 | puedeIniciarAtencion es true para operativo en ASIGNADA y REABIERTA | Unitaria | En vista operativo, la acción de iniciar atención está habilitada únicamente si la incidencia está asignada o reabierta | 1 |
| HU-15 | puedeIniciarAtencion es false para ciudadano, admin o estados no válidos | Unitaria | Para roles no operativos o estados pendientes, en proceso, resueltas o cerradas, la acción devuelve `false` | 1 |
| HU-15 | iniciarAtencion en DetalleIncidenciaViewModel invoca repo y recarga | Unitaria | Ejecutar inicio de atención invoca al repositorio y recarga automáticamente la ficha con el nuevo estado | 1 |
| HU-15 | iniciarAtencion en AsignadasViewModel invoca repo y recarga lista | Unitaria | Ejecutar inicio de atención desde la lista actualiza el listado de asignadas reflejando el cambio de estado | 1 |
| HU-15 | Diálogo modal de confirmación de inicio de atención | Interfaz | Al pulsar «Iniciar atención» aparece diálogo modal de confirmación; confirmar ejecuta la acción y cancelar la descarta | 1 |
| | | | **Total HU-15** | **7** |

## HU-16 — REGISTRAR SOLUCIÓN DE UNA INCIDENCIA

Como personal operativo quiero registrar la solución aplicada a una incidencia para documentar cómo fue atendido el problema.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-16 | Validador de descripción de solución (CA-1) | Unitaria | Rechaza campo vacío, espacios o más de 500 caracteres; acepta texto válido de hasta 500 caracteres | 1 |
| HU-16 | Envío de solución a la API y mapeo de errores HTTP (CA-1, CA-2, RN-14) | Unitaria | `OperativoRepositoryImpl` envía `POST /incidencias/{id}/solucion` con y sin coordenadas GPS; traduce HTTP 409 a `Conflicto` y HTTP 422 a `EvidenciaInvalida` | 2 |
| HU-16 | Comportamiento en repositorios simulados del modo mock (CA-5, RN-14) | Unitaria | `FakeOperativoRepository` transita la incidencia a `RESUELTA`, la remueve de activas y aísla estado entre instancias; `FakeEvidenciaRepository` sube foto a la carpeta de soluciones | 2 |
| HU-16 | Habilitación de acción según rol y estado en DetalleIncidenciaViewModel (CA-5, RN-05, RN-14) | Unitaria | `puedeRegistrarSolucion` es `true` exclusivamente para la vista del operativo cuando el estado es `EN_PROCESO`; para ciudadano, admin u otros estados devuelve `false` | 1 |
| HU-16 | Carga y validación en SolucionViewModel sin llamadas innecesarias (CA-1, CA-4) | Unitaria | Carga nombre del operativo autenticado; si faltan campos obligatorios detiene el flujo sin invocar repositorios; ignora pulsaciones repetidas mientras se encuentra enviando | 2 |
| HU-16 | Flujo completo de registro y resiliencia de subida en SolucionViewModel (CA-1 a CA-5, RN-10, RNF-08) | Unitaria | Sube foto con tipo solución, lee coordenadas del GPS y registra con éxito; si la API falla tras subir la foto, reutiliza la URL en el reintento sin volver a subirla a Cloudinary | 2 |
| HU-16 | Campos iniciales y validación de formulario vacío en pantalla D3 (CA-1, CA-2) | Interfaz | `SolucionScreen` muestra título, caja de foto, contador `0/500`, leyenda de operativo y botón de envío; al enviar vacío muestra errores visuales bajo foto y descripción | 1 |
| HU-16 | Captura, redacción y confirmación exitosa en pantalla D3 (CA-1, CA-3, CA-5) | Interfaz | Permite capturar foto, ingresar descripción con contador actualizado, invoca repositorios y notifica con snackbar «Solución registrada» regresando a la vista anterior | 1 |
| HU-16 | Presentación de error del servidor en pantalla D3 (RN-14) | Interfaz | Si el registro falla con `Conflicto` (p. ej. incidencia no está en proceso), muestra el mensaje de error provisto por el servidor en `AvisoError` | 1 |
| HU-16 | Visibilidad del botón de registrar solución en detalle D2 (CA-5, RN-05, RN-14) | Interfaz | Pantalla de detalle de la incidencia (D2) muestra el botón «Registrar solución» únicamente cuando la incidencia está en proceso y la consulta un operativo | 1 |
| | | | **Total HU-16** | **14** |

## HU-17 — VISUALIZAR INCIDENCIAS MUNICIPALES

Como administrador municipal quiero visualizar las incidencias registradas para conocer el estado general de los problemas reportados en el municipio.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-17 | Carga de primera página y actualización de estado en VM (CA-1) | Unitaria | `iniciar()` solicita la página 0 a `AdminRepository`, pasa a estado `Listo` y registra índices de paginación | 1 |
| HU-17 | Concatenación de elementos en scroll infinito (cargarMas) | Unitaria | `cargarMas()` solicita página siguiente, concatena elementos a la lista existente y actualiza `_pagina` | 1 |
| HU-17 | Manejo de fallo de red en listado municipal | Unitaria | Error en repositorio de administración cambia el estado a `ConError` con mensaje traducido | 1 |
| HU-17 | Renderizado de listado municipal E2 y pie de página | Interfaz | Pantalla E2 muestra tarjetas de incidencias del municipio, esqueleto durante la carga y pie de fin de resultados en la última página | 1 |
| | | | **Total HU-17** | **4** |

## HU-19 — CONSULTAR INDICADORES DE ATENCIÓN

Como administrador municipal quiero consultar métricas sobre las incidencias para conocer el comportamiento y desempeño de la atención de problemas urbanos.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-19 | Carga las cifras y prioritarias sin asignar en PanelViewModel (CA-1, CA-2) | Unitaria | `PanelViewModel` carga total de registradas (128) e incidencias prioritarias pendientes de atención | 1 |
| HU-19 | Sin conexión → mensaje de error y sin cifras | Unitaria | Repositorio responde `Result.error(SinConexion())` → ViewModel pasa a `ConError` sin mostrar cifras vacías | 1 |
| HU-19 | Panel E1 renderiza tarjetas de indicadores numéricos (CA-1, CA-2) | Interfaz | Pantalla E1 muestra cuadrícula de métricas con registradas, pendientes, en atención y tiempos de resolución | 1 |
| | | | **Total HU-19** | **3** |

## HU-21 — ASIGNAR INCIDENCIA A PERSONAL OPERATIVO

Como administrador municipal quiero asignar una incidencia a un miembro del personal operativo para garantizar que el problema sea atendido por el personal correspondiente.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-21 | Selección obligatoria de operativo al confirmar (CA-2) | Unitaria | Confirmar sin operativo seleccionado asigna `errorFormulario` y bloquea el envío | 1 |
| HU-21 | Preselección de responsable en reasignación E6 (CA-8) | Unitaria | Si la incidencia ya cuenta con responsable asignado, este aparece preseleccionado en la lista | 1 |
| HU-21 | Envío de asignación exitosa a través de AdminRepository (CA-3) | Unitaria | `AdminRepository.asignar(id, operativoId)` envía `POST /incidencias/{id}/asignacion` y retorna éxito | 1 |
| HU-21 | Pantalla E5/E6 muestra lista con carga actual y selección | Interfaz | Renderiza lista de personal operativo con su carga de trabajo («X asignadas»), selector y botón de confirmar | 1 |
| | | | **Total HU-21** | **4** |

## HU-22 — CONSULTAR HISTORIAL DE UNA INCIDENCIA

Como usuario autorizado quiero consultar el historial de una incidencia para conocer las acciones realizadas desde su creación hasta su resolución.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-22 | Historial se ordena de forma cronológica inversa (CA-1, CA-5) | Unitaria | La lista de eventos se ordena del más reciente al más antiguo situando el último cambio al inicio | 1 |
| HU-22 | Recorte a 3 eventos más recientes si hay más de 4 | Unitaria | Con más de 4 eventos en el historial, se muestran inicialmente solo los 3 más recientes y se activa la opción de ver más | 1 |
| HU-22 | Botón «Ver todo» expande la totalidad de los eventos | Interfaz | Pulsar «Ver todo» despliega todos los eventos cronológicos del historial sin recortar | 1 |
| | | | **Total HU-22** | **3** |

## HU-24 — GESTIONAR PERSONAL OPERATIVO

Como administrador municipal quiero dar de alta y desactivar cuentas del personal operativo para que solo el personal vigente pueda iniciar sesión y recibir incidencias.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-24 | Filtrado local de personal por búsqueda y estatus (CA-1) | Unitaria | `PersonalViewModel` filtra la lista por texto (nombre/correo) y por estado activo/inactivo/todos | 1 |
| HU-24 | Modificación de estatus activo/inactivo (CA-4) | Unitaria | `cambiarEstatusOperativo` envía `PATCH /admin/operativos/{id}/estatus` con `{activo}` y recarga la lista | 1 |
| HU-24 | Creación de cuenta con contraseña temporal (CA-2, CA-3) | Unitaria | `AltaOperativoViewModel` envía `POST /admin/operativos` con datos del operativo y contraseña generada | 1 |
| HU-24 | Pantalla E8 con switch de estatus y confirmación | Interfaz | Renderiza lista de personal con interruptor; desactivar operativo solicita confirmación previa | 1 |
| HU-24 | Formulario de alta E9 y botón de copia de contraseña | Interfaz | Formulario valida campos obligatorios y botón permite copiar la contraseña temporal generada al portapapeles | 1 |
| | | | **Total HU-24** | **5** |

## HU-25 — GESTIONAR MI PERFIL

Como usuario registrado quiero consultar y actualizar los datos de mi cuenta y cambiar mi contraseña para mantener mi información al día y reemplazar una contraseña temporal por una propia.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-25 | Perfil arma el nombre completo y las iniciales | Unitaria | Nombre y apellidos → «Mariana García Ruiz» y «MG»; sin apellidos → solo el nombre y una inicial | 2 |
| HU-25 | Validador de nueva contraseña cumple RN-02 y es distinta de la actual | Unitaria | Igual a la actual → error; solo letras → error; válida y distinta → sin error; requisitos dinámicos de longitud y alfanuméricos | 4 |
| HU-25 | AuthRemoteDataSource habla con /usuarios/me | Unitaria | `GET /usuarios/me` 200 devuelve perfil; `PUT /usuarios/me` actualiza nombre/apellidos; `PATCH /usuarios/me/password` 200 cambia contraseña; `PATCH` 400 falla con mensaje del back | 4 |
| HU-25 | AuthRepositoryImpl con el back simulado | Unitaria | `miPerfil()` devuelve datos; `actualizarPerfil()` guarda nuevo nombre en sesión; `cambiarPassword()` rechaza actual errónea; `cambiarPassword()` exitoso permite nuevo login | 4 |
| HU-25 | Pantalla A3: visualización de datos y reintento ante error | Interfaz | Muestra iniciales, nombre, correo y rol; si la consulta falla muestra mensaje de error y botón Reintentar | 2 |
| HU-25 | Confirmar y cancelar cierre de sesión en A3c | Interfaz | Cancelar cierra el diálogo y mantiene la sesión; confirmar cierra la sesión y navega al login | 2 |
| HU-25 | Pantalla A3a: edición de datos y campos bloqueados | Interfaz | Correo y rol aparecen bloqueados como solo lectura; nombre vacío no se guarda; guardar manda datos sin espacios de más | 3 |
| HU-25 | Pantalla A3b: cambio de contraseña y validaciones en vivo | Interfaz | Contraseña igual a actual o sin números no se manda; actual incorrecta muestra error del back; datos válidos actualizan contraseña | 4 |
| HU-25 | Flujo completo de gestión de perfil de punta a punta | Integración | Login → abrir perfil → editar nombre → cambiar contraseña → cerrar sesión → login exitoso con la contraseña nueva | 1 |
| | | | **Total HU-25** | **26** |

## HU-26 — GESTIONAR EL CATÁLOGO DE TIPOS DE INCIDENCIA

Como administrador municipal quiero dar de alta, editar y desactivar tipos de incidencia para mantener el catálogo de reportes al día sin cambiar la aplicación.

| Historia de Usuario | ¿Qué comprueba? | Tipo | Criterio de Aprobación | Tests |
| --- | --- | --- | --- | ---: |
| HU-26 | Generación automática de código sugerido a partir del nombre (RN-07) | Unitaria | `codigoSugerido('Fuga de agua')` normaliza a mayúsculas y guiones bajos generando `'FUGA_DE_AGUA'` | 1 |
| HU-26 | Validadores de nombre y código de tipo de incidencia | Unitaria | Nombre vacío o código con caracteres no permitidos devuelven mensajes de validación | 1 |
| HU-26 | Mapeo de conflicto 409 por código duplicado en formulario | Unitaria | Respuesta 409 del servidor asigna directamente el mensaje de conflicto al campo de código | 1 |
| HU-26 | Repositorio de catálogo: cambio de estatus activo/inactivo | Unitaria | `IncidenceTypeRepository.cambiarEstatus` envía `PATCH /admin/tipos-incidencia/{id}/estatus` y retorna éxito | 1 |
| HU-26 | Formulario guarda alta o edición según corresponda | Unitaria | En alta invoca `crear` y en edición invoca `editar` en el repositorio de tipos | 1 |
| HU-26 | Catálogo E10 con contador y diálogo de desactivación E12a | Interfaz | Fila muestra nombre, código, prioridad y conteo de incidencias; switch de desactivación muestra aviso de confirmación | 1 |
| HU-26 | Formularios E11 y E12 con código bloqueado en edición | Interfaz | E11 muestra código sugerido autogenerado; E12 muestra el campo código bloqueado como solo lectura | 1 |
| | | | **Total HU-26** | **7** |

## Resumen del Sprint 3

| HU | Tests |
| --- | ---: |
| HU-04 — Capturar evidencia fotográfica en vivo | 5 |
| HU-06 — Validar orientación del dispositivo | 17 |
| HU-07 — Asociar coordenadas a la evidencia | 3 |
| HU-09 — Determinar prioridad de una incidencia | 7 |
| HU-10 — Consultar mis reportes | 4 |
| HU-11 — Consultar estado de una incidencia | 4 |
| HU-14 — Consultar incidencias asignadas | 3 |
| HU-15 — Actualizar estado de una incidencia | 7 |
| HU-16 — Registrar solución de una incidencia | 14 |
| HU-17 — Visualizar incidencias municipales | 4 |
| HU-19 — Consultar indicadores de atención | 3 |
| HU-21 — Asignar incidencia a personal operativo | 4 |
| HU-22 — Consultar historial de una incidencia | 3 |
| HU-24 — Gestionar personal operativo | 5 |
| HU-25 — Gestionar mi perfil | 26 |
| HU-26 — Gestionar el catálogo de tipos de incidencia | 7 |
| **Total Sprint 3** | **116** |

## Correspondencia con tarjetas del tablero

| Issue / PR | Tarjeta | HUs que cubre |
| --- | --- | --- |
| #20 | Cámara en vivo con permisos | HU-04 |
| #23 / PR #54 | Guía de orientación en la cámara | HU-06 |
| PR #57 | Orientación opcional según el sensor (B3e) | HU-06 |
| #22 | Coordenadas asociadas a la evidencia | HU-07 |
| PR #32 | Priorización y tarjetas de incidencia | HU-09 |
| PR #32 | Mis reportes (B1, C4) | HU-10 |
| PR #49 | Detalle de incidencia | HU-11 |
| PR #32 | Incidencias asignadas al operativo (D1) | HU-14 |
| #46 / PR #64 | Iniciar atención de incidencias | HU-15 |
| #70 | Registrar solución con evidencia fotográfica (D3) | HU-16 |
| PR #78 | Incidencias del municipio (E2) | HU-17 |
| PR #32 | Panel municipal e indicadores (E1) | HU-19 |
| PR #50 | Asignación y reasignación de operativos (E5, E6) | HU-21 |
| PR #49 | Historial cronológico de la incidencia | HU-22 |
| PR #53 | Gestión de personal operativo (E8, E9) | HU-24 |
| PR #52 | Gestión de perfil y contraseña (A3–A3c) | HU-25 |
| PR #55 | Catálogo de tipos de incidencia (E10–E12) | HU-26 |

## ¿Qué queda fuera?

- Pruebas del backend: almacenamiento de incidencias en MySQL, subida real de fotos a Cloudinary, validaciones del servidor, cálculo de métricas agregadas y envío de notificaciones push.
- Pruebas con el servidor real; todas las respuestas de red son simuladas (`http_mock_adapter`, mocks y fakes en memoria).
- Pruebas con sensores físicos reales (cámara, GPS, acelerómetro); se usan mocks y fakes de los servicios del dispositivo.
- Filtro por zona geográfica circular en mapa (E3): requiere vista de mapa administrativo con radio en kilómetros.

## ANEXOS

### Tipos

| Prueba | ¿Qué es? | Herramienta |
| --- | --- | --- |
| Unitaria | Una función, validador, entidad, repositorio o ViewModel aislado | flutter_test + mocktail + http_mock_adapter |
| Interfaz | Una pantalla o widget: lo que se ve, se toca y valida en pantalla | testWidgets |
| Integración | Varias pantallas juntas (la app completa) con servicios simulados | testWidgets levantando la app completa con mocks inyectados |

### Reglas de negocio verificadas en este sprint

| ID | Regla | HUs |
| --- | --- | --- |
| RN-02 | Requisitos mínimos de contraseña y no reutilización de la actual | HU-24, HU-25 |
| RN-05 | Restricción y aislamiento de accesos y vistas por rol | HU-11, HU-14, HU-15, HU-16, HU-17, HU-21, HU-24, HU-26 |
| RN-07 | Catálogo de tipos de incidencia y código autogenerado | HU-06, HU-26 |
| RN-09 | Evidencia principal capturada en vivo (sin galería) | HU-04, HU-16 |
| RN-10 | Coordenadas GPS obtenidas exclusivamente durante la captura | HU-07, HU-16 |
| RN-11 | Orientación angular esperada por tipo y tolerancia sin sensor (B3e) | HU-06 |
| RN-13 | Prioridad automática y motivo provisto por el sistema | HU-09, HU-26 |
| RN-14 | Estados y transiciones válidas (`ASIGNADA` / `REABIERTA` → `EN_PROCESO` → `RESUELTA`) | HU-11, HU-15, HU-16, HU-21 |
| RN-15 | Registro cronológico de acciones y trazabilidad en el historial | HU-09, HU-15, HU-16, HU-21, HU-22 |
| RNF-04 | Protección de datos personales (operativo no visualiza datos del ciudadano) | HU-11, HU-14 |
| RNF-08 | Reintento resiliente de envío sin duplicar subida de foto a Cloudinary | HU-16 |
