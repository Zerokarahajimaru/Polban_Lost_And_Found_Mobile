import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/src/repositories/notification_repository.dart';
import '../../lib/src/models/notification.dart';

final _repo = NotificationRepository();

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
    final userId = params['userId'];

    if (userId == null) {
      return Response(statusCode: HttpStatus.badRequest, body: 'userId is required');
    }

    final notifications = await _repo.getNotificationsByUserId(userId);
    return Response.json(body: notifications.map((n) => n.toJson()).toList());
  } catch (e) {
    return Response(statusCode: 500, body: 'Error: $e');
  }
}

Future<Response> _onPost(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;

    final notification = NotificationModel(
      userId: body['userId']?.toString() ?? '',
      judul: body['judul']?.toString() ?? '',
      pesan: body['pesan']?.toString() ?? '',
      tipeNotif: body['tipeNotif']?.toString() ?? 'system',
      createdAt: DateTime.now(),
    );

    final id = await _repo.createNotification(notification);
    return Response.json(
      statusCode: HttpStatus.created,
      body: {'id': id, 'message': 'Notifikasi berhasil dibuat.'},
    );
  } catch (e) {
    return Response(statusCode: 500, body: 'Error: $e');
  }
}
