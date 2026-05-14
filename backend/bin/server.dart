import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  // Bind to all IPv4 interfaces so the backend is reachable
  // from other devices on the same network.
  return serve(handler, InternetAddress.anyIPv4, port);
}
