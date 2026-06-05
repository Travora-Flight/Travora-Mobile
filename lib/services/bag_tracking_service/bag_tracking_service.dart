import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/servicess/validate_flight_request.dart';
import '../../models/servicess/validate_flight_response.dart';
import '../../models/servicess/validate_companion_request.dart';
import 'package:graduation_project/models/servicess/validate_companion_response.dart';
import 'package:graduation_project/models/servicess/validate_baggage.dart';

class BagTrackingService {
  final ApiService _apiService = ApiService();

  String _extractError(dynamic e) {
    if (e is DioException && e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        String? rawMessage = data['errorMessage']?.toString() ??
            data['message']?.toString() ??
            data['error']?.toString() ??
            data['title']?.toString();

        if (rawMessage != null &&
            rawMessage.isNotEmpty &&
            rawMessage.toLowerCase() != 'null') {
          if (rawMessage.contains(',')) {
            return rawMessage.split(',').first.trim();
          }
          return rawMessage;
        }
      }
    }
    return "An error occurred, please try again.";
  }

  Future<ValidateFlightResponse> validateFlight(
      ValidateFlightRequest requestData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.post(
        endpoint: "/api/v1/orders/bag-tracking/validate-flight",
        data: requestData.toJson(),
        token: token,
      );

      final result = ValidateFlightResponse.fromJson(response.data);

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
    required ValidateCompanionRequest requestData,
    required String passportImagePath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final formData = FormData.fromMap({
        ...requestData.toFormFields(),
        "PassportImage": await MultipartFile.fromFile(
          passportImagePath,
          filename: passportImagePath.split('/').last,
        ),
      });

      final response = await _apiService.postMultipart(
        endpoint: "/api/v1/orders/bag-tracking/validate-companion",
        formData: formData,
        token: token,
      );

      final result = ValidateCompanionResponse.fromJson(response.data);

      if (result.isValid == false) {
        String msg = result.errorMessage ?? "Invalid Companion Data";
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
        endpoint: "/api/v1/orders/bag-tracking/validate-baggage",
        data: {},
        token: token,
      );

      final result = ValidateBaggageResponse.fromJson(response.data);

      if (result.isValid == false) {
        String msg = result.errorMessage ?? "Baggage validation failed";
        throw Exception(msg.contains(',') ? msg.split(',').first.trim() : msg);
      }

      return result;
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }
}
