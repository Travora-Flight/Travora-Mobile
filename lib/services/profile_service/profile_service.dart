import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/profile/profile_model.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  Future<ProfileModel> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final response = await _apiService.get(
      endpoint: "/api/v1/customer/profile",
      token: token,
    );

    if (response.statusCode == 200) {
      return ProfileModel.fromJson(response.data);
    } else {
      throw Exception("Failed to load profile");
    }
  }

  Future<String> uploadPhoto(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'photo.jpg',
      ),
    });

    final response = await _apiService.postMultipart(
      endpoint: "/api/v1/customer/account/photo",
      formData: formData,
      token: token,
    );

    if (response.statusCode == 200) {
      return response.data['photoUrl']?.toString() ?? '';
    } else {
      throw Exception("Failed to upload photo");
    }
  }
}
