import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  HiveService._();

  static final HiveService _instance = HiveService._();

  factory HiveService() => _instance;

  static const String reportsBoxName = 'reports_box';
  static const String settingsBoxName = 'settings_box';

  static const String _isLoggedInKey = 'is_logged_in';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(reportsBoxName);
    await Hive.openBox(settingsBoxName);
    debugPrint('Hive initialized successfully.');
  }

  Box<Map> get reportsBox => Hive.box<Map>(reportsBoxName);

  Box get settingsBox => Hive.box(settingsBoxName);

  bool isLoggedIn() {
    return settingsBox.get(_isLoggedInKey, defaultValue: false) as bool;
  }

  Future<void> saveLoginState(bool value) async {
    await settingsBox.put(_isLoggedInKey, value);
  }

  Future<void> close() async {
    await Hive.close();
    debugPrint('Hive boxes closed.');
  }
}
