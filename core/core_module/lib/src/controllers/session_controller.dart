import 'package:flutter/foundation.dart';
import 'package:core_module/src/models/user_model.dart';

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
    notifyListeners();
  }

  bool get isTeknisi => _currentUser?.role == 'Teknisi';
  bool get isUser => _currentUser?.role == 'User';
}
