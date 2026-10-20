---
id: HU-24
titulo: Gestionar personal operativo
modulo: Autenticación y usuarios
actor: Administrador municipal
---

# HU-24 — Gestionar personal operativo

## Historia

**Como** administrador municipal
**Quiero** dar de alta y desactivar cuentas del personal operativo
**Para** que solo el personal vigente pueda iniciar sesión y recibir incidencias.

## Criterios de aceptación

- [ ] El administrador puede registrar a un miembro del personal operativo con nombre, apellidos, correo y una contraseña temporal.
- [ ] La cuenta creada recibe el rol **Personal operativo**. Nadie puede asignarse ese rol desde el registro público.
- [ ] No se puede registrar un correo que ya exista.
- [ ] El administrador puede consultar la lista del personal operativo con su estado (activo o inactivo) y su carga actual.
- [ ] El administrador puede desactivar y reactivar una cuenta.
- [ ] Una cuenta inactiva no puede iniciar sesión ni aparece entre el personal disponible para asignar.
- [ ] Desactivar una cuenta no cambia las incidencias que ya tenía asignadas; el administrador puede reasignarlas (HU-21).

## Dependencias

- **Depende de:** HU-02.
- **Relacionada con:** HU-21 (asignación), HU-25 (el operativo cambia su contraseña temporal).

## Notas funcionales

- Origen: HU-01 solo registra ciudadanos (RN-04); sin esta HU no hay forma de crear operativos ni de cumplir RN-16.
- Reglas de negocio: RN-01, RN-02, RN-05, RN-16, RN-19.
- Requisitos funcionales: RF-26.
- Requisitos no funcionales: RNF-09.
