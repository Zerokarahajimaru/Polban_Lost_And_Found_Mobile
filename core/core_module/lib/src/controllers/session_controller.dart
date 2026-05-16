import 'package:flutter/foundation.dart';
import 'package:core_module/src/models/user_model.dart';
import 'package:core_module/src/services/hive_service.dart';

class SessionController extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoggedIn = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  void login(UserModel user) {
    _currentUser = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;

    final hiveService = HiveService();
    hiveService.reportsBox.clear();

    notifyListeners();
  }

  bool get isTeknisi {
    final role = _currentUser?.role.toLowerCase().trim();
    return role == 'teknisi' ||
        role == 'administration' ||
        role == 'admin';
  }

  bool get isUser => !isTeknisi;
}
