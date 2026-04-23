import 'dart:async';
import 'dart:io';

import 'package:backend/src/controller/report_controller.dart';
import 'package:backend/src/models/report.dart';
import 'package:backend/src/services/mongodb_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final reportController = ReportController(context.read<MongodbService>());
  switch (context.request.method) {
    case HttpMethod.get:
      return _onGet(context, reportController);
    case HttpMethod.post:
      return _onPost(context, reportController);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _onGet(
  RequestContext context,
  ReportController controller,
) async {
  final reports = await controller.getAllReports();
  return Response.json(body: reports);
}

Future<Response> _onPost(
  RequestContext context,
  ReportController controller,
) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final report = ReportModel.fromMap(body);
  final createdReport = await controller.createReport(report);
  return Response.json(body: createdReport);
}