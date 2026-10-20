# Requisitos — FixFlow

Punto de entrada a la definición permanente del producto.

## Estructura

```text
requirements/
├── README.md                          ← este archivo
├── user-stories/
│   ├── README.md                      ← índice por módulo, dependencias, plantilla
│   └── HU-XX-<slug>.md                ← una HU por archivo
├── functional/
│   └── functional-requirements.md     ← RF-XX: capacidades del sistema y su origen (HU)
├── non-functional/
│   └── non-functional-requirements.md ← RNF-XX: restricciones y atributos de calidad
├── business-rules/
│   └── business-rules.md              ← RN-XX: reglas del dominio (únicas, referenciadas desde HUs)
└── glossary.md                        ← términos del dominio
```

## Qué va en cada categoría

| Categoría | Prefijo | Responde a | Ejemplo |
| --- | --- | --- | --- |
| Historia de usuario | `HU-XX` | ¿Qué necesita un usuario y para qué? ¿Cómo se verifica? | HU-04 Capturar evidencia fotográfica en vivo |
| Requisito funcional | `RF-XX` | ¿Qué capacidad debe ofrecer el sistema? | RF-05 Captura de fotografía en vivo |
| Requisito no funcional | `RNF-XX` | ¿Con qué restricciones o calidad debe funcionar? | RNF-01 Sensores permitidos |
| Regla de negocio | `RN-XX` | ¿Qué política del dominio se aplica, sin importar la pantalla? | RN-09 Evidencia principal capturada en vivo |
| Glosario | — | ¿Qué significa este término en FixFlow? | Incidencia, Evidencia |

## Principio de no duplicación

- Cada regla de negocio se define **una sola vez** en `business-rules.md`. Las HUs la referencian por su ID (`RN-XX`) en *Notas funcionales*.
- Los criterios de aceptación originales se conservan en cada HU aunque expresen una regla; la definición canónica (y sus valores pendientes) está en la RN.
- Los RF no repiten criterios de aceptación: enuncian la capacidad y apuntan a la HU de origen.
- La información dinámica del trabajo (Sprint, Status, Assignee, fechas, prioridad de tablero) vive en GitHub Projects, nunca en estos archivos.
- DoR y DoD son reglas del proceso, no del producto: viven en [../methodology/](../methodology/README.md).

## Fuera de alcance

Estas funcionalidades fueron **descartadas** y no deben reintroducirse en HUs, RF, RN ni código:

- Uso de micrófono, reconocimiento de voz, dictado o cualquier funcionalidad de voz.
- Detección de reportes duplicados por proximidad.
- Votos de urgencia.

Los únicos sensores del dispositivo que usa la app móvil son **GPS, cámara y acelerómetro** (ver RNF-01).

## Convenciones

- Nombres de archivo en minúsculas, sin acentos, separados por guiones: `HU-04-capturar-evidencia-fotografica.md`.
- El ID (`HU-XX`, `RF-XX`, `RNF-XX`, `RN-XX`) nunca se reutiliza ni se renumera. Si algo se descarta, se marca como *Descartado* en lugar de borrar el ID.
- Toda modificación a un requisito se hace mediante commit/PR, de modo que el historial de Git sea el registro de cambios.
