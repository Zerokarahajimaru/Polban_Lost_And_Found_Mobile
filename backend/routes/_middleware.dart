import 'package:backend/src/services/database_service.dart';
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  // The DatabaseService singleton is already initialized in `bin/server.dart`.
  // Here, we just provide its instance to the request context so that
  // our route handlers can access it.
  return handler.use(
    provider<DatabaseService>((_) => DatabaseService()),
  );
}
