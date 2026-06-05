import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/orders/boarding_pass_model.dart';

class BoardingPassService {
  final ApiService _apiService = ApiService();

  String _extractError(DioException e) {
    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        return data['message'] ??
            data['Message'] ??
            data['error'] ??
            data['title'] ??
            "An error occurred, please try again.";
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    }
    return "Connection error, please check your internet.";
  }

  Future<List<BoardingPassModel>> getBoardingPasses(int orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.get(
        endpoint: '/api/v1/orders/$orderId/boarding-pass',
        token: token,
      );

      if (response.statusCode == 200) {
        final List<dynamic> passes = response.data['boardingPasses'];
        return passes.map((e) => BoardingPassModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load boarding pass");
      }
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }
}
