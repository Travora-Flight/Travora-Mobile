import 'package:dio/dio.dart';
import '../../models/auth/verify_otp_model.dart';
import '../api_service.dart';

class VerifyOtpService {
  final ApiService _apiService = ApiService();

  Future<VerifyOtpResponse> verifyOtp(
      {required String email, required String otp}) async {
    try {
      final response = await _apiService.post(
        endpoint: '/api/v1/auth/customer/verify-otp',
        data: {"email": email, "otp": otp},
      );

      return VerifyOtpResponse.fromJson(response.data);
    } on DioException catch (e) {
      String errorMessage = "An error occurred. Please try again.";

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
