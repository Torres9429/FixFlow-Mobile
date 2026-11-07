import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/dependencies.dart';

void main() {
  final dependencias = crearDependencias();
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
      sesionExpirada: dependencias.sesionExpirada,
    ),
  );
}
