import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../constants/api_constants.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;

  AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final box = Hive.box(ApiConstants.authBox);
    final token = box.get(ApiConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        // Retry the original request with the new token
        final box = Hive.box(ApiConstants.authBox);
        final newToken = box.get(ApiConstants.accessTokenKey);
        final opts = err.requestOptions
          ..headers['Authorization'] = 'Bearer $newToken';
        try {
          final response = await _dio.fetch(opts);
          return handler.resolve(response);
        } catch (_) {}
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    try {
      final box = Hive.box(ApiConstants.authBox);
      final refreshToken = box.get(ApiConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {}), // no auth header for refresh
      );

      final data = response.data as Map<String, dynamic>;
      await box.put(ApiConstants.accessTokenKey, data['accessToken']);
      await box.put(ApiConstants.refreshTokenKey, data['refreshToken']);
      return true;
    } catch (_) {
      return false;
    }
  }
}
