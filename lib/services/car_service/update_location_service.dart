import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/servicess/update_location.dart';

class CarServiceUpdateLocationService {
  final ApiService _apiService = ApiService();

  String _extractError(DioException e) {
    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        return data['message'] ??
            data['Message'] ??
            data['error'] ??
            data['Error'] ??
            data['title'] ??
            data['Title'] ??
            data.values.firstOrNull?.toString() ??
            "An error occurred, please try again.";
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    }
    return "Connection error, please check your internet.";
  }

  Future<void> updateLocation({
    required UpdateLocationModel locationData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      await _apiService.patch(
        endpoint: '/api/v1/orders/car-service/update-location',
        data: locationData.toJson(),
        token: token,
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }
}
