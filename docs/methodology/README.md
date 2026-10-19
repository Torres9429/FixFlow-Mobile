# Metodología — FixFlow

## ScrumBan

- Sprints de **2 semanas**.
- Tablero Kanban en **GitHub Projects**.
- **Product Owner:** Rocío Rodríguez Torres.
- **Scrum Master:** García González Antonio.

## Tablero

```text
Backlog → Ready → In progress → In review → Done
```

| Columna | Significado | Condición para entrar |
| --- | --- | --- |
| **Backlog** | Trabajo identificado, aún no preparado. | Existe el Issue y su HU en `docs/requirements/user-stories/`. |
| **Ready** | Preparada para iniciarse. | Cumple la [Definition of Ready](definition-of-ready.md). |
| **In progress** | En desarrollo. | Tiene responsable asignado en el Project y entra en el Sprint. |
| **In review** | Pull Request abierto en revisión. | PR enlazado al Issue; el autor verificó los criterios de aceptación. |
| **Done** | Terminada. | Cumple la [Definition of Done](definition-of-done.md). |

## Relación HU → Issue → Project

```text
HU en docs  (qué se construye — permanente, en Git)
   ↓ 1 a 1
GitHub Issue  (unidad de trabajo — enlaza al archivo de la HU)
   ↓
GitHub Project  (estado del trabajo — dinámico)
   ↓
Backlog → Ready → In progress → In review → Done
```

## Dónde vive cada dato

| Dato | Dónde | Motivo |
| --- | --- | --- |
| Historia, criterios de aceptación, dependencias, notas | Archivo de la HU | Definición permanente del producto. |
| Reglas de negocio, RF, RNF, glosario | `docs/requirements/` | Compartidos por varias HUs. |
| DoR y DoD | `docs/methodology/` | Aplican a todas las HUs por igual. |
| Status, Sprint, Assignee, fechas, prioridad de tablero, estimación | GitHub Projects | Cambian durante el trabajo. |
| Verificación de criterios y de DoD | Issue / Pull Request | Evidencia de un trabajo concreto, no del requisito. |

## Criterios de aceptación vs. DoR vs. DoD

| | Pregunta que responde | Alcance | Dónde |
| --- | --- | --- | --- |
| **Criterios de aceptación** | ¿Qué debe cumplir funcionalmente *esta* HU? | Específico de cada HU | Archivo de la HU |
| **DoR** | ¿Está la HU suficientemente preparada para empezar? | Igual para todas | [definition-of-ready.md](definition-of-ready.md) |
| **DoD** | ¿Puede considerarse completamente terminada? | Igual para todas | [definition-of-done.md](definition-of-done.md) |

La DoD **incluye** "se cumplen todos los criterios de aceptación", pero no los repite ni los amplía. Si una HU no cumple la DoR, se corrige la información faltante (por ejemplo, definir una regla de negocio) en lugar de modificar la HU para que encaje.

## Convenciones para Issues

- Título: `HU-XX — Título de la HU` (idéntico al encabezado del archivo).
- Etiquetas sugeridas: `user-story` y el módulo (`mod:captura-sensores`, `mod:seguimiento-ciudadano`, …).
