import 'dart:io';

import '../../lib/src/models/report_model.dart';
import '../../lib/src/services/database_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  // Route the request to the appropriate handler based on the HTTP method.
  switch (context.request.method) {
    case HttpMethod.get:
      return _onGet(context);
    case HttpMethod.post:
      return _onPost(context);
    case HttpMethod.delete:
    case HttpMethod.put:
    case HttpMethod.patch:
    case HttpMethod.head:
    case HttpMethod.options:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

/// Handles GET requests to fetch all reports.
Future<Response> _onGet(RequestContext context) async {
  try {
    // Read the DatabaseService from the context.
    final dbService = context.read<DatabaseService>();

    // Fetch all documents from the 'reports' collection.
    final reports = await dbService.reports.find().toList();

    // Return the list of reports as a JSON response.
    return Response.json(body: reports);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'message': 'An internal server error occurred: $e'},
    );
  }
}

/// Handles POST requests to create a new report.
Future<Response> _onPost(RequestContext context) async {
  try {
    // Read the DatabaseService from the context.
    final dbService = context.read<DatabaseService>();

    // Parse the JSON body from the request.
    final json = await context.request.json() as Map<String, dynamic>;

    // Create a ReportModel instance. This helps validate the incoming data
    // and ensures we are saving a correctly structured document.
    final report = ReportModel(
      title: json['title'] as String,
      description: json['description'] as String,
      // The imageUrl is provided by the client after uploading to Cloudinary.
      imageUrl: json['imageUrl'] as String,
      location: json['location'] as String,
      // The server is responsible for setting the creation timestamp.
      createdAt: DateTime.now().toUtc(),
      status: (json['status'] as String?) ?? 'lost',
    );

    // Insert the report's data into the database.
    final result = await dbService.reports.insertOne(report.toMap());

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
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'message': 'An internal server error occurred: $e'},
    );
  }
}
