import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  Future<void> init() async {
    await Hive.initFlutter();
  }

  Future<Box<T>> openBox<T>(String name) async {
    return Hive.openBox<T>(name);
  }
}
