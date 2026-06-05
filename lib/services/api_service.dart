import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "https://travora-001-site1.site4future.com",
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors
        .add(LogInterceptor(responseBody: true, requestBody: true));
    _dio.interceptors.add(_TokenInterceptor(_dio)); 
  }

  Future<Options> _buildOptions(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('accessToken') ?? '';
    final finalToken = token ?? (savedToken.isNotEmpty ? savedToken : null);

    return Options(
      headers:
          finalToken != null ? {'Authorization': 'Bearer $finalToken'} : null,
    );
  }

  Future<Response> post({
    required String endpoint,
    required Map<String, dynamic> data,
    String? token,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        options: await _buildOptions(token),
      );
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  Future<Response> postMultipart({
    required String endpoint,
    required FormData formData,
    String? token,
  }) async {
    try {
      final options = await _buildOptions(token);
      options.contentType = 'multipart/form-data';

      return await _dio.post(
        endpoint,
        data: formData,
        options: options,
      );
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  Future<Response> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: await _buildOptions(token),
      );
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  Future<Response> put({
    required String endpoint,
    required Map<String, dynamic> data,
    String? token,
  }) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,
        options: await _buildOptions(token),
      );
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  Future<Response> delete({
    required String endpoint,
    String? token,
  }) async {
    try {
      return await _dio.delete(
        endpoint,
        options: await _buildOptions(token),
      );
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      rethrow;
    }
  }

  Future<Response> patch({
    required String endpoint,
    Map<String, dynamic>? data,
    String? token,
  }) async {
    try {
      return await _dio.patch(
        endpoint,
        data: data,
        options: await _buildOptions(token),
      );
    } on DioException catch (e) {
      if (e.response != null) return e.response!;
      rethrow;
    }
  }
}

class _TokenInterceptor extends Interceptor {
  final Dio dio;
  bool _isRefreshing = false; 

  _TokenInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      final didRefresh = await _tryRefreshToken();

      _isRefreshing = false;

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

      final tempDio = Dio(BaseOptions(
        baseUrl: "https://travora-001-site1.site4future.com",
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));

      final response = await tempDio.post(
        "/api/v1/auth/refresh", 
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
