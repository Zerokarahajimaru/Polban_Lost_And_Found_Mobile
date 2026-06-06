import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/src/repositories/notification_repository.dart';

final _repo = NotificationRepository();

Future<Response> onRequest(RequestContext context, String id) async {
  try {
    switch (context.request.method) {
      case HttpMethod.post:
        return _onPost(context, id);
      case HttpMethod.delete:
        return _onDelete(id);
      default:
        return Response(statusCode: HttpStatus.methodNotAllowed);
    }
  } catch (e) {
    return Response(statusCode: 500, body: 'Error: $e');
  }
}

/// POST /notifications/:id dengan body {"action": "read"}
Future<Response> _onPost(RequestContext context, String id) async {
  final body = await context.request.json() as Map<String, dynamic>;
  final action = body['action']?.toString();

  if (action == 'read') {
    await _repo.markAsRead(id);
    return Response.json(body: {'message': 'Notifikasi ditandai sebagai dibaca.'});
  } else {
    return Response(statusCode: HttpStatus.badRequest, body: 'Action tidak valid.');
  }
}

Future<Response> _onDelete(String id) async {
  await _repo.deleteNotification(id);
  return Response(statusCode: HttpStatus.noContent);
}
