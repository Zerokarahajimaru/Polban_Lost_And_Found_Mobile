import 'dart:io';

import 'package:backend/src/models/report.dart';
import 'package:backend/src/services/database_service.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.put:
      return _onPut(context, id);
    case HttpMethod.delete:
      return _onDelete(context, id);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _onPut(RequestContext context, String id) async {
  try {
    final reportsCollection = await DatabaseService().reports;
    final objectId = ObjectId.fromHexString(id);
    final json = await context.request.json() as Map<String, dynamic>;

    final report = ReportModel(
      id: id,
      userId: 'user_dummy_polban', // This should ideally come from auth
      namaBarang: json['title'] as String,
      kategoriBarang: json['category'] as String,
      statusPostingan: json['status'] as String,
      deskripsiBarang: json['description'] as String,
      lokasiKehilangan: json['location'] as String,
      kontak: json['contact'] as String,
      images: [json['imageUrl'] as String],
      lastActivityAt: DateTime.now(), // Update activity time
      createdAt: DateTime.parse(json['createdAt'] as String), // Preserve original creation time
      updatedAt: DateTime.now(),
      reportCount: 0, // Should not be updated by user
      isSynced: true,
      bounty: (json['reward'] != null && (json['reward'] as String).isNotEmpty)
          ? BountyModel(amount: int.parse(json['reward'] as String), description: 'Imbalan')
          : null,
    );

    final result = await reportsCollection.replaceOne(
      where.id(objectId),
      report.toMap(),
    );

    if (result.isSuccess && result.nModified == 1) {
      return Response.json(body: {'message': 'Report updated successfully'});
    } else {
      return Response(
        statusCode: HttpStatus.notFound,
        body: 'Report with ID $id not found or no changes made.',
      );
    }
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'An internal server error occurred: $e',
    );
  }
}


Future<Response> _onDelete(RequestContext context, String id) async {
  try {
    final reportsCollection = await DatabaseService().reports;
    final objectId = ObjectId.fromHexString(id);

    final result = await reportsCollection.deleteOne(where.id(objectId));

    if (result.isSuccess && result.nRemoved == 1) {
      return Response(statusCode: HttpStatus.noContent); // Success, no content
    } else {
      return Response(
        statusCode: HttpStatus.notFound,
        body: 'Report with ID $id not found.',
      );
    }
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'An internal server error occurred: $e',
    );
  }
}
