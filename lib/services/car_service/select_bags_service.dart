
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/servicess/car_service/select_bags.dart';

class SelectBagsService {
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

  Future<MyBagsResponse> getMyBags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.get(
        endpoint: '/api/v1/orders/car-service/my-bags',
        token: token,
      );

      return MyBagsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<SelectBagsResponse> selectBags(List<String> tagNumbers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.post(
        endpoint: '/api/v1/orders/car-service/select-bags',
        data: {'selectedTagNumbers': tagNumbers},
        token: token,
      );

      return SelectBagsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }
}
