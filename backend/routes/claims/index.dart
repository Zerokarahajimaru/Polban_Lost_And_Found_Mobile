import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/repositories/claim_repository.dart';
import 'package:backend/src/models/claim.dart';

final _repo = ClaimRepository();

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _getClaims(context);
    case HttpMethod.post:
      return _createClaim(context);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getClaims(RequestContext context) async {
  try {
    final claims = await _repo.getAllClaims();
    return Response.json(body: claims.map((c) => c.toMap()).toList());
  } catch (e) {
    return Response(statusCode: 500, body: 'Error: $e');
  }
}

Future<Response> _createClaim(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final claim = Claim.fromMap(body);
    final id = await _repo.createClaim(claim);
    return Response.json(
      statusCode: HttpStatus.created,
      body: {'id': id, 'message': 'Klaim berhasil diajukan.'},
    );
  } catch (e) {
    return Response(statusCode: 500, body: 'Error: $e');
  }
}
