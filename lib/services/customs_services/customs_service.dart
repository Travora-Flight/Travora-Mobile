import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/servicess/customs_models/customs_model.dart';
import '../../models/servicess/customs_models/customs_item_model.dart';
import '../../models/servicess/customs_models/invoice_model.dart';
import '../../models/servicess/customs_models/customs_category_model.dart';
import '../../models/servicess/confirm_order/confirm_order_model.dart';

class CustomsService {
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

  Future<CustomsModel> setCustomsType({
    required String customsType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.post(
        endpoint: '/api/v1/orders/door-to-door/customs',
        data: {'customsType': customsType},
        token: token,
      );

      return CustomsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<CustomsItemModel> addCustomsItem({
    required String externalCategoryId,
    required String externalCategoryName,
    required String itemDescription,
    required double declaredValue,
    required int quantity,
    File? purchaseInvoice,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final formData = FormData.fromMap({
        'ExternalCategoryId': externalCategoryId,
        'ExternalCategoryName': externalCategoryName,
        'ItemDescription': itemDescription,
        'DeclaredValue': declaredValue,
        'Quantity': quantity,
        if (purchaseInvoice != null)
          'PurchaseInvoice': await MultipartFile.fromFile(
            purchaseInvoice.path,
            filename: purchaseInvoice.path.split('/').last,
          ),
      });

      final response = await _apiService.postMultipart(
        endpoint: '/api/v1/orders/door-to-door/customs/items',
        formData: formData,
        token: token,
      );

      return CustomsItemModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<InvoiceModel> getInvoice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.get(
        endpoint: '/api/v1/orders/door-to-door/invoice',
        token: token,
      );

      return InvoiceModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<List<CustomsCategoryModel>> getCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.get(
        endpoint: '/api/v1/orders/door-to-door/customs/categories',
        token: token,
      );

      final List<dynamic> data = response.data;
      return data.map((e) => CustomsCategoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<ConfirmOrderModel> confirmOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await _apiService.post(
        endpoint: '/api/v1/orders/door-to-door/confirm',
        data: {},
        token: token,
      );

      return ConfirmOrderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }
}
