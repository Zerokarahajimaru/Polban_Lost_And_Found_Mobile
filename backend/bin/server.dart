import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  // Nothing special is needed here anymore.
  // The DatabaseService will initialize itself on first use.
  return serve(handler, ip, port);
}
