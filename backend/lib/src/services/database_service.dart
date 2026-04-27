import 'dart:async';

import 'package:dotenv/dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// A self-initializing, race-safe singleton service for MongoDB connection.
class DatabaseService {
  // Private constructor that kicks off initialization.
  DatabaseService._() {
    _init();
  }

  // The single, static instance of this class.
  static final DatabaseService _instance = DatabaseService._();

  // The factory constructor that returns the singleton instance.
  factory DatabaseService() => _instance;

  // A completer to safely handle the result of the async initialization.
  final Completer<DbCollection> _completer = Completer();

  /// Private initialization method. Runs only once.
  Future<void> _init() async {
    try {
      final env = DotEnv(includePlatformEnvironment: true)..load();
      final mongoUri = env['MONGO_ATLAS_URI'];

      if (mongoUri == null || mongoUri.isEmpty) {
        throw Exception('MONGO_ATLAS_URI not found or is empty in .env file');
      }

      final db = await Db.create(mongoUri);
      await db.open();
      final reportsCollection = db.collection('reports');
      print('--- DatabaseService Initialized Successfully ---');

      // Mark initialization as complete and provide the collection as the result.
      _completer.complete(reportsCollection);
    } catch (e) {
      // If initialization fails, complete with an error.
      print('--- DatabaseService Initialization Failed ---');
      _completer.completeError(e);
    }
  }

  /// A publicly accessible getter for the 'reports' collection.
  ///
  /// It returns a future that completes with the collection once initialized.
  /// This is safe to call multiple times, even concurrently.
  Future<DbCollection> get reports => _completer.future;
}
