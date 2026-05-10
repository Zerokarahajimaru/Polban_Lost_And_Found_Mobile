import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class FileService {
  static final Dio _dio = Dio();
  static const Uuid _uuid = Uuid();

  /// Downloads an image from a given URL and saves it to the app's local temporary directory.
  /// Returns the local path of the saved image.
  static Future<String?> downloadImageAndGetPath(String imageUrl) async {
    if (imageUrl.isEmpty) return null;
    
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = '${_uuid.v4()}.jpg'; // Generate a unique filename
      final String localPath = '${tempDir.path}/$fileName';

      final Response response = await _dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final File file = File(localPath);
      await file.writeAsBytes(response.data);

      return localPath;
    } catch (e) {
      debugPrint('Error downloading image: $e');
      return null;
    }
  }
}