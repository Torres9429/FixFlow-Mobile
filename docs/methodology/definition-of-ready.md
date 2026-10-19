# Definition of Ready (DoR) — FixFlow

Una HU puede moverse de **Backlog** a **Ready** cuando cumple **todos** los puntos siguientes. La DoR evalúa la preparación de la HU; no añade criterios de aceptación.

## Definición

- [ ] La HU tiene su archivo en `docs/requirements/user-stories/` con historia (Como / Quiero / Para), criterios de aceptación, dependencias y notas funcionales.
- [ ] Los criterios de aceptación son verificables: el equipo sabe cómo comprobar cada uno.
- [ ] Las reglas de negocio que referencia la HU no están en estado *Pendiente de definir*. Si están en estado *Parcial*, el PO confirmó que lo definido basta para esta HU.
- [ ] Las HUs de las que **depende** están en Done o planificadas antes, dentro del mismo Sprint.
- [ ] El equipo la estimó y cabe en un Sprint de 2 semanas; si no cabe, se divide.
- [ ] Si la HU tiene interfaz, existe un boceto o una descripción de pantalla acordada.
- [ ] Si la HU usa sensores, están identificados y son solo GPS, cámara o acelerómetro (RNF-01).
- [ ] Si la HU requiere datos del backend, se conoce la información que se envía y se recibe.
- [ ] El Product Owner revisó la HU y no tiene dudas abiertas sobre su alcance.

## Ejemplo

**HU-15** (actualizar estado) depende de RN-14 (estados y transiciones). Mientras RN-14 estuvo *Pendiente de definir*, HU-15 no cumplía la DoR. Cuando el PO definió los estados y las transiciones, RN-14 pasó a *Vigente* y HU-15 pudo pasar a Ready. El texto de HU-15 no se modificó: solo se quitó la marca *(pendiente)* de sus notas funcionales.

Si en el futuro una regla vuelve a quedar *Pendiente* o *Parcial*, aplica lo mismo: la HU que la referencia espera en Backlog hasta que la regla se defina.
