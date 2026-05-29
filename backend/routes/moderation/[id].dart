import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/src/repositories/moderation_repository.dart';

final _repo = ModerationRepository();

Future<Response> onRequest(RequestContext context, String id) async {
  try {
    switch (context.request.method) {
      case HttpMethod.get:
        return _onGet(id);
      case HttpMethod.post:
        return _onPost(context, id);
      default:
        return Response(statusCode: HttpStatus.methodNotAllowed);
    }
  } catch (e) {
    return Response(statusCode: 500, body: 'Error: $e');
  }
}

Future<Response> _onGet(String id) async {
  final report = await _repo.getById(id);
  if (report == null) {
    return Response(statusCode: HttpStatus.notFound, body: 'Laporan tidak ditemukan.');
  }
  return Response.json(body: report.toJson());
}

/// POST /moderation/:id dengan body {"action": "takedown"} atau {"action": "ignore"}
Future<Response> _onPost(RequestContext context, String id) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final action = body['action']?.toString();

  if (action == 'takedown') {
    await _repo.takedown(id);
    return Response.json(body: {'message': 'Postingan berhasil ditakedown.'});
  } else if (action == 'ignore') {
    await _repo.ignore(id);
    return Response.json(body: {'message': 'Laporan berhasil diabaikan.'});
  } else {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Action tidak valid. Gunakan "takedown" atau "ignore".',
    );
  }
}
