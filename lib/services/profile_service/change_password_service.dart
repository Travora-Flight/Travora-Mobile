import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/profile/change_password_model.dart';
import 'package:dio/dio.dart';

class ChangePasswordService {
  final ApiService _apiService = ApiService();

  Future<void> changePassword(ChangePasswordRequestModel requestData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        throw Exception("User not authenticated");
      }

      final response = await _apiService.post(
        endpoint: "/api/v1/customer/change-password",
        data: requestData.toJson(),
        token: token,
      );

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception("Failed to change password");
      }
    } on DioException catch (e) {
      String errorMsg = e.response?.data['message'] ??
          e.response?.data['Message'] ??
          "Something went wrong";
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
