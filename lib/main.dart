import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/dependencies.dart';
import 'core/log/bitacora.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bitacora.info('arranque', 'FixFlow ${AppConfig.version} · ambiente=${AppConfig.env} · mock=${AppConfig.usarMocks}');
  final dependencias = crearDependencias(conPush: await _iniciarFirebase());
  runApp(
    FixFlowApp(
      authRepository: dependencias.authRepository,
      incidenceTypeRepository: dependencias.incidenceTypeRepository,
      reportesCiudadanoRepository: dependencias.reportesCiudadanoRepository,
      operativoRepository: dependencias.operativoRepository,
      adminRepository: dependencias.adminRepository,
      ubicacionRepository: dependencias.ubicacionRepository,
      evidenciaRepository: dependencias.evidenciaRepository,
      inclinacionRepository: dependencias.inclinacionRepository,
      incidenciasRepository: dependencias.incidenciasRepository,
      direccionRepository: dependencias.direccionRepository,
      pushRepository: dependencias.pushRepository,
      avisosRepository: dependencias.avisosRepository,
      sesionExpirada: dependencias.sesionExpirada,
    ),
  );
}

/// Push (FCM): solo con FIREBASE=true en el config y back real (antes: flutterfire configure).
/// Si falla, la app sigue igual y los avisos quedan en la bandeja.
Future<bool> _iniciarFirebase() async {
  if (AppConfig.usarMocks || !AppConfig.usarFirebase) return false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    return true;
  } catch (e) {
    Bitacora.error('Firebase no disponible', e);
    return false;
  }
}
