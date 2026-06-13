import '../services/network_service.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final _networkService = NetworkService();

  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    try {
      final response = await _networkService.dio.get('/notifications', queryParameters: {'userId': userId});
      final data = response.data as List<dynamic>;
      return data.map((json) => NotificationModel.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> sendNotification({
    required String userId,
    required String judul,
    required String pesan,
    String tipeNotif = 'system',
  }) async {
    try {
      await _networkService.dio.post('/notifications', data: {
        'userId': userId,
        'judul': judul,
        'pesan': pesan,
        'tipeNotif': tipeNotif,
      });
    } catch (e) {
      // Log or ignore
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _networkService.dio.post('/notifications/$notificationId', data: {'action': 'read'});
    } catch (e) {
      // Log or ignore
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _networkService.dio.delete('/notifications/$notificationId');
    } catch (e) {
      // Log or ignore
    }
  }
}
