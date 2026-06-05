import 'package:dio/dio.dart';
import '../api_service.dart';
import '../../models/auth/verify_email_model.dart'; 

class VerifyEmailService {
  final ApiService _apiService = ApiService();

  Future<void> verifyEmail(VerifyEmailRequestModel model) async {
    try {
      await _apiService.post(
        endpoint: '/api/v1/auth/customer/verify-email',
        data: model.toJson(), 
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    try {
      await _apiService.post(
        endpoint: '/api/v1/auth/customer/resend-verification-email',
        data: {"email": email},
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException e) {
    if (e.response != null && e.response!.data != null) {
      return e.response!.data['message'] ??
          e.response!.data['Message'] ??
          "An error occurred, please try again.";
    }
    return "Connection error, please check your internet.";
  }
}
