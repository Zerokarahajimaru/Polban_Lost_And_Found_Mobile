import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
// Corrected import path
import '../../lib/src/services/mongodb_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final db = await MongodbService.db;
  final reportsCollection = db.collection('reports');
  final objectId = ObjectId.fromHexString(id);

  try {
    if (context.request.method == HttpMethod.put) {
      final payload = await context.request.json() as Map<String, dynamic>;
      await reportsCollection.updateOne(where.id(objectId), {'\$set': payload});
      return Response(body: 'Report updated');
    }

    if (context.request.method == HttpMethod.delete) {
      await reportsCollection.deleteOne(where.id(objectId));
      return Response(statusCode: HttpStatus.noContent);
    }
  } catch (e) {
    return Response(statusCode: 500, body: 'An error occurred: $e');
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}