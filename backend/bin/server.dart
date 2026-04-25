import 'dart:io';

import 'package:backend/src/services/database_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  // Initialize the database service when the server starts.
  // This ensures the connection is ready before any requests are handled.
  await DatabaseService().init();

  // Continue to serve the handler as normal.
  return serve(handler, ip, port);
}
