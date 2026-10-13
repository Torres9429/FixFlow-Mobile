# FixFlow Mobile

App móvil de **FixFlow**: reporte ciudadano y gestión de incidencias urbanas. Hecha en Flutter y consume la API de Spring Boot del repositorio `FixFlow-Backend`.

> 📌 **Antes de programar, lean [docs/architecture/arquitectura-mobile.md](docs/architecture/arquitectura-mobile.md).**
> Explica cómo está organizado el código: las capas de **datos, dominio y presentación**, qué va en cada carpeta, cómo funciona **MVVM** dentro de presentación y los pasos para agregar una HU nueva. Todo el código nuevo debe seguir esas reglas.

---

## Requisitos

| Herramienta | Versión |
| --- | --- |
| Flutter | 3.47.x (canal `stable`) — revisen con `flutter --version` |
| Dart | 3.13.x (viene con Flutter) |
| Android Studio o VS Code | Con el plugin de Flutter |
| Emulador o teléfono Android | Para correr la app y las pruebas de integración |

> Usen todos la misma versión de Flutter para evitar el clásico "en mi máquina sí corre".
> El SDK de Flutter debe estar en una ruta **sin espacios** (por ejemplo `C:\src\flutter`).

## Instalación

```powershell
git clone <url-del-repo>
cd FixFlow-Mobile
flutter pub get
```

## Correr la app

La app tiene dos modos: **mock**, con un back simulado que no necesita servidor, y **dev**, que usa el back real.

| Modo | Cómo | Para qué |
| --- | --- | --- |
| **Mock** | Botón ▶ normal, o `flutter run --dart-define-from-file=config/mock.json` | Desarrollar y probar pantallas sin back |
| **Dev** | `flutter run --dart-define-from-file=config/dev.json` | Probar contra el back corriendo en tu PC (`http://10.0.2.2:8080/api`) |

En Android Studio, el archivo de configuración se pone en *Run → Edit Configurations → Additional run args*.

### Cuentas del modo mock

Todas usan la contraseña **`abc12345`**:

| Correo | Llega a |
| --- | --- |
| `ciudadano@fixflow.mx` | Home de ciudadano |
| `operativo@fixflow.mx` | Home de personal operativo |
| `admin@fixflow.mx` | Home de administrador |

### ¿Hot reload, hot restart o volver a correr?

| Si cambiaste… | Haz |
| --- | --- |
| Código dentro de un `build()` | Hot reload ⚡ |
| `main()`, el widget raíz o el estado inicial | Hot restart 🔄 |
| `pubspec.yaml` (paquetes, fuentes, assets), algo en `android/` o `ios/`, o los archivos de `config/` | **Detener ■ y volver a correr ▶** |

> Si aparece `MissingPluginException`, agregaron un paquete con código nativo y solo hicieron hot restart. Detengan la app y vuelvan a correrla.

## Pruebas

| Comando | Qué corre | Necesita |
| --- | --- | --- |
| `flutter test` | Unitarias (`test/unitaria/`) e interfaz (`test/interfaz/`) | Nada |
| `flutter test integration_test` | Integración (`integration_test/`) | Emulador o teléfono abierto |

Todas las respuestas del servidor están simuladas. El plan de pruebas del sprint, con el número de tests de cada fila, está en [docs/testing/plan-pruebas-sprint-1.md](docs/testing/plan-pruebas-sprint-1.md).

Antes de subir cambios corran también:

```powershell
flutter analyze
```

## Estructura

```
FixFlow-Mobile/
├── lib/
│   ├── main.dart / app.dart   ← arranque de la app
│   ├── core/                  ← Result, configuración e inyección de dependencias
│   ├── domain/                ← DOMINIO: entidades, contratos, errores y validadores
│   ├── data/                  ← DATOS: API (dio), almacenamiento y repositorios
│   └── presentation/          ← PRESENTACIÓN: pantallas + ViewModels (MVVM), rutas y theme
├── test/                      ← pruebas unitarias e interfaz, y mocks
├── integration_test/          ← pruebas de integración
├── config/                    ← mock.json, dev.json, example.json
├── assets/fonts/              ← tipografía Plus Jakarta Sans
└── docs/                      ← documentación del proyecto
```

El detalle de cada carpeta está en la [guía de arquitectura](docs/architecture/arquitectura-mobile.md).

## Documentación

| Documento | Contenido |
| --- | --- |
| ⭐ [Arquitectura](docs/architecture/arquitectura-mobile.md) | **Capas, MVVM, qué va en cada carpeta y reglas del equipo. Lectura obligatoria.** |
| [Requisitos](docs/requirements/README.md) | Historias de usuario, requisitos, reglas de negocio y glosario |
| [Metodología](docs/methodology/README.md) | Cómo trabaja el equipo: ScrumBan, DoR y DoD |
| [Plan de pruebas](docs/testing/plan-pruebas-sprint-1.md) | Pruebas del sprint y cuántos tests debe tener cada HU |

## Paquetes principales

| Paquete | Para qué |
| --- | --- |
| `provider` | Inyección de dependencias y ViewModels (`ChangeNotifier`) |
| `go_router` | Rutas y home según el rol |
| `dio` | Peticiones HTTP a la API |
| `flutter_secure_storage` | Guardar el token de sesión |
| `mocktail` *(dev)* | Mocks en las pruebas |
| `http_mock_adapter` *(dev)* | Simular respuestas de `dio` |
| `integration_test` *(dev)* | Pruebas de integración en el emulador |

## Reglas rápidas

- **No suban secretos** a `config/*.json`: todo lo que va en la app se puede extraer del APK.
- Colores y estilos **solo** desde `lib/presentation/core/theme/`.
- Cada pantalla con lógica tiene su **ViewModel**, y la pantalla nunca llama directo al repositorio.
- Las demás reglas están en la [sección 7 de la guía de arquitectura](docs/architecture/arquitectura-mobile.md#7-reglas-del-equipo).
