# Definition of Done (DoD) — FixFlow

Una HU puede moverse de **In review** a **Done** cuando cumple **todos** los puntos siguientes. La DoD garantiza calidad y cierre; no añade funcionalidad.

## Definición

### Funcionalidad

- [ ] Se cumplen todos los criterios de aceptación de la HU, y la verificación está descrita en el PR.
- [ ] Solo los roles indicados en la HU pueden acceder a la funcionalidad (RN-05).
- [ ] No se introdujo funcionalidad fuera de alcance (voz/micrófono, duplicados por proximidad, votos de urgencia).

### Código

- [ ] El código está en una rama y se integró a `main` mediante un Pull Request.
- [ ] Al menos otro miembro del equipo revisó y aprobó el PR.
- [ ] El proyecto compila sin errores y sin advertencias nuevas del analizador/linter.
- [ ] No quedan credenciales, claves ni datos de prueba sensibles en el código.

### Pruebas

- [ ] La HU se probó manualmente en la app.
- [ ] Si usa permisos, se probaron los casos de permiso concedido y rechazado.

### Documentación y cierre

- [ ] Si la implementación aclaró o cambió una regla, se actualizó el documento correspondiente (HU, RN, RF o RNF) en el mismo PR o en uno enlazado, con aprobación del PO.
- [ ] El Product Owner aceptó la HU.
- [ ] El Issue está cerrado y la tarjeta está en Done.
