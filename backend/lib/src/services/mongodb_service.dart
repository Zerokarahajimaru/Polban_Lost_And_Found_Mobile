import 'package:dotenv/dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongodbService {
  static Db? _db;
  static bool _isInitializing = false;

  static Future<Db> get db async {
    if (_db != null && _db!.isConnected) {
      return _db!;
    }

    if (_isInitializing) {
      await Future.doWhile(() => _isInitializing);
      // After waiting, the db should be ready.
      if (_db != null && _db!.isConnected) return _db!;
    }

    _isInitializing = true;

    try {
      final env = DotEnv(includePlatformEnvironment: true)..load();
      final rawUri = env['MONGO_ATLAS_URI'];

      if (rawUri == null || rawUri.isEmpty) {
        throw Exception('MONGO_ATLAS_URI is not set in the .env file');
      }

      // Strip surrounding quotes that dotenv sometimes preserves
      final sanitizedUri = rawUri.replaceAll('"', '').trim();

      _db = await Db.create(sanitizedUri);
      await _db!.open();
      print('--- MongoDB Connection Successful ---');
      return _db!;
    } catch (e) {
      print('--- MongoDB Connection Failed: $e ---');
      _db = null; // Reset on failure
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }
}