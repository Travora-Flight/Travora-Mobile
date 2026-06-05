import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/orders/available_slots_model.dart';
import 'package:flutter/foundation.dart';

class AvailableSlotsService {
  final ApiService _apiService = ApiService();

  String _extractError(DioException e) {
    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        return data['message'] ??
            data['Message'] ??
            data['error'] ??
            data['title'] ??
            data.values.firstOrNull?.toString() ??
            "An error occurred, please try again.";
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    }
    return "Connection error, please check your internet.";
  }

  dynamic _decodeResponse(dynamic data) {
    if (data is String) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return data;
      }
    }
    return data;
  }

  Future<AvailableDatesModel> getAvailableDates({
    required int orderId,
    required String type,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.get(
        endpoint: '/api/v1/orders/$orderId/available-dates',
        queryParameters: {'type': type},
        token: token,
      );

      debugPrint('Raw available-dates response: ${response.data}');
      debugPrint('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = _decodeResponse(response.data);
        return AvailableDatesModel.fromJson(decoded);
      } else {
        throw Exception("Failed to load available dates");
      }
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<AvailableSlotsModel> getAvailableSlots({
    required int orderId,
    required String type,
    required String date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.get(
        endpoint: '/api/v1/orders/$orderId/available-slots',
        queryParameters: {'type': type, 'date': date},
        token: token,
      );

      debugPrint('Raw available-slots response: ${response.data}');
      debugPrint('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = _decodeResponse(response.data);
        return AvailableSlotsModel.fromJson(decoded);
      } else {
        throw Exception("Failed to load available slots");
      }
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<RescheduleResponseModel> reschedule({
    required int orderId,
    required String type,
    required String newDate,
    required String newTimeSlot,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.patch(
        endpoint: '/api/v1/orders/$orderId/reschedule',
        data: {
          'type': type,
          'newDate': newDate,
          'newTimeSlot': newTimeSlot,
        },
        token: token,
      );

      debugPrint('Raw reschedule response: ${response.data}');

      if (response.statusCode == 200) {
        final decoded = _decodeResponse(response.data);
        return RescheduleResponseModel.fromJson(decoded);
      } else {
        throw Exception("Failed to reschedule");
      }
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }
}
