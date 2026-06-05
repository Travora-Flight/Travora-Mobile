import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/servicess/door_to_door/slot.dart';

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

  Future<AvailableDatesResponse> getAvailablePickupDates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.get(
        endpoint: '/api/v1/orders/door-to-door/available-pickup-dates',
        token: token,
      );
      print('=== Available Pickup Dates ===');
      print(response.data);
      return AvailableDatesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<AvailableDatesResponse> getAvailableDeliveryDates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.get(
        endpoint: '/api/v1/orders/door-to-door/available-delivery-dates',
        token: token,
      );
      print('=== Available Delivery Dates ===');
      print(response.data);
      return AvailableDatesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<AvailableSlotsResponse> getAvailablePickupSlots({
    required String date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.get(
        endpoint: '/api/v1/orders/door-to-door/available-slots',
        queryParameters: {'date': date},
        token: token,
      );
      print('=== Pickup Slots Response ===');
      print(response.data);
      return AvailableSlotsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<SelectSlotResponse> selectPickupSlot({
    required String slot,
    required String date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.post(
        endpoint: '/api/v1/orders/door-to-door/select-slot',
        data: {'slot': slot, 'date': date},
        token: token,
      );

      return SelectSlotResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<AvailableSlotsResponse> getAvailableDeliverySlots({
    required String date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.get(
        endpoint: '/api/v1/orders/door-to-door/available-delivery-slots',
        queryParameters: {'date': date},
        token: token,
      );

      return AvailableSlotsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<SelectSlotResponse> selectDeliverySlot({
    required String slot,
    required String date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.post(
        endpoint: '/api/v1/orders/door-to-door/select-delivery-slot',
        data: {'slot': slot, 'date': date},
        token: token,
      );

      return SelectSlotResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }
}
