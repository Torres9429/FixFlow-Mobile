---
id: HU-01
titulo: Registro de ciudadano
modulo: Autenticación y usuarios
actor: Ciudadano
---

# HU-01 — Registro de ciudadano

## Historia

**Como** ciudadano
**Quiero** crear una cuenta en FixFlow
**Para** poder registrar incidencias y consultar el seguimiento de mis reportes.

## Criterios de aceptación

- [ ] El usuario debe proporcionar los datos requeridos para crear su cuenta.
- [ ] El sistema debe validar que los campos obligatorios estén completos.
- [ ] El sistema debe evitar el registro de un correo electrónico que ya exista.
- [ ] La contraseña debe cumplir con los requisitos mínimos de seguridad establecidos.
- [ ] Al completar correctamente el registro, el sistema debe crear el usuario con el rol **Ciudadano**.
- [ ] El usuario debe poder iniciar sesión posteriormente con sus credenciales.

## Dependencias

- **Depende de:** ninguna.
- **Relacionada con:** HU-02 (el inicio de sesión posterior es parte de la verificación).

## Notas funcionales

- Reglas de negocio: RN-01, RN-02 *(pendiente)*, RN-03 *(pendiente)*, RN-04.
- Requisitos funcionales: RF-01.
