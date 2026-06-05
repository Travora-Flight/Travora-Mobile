import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/profile/account_model.dart';

class AccountService {
  final ApiService _apiService = ApiService();

  Future<AccountModel> getAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final response = await _apiService.get(
      endpoint: "/api/v1/customer/account",
      token: token,
    );

    if (response.statusCode == 200) {
      return AccountModel.fromJson(response.data);
    } else {
      throw Exception("Failed to load account");
    }
  }

  Future<void> updateAccount(AccountModel account) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final response = await _apiService.put(
      endpoint: "/api/v1/customer/account",
      data: account.toJson(),
      token: token,
    );

    if (response.statusCode != 200) {
      throw Exception(response.data.toString());
    }
  }
}
