import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/services/api_service.dart';
import 'package:graduation_project/models/profile/payment_model.dart';
import 'package:graduation_project/models/servicess/confirm_order/payment_status_model.dart';

class PaymentService {
  final ApiService _apiService = ApiService();

  Future<PaymentResponse> getPaymentData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');

    final response = await _apiService.get(
      endpoint: "/api/v1/customer/payment-methods",
      token: token,
    );

    print("----------------------------------------");
    print("SERVER RESPONSE DATA: ${response.data}");
    print("----------------------------------------");

    return PaymentResponse.fromJson(response.data);
  }

  Future<bool> addPaymentMethod(Map<String, dynamic> cardData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');

    print("----------------------------------------");
    print("DATA BEING SENT TO SERVER: $cardData");
    print("----------------------------------------");

    final response = await _apiService.post(
      endpoint: "/api/v1/customer/payment-methods",
      token: token,
      data: cardData,
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<String?> deletePaymentMethod(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');

    final response = await _apiService.delete(
      endpoint: "/api/v1/customer/payment-methods/$id",
      token: token,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return null;
    } else {
      return response.data['message'] ?? "Failed to delete card";
    }
  }

  Future<bool> setDefaultPaymentMethod(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');

    final response = await _apiService.post(
      endpoint: "/api/v1/customer/payment-methods/$id/set-default",
      token: token,
      data: {},
    );

    return response.statusCode == 200;
  }

  Future<String> initiatePayment({required int orderId}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');

    final response = await _apiService.post(
      endpoint: "/api/v1/payments/initiate",
      token: token,
      data: {'orderId': orderId},
    );

    print("----------------------------------------");
    print("INITIATE PAYMENT RESPONSE: ${response.data}");
    print("----------------------------------------");

    final paymentKey = response.data['paymentKey'] ?? '';
    if (paymentKey.isEmpty) return '';
    return "https://accept.paymob.com/api/acceptance/iframes/1014653?payment_token=$paymentKey";
  }

  Future<PaymentStatusModel> getPaymentStatus({required int orderId}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');

    final response = await _apiService.get(
      endpoint: "/api/v1/payments/status/$orderId",
      token: token,
    );

    print("----------------------------------------");
    print("PAYMENT STATUS RESPONSE: ${response.data}");
    print("----------------------------------------");

    return PaymentStatusModel.fromJson(response.data);
  }
}
