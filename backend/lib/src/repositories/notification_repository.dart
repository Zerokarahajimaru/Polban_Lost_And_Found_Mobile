import 'package:mongo_dart/mongo_dart.dart';
import 'package:backend/src/models/notification.dart';
import 'package:backend/src/services/mongodb_service.dart';

class NotificationRepository {
  Future<List<NotificationModel>> getNotificationsByUserId(String userId) async {
    final db = await MongodbService.db;
    final col = db.collection('notifications');
    final results = await col.find(where.eq('user_id', userId).sortBy('created_at', descending: true)).toList();
    return results.map(NotificationModel.fromMap).toList();
  }

  Future<String> createNotification(NotificationModel notification) async {
    final db = await MongodbService.db;
    final col = db.collection('notifications');
    final data = notification.toMap();
    data.remove('_id');
    final result = await col.insertOne(data);
    return (result.id as ObjectId).toHexString();
  }

  Future<void> markAsRead(String id) async {
    final db = await MongodbService.db;
    final col = db.collection('notifications');
    await col.updateOne(
      where.id(ObjectId.fromHexString(id)),
      modify.set('is_read', true),
    );
  }

  Future<void> deleteNotification(String id) async {
    final db = await MongodbService.db;
    final col = db.collection('notifications');
    await col.deleteOne(where.id(ObjectId.fromHexString(id)));
  }
}
