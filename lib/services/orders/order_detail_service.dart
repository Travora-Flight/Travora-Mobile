import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/orders/order_detail_model.dart';

class OrderDetailService {
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

  Future<OrderDetailModel> getOrderDetail(int orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.get(
        endpoint: '/api/v1/orders/$orderId',
        token: token,
      );

      if (response.statusCode == 200) {
        return OrderDetailModel.fromJson(response.data);
      } else {
        throw Exception("Failed to load order details");
      }
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<bool> cancelOrder(int orderId, String reason) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.patch(
        endpoint: '/api/v1/orders/$orderId/cancel',
        data: {'cancellationReason': reason},
        token: token,
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }
}
