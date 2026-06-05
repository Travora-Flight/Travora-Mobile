import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../../models/home/notification_model.dart';

class NotificationsService {
  final ApiService _apiService = ApiService();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<NotificationResponseModel> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    final token = await _getToken();

    final response = await _apiService.get(
      endpoint: '/api/v1/customer/notifications',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
      token: token,
    );

    return NotificationResponseModel.fromJson(response.data);
  }

  Future<bool> markAsRead(int notificationId) async {
    final token = await _getToken();

    final response = await _apiService.patch(
      endpoint: '/api/v1/customer/notifications/$notificationId/read',
      token: token,
    );

    return response.data['success'] == true;
  }

  Future<bool> markAllAsRead() async {
    final token = await _getToken();

    final response = await _apiService.patch(
      endpoint: '/api/v1/customer/notifications/read-all',
      token: token,
    );

    return response.data['success'] == true;
  }
}
