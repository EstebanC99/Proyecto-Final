import 'package:care_well_app/infrastructure/http/http_configs.dart';
import 'package:care_well_app/infrastructure/storage/token_storage.dart';
import 'package:dio/dio.dart';

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
  dio.interceptors.addAll([
    AuthInterceptor(tokenStorage, refreshDio),
    LogInterceptor(requestBody: true, responseBody: true), // quitar en prod
  ]);

  return dio;
}
