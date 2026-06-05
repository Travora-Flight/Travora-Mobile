import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/orders/order_model.dart';

class OrdersService {
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

  Future<List<OrderModel>> getOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.get(
        endpoint: '/api/v1/orders',
        token: token,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load orders");
      }
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }
}
