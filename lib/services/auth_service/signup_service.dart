import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/auth/signup_model.dart';
import '../../models/auth/signup_response_model.dart';
import '../../models/auth/login_model.dart';
import 'login_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final LoginService _loginService = LoginService();

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

  Future<SignUpResponseModel> registerStep1(
      SignUpRequestModel signUpData) async {
    try {
      final response = await _apiService.post(
        endpoint: "/api/v1/auth/customer/register/step1",
        data: signUpData.toStep1Json(),
      );

      if (response.statusCode != 200) {
        throw Exception(_extractError(response.data));
      }

      return SignUpResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<void> registerStep2({
    required SignUpRequestModel signUpData,
    required File passportImage,
  }) async {
    try {
      Map<String, dynamic> data = signUpData.toStep2Json();

      data["PassportImage"] = await MultipartFile.fromFile(
        passportImage.path,
        filename: passportImage.path.split('/').last,
      );

      FormData formData = FormData.fromMap(data);

      final response = await _apiService.postMultipart(
        endpoint: "/api/v1/auth/customer/register/step2",
        formData: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_extractError(response.data));
      }

      try {
        await _loginService.login(
          LoginRequestModel(
            email: signUpData.email ?? '',
            password: signUpData.password ?? '',
          ),
        );
      } catch (_) {
      }
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }
}
