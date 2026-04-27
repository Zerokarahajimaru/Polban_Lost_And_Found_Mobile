import 'dart:io';

import 'package:backend/src/models/report.dart';
import 'package:backend/src/services/database_service.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  // Route the request to the appropriate handler based on the HTTP method.
  switch (context.request.method) {
    case HttpMethod.get:
      return _onGet(context);
    case HttpMethod.post:
      return _onPost(context);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

/// Handles GET requests to fetch all reports.
Future<Response> _onGet(RequestContext context) async {
  try {
    // Directly access the service. It will self-initialize on first use.
    final reportsCollection = await DatabaseService().reports;
    final reportsFromDb = await reportsCollection.find().toList();

    // Manually convert non-serializable types (like ObjectId) to JSON-safe types.
    final jsonSafeReports = reportsFromDb.map((reportMap) {
      reportMap['_id'] = (reportMap['_id'] as ObjectId).toHexString();
      return reportMap;
    }).toList();

    return Response.json(body: jsonSafeReports);
  } catch (e, s) {
    print('Error in _onGet: $e\n$s');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'message': 'An internal server error occurred: $e'},
    );
  }
}

/// Handles POST requests to create a new report.
Future<Response> _onPost(RequestContext context) async {
  try {
    // Directly access the service.
    final reportsCollection = await DatabaseService().reports;
    final json = await context.request.json() as Map<String, dynamic>;
    final now = DateTime.now();

    // Map incoming JSON from client to the ReportModel structure
    final report = ReportModel(
      userId: 'user_dummy_polban', // Placeholder user ID as agreed
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
      bounty: (json['reward'] != null && (json['reward'] as String).isNotEmpty)
          ? BountyModel(amount: int.parse(json['reward'] as String), description: 'Imbalan')
          : null,
    );

    final result = await reportsCollection.insertOne(report.toMap());

    if (result.isSuccess) {
      return Response.json(
        statusCode: HttpStatus.created,
        body: {'message': 'Report created successfully'},
      );
    } else {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'message': 'Failed to save report: ${result.writeError?.errmsg}'},
      );
    }
  } catch (e, s) {
    print('Error in _onPost: $e\n$s');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'message': 'An internal server error occurred: $e'},
    );
  }
}
