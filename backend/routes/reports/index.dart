import 'dart:io';

import 'package:backend/src/models/report.dart';
import 'package:backend/src/services/database_service.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

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
    final reportsCollection = await DatabaseService().reports;
    final reportsFromDb = await reportsCollection.find().toList();
    final jsonSafeReports = reportsFromDb.map((reportMap) {
      reportMap['_id'] = (reportMap['_id'] as ObjectId).oid; // Use .oid
      return reportMap;
    }).toList();

    return Response.json(body: jsonSafeReports);
  } catch (e, s) {
    print('Error in _onGet: $e\n$s');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'status': 'error', 'message': e.toString()},
    );
  }
}

Future<Response> _onPost(RequestContext context) async {
  try {
    final reportsCollection = await DatabaseService().reports;
    final json = await context.request.json() as Map<String, dynamic>;
    final now = DateTime.now();

    final report = ReportModel(
      userId: 'user_dummy_polban',
      namaBarang: json['title'] as String,
      kategoriBarang: json['category'] as String,
      statusPostingan: json['status'] as String? ?? 'Available',
      deskripsiBarang: json['description'] as String,
      lokasiKehilangan: json['location'] as String,
      kontak: json['contact'] as String,
      images: [json['imageUrl'] as String],
      lastActivityAt: now,
      createdAt: now,
      updatedAt: now,
      // Provide default values for required fields from the new model
      reportCount: 0,
      isSynced: true, // If it reaches the server, it's synced
      bounty: (json['reward'] != null && (json['reward'] as String).isNotEmpty)
          ? BountyModel(
              amount: int.tryParse(json['reward'] as String) ?? 0,
              description: 'Imbalan')
          : null,
    );

    final result = await reportsCollection.insertOne(report.toMap());

    if (result.isSuccess) {
      return Response.json(
        statusCode: HttpStatus.created,
        body: {
          'status': 'success',
          'message': 'Laporan berhasil dibuat',
          'data': report.toMap()..['_id'] = (result.id as ObjectId).oid,
        },
      );
    } else {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Gagal menyimpan ke database'},
      );
    }
  } catch (e, s) {
    print('Error in _onPost: $e\n$s');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'status': 'error', 'message': e.toString()},
    );
  }
}