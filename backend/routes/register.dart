import 'dart:io';

import 'package:backend/src/models/user_model.dart';
import 'package:backend/src/repositories/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final userRepository = UserRepository();
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final name = body['name'] as String?;
    final email = body['email'] as String?;
    final password = body['password'] as String?;

    if (name == null ||
        name.isEmpty ||
        email == null ||
        email.isEmpty ||
        password == null ||
        password.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'Name, email, and password are required.'},
      );
    }

    final existingUser = await userRepository.getUserByEmail(email);
    if (existingUser != null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'Email is already registered.'},
      );
    }

    final newUser = await userRepository.registerUser(
      name: name,
      email: email,
      password: password,
    );

    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'message': 'Registration successful!',
        'user': newUser.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'message': 'An internal error occurred: $e'},
    );
  }
}
