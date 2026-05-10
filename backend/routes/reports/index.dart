import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
// Corrected import path
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
    final reportsCollection = db.collection('reports');
    final reports = await reportsCollection.find().toList();
    // Sanitize ObjectIds for JSON response
    final sanitizedReports = reports.map((report) {
      report['_id'] = (report['_id'] as ObjectId).toHexString();
      return report;
    }).toList();
    return Response.json(body: sanitizedReports);
  } catch (e) {
    return Response(statusCode: 500, body: 'Error: $e');
  }
}

Future<Response> _onPost(RequestContext context) async {
  try {
    final db = await MongodbService.db;
    final reportsCollection = db.collection('reports');
    final json = await context.request.json() as Map<String, dynamic>;
    await reportsCollection.insertOne(json);
    return Response(statusCode: 201, body: 'Report created');
  } catch (e) {
    return Response(statusCode: 500, body: 'Error: $e');
  }
}