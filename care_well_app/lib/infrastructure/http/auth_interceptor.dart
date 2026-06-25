import 'package:care_well_app/infrastructure/http/api_config.dart';
import 'package:care_well_app/infrastructure/storage/token_storage.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends QueuedInterceptorsWrapper {
  final TokenStorage _tokenStorage;
  final Dio _refreshDio;

  AuthInterceptor(this._tokenStorage, this._refreshDio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skipPaths = [
      ApiConfig.loginPath,
      ApiConfig.refreshPath,
      ApiConfig.cuentaPath,
    ];
    final isAuthEndpoint = skipPaths.any((p) => options.path.contains(p));

    if (!isAuthEndpoint) {
      final token = await _tokenStorage.accessToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshCall = err.requestOptions.path.contains(
      ApiConfig.refreshPath,
    );

    if (isUnauthorized && !isRefreshCall) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final token = await _tokenStorage.accessToken;
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $token';
        try {
          final response = await _refreshDio.fetch(opts);
          return handler.resolve(response);
        } catch (_) {}
      }
      await _tokenStorage.clear();
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    try {
      final refreshToken = await _tokenStorage.refreshToken;
      if (refreshToken == null) return false;

      final response = await _refreshDio.post(
        ApiConfig.refreshPath,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      final userId = await _tokenStorage.userId;
      await _tokenStorage.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        userId: userId ?? 0,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
