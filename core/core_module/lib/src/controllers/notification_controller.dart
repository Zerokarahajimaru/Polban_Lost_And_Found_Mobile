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

  void clearData() {
    _notifications = [];
    _message = '';
    notifyListeners();
  }

  Future<void> loadNotificationsForUser(SessionController session) async {
    final userId = session.currentUser?.id;
    if (userId == null) return;

    final ids = [userId];
    if (session.isTeknisi) {
      ids.add('staff_general');
    }
    await loadNotifications(ids);
  }

  Future<void> loadNotifications(dynamic userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (userId is List<String>) {
        List<NotificationModel> combined = [];
        for (var id in userId) {
          final results = await _repository.fetchNotifications(id);
          combined.addAll(results);
        }
        combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _notifications = combined;
      } else {
        _notifications = await _repository.fetchNotifications(userId.toString());
      }
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
