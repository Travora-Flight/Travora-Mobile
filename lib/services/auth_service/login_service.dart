import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/auth/login_model.dart';
import '../../models/auth/login_response_model.dart';

class LoginService {
  final ApiService _apiService = ApiService();

  String _extractError(dynamic source) {
    if (source is DioException) {
      if (source.type == DioExceptionType.connectionTimeout ||
          source.type == DioExceptionType.receiveTimeout ||
          source.type == DioExceptionType.sendTimeout) {
        return "Connection timeout, please try again.";
      }
      if (source.type == DioExceptionType.unknown &&
          source.error is SocketException) {
        return "No internet connection.";
      }
      source = source.response?.data;
    }

    if (source is Map<String, dynamic>) {
      return source['message'] ??
          source['Message'] ??
          source['error'] ??
          source['Error'] ??
          source['title'] ??
          source['Title'] ??
          "An error occurred, please try again.";
    }

    if (source is String && source.isNotEmpty) return source;

    return "An error occurred, please try again.";
  }

  Future<LoginResponseModel> login(LoginRequestModel loginData) async {
    try {
      final response = await _apiService.post(
        endpoint: "/api/v1/auth/customer/login",
        data: loginData.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception(_extractError(response.data));
      }

      LoginResponseModel loginResponse =
          LoginResponseModel.fromJson(response.data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', loginResponse.accessToken ?? '');
      await prefs.setString('refreshToken', loginResponse.refreshToken ?? '');
      await prefs.setInt('customerId', loginResponse.customerId ?? 0);
      await prefs.setString('firstName', loginResponse.firstName ?? '');
      await prefs.setString('accountStatus', loginResponse.accountStatus ?? '');

      return loginResponse;
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? refreshToken = prefs.getString('refreshToken');

      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception("Session expired, please login again.");
      }

      final response = await _apiService.post(
        endpoint: "/api/v1/auth/logout",
        data: {"refreshToken": refreshToken},
      );

      if (response.statusCode != 200) {
        throw Exception(_extractError(response.data));
      }

      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      await prefs.remove('customerId');
      await prefs.remove('firstName');
      await prefs.remove('accountStatus');
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }
}
