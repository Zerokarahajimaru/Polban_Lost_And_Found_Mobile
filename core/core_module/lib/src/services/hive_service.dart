import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A service for managing local data caching using Hive.
///
/// This class follows the Singleton pattern to provide a single point of
/// access to the Hive database throughout the app.
class HiveService {
  // Private constructor
  HiveService._();

  // The single, static instance of this class.
  static final HiveService _instance = HiveService._();

  /// The factory constructor that returns the singleton instance.
  factory HiveService() => _instance;

  /// The name for the box that will store report data.
  static const String reportsBoxName = 'reports_box';

  /// Initializes the Hive database.
  ///
  /// This must be called once when the app starts, preferably in `main.dart`.
  /// It sets up Hive and opens the necessary boxes for the app to use.
  Future<void> init() async {
    await Hive.initFlutter();
    // We open a box to store raw Map data (JSON-like) for simplicity.
    // This avoids the need for TypeAdapters if the model is simple.
    await Hive.openBox<Map>(reportsBoxName);
    debugPrint('Hive initialized successfully and reports box opened.');
  }

  /// Provides access to the 'reports' box.
  Box<Map> get reportsBox => Hive.box<Map>(reportsBoxName);

  /// Closes all open Hive boxes.
  Future<void> close() async {
    await Hive.close();
    debugPrint('Hive boxes closed.');
  }
}