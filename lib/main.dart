import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/dependencies.dart';

void main() {
  final dependencias = crearDependencias();
  runApp(FixFlowApp(
    authRepository: dependencias.authRepository,
    incidenceTypeRepository: dependencias.incidenceTypeRepository,
  ));
}
