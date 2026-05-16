import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../lib/src/services/mongodb_service.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _onGet(context);
    case HttpMethod.post:
      return _onPost(context);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _onGet(RequestContext context) async {
  try {
    final db = await MongodbService.db;
    final col = db.collection('reports');

    // Opsional: filter by userId
    final params = context.request.uri.queryParameters;
    final userId = params['userId'];

    final selector = userId != null ? where.eq('userId', userId) : null;
    final reports = selector != null
        ? await col.find(selector).toList()
        : await col.find().toList();

    final sanitized = reports.map((doc) {
      final id = doc['_id'];
      if (id is ObjectId) {
        doc['_id'] = id.toHexString();
      }
      return doc;
    }).toList();

    return Response.json(body: sanitized);
  } catch (e) {
    return Response(statusCode: 500, body: 'Error: $e');
  }
}

Future<Response> _onPost(RequestContext context) async {
  try {
    final db = await MongodbService.db;
    final col = db.collection('reports');
    final json = await context.request.json() as Map<String, dynamic>;

    // Tambahkan timestamp jika tidak ada
    json['createdAt'] ??= DateTime.now().toIso8601String();
    json['updatedAt'] = DateTime.now().toIso8601String();

    final result = await col.insertOne(json);
    final insertedId = (result.id as ObjectId).toHexString();

    return Response.json(
      statusCode: HttpStatus.created,
      body: {'id': insertedId, 'message': 'Report created'},
    );
  } catch (e) {
    return Response(statusCode: 500, body: 'Error: $e');
  }
}
