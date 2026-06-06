import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';

class NotificationController extends ChangeNotifier {
  final _repository = NotificationRepository();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String _message = '';

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get message => _message;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _repository.fetchNotifications(userId);
      _message = 'Notifikasi berhasil dimuat';
    } catch (e) {
      _message = 'Gagal memuat notifikasi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      _message = 'Gagal menandai notifikasi: $e';
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      _message = 'Gagal menghapus notifikasi: $e';
    }
  }
}
