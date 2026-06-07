import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/repositories/moderation_repository.dart';
import 'package:backend/src/models/moderation_report.dart';

final _repo = ModerationRepository();

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
    final params = context.request.uri.queryParameters;
    final statusFilter = params['status']; // optional: ?status=pending

    List<ModerationReportModel> reports;
    if (statusFilter == 'pending') {
      reports = await _repo.getPendingReports();
    } else {
      reports = await _repo.getAllReports();
    }

    return Response.json(body: reports.map((r) => r.toJson()).toList());
  } catch (e) {
    return Response(statusCode: 500, body: 'Error: $e');
  }
}

Future<Response> _onPost(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;

    await _repo.submitUserReport(
      postId: body['postId']?.toString() ?? '',
      postTitle: body['postTitle']?.toString() ?? '',
      uploaderName: body['uploaderName']?.toString() ?? '',
      postImageUrl: body['postImageUrl']?.toString(),
      reporterName: body['reporterName']?.toString() ?? 'Anonymous',
      reporterNim: body['reporterNim']?.toString() ?? '-',
      reason: body['reportReason']?.toString() ?? 'Lainnya',
    );

    return Response.json(
      statusCode: HttpStatus.created,
      body: {'message': 'Laporan berhasil dikirim.'},
    );
  } catch (e) {
    return Response(statusCode: 500, body: 'Error: $e');
  }
}
