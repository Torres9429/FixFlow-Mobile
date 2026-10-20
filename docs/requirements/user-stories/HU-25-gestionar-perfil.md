---
id: HU-25
titulo: Gestionar mi perfil
modulo: Autenticación y usuarios
actor: Usuario registrado
---

# HU-25 — Gestionar mi perfil

## Historia

**Como** usuario registrado
**Quiero** consultar y actualizar los datos de mi cuenta y cambiar mi contraseña
**Para** mantener mi información al día y reemplazar una contraseña temporal por una propia.

## Criterios de aceptación

- [ ] El usuario puede consultar su nombre, apellidos, correo y rol.
- [ ] El usuario puede editar su nombre y sus apellidos.
- [ ] El correo y el rol no se pueden modificar desde el perfil.
- [ ] El usuario puede cambiar su contraseña indicando la actual y la nueva.
- [ ] La nueva contraseña debe cumplir la política de contraseñas y ser distinta de la actual.
- [ ] Si la contraseña actual no es correcta, el cambio se rechaza con un mensaje.

## Dependencias

- **Depende de:** HU-02.
- **Relacionada con:** HU-24 (el operativo cambia aquí su contraseña temporal).

## Notas funcionales

- Aplica a los tres roles (pantalla A3 del lienzo, junto con cerrar sesión de HU-02).
- Reglas de negocio: RN-02, RN-03, RN-19.
- Requisitos funcionales: RF-27.
- Requisitos no funcionales: RNF-09.
