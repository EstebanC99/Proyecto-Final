import 'package:care_well_app/infrastructure/http/http_configs.dart';
import 'package:care_well_app/infrastructure/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

Dio createDioClient(TokenStorage tokenStorage) {
  final baseOptions = BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
    headers: {'Content-Type': 'application/json'},
  );

  // Dio sin interceptores para el refresh (evita recursión)
  final refreshDio = Dio(baseOptions);

  final dio = Dio(baseOptions);
  dio.interceptors.add(AuthInterceptor(tokenStorage, refreshDio));

  // Solo en debug: el log vuelca los bodies completos (tokens JWT, contraseñas
  // del login, imágenes en base64) y no debe quedar en un build de release.
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  return dio;
}
