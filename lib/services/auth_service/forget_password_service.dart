import 'package:dio/dio.dart';
import '../../models/auth/forget_password_model.dart';
import '../api_service.dart';

class ForgetPasswordService {
  final ApiService _apiService = ApiService();

  Future<ForgetPasswordResponse> forgotPassword(String email) async {
    try {
      final response = await _apiService.post(
        endpoint: '/api/v1/auth/customer/forgot-password',
        data: {"email": email},
      );

      return ForgetPasswordResponse.fromJson(response.data);
    } on DioException catch (e) {
      String errorMessage = "Something went wrong. Please try again.";

      if (e.response != null && e.response!.data != null) {
        errorMessage = e.response!.data['message'] ??
            e.response!.data['Message'] ??
            "Unknown server error";
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Connection Error: Please check your internet.");
    }
  }
}
