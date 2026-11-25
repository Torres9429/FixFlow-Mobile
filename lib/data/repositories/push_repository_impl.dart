import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../core/log/bitacora.dart';
import '../../domain/entities/accion_aviso.dart';
import '../../domain/entities/aviso_push.dart';
import '../../domain/repositories/push_repository.dart';

// getToken / onTokenRefresh / deleteToken están marcados obsoletos en firebase_messaging 17, pero se usan a propósito:
// su reemplazo (register / onRegistered) entrega un Installation ID para «direct-send», no el token de registro
// que espera el back (firebase-admin 9.4: Message.setToken). Cambiarlo exige cambiar también PushService.
// ignore_for_file: deprecated_member_use

class PushRepositoryImpl implements PushRepository {
  PushRepositoryImpl(this._dio) : _messaging = FirebaseMessaging.instance;

  final Dio _dio;
  final FirebaseMessaging _messaging;
  final _recibidos = StreamController<AvisoPush>.broadcast();
  final _tocados = StreamController<AvisoPush>.broadcast();
  StreamSubscription<String>? _renovacion;
  StreamSubscription<RemoteMessage>? _enPrimerPlano;
  StreamSubscription<RemoteMessage>? _alTocar;
  String? _token;

  // Firebase entrega el mismo token por getToken y por onTokenRefresh: se registra una sola vez
  String? _registrado;

  // Sin sesión no se registra nada: un 401 aquí mandaría al login con «sesión vencida»
  bool _activo = false;

  @override
  Stream<AvisoPush> get recibidos => _recibidos.stream;

  @override
  Stream<AvisoPush> get tocados => _tocados.stream;

  @override
  Future<void> activar() async {
    _activo = true;
    try {
      // Android 13+: diálogo del sistema. Si lo niega, igual se registra: con la app abierta sí llegan
      final permiso = await _messaging.requestPermission();
      if (permiso.authorizationStatus == AuthorizationStatus.denied) {
        Bitacora.info('push', 'Sin permiso de notificaciones: solo bandeja y avisos con la app abierta');
      }
      _token = await _messaging.getToken();
      if (_token != null) await _registrar(_token!);

      _renovacion ??= _messaging.onTokenRefresh.listen((token) {
        _token = token;
        if (_activo) _registrar(token);
      });
      _enPrimerPlano ??= FirebaseMessaging.onMessage.listen((m) => _emitir(_recibidos, m, 'recibido con la app abierta'));
      _alTocar ??= FirebaseMessaging.onMessageOpenedApp.listen((m) => _emitir(_tocados, m, 'tocado en segundo plano'));
    } catch (e) {
      Bitacora.error('No se pudo activar el push', e);
    }
  }

  @override
  Future<void> desactivar() async {
    _activo = false;
    try {
      final token = _token ?? await _messaging.getToken();
      if (token != null) await _dio.delete<Map<String, dynamic>>('/notificaciones/token', data: {'token': token});
      // El siguiente inicio de sesión pide un token nuevo
      await _messaging.deleteToken();
    } catch (e) {
      Bitacora.error('No se pudo desactivar el push', e);
    }
    _token = null;
    _registrado = null;
  }

  @override
  Future<AvisoPush?> avisoInicial() async {
    try {
      final mensaje = await _messaging.getInitialMessage();
      final aviso = mensaje == null ? null : _aviso(mensaje);
      if (aviso != null) Bitacora.debug('push', 'La app se abrió desde un aviso (incidencia ${aviso.incidenciaId})');
      return aviso;
    } catch (e) {
      Bitacora.error('No se pudo leer el aviso inicial', e);
      return null;
    }
  }

  Future<void> _registrar(String token) async {
    if (token == _registrado) return;
    _registrado = token;
    try {
      await _dio.post<Map<String, dynamic>>('/notificaciones/token', data: {'token': token});
      Bitacora.debug('push', 'Token de FCM registrado en el back');
    } catch (e) {
      _registrado = null;
      Bitacora.error('No se pudo registrar el token de FCM', e);
    }
  }

  void _emitir(StreamController<AvisoPush> destino, RemoteMessage mensaje, String como) {
    final aviso = _aviso(mensaje);
    if (aviso == null) return;
    Bitacora.debug('push', 'Aviso $como (incidencia ${aviso.incidenciaId}, ${aviso.accion.name})');
    destino.add(aviso);
  }

  // `data` lo arma NotificacionService.enviarDespuesDelCommit en el back
  AvisoPush? _aviso(RemoteMessage mensaje) {
    final id = int.tryParse('${mensaje.data['incidenciaId']}');
    if (id == null) return null;
    return AvisoPush(
      incidenciaId: id,
      accion: AccionAviso.desde(mensaje.data['accion'] as String?),
      titulo: mensaje.notification?.title ?? '',
      mensaje: mensaje.notification?.body ?? '',
    );
  }
}
