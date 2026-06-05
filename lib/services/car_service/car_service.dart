import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/servicess/car_service/validate_car_flight_request.dart';
import '../../models/servicess/car_service/validate_car_flight_response.dart';
import '../../models/servicess/validate_companion_request.dart';
import 'package:graduation_project/models/servicess/validate_companion_response.dart';
import 'package:graduation_project/models/servicess/validate_baggage.dart';

class CarService {
  final ApiService _apiService = ApiService();

  String _extractError(dynamic e) {
    if (e is DioException && e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        String? rawMessage = data['errorMessage']?.toString() ??
            data['message']?.toString() ??
            data['error']?.toString() ??
            data['title'] ??
            data.values.firstOrNull?.toString();

        if (rawMessage != null &&
            rawMessage.isNotEmpty &&
            rawMessage.toLowerCase() != 'null') {

          if (rawMessage.contains(',')) {
            return rawMessage.split(',').first.trim();
          }
          return rawMessage;
        }
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    }
    return "Connection error, please check your internet.";
  }

  Future<ValidateCarFlightResponse> validateFlight(
      ValidateCarFlightRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.post(
        endpoint: "/api/v1/orders/car-service/validate-flight",
        data: request.toJson(),
        token: token,
      );

      final result = ValidateCarFlightResponse.fromJson(response.data);

      if (result.isValid == false) {
        String msg = result.errorMessage ?? "Invalid Flight Data";
        throw Exception(msg.contains(',') ? msg.split(',').first.trim() : msg);
      }

      return result;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final data = e.response!.data;
        if (data['errorMessage'] != null) {
          String msg = data['errorMessage'].toString();
          throw Exception(
              msg.contains(',') ? msg.split(',').first.trim() : msg);
        }
      }
      throw Exception(_extractError(e));
    }
  }

  Future<ValidateCompanionResponse> validateCompanion({
    required ValidateCompanionRequest request,
    required File passportImageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final formData = FormData.fromMap({
        ...request.toFormFields(),
        "PassportImage": await MultipartFile.fromFile(
          passportImageFile.path,
          filename: passportImageFile.path.split('/').last,
        ),
      });

      final response = await _apiService.postMultipart(
        endpoint: "/api/v1/orders/car-service/validate-companion",
        formData: formData,
        token: token,
      );

      final result = ValidateCompanionResponse.fromJson(response.data);
      if (result.isValid == false) {
        String msg = result.errorMessage ?? "Invalid companion data";
        throw Exception(msg.contains(',') ? msg.split(',').first.trim() : msg);
      }

      return result;
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<ValidateBaggageResponse> validateBaggage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.post(
        endpoint: "/api/v1/orders/car-service/validate-baggage",
        data: {},
        token: token,
      );

      return ValidateBaggageResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }
}
