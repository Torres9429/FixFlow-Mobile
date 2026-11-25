# Ambientes, modos de compilación y logs

Cómo elige la app contra qué back trabaja, cuánto escribe en el log y cómo se compila para la entrega.

Hay dos cosas que se combinan:

- **Ambiente:** contra qué back trabaja la app y cuánto registra. Se elige con un archivo de `config/`.
- **Modo de compilación:** debug, profile o release. Se elige con una bandera de `flutter run`.

## Comandos rápidos

```powershell
flutter run                                                    # mock (sin back), debug
flutter run --dart-define-from-file=config/mock.json           # lo mismo, explícito
flutter run --dart-define-from-file=config/dev.json            # back en la laptop, desde el emulador
flutter run --dart-define-from-file=config/device.json         # back en la laptop, desde un teléfono
flutter run --profile --dart-define-from-file=config/dev.json  # medir rendimiento con DevTools
flutter run --release --dart-define-from-file=config/prod.json # probar el release sin generar el APK
flutter build apk --release --dart-define-from-file=config/prod.json  # APK de la entrega
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk`.

## 1. Los ambientes

Cada archivo de `config/` es un ambiente:

| Archivo | `ENV` | Back | `LOG_HTTP` | `FIREBASE` |
| --- | --- | --- | --- | --- |
| `mock.json` | dev | simulado (`USE_MOCKS: true`) | false | — |
| `dev.json` | dev | `http://10.0.2.2:8080/api` (la laptop vista desde el emulador) | true | true |
| `device.json` | dev | `http://<IPv4 de tu laptop>:8080/api` | true | true |
| `prod.json` | prod | `http://<IPv4 de la laptop de la demo>:8080/api` | false | true |
| `example.json` | — | plantilla con todas las llaves | — | — |

Las llaves:

| Llave | Qué hace | Si no viene |
| --- | --- | --- |
| `ENV` | `dev`, `qa` o `prod`. Define el nivel de log y si se muestra la cinta del ambiente | `dev` |
| `API_BASE_URL` | URL base del back | vacía → la app entra en mock |
| `USE_MOCKS` | Fuerza el back simulado | `false` |
| `LOG_HTTP` | Registra cada petición: método, ruta, código y duración | `false` |
| `FIREBASE` | Inicia Firebase para las notificaciones push | `false` |
| `APP_VERSION` | Texto de la versión en el perfil | `1.0.0` |

**Nunca pongas secretos en `config/*.json`:** quedan grabados dentro del APK.

## 2. Cómo llegan a la app

`--dart-define-from-file=config/dev.json` toma cada llave del JSON y la pasa como un `--dart-define`. Es lo mismo que escribir:

```powershell
flutter run --dart-define=ENV=dev --dart-define=API_BASE_URL=http://10.0.2.2:8080/api --dart-define=LOG_HTTP=true --dart-define=FIREBASE=true
```

La app los lee en `lib/core/config/app_config.dart`:

```dart
static const env = String.fromEnvironment('ENV', defaultValue: 'dev');
static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
static const usarMocks = bool.fromEnvironment('USE_MOCKS') || apiBaseUrl == '';
```

- **Son `const`:** el valor queda grabado al compilar. La app no lee el JSON mientras corre.
- **Si cambias un JSON**, detén la app (■) y vuelve a correrla. Hot reload y hot restart no lo toman.
- **De `ENV` sale el nivel de log** (`AppConfig.nivelPara`): `dev` → debug, `qa` → info, `prod` → error.

## 3. Quién usa cada valor

| Valor de `AppConfig` | Lo usa | Para qué |
| --- | --- | --- |
| `usarMocks` | `core/di/dependencies.dart` | Crear los `Fake…Repository` o los que hablan con el back |
| `apiBaseUrl` | `ApiClient` | La URL base de `dio` |
| `logHttp` | `ApiClient` | Agregar o no `BitacoraInterceptor` |
| `nivelLog` | `core/log/bitacora.dart` | Qué se escribe en el log |
| `usarFirebase` | `main.dart` | Iniciar Firebase (sin él se usa `FakePushRepository`) |
| `esProd` | `app.dart` | Ocultar la cinta naranja `MOCK` / `DEV` |
| `version` | `perfil_screen.dart` | «FixFlow · versión 1.0.0» |

## 4. Modos de compilación

| Bandera | Modo | Hot reload | Para qué |
| --- | --- | --- | --- |
| *(ninguna)* | debug | sí | Desarrollar |
| `--profile` | profile | no | Medir rendimiento con DevTools |
| `--release` | release | no | Probar como en la entrega; `flutter build apk --release` genera el APK |

El primer build release tarda (unos 10 minutos), porque R8 optimiza el código. Los siguientes son más rápidos. Para correr release en un emulador, este debe ser x86_64.

El release se firma con la clave de debug: sirve para la demo, no para publicar en una tienda.

## 5. Logs

Todo log pasa por `Bitacora` (`lib/core/log/bitacora.dart`). **No uses `print` ni `debugPrint`.**

```dart
Bitacora.debug('push', 'Token de FCM registrado en el back');  // detalle para desarrollar
Bitacora.info('arranque', 'ambiente=dev');                      // eventos importantes
Bitacora.error('No se pudo leer el GPS', e);                    // dentro de un catch
```

Lo que se escribe depende del ambiente **y** del modo:

| | debug | release |
| --- | --- | --- |
| `ENV=dev` | debug, info y error con el detalle | solo el tipo del error |
| `ENV=qa` | info y error con el detalle | solo el tipo del error |
| `ENV=prod` | solo el tipo del error | solo el tipo del error |

«Solo el tipo» significa `[ERROR][No se pudo guardar el token] FormatException`, sin el mensaje: ahí pueden viajar correos, tokens o rutas del back.

`BitacoraInterceptor` escribe una línea por petición (`→ GET /ruta`, `← 200 GET /ruta (110 ms)`) en nivel info. Nunca registra encabezados, query ni cuerpo.

## 6. Android: `http` en release

Android bloquea las URLs `http://` en release. Como el back de la demo corre en una laptop sin `https`, hay dos archivos `network_security_config.xml`:

| Archivo | Se usa en | Permite `http` hacia |
| --- | --- | --- |
| `android/app/src/debug/res/xml/network_security_config.xml` | debug | cualquier IP (cada quien usa la de su laptop) |
| `android/app/src/main/res/xml/network_security_config.xml` | profile y release | solo la IP de `prod.json` y `10.0.2.2` |

**Si cambia la IP de la laptop de la demo**, cámbiala en `config/prod.json` **y** en el XML de `main`, y vuelve a compilar.

## 7. Configurar y probar `prod`

`prod` no es un servidor: es el back corriendo en una laptop, en la misma red que los teléfonos. `prod.json` lleva la IP de esa laptop en esa red.

### Poner la IP de la laptop que corre el back

1. En esa laptop, con el WiFi que se va a usar, corre `ipconfig` y toma la **Dirección IPv4** del adaptador **Wi-Fi**, por ejemplo `192.168.0.23`. No uses la de `vEthernet (WSL)` ni la de otros adaptadores virtuales.
2. Ponla en `config/prod.json`:

   ```json
   "API_BASE_URL": "http://192.168.0.23:8080/api"
   ```

3. Ponla en `android/app/src/main/res/xml/network_security_config.xml`, en lugar de la anterior:

   ```xml
   <domain includeSubdomains="false">192.168.0.23</domain>
   ```

4. Comprueba que el back responde en esa IP. Desde la laptop, abre `http://192.168.0.23:8080/api/tipos-incidencia` en el navegador: debe contestar con un JSON de «Sesión no válida» (401). Eso confirma que el back está arriba en esa IP.
5. Vuelve a compilar. La IP queda grabada en el APK.

Si solo cambias el JSON y olvidas el XML, en release Android bloquea el `http` y la app no conecta.

### ¿Emulador o teléfono?

Las dos opciones funcionan con la misma `prod.json`:

| Dónde corre la app | Llega a la IP de la laptop | Qué revisar |
| --- | --- | --- |
| **Emulador** en la misma laptop del back | Sí: el emulador sale a la red a través de la laptop | Que el emulador sea x86_64 (release no corre en x86) |
| **Teléfono físico** | Sí, si está en el **mismo WiFi** que la laptop | Que el firewall de Windows deje pasar conexiones entrantes al puerto 8080 en redes privadas, y que la red no aísle a los clientes (algunas redes de escuelas lo hacen) |

```powershell
flutter run --release --dart-define-from-file=config/prod.json   # instala y abre en el emulador o teléfono conectado
flutter build apk --release --dart-define-from-file=config/prod.json   # APK para instalar en los teléfonos
```

Si hay varios dispositivos conectados, elige uno con `-d`: `flutter devices` muestra los ids (`emulator-5554`, el id del teléfono).

### Para el día de la presentación

- Decidan qué laptop corre el back y lleven una red propia (por ejemplo, el hotspot de un teléfono), para que la IP no dependa del WiFi del lugar.
- Ya conectados a esa red, revisen la IP con `ipconfig`, actualicen los dos archivos y compilen el APK final. Una IP equivocada solo se arregla compilando otra vez.

## 8. Cómo agregar…

**Un ambiente nuevo** (por ejemplo `qa`):

1. Copia `config/example.json` como `config/qa.json` y pon `"ENV": "qa"` y su `API_BASE_URL`.
2. Si la URL es `http://`, agrega su IP al XML de `main` (secciones 6 y 7).
3. Córrelo con `flutter run --dart-define-from-file=config/qa.json`. `nivelPara('qa')` ya da nivel info.

**Una llave nueva:**

1. Agrégala a los JSON que la necesiten y a `example.json`.
2. Léela en `AppConfig` con `String.fromEnvironment` o `bool.fromEnvironment`, con un valor por defecto que no rompa el modo mock.
3. Úsala desde `AppConfig`; no llames a `fromEnvironment` en otros archivos.

## 9. Otra forma de nombrar los ambientes

Hay proyectos de Flutter que eligen el ambiente con un solo valor y tienen la configuración escrita en Dart:

```powershell
flutter run --dart-define=AMBIENTE=qa
flutter run --profile
flutter run --release --dart-define=AMBIENTE=prod
```

Ahí, una clase `Ambiente` guarda los valores de cada ambiente (`nombre`, `apiBase`, `logsVerbosos`, `mostrarBanner`, `color`) en constantes `_dev`, `_qa` y `_prod`, y un getter `Ambiente.actual` elige uno según `AMBIENTE`. Un `LoggerSeguro` con `debug`, `info` y `error` decide qué imprimir con `logsVerbosos` y `kReleaseMode`.

En FixFlow es la misma idea, con estas equivalencias:

| Esa estructura | FixFlow |
| --- | --- |
| `--dart-define=AMBIENTE=qa` | `--dart-define-from-file=config/qa.json` |
| `--release --dart-define=AMBIENTE=prod` | `--release --dart-define-from-file=config/prod.json` |
| Clase `Ambiente` con `_dev`, `_qa`, `_prod` | `AppConfig` + un JSON por ambiente en `config/` |
| `Ambiente.actual.apiBase` | `AppConfig.apiBaseUrl` |
| `logsVerbosos` | `AppConfig.nivelLog` (debug / info / error) |
| `mostrarBanner` | `!AppConfig.esProd` (cinta naranja en `app.dart`) |
| `LoggerSeguro.debug / info / error` | `Bitacora.debug / info / error` |

**Por qué FixFlow usa archivos:** la URL del back es la IP de la laptop de cada integrante. En un JSON, cada quien la cambia en su `device.json` sin tocar el código, y la IP no termina escrita en Dart.

## Problemas comunes

| Pasa esto | Revisa |
| --- | --- |
| Cambié un JSON y la app sigue igual | Detén la app (■) y vuelve a correrla: los valores se graban al compilar |
| ▶ entra en mock aunque el back está corriendo | ▶ sin argumentos siempre es mock. Agrega `--dart-define-from-file=config/dev.json` en *Additional run args* |
| La cinta dice `MOCK` | No llegó `API_BASE_URL`: revisa el nombre del archivo en el comando |
| En release no conecta al back | Que la IP de `prod.json` sea tu IPv4 actual (`ipconfig`), que esté en el XML de `main` y que el firewall deje pasar el puerto 8080 |
| No aparecen los logs de HTTP | `LOG_HTTP` debe ser `true` y el modo debug: en release no se escriben |
