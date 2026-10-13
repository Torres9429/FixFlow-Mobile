# Arquitectura de FixFlow Mobile

Cómo está organizado el código de `lib/`: las **tres capas** (datos, dominio y presentación) y el patrón **MVVM** dentro de presentación.

## Índice

1. [Dos ideas que se combinan](#1-dos-ideas-que-se-combinan)
2. [Las capas](#2-las-capas)
3. [Qué va en cada carpeta](#3-qué-va-en-cada-carpeta)
4. [MVVM](#4-mvvm)
5. [Capas + MVVM juntos](#5-capas--mvvm-juntos)
6. [Ejemplo completo: el login](#6-ejemplo-completo-el-login)
7. [Reglas del equipo](#7-reglas-del-equipo)
8. [Cómo agregar una HU nueva](#8-cómo-agregar-una-hu-nueva)

---

## 1. Dos ideas que se combinan

| | Arquitectura en capas | MVVM |
| --- | --- | --- |
| **Qué es** | Un estilo de arquitectura | Un **patrón de arquitectura** |
| **Qué organiza** | **Toda la app** | **Solo la capa de presentación** |
| **Pregunta que responde** | ¿Cómo evito que las reglas del negocio dependan de la API o de la UI? | ¿Cómo evito que la lógica de una pantalla quede mezclada con los widgets? |
| **Piezas** | Datos, Dominio, Presentación | View, ViewModel, Model |

### ¿Patrón de arquitectura o patrón de diseño?

- Un **patrón de arquitectura** define cómo se reparten las responsabilidades entre partes grandes del sistema. **MVVM** dice cómo se dividen todas las pantallas de la app: View por un lado, ViewModel por otro.
- Un **patrón de diseño** resuelve un problema puntual entre unas pocas clases. En FixFlow también usamos algunos:

| Patrón de diseño | Dónde |
| --- | --- |
| **Repository** | `AuthRepository` (contrato) + `AuthRepositoryImpl` (implementación) |
| **Observer** | `ChangeNotifier` + `notifyListeners()` + `Consumer`: la View se redibuja cuando cambia el ViewModel |
| **Inyección de dependencias** | `dependencies.dart` arma las clases y `provider` las entrega |
| **Adapter / Mapper** | `LoginResponseModel.toEntity()`: convierte el JSON del back en una entidad |

---

## 2. Las capas

```
┌──────────────────────────────────────────┐
│ PRESENTACIÓN   lo que el usuario ve      │  ← aquí vive MVVM (View + ViewModel)
└────────────────────┬─────────────────────┘
                     │ usa
┌────────────────────▼─────────────────────┐
│ DOMINIO        reglas y contratos        │  ← Dart puro; no depende de nadie
└────────────────────▲─────────────────────┘
                     │ implementa
┌────────────────────┴─────────────────────┐
│ DATOS          de dónde salen los datos  │  ← API, almacenamiento, JSON
└──────────────────────────────────────────┘
```

| Capa | Responsabilidad | Ejemplos |
| --- | --- | --- |
| **Dominio** | Qué es la app: entidades, reglas de negocio y los **contratos** de lo que se puede pedir | `Usuario`, `Rol`, `AuthRepository`, validadores |
| **Datos** | Cómo se obtienen y guardan los datos: HTTP, almacenamiento seguro, JSON | `AuthRepositoryImpl`, `AuthRemoteDataSource`, `SessionStorage` |
| **Presentación** | Cómo se muestra y se usa: pantallas, su estado, navegación, estilos | `LoginScreen`, `LoginViewModel`, `router.dart` |

**Dominio está en el centro.** Presentación y Datos dependen de él, y él no depende de nadie. Así, si cambia el back, solo cambia Datos; si cambia el diseño, solo cambia Presentación.

---

## 3. Qué va en cada carpeta

```
lib/
├── main.dart                 ← arma las dependencias y arranca la app
├── app.dart                  ← FixFlowApp: theme, router y providers
├── core/                     ← piezas transversales (no son de una sola capa)
├── domain/                   ═══ DOMINIO ═══
├── data/                     ═══ DATOS ═══
└── presentation/             ═══ PRESENTACIÓN (MVVM) ═══
```

### `core/`: transversal

| Carpeta / archivo | Qué va | Ejemplo |
| --- | --- | --- |
| `result.dart` | El tipo `Result<T>` (`Ok` / `Error`) con el que viajan las respuestas entre capas | `Result.ok(usuario)`, `Result.error(CredencialesInvalidas())` |
| `config/` | Configuración del ambiente leída de `config/*.json` | `app_config.dart`: `API_BASE_URL`, `USE_MOCKS` |
| `di/` | **El único lugar** que crea las clases de Datos y las conecta | `dependencies.dart` |

### `domain/`: dominio (Dart puro, sin Flutter)

| Carpeta | Qué va | Ejemplo |
| --- | --- | --- |
| `entities/` | Los objetos del negocio, tal como los piensa la app (no como los manda el back) | `usuario.dart`, `rol.dart` |
| `repositories/` | Los **contratos** (`abstract interface class`): qué se puede pedir, sin decir cómo | `auth_repository.dart` |
| `errors/` | Los errores del negocio que entiende la app | `auth_failure.dart`: `CredencialesInvalidas`, `SinConexion` |
| `validators/` | Reglas de negocio que se pueden probar solas | `campos_validators.dart`: `validarObligatorio` |

### `data/`: datos

| Carpeta | Qué va | Ejemplo |
| --- | --- | --- |
| `datasources/remote/` | Lo que habla con servicios externos por HTTP (`dio`) | `api_client.dart`, `auth_remote_datasource.dart` |
| `datasources/remote/` (fake) | El back simulado del **modo mock** | `fake_auth_remote_datasource.dart` |
| `datasources/local/` | Lo que se guarda en el teléfono | `session_storage.dart` (token en `flutter_secure_storage`) |
| `datasources/device/` | Sensores del teléfono *(Sprint 2)* | cámara, GPS, acelerómetro |
| `models/` | La forma del JSON del back y su conversión a entidad (`fromJson` / `toEntity`) | `login_response_model.dart` |
| `repositories/` | Las **implementaciones** de los contratos de dominio: coordinan datasources y traducen errores | `auth_repository_impl.dart` |

### `presentation/`: presentación (MVVM)

| Carpeta | Qué va | Ejemplo |
| --- | --- | --- |
| `core/theme/` | Colores y estilos de la app (la paleta) | `app_colors.dart`, `app_theme.dart` |
| `core/widgets/` | Widgets reutilizables entre pantallas | `campo_texto.dart` |
| `routing/` | Rutas, navegación y qué home le toca a cada rol | `router.dart`, `rutas.dart`, `home_por_rol.dart` |
| `<módulo>/<pantalla>/` | **Una carpeta por pantalla con su View y su ViewModel** | `auth/login/login_screen.dart` + `login_viewmodel.dart` |
| `home/` | Las homes de cada rol (por ahora provisionales) | `home_ciudadano_screen.dart`, `home_base.dart` |

---

## 4. MVVM

MVVM divide **cada pantalla** en tres partes:

```
  VIEW                      VIEWMODEL                    MODEL
  (lo que se ve)            (estado y lógica)            (datos y reglas)
┌──────────────┐  llama   ┌──────────────────┐  pide   ┌──────────────────┐
│ LoginScreen  │ ───────▶ │ LoginViewModel   │ ──────▶ │ AuthRepository   │
│              │ ◀─────── │  cargando        │ ◀────── │ Usuario, Rol     │
└──────────────┘ notifica └──────────────────┘ responde└──────────────────┘
```

| Pieza | Qué hace | Qué **no** hace |
| --- | --- | --- |
| **View** (`*_screen.dart`) | Dibuja el estado del ViewModel y le avisa lo que hace el usuario (tocar, escribir) | Decidir reglas, llamar al repositorio, elegir mensajes de error |
| **ViewModel** (`*_viewmodel.dart`) | Guarda el estado de la pantalla (`cargando`, `error`, `usuario`), llama al Model y decide qué mostrar | Importar `material.dart` o tocar widgets |
| **Model** | Las capas de **dominio y datos** | Saber que existen pantallas |

### Cómo se entera la View de los cambios (Observer)

| Pieza | Papel |
| --- | --- |
| `ChangeNotifier` | El ViewModel puede ser observado |
| `notifyListeners()` | El ViewModel avisa "cambié" |
| `Consumer<LoginViewModel>` | La View escucha y se redibuja |
| `ChangeNotifierProvider` (en `router.dart`) | Crea el ViewModel y se lo entrega a su pantalla |

### Estado visual vs. estado de negocio

- **De negocio** (¿está cargando?, ¿qué error hubo?, ¿quién entró?) → en el **ViewModel**.
- **Puramente visual** (¿se ve la contraseña?, ¿qué pestaña está abierta?) → se puede quedar en la **View**. Ejemplo: `_passwordVisible` en `LoginScreen`.

---

## 5. Capas + MVVM juntos

MVVM **solo se aplica a la capa de presentación**. La "M" de MVVM (el Model) no es una carpeta: son las capas de **dominio y datos** completas. MVVM dice que el Model existe, pero no dice cómo organizarlo; eso lo resuelven las capas.

```
MVVM dice:       View        ViewModel   │   Model  ← "de aquí para abajo no es asunto de MVVM"
                 └──── presentación ─────┘   │
Las capas dicen:                             dominio + datos
```

```
┌─────────────────────── PRESENTACIÓN ───────────────────────┐
│   VIEW                         VIEWMODEL                   │
│   LoginScreen  ──llama──▶      LoginViewModel              │   ← MVVM: V + VM
│                ◀─notifica──    (cargando, error, usuario)  │
└──────────────────────────────────┬─────────────────────────┘
                                   │ pide al CONTRATO
┌──────────────────────── DOMINIO ─▼─────────────────────────┐
│   AuthRepository (abstracto)   Usuario, Rol                │   ← MVVM: Model
│   validarObligatorio           CredencialesInvalidas…      │     (reglas)
└──────────────────────────────────▲─────────────────────────┘
                                   │ implementa
┌───────────────────────── DATOS ──┴─────────────────────────┐
│   AuthRepositoryImpl                                       │   ← MVVM: Model
│     ├── AuthRemoteDataSource (dio → API)  / Fake (mock)    │     (de dónde salen)
│     └── SessionStorage (flutter_secure_storage)            │
│   LoginResponseModel (JSON → Usuario)                      │
└────────────────────────────────────────────────────────────┘
```

Las dos ideas son independientes y se pueden combinar como se quiera
### Quién conoce a quién

| Capa | Importa a | Nunca importa a |
| --- | --- | --- |
| Presentación | Dominio | Datos |
| Datos | Dominio | Presentación |
| Dominio | Nadie (Dart puro) | Datos, Presentación ni Flutter |

El ViewModel pide el **contrato** (`AuthRepository`), nunca la implementación (`AuthRepositoryImpl`). Quien los une es `core/di/dependencies.dart`:

```
main.dart → crearDependencias() → FixFlowApp(authRepository: AuthRepositoryImpl(...))
                                        │ Provider
                                        ▼
                    router.dart → LoginViewModel(authRepository: context.read<AuthRepository>())
```

### Contrato vs. implementación del repositorio

| | `domain/repositories/auth_repository.dart` | `data/repositories/auth_repository_impl.dart` |
| --- | --- | --- |
| Es | El **contrato**: clase abstracta | La **implementación**: `implements AuthRepository` |
| Dice | **Qué** se puede pedir | **Cómo** se hace |
| Sabe de HTTP, JSON, token | No | Sí |
| Lo usa | El ViewModel | Solo `dependencies.dart` lo crea |
| En las pruebas se reemplaza por | `MockAuthRepository` | — |

En EcoTrack el contrato y la implementación están en el mismo archivo (`datos/consumo_repository.dart`). La idea es la misma; FixFlow solo pone el contrato en dominio y la implementación en datos.

---

## 6. Ejemplo completo: el login

| # | Capa | Pieza | Qué hace |
| --- | --- | --- | --- |
| 1 | Presentación · View | `login_screen.dart` | El usuario toca "Iniciar sesión"; el formulario valida con `validarObligatorio` |
| 2 | Presentación · ViewModel | `login_viewmodel.dart` | `cargando = true`, `notifyListeners()` → la View muestra el spinner |
| 3 | Dominio | `auth_repository.dart` | El ViewModel llama a `iniciarSesion` del contrato |
| 4 | Datos | `auth_repository_impl.dart` | Coordina la API y el almacenamiento |
| 5 | Datos | `auth_remote_datasource.dart` / fake | `POST /auth/login`; un 401 se convierte en `CredencialesInvalidas` |
| 6 | Datos | `session_storage.dart` | Guarda el token |
| 7 | Datos → Dominio | `login_response_model.dart` | JSON → `Usuario` |
| 8 | Presentación · ViewModel | `login_viewmodel.dart` | Guarda `usuario` o `error`, `cargando = false`, `notifyListeners()` |
| 9 | Presentación · View | `login_screen.dart` | Muestra el error, o navega a la home con `rutaHomePorRol` |

Entre capas solo viajan **entidades** (`Usuario`) y **errores de dominio** (`CredencialesInvalidas`) dentro de un `Result`. Nunca sube JSON ni un `DioException`.

### Qué se toca si algo cambia

| Si cambia… | Se toca solo… |
| --- | --- |
| El diseño de la pantalla | La View |
| Qué mensaje mostrar o a dónde navegar | El ViewModel / `routing/` |
| Una regla de negocio (p. ej. la política de contraseña) | Dominio |
| El back, la URL o el formato del JSON | Datos |

---

## 7. Reglas del equipo

1. **`domain/` no importa nada** de `data/`, de `presentation/` ni de Flutter.
2. **Presentación pide contratos**, nunca implementaciones: `AuthRepository`, no `AuthRepositoryImpl`.
3. **Las clases de `data/` solo se crean** en `core/di/dependencies.dart`.
4. **Ningún `DioException` ni JSON sale de `data/`.** Hacia arriba viajan entidades y errores de dominio dentro de un `Result`.
5. **La View no llama al repositorio**; siempre pasa por su ViewModel.
6. **Un ViewModel no importa `material.dart`.** Expone datos; la View decide cómo mostrarlos.
7. **Colores y estilos solo desde `presentation/core/theme/`.**

---

## 8. Cómo agregar una HU nueva

Ejemplo: **HU-01, registro de ciudadano**.

| Paso | Capa | Archivo |
| --- | --- | --- |
| 1 | Dominio | Agregar `registrar(...)` al contrato `auth_repository.dart`; nuevos validadores en `validators/`; `CorreoDuplicado` en `errors/` |
| 2 | Datos | `registrar()` en `auth_remote_datasource.dart` (y en el fake); implementarlo en `auth_repository_impl.dart` |
| 3 | Presentación · ViewModel | `presentation/auth/registro/registro_viewmodel.dart` |
| 4 | Presentación · View | `presentation/auth/registro/registro_screen.dart` |
| 5 | Presentación · rutas | Agregar `/registro` en `rutas.dart` y `router.dart` |
| 6 | Core | Nada, salvo que haya una dependencia nueva en `dependencies.dart` |
