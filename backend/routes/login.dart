import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
// Corrected import path
import '../lib/src/repositories/user_repository.dart';
import '../lib/src/models/user_model.dart';


Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final userRepository = UserRepository();
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final email = body['email'] as String?;
    final password = body['password'] as String?;

    if (email == null || password == null) {
      return Response(statusCode: HttpStatus.badRequest, body: 'Email and password are required.');
    }
    final isAuthenticated = await userRepository.verifyPassword(email, password);
    if (!isAuthenticated) {
      return Response(statusCode: HttpStatus.unauthorized, body: 'Invalid email or password.');
    }
    final user = await userRepository.getUserByEmail(email);
    return Response.json(body: {'message': 'Login successful!', 'user': user!.toJson()});
  } catch (e) {
    return Response(statusCode: HttpStatus.internalServerError, body: 'An internal error occurred: $e');
  }
}
