import 'dart:io';
import 'package:dotenv/dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongodbService {
  static Db? _db;

  static Future<Db> get db async {
    if (_db == null || !_db!.isConnected) {
      //Load file .env
      var env = DotEnv()..load();
      

      final uri = env['MONGODB_URI'] ?? "";
      
      if (uri.isEmpty) {
        throw Exception(" MONGODB_URI tidak ditemukan di file .env");
      }

      print(" Connecting to MongoDB via Environment Variable...");
      _db = await Db.create(uri);
      await _db!.open();
      print(" Connected to MongoDB Atlas");
    }
    return _db!;
  }
}