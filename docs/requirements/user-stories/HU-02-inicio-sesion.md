---
id: HU-02
titulo: Inicio de sesión
modulo: Autenticación y usuarios
actor: Usuario registrado
---

# HU-02 — Inicio de sesión

## Historia

**Como** usuario registrado
**Quiero** iniciar sesión en la aplicación
**Para** acceder a las funcionalidades correspondientes a mi rol.

## Criterios de aceptación

- [ ] El usuario debe ingresar sus credenciales.
- [ ] El sistema debe validar las credenciales contra la información registrada.
- [ ] Si son correctas, debe permitir el acceso.
- [ ] Si son incorrectas, debe mostrar un mensaje indicando que las credenciales no son válidas.
- [ ] El sistema debe mostrar únicamente las funcionalidades correspondientes al rol del usuario.
- [ ] El usuario debe poder cerrar sesión; al hacerlo se elimina la sesión guardada en el dispositivo.

## Dependencias

- **Depende de:** HU-01.
- **Relacionada con:** HU-24 (las cuentas inactivas no pueden iniciar sesión), HU-25 (perfil).

## Notas funcionales

- Aplica a los tres roles (Ciudadano, Personal operativo, Administrador municipal).
- Reglas de negocio: RN-05, RN-19.
- Requisitos funcionales: RF-02, RF-03.
- Requisitos no funcionales: RNF-09.
