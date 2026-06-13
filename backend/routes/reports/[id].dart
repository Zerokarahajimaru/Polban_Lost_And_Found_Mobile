import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:backend/src/services/mongodb_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  // Normalize ID: Remove ObjectId("...") wrapper if present
  var cleanId = id;
  if (cleanId.startsWith('ObjectId("') && cleanId.endsWith('")')) {
    cleanId = cleanId.substring(10, cleanId.length - 2);
  }

  final db = await MongodbService.db;
  final reportsCollection = db.collection('reports');
  
  ObjectId objectId;
  try {
    objectId = ObjectId.fromHexString(cleanId);
  } catch (e) {
    return Response(statusCode: 400, body: 'Invalid ID format: $id');
  }

  try {
    if (context.request.method == HttpMethod.put) {
      final payload = await context.request.json() as Map<String, dynamic>;
      // Sanitize payload: avoid updating _id
      payload.remove('_id');
      payload.remove('id');
      
      await reportsCollection.updateOne(where.id(objectId), {r'$set': payload});
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
