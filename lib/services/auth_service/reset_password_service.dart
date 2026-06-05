import 'package:dio/dio.dart';
import '../api_service.dart';
import '../../models/auth/reset_password_model.dart';

class ResetPasswordService {
  final ApiService _apiService = ApiService();

  Future<ResetPasswordResponse> resetPassword(
      ResetPasswordRequest request) async {
    try {
      final response = await _apiService.post(
        endpoint: '/api/v1/auth/customer/reset-password',
        data: request.toJson(),
      );

      return ResetPasswordResponse.fromJson(response.data);
    } on DioException catch (e) {
      String errorMessage = "Failed to reset password. Please try again.";

      if (e.response != null && e.response!.data != null) {
        errorMessage = e.response!.data['message'] ??
            e.response!.data['Message'] ??
            errorMessage;
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("Connection Error: Please check your internet.");
    }
  }
}
