import 'package:mongo_dart/mongo_dart.dart';
import '../models/claim.dart';
import '../services/mongodb_service.dart';

class ClaimRepository {
  Future<List<Claim>> getAllClaims() async {
    final db = await MongodbService.db;
    final collection = db.collection('claims');
    final data = await collection.find().toList();
    return data.map((map) => Claim.fromMap(map)).toList();
  }

  Future<String> createClaim(Claim claim) async {
    final db = await MongodbService.db;
    final collection = db.collection('claims');
    final id = ObjectId();
    await collection.insertOne({
      '_id': id,
      ...claim.toMap(),
    });
    return id.toHexString();
  }

  Future<void> updateClaimStatus(String id, String status) async {
    final db = await MongodbService.db;
    final collection = db.collection('claims');
    await collection.updateOne(
      where.id(ObjectId.fromHexString(id)),
      modify.set('status', status),
    );
  }

  Future<void> deleteClaim(String id) async {
    final db = await MongodbService.db;
    final collection = db.collection('claims');
    await collection.deleteOne(where.id(ObjectId.fromHexString(id)));
  }
}
