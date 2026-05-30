import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../lib/src/repositories/claim_repository.dart';

final _repo = ClaimRepository();

Future<Response> onRequest(RequestContext context, String id) async {
  // Normalize ID: Remove ObjectId("...") wrapper if present
  String cleanId = id;
  if (cleanId.startsWith('ObjectId("') && cleanId.endsWith('")')) {
    cleanId = cleanId.substring(10, cleanId.length - 2);
  }

  if (context.request.method == HttpMethod.post) {
    try {
      final body = await context.request.json() as Map<String, dynamic>;
      final action = body['action'] as String?;

      if (action == 'verify' || action == 'verified') {
        await _repo.updateClaimStatus(cleanId, 'verified');
        return Response.json(body: {'message': 'Klaim berhasil diverifikasi.'});
      } else if (action == 'reject' || action == 'rejected') {
        await _repo.updateClaimStatus(cleanId, 'rejected');
        return Response.json(body: {'message': 'Klaim ditolak.'});
      } else {
        return Response(statusCode: HttpStatus.badRequest, body: 'Invalid action: $action');
      }
    } catch (e) {
      return Response(statusCode: 500, body: 'Error in POST /claims/[id]: $e');
    }
  }

  if (context.request.method == HttpMethod.delete) {
    try {
      await _repo.deleteClaim(cleanId);
      return Response(statusCode: HttpStatus.noContent);
    } catch (e) {
      return Response(statusCode: 500, body: 'Error in DELETE /claims/[id]: $e');
    }
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
