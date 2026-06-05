import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/servicess/car_service/slot.dart';

class SlotService {
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

  Future<AvailableDatesResponse> fetchAvailableDates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.get(
        endpoint: '/api/v1/orders/car-service/available-dates',
        token: token,
      );

      return AvailableDatesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<AvailableSlotsResponse> fetchAvailableSlots(String date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.get(
        endpoint: '/api/v1/orders/car-service/available-slots',
        queryParameters: {'date': date},
        token: token,
      );

      return AvailableSlotsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<SelectSlotResponse> selectSlot({
    required String slot,
    required String date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.post(
        endpoint: '/api/v1/orders/car-service/select-slot',
        data: {
          'slot': slot,
          'date': date,
        },
        token: token,
      );

      return SelectSlotResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }
}
