import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenInterceptor extends Interceptor {
  final Dio dio;

  TokenInterceptor(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken') ?? '';

    if (accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final didRefresh = await _tryRefreshToken();

      if (didRefresh) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final newAccessToken = prefs.getString('accessToken') ?? '';

          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';

          final response = await dio.fetch(opts);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      }
    }

    handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken') ?? '';

      if (refreshToken.isEmpty) return false;

      final tempDio = Dio();
      final response = await tempDio.post(
        'YOUR_BASE_URL/api/v1/auth/refresh-token', 
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken']?.toString() ?? '';
        final newRefreshToken = response.data['refreshToken']?.toString() ?? '';

        if (newAccessToken.isEmpty) return false;

        await prefs.setString('accessToken', newAccessToken);
        if (newRefreshToken.isNotEmpty) {
          await prefs.setString('refreshToken', newRefreshToken);
        }

        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}
