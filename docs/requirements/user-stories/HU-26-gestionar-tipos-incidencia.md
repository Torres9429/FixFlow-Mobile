---
id: HU-26
titulo: Gestionar el catálogo de tipos de incidencia
modulo: Administración municipal
actor: Administrador municipal
---

# HU-26 — Gestionar el catálogo de tipos de incidencia

## Historia

**Como** administrador municipal
**Quiero** dar de alta, editar y desactivar tipos de incidencia
**Para** mantener el catálogo de reportes al día sin cambiar la aplicación.

## Criterios de aceptación

- [ ] El administrador puede consultar todos los tipos, activos e inactivos.
- [ ] El administrador puede registrar un tipo con nombre, orientación esperada y prioridad base. El código se genera solo a partir del nombre si no se indica.
- [ ] No se puede registrar un código que ya exista; un código generado que choque con otro recibe un sufijo (`_2`, `_3`…).
- [ ] El administrador puede editar el nombre, la orientación y la prioridad base de un tipo. El código no se puede modificar después de crearlo.
- [ ] El administrador puede desactivar y reactivar un tipo.
- [ ] Un tipo inactivo no aparece al crear un reporte; las incidencias existentes conservan su tipo.

## Dependencias

- **Depende de:** HU-02.
- **Relacionada con:** HU-03 (selección del tipo), HU-06 (orientación), HU-09 (prioridad base).

## Notas funcionales

- El **código** es la clave fija y legible del tipo (por ejemplo `BACHE`): mayúsculas, números y guion bajo, de 2 a 30 caracteres. Si no se indica, se genera del nombre sin acentos (`Fuga de agua` → `FUGA_DE_AGUA`). El **nombre** es el texto que ve el usuario y sí puede cambiar (RN-07).
- Por ahora no tiene pantalla en el lienzo; el catálogo inicial se carga desde el servidor.
- Reglas de negocio: RN-05, RN-07, RN-11, RN-13.
- Requisitos funcionales: RF-28.
