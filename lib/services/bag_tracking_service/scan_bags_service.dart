import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/servicess/bag_tracking/scan_bags.dart';

class ScanBagsService {
  final ApiService _apiService = ApiService();

  String _extractError(DioException e) {
    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        return data['message'] ??
            data['Message'] ??
            data['error'] ??
            data['errorMessage'] ??
            "An error occurred, please try again.";
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    }
    return "Connection error, please check your internet.";
  }

  Future<ScanBagResponse> scanBag({
    required String qrData,
    required bool enteredManually,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.post(
        endpoint: '/api/v1/orders/bag-tracking/scan-bag',
        data: {
          'qrData': qrData,
          'enteredManually': enteredManually,
        },
        token: token,
      );

      return ScanBagResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }
  Future<UploadBagPhotosResponse> uploadBagPhotos({
    required String tagNumber,
    required List<File> photos,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final List<MultipartFile> multipartFiles = await Future.wait(
        photos.map((file) async => await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            )),
      );

      final formData = FormData.fromMap({
        'photos': multipartFiles,
      });

      final response = await _apiService.postMultipart(
        endpoint: '/api/v1/orders/bag-tracking/bags/$tagNumber/photos',
        formData: formData,
        token: token,
      );

      return UploadBagPhotosResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }
}
