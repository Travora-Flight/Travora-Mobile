import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/servicess/bag_tracking/invoice.dart';
import '../../models/servicess/confirm_order/confirm_order_model.dart';

class BagTrackingOrderService {
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

  Future<BagTrackingInvoiceModel> getInvoice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.get(
        endpoint: '/api/v1/orders/bag-tracking/invoice',
        token: token,
      );
      debugPrint("BAG TRACKING INVOICE RESPONSE: ${response.data}");

      return BagTrackingInvoiceModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<ConfirmOrderModel> confirmOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.post(
        endpoint: '/api/v1/orders/bag-tracking/confirm',
        data: {},
        token: token,
      );

      return ConfirmOrderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }
}
