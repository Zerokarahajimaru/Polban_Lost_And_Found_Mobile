import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';

// =============================================================================
// MANUAL MOCK CLASSES
// Mengimplementasikan interface asli secara manual tanpa build_runner
// =============================================================================

class FakeSessionController extends ChangeNotifier
    implements SessionController {
  @override
  UserModel? currentUser;

  FakeSessionController({this.currentUser});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeNotificationController extends ChangeNotifier
    implements NotificationController {
  @override
  List<NotificationModel> notifications = [];

  @override
  bool isLoading = false;

  @override
  String message = '';

  @override
  int get unreadCount => notifications.where((item) => !item.isRead).length;

  // Tracker array untuk keperluan White-Box Assertion (Merekam pemanggilan internal)
  final List<SessionController> loadNotificationsForUserCalls = [];
  final List<dynamic> loadNotificationsCalls = [];
  final List<String> markAsReadCalls = [];
  final List<String> deleteNotificationCalls = [];

  @override
  void clearData() {
    notifications = [];
    message = '';
    notifyListeners();
  }

  @override
  Future<void> loadNotificationsForUser(SessionController session) async {
    loadNotificationsForUserCalls.add(session);
  }

  @override
  Future<void> loadNotifications(dynamic userId) async {
    loadNotificationsCalls.add(userId);
  }

  @override
  Future<void> markAsRead(String id) async {
    markAsReadCalls.add(id);
    final index = notifications.indexWhere((item) => item.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    deleteNotificationCalls.add(id);
    notifications.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
