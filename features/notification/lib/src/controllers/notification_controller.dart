import 'package:flutter/material.dart';
import 'package:notification/src/models/notification_model.dart';

/// State enum untuk notification
enum NotificationState { initial, loading, loaded, error }

/// Controller untuk mengelola notifikasi
class NotificationController extends ChangeNotifier {
  // Private state properties
  NotificationState _state = NotificationState.initial;
  List<NotificationModel> _notifications = [];
  String _message = '';

  // Public getters
  NotificationState get state => _state;
  List<NotificationModel> get notifications => _notifications;
  String get message => _message;

  /// Menghitung jumlah notifikasi yang belum dibaca
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Mendapatkan notifikasi yang belum dibaca saja
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  /// Fetch semua notifikasi (simulasi dari database/server)
  Future<void> getNotifications() async {
    _setState(NotificationState.loading);
    try {
      // TODO: Ganti dengan API call ke backend
      // Simulasi delay network
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulasi data notifikasi
      _notifications = [
        NotificationModel(
          id: 'notif_1',
          title: 'Laporan Diterima',
          message: 'Laporan Anda tentang kehilangan dompet telah diterima dan sedang ditinjau.',
          type: 'report',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: true,
          metadata: {'reportId': 'report_123'},
        ),
        NotificationModel(
          id: 'notif_2',
          title: 'Klaim Barang',
          message: 'Ada orang yang mengklaim barang yang Anda temukan. Silakan tinjau.',
          type: 'claim',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: false,
          metadata: {'claimId': 'claim_456'},
        ),
        NotificationModel(
          id: 'notif_3',
          title: 'Laporan Diterima',
          message: 'Laporan untuk postingan tidak sesuai telah dicatat.',
          type: 'system',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          isRead: false,
          metadata: {'postId': 'post_789'},
        ),
      ];

      _setState(NotificationState.loaded);
      _message = 'Notifikasi berhasil dimuat';
    } catch (e) {
      _message = 'Gagal memuat notifikasi: $e';
      _setState(NotificationState.error);
    }
  }

  /// Menandai notifikasi sebagai dibaca
  Future<void> markAsRead(String notificationId) async {
    try {
      final index = _notifications
          .indexWhere((notification) => notification.id == notificationId);

      if (index != -1) {
        _notifications[index] =
            _notifications[index].copyWith(isRead: true);
        notifyListeners();

        // TODO: Kirim update ke server
      }
    } catch (e) {
      _message = 'Gagal menandai notifikasi: $e';
    }
  }

  /// Menandai semua notifikasi sebagai dibaca
  Future<void> markAllAsRead() async {
    try {
      _notifications = _notifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();
      notifyListeners();

      // TODO: Kirim update ke server
    } catch (e) {
      _message = 'Gagal menandai semua notifikasi: $e';
    }
  }

  /// Menghapus notifikasi tertentu
  Future<void> deleteNotification(String notificationId) async {
    try {
      _notifications
          .removeWhere((notification) => notification.id == notificationId);
      notifyListeners();

      // TODO: Kirim delete ke server
    } catch (e) {
      _message = 'Gagal menghapus notifikasi: $e';
    }
  }

  /// Menghapus semua notifikasi
  Future<void> deleteAllNotifications() async {
    try {
      _notifications.clear();
      notifyListeners();

      // TODO: Kirim delete all ke server
    } catch (e) {
      _message = 'Gagal menghapus semua notifikasi: $e';
    }
  }

  /// Menambah notifikasi baru (untuk real-time dari server/websocket)
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Helper function untuk update state
  void _setState(NotificationState newState) {
    _state = newState;
    notifyListeners();
  }
}
