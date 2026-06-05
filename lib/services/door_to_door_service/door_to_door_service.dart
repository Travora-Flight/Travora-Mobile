import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/servicess/validate_flight_request.dart';
import '../../models/servicess/validate_flight_response.dart';
import '../../models/servicess/validate_companion_request.dart';
import 'package:graduation_project/models/servicess/validate_companion_response.dart';
import 'package:graduation_project/models/servicess/validate_baggage.dart';

class DoorToDoorService {
  final ApiService _apiService = ApiService();

  String _extractError(dynamic e) {
    if (e is DioException && e.response != null && e.response!.data != null) {
      final data = e.response!.data;

      if (data is Map) {
        String? rawMessage = data['errorMessage']?.toString();

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

    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError)
        return "No Internet Connection";
      if (e.response?.statusCode == 500) return "Server Error (500)";
    }

    return "An unexpected error occurred";
  }

  Future<ValidateFlightResponse> validateFlight(
      ValidateFlightRequest requestData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.post(
        endpoint: "/api/v1/orders/door-to-door/validate-flight",
        data: requestData.toJson(),
        token: token,
      );

      final result = ValidateFlightResponse.fromJson(response.data);

      if (result.isValid == false) {
        throw Exception(_extractError(DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            data: response.data,
            statusCode: 400,
          ),
        )));
      }

      return result;
    } catch (e) {
      if (e is! Exception) {
        throw Exception(_extractError(e));
      }
      rethrow;
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
        endpoint: "/api/v1/orders/door-to-door/validate-companion",
        formData: formData,
        token: token,
      );

      final result = ValidateCompanionResponse.fromJson(response.data);

      if (response.statusCode != null && response.statusCode! >= 400) {
        throw Exception(_extractError(DioException(
          requestOptions: RequestOptions(path: ''),
          response: response,
        )));
      }

      return result;
    } catch (e) {
      if (e is! Exception) throw Exception(_extractError(e));
      rethrow;
    }
  }

  Future<ValidateBaggageResponse> validateBaggage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.post(
        endpoint: "/api/v1/orders/door-to-door/validate-baggage",
        data: {},
        token: token,
      );

      final result = ValidateBaggageResponse.fromJson(response.data);

      if (response.statusCode != null && response.statusCode! >= 400) {
        throw Exception(_extractError(DioException(
          requestOptions: RequestOptions(path: ''),
          response: response,
        )));
      }

      return result;
    } catch (e) {
      if (e is! Exception) throw Exception(_extractError(e));
      rethrow;
    }
  }
}
