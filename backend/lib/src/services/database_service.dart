import 'package:dotenv/dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// A service class to manage the connection to the MongoDB database.
///
/// This class follows the Singleton pattern to ensure only one instance
/// of the database connection is active throughout the application.
class DatabaseService {
  late final Db _db;
  late final DbCollection _reportsCollection;

  /// Provides access to the `reports` collection in the database.
  DbCollection get reports => _reportsCollection;

  // Private constructor to prevent direct instantiation.
  DatabaseService._();

  // The single, static instance of this class.
  static final DatabaseService _instance = DatabaseService._();

  /// The factory constructor that returns the singleton instance.
  factory DatabaseService() => _instance;

  /// Initializes the database connection.
  ///
  /// It loads the MongoDB URI from the environment variables,
  /// establishes a connection, and prepares the `reports` collection.
  /// Throws an [Exception] if the MONGO_ATLAS_URI is not set.
  Future<void> init() async {
    // Load environment variables from a .env file
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final mongoUri = env['MONGO_ATLAS_URI'];

    if (mongoUri == null || mongoUri.isEmpty) {
      throw Exception('MONGO_ATLAS_URI not found or is empty in .env file');
    }

    _db = await Db.create(mongoUri);
    await _db.open();
    _reportsCollection = _db.collection('reports');
    print('MongoDB connection opened successfully.');
  }

  /// Closes the database connection.
  Future<void> close() async {
    await _db.close();
    print('MongoDB connection closed.');
  }
}
