import 'package:graduation_project/models/profile/settings_model.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:dio/dio.dart';

class SettingsService {
  final ApiService _apiService;

  SettingsService(this._apiService);

  Future<SettingsModel> getSettings(String token) async {
    try {
      final response = await _apiService.get(
        endpoint: '/api/v1/customer/settings',
        token: token,
      );
      return SettingsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to load settings');
    }
  }

  Future<bool> updateSettings(String token, SettingsModel settings) async {
    try {
      final response = await _apiService.put(
        endpoint: '/api/v1/customer/settings',
        data: settings.toJson(),
        token: token,
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to update settings');
    }
  }
}
