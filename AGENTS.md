# AGENTS.md — FixFlow Mobile

## Proyecto
App Android 8.0+ de reporte ciudadano de incidencias urbanas, con tres roles en la misma app: el ciudadano reporta con foto en vivo, GPS e inclinación; el admin asigna; el operativo resuelve. Alcance, pantallas y criterios por flujo: `docs/prd.md`. Reglas del dominio: `docs/requirements/` (cita HU-XX, RN-XX, RNF-XX; no las copies).

## Stack
- Flutter 3.47 / Dart 3.13 · `provider` (MVVM con `ChangeNotifier`) · `go_router` · `dio` · `flutter_secure_storage` · `geolocator` · `image_picker`.
- Pruebas: `flutter_test`, `mocktail`, `http_mock_adapter`, `integration_test`.
- Back: Spring Boot 4.1 + MySQL 8 en `FixFlow-Backend`, ya completo. Contrato: `docs/architecture/contrato-api.md`.

## Reglas
1. Capas según `docs/architecture/arquitectura-mobile.md`: `domain/` no importa Flutter ni `data/`; la View solo habla con su ViewModel; el ViewModel no importa `material.dart`; las clases de `data/` se crean solo en `core/di/dependencies.dart`.
2. Ningún `DioException` ni JSON sale de `data/`: hacia arriba viaja un `Result` con entidades o errores de dominio.
3. Cámara, GPS y acelerómetro van en `data/datasources/device/`, nunca en una pantalla.
4. Evidencia: solo foto en vivo (`ImageSource.camera`, nunca galería), GPS de la captura e inclinación dentro de `anguloMin`/`anguloMax` del tipo. Sin borradores ni modo offline.
5. Toda respuesta llega como `{text, type, result}`: decide por el código HTTP y muestra `text`.
6. Fuera de alcance: micrófono o voz, duplicados por cercanía, votos de urgencia, rechazo de reportes y push.
7. Colores y estilos solo desde `presentation/core/theme/`, siguiendo `docs/design.md`. Sin secretos en `config/*.json`.
8. Cada pantalla trae su fake del modo mock y las pruebas que pide `docs/testing/plan-pruebas-sprint-N.md`.
9. Si el back no responde como dice el contrato, avisa; no lo rodees en la app.
10. Rama propia y PR a `develop`. Sprint, Status y Assignee viven en GitHub Projects, no en `docs/`; no marques las casillas de las HU.

## Comandos
```powershell
flutter pub get
flutter run --dart-define-from-file=config/mock.json   # back simulado
flutter run --dart-define-from-file=config/dev.json    # back en la laptop
flutter analyze                                         # sin advertencias nuevas
flutter test                                            # unitarias e interfaz
flutter test integration_test                           # con emulador o teléfono
```
Back (en `FixFlow-Backend`): `.\mvnw.cmd spring-boot:run`. Para probar los procesos de 7 días: `POST /api/admin/jobs/ejecutar?dias=0` como admin.
