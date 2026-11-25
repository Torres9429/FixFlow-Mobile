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

La configuración se lee de un archivo de `config/` según el ambiente. Hay dos ambientes, **dev** y **prod**, y dev puede usar un back simulado (mock).

| Modo | Cómo | Para qué | Logs |
| --- | --- | --- | --- |
| **Mock** (dev) | Botón ▶ sin argumentos, o `flutter run --dart-define-from-file=config/mock.json` | Desarrollar y probar pantallas sin back | Todo, con detalle |
| **Dev** | `flutter run --dart-define-from-file=config/dev.json` (emulador) o `config/device.json` (teléfono, con la IPv4 de tu PC) | Probar contra el back corriendo en tu PC, con push (FCM) | Todo, con detalle y peticiones HTTP |
| **Prod** | `flutter build apk --release --dart-define-from-file=config/prod.json` | El APK de la entrega | Solo el tipo de cada error |

- Fuera de prod, la app muestra una cinta naranja en la esquina (`MOCK` o `DEV`).
- El APK queda en `build/app/outputs/flutter-apk/app-release.apk`. Se firma con la clave de debug: sirve para la demo, no para publicar en la tienda.
- `config/prod.json` y `android/app/src/main/res/xml/network_security_config.xml` apuntan a la IP de la laptop del back. **Si cambia la IP, se cambia en los dos y se vuelve a compilar**: en release, Android solo permite `http` hacia esa IP.

En Android Studio, el archivo de configuración se pone en *Run → Edit Configurations → Additional run args*.

### Logs

Todo log pasa por `Bitacora` (`lib/core/log/bitacora.dart`): `Bitacora.debug`, `Bitacora.info` y `Bitacora.error`. **No uses `print` ni `debugPrint`.** El nivel sale del `ENV` del config: dev escribe todo; prod y cualquier build `--release` solo escriben el tipo del error, nunca el mensaje, porque ahí pueden viajar correos o tokens.

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
├── config/                    ← mock.json, dev.json, device.json, prod.json, example.json
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
| `camera` | Acceso a la cámara del dispositivo |
| `geolocator` | Obtener la ubicación GPS |
| `sensors_plus` | Leer acelerómetro y sensores |
| `google_maps_flutter` | Mostrar mapas |
| `flutter_image_compress` | Comprimir evidencia fotográfica |
| `mocktail` *(dev)* | Mocks en las pruebas |
| `http_mock_adapter` *(dev)* | Simular respuestas de `dio` |
| `integration_test` *(dev)* | Pruebas de integración en el emulador |

## Reglas rápidas

- **No suban secretos** a `config/*.json`: todo lo que va en la app se puede extraer del APK.
- El procedimiento para medir el acelerómetro en teléfonos físicos está en
  [docs/testing/medicion-acelerometro-rn11.md](docs/testing/medicion-acelerometro-rn11.md).
- Colores y estilos **solo** desde `lib/presentation/core/theme/`.
- Cada pantalla con lógica tiene su **ViewModel**, y la pantalla nunca llama directo al repositorio.
- Las demás reglas están en la [sección 7 de la guía de arquitectura](docs/architecture/arquitectura-mobile.md#7-reglas-del-equipo).
