import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/src/repositories/claim_repository.dart';

final _repo = ClaimRepository();

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final action = body['action'] as String?;

    if (action == 'verify') {
      await _repo.updateClaimStatus(id, 'verified');
      return Response.json(body: {'message': 'Klaim berhasil diverifikasi.'});
    } else if (action == 'reject') {
      await _repo.updateClaimStatus(id, 'rejected');
      return Response.json(body: {'message': 'Klaim ditolak.'});
    } else {
      return Response(statusCode: HttpStatus.badRequest, body: 'Invalid action');
    }
  } catch (e) {
    return Response(statusCode: 500, body: 'Error: $e');
  }
}
