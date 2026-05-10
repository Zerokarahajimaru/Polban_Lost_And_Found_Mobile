import 'package:mongo_dart/mongo_dart.dart';
import '../models/user_model.dart';
import '../services/mongodb_service.dart';

class UserRepository {
  Future<UserModel?> getUserByEmail(String email) async {
    final db = await MongodbService.db;
    final usersCollection = db.collection('users');
    final userMap = await usersCollection.findOne(where.eq('email', email));

    if (userMap != null) {
      return UserModel.fromMap(userMap);
    }
    return null;
  }

  Future<bool> verifyPassword(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user == null) {
      return false;
    }
    // Insecure: a real implementation must compare password hashes.
    return user.password == password;
  }
}