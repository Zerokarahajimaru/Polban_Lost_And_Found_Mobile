import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as p;

class ImageCompressService {
  static Future<File?> compressImage(File file) async {
    try {
      final tempDir = await path_provider.getTemporaryDirectory();
      final path = tempDir.path;
      final targetPath = p.join(path, "${DateTime.now().millisecondsSinceEpoch}_compressed.jpg");

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70, // 70% quality balance between size and clarity
        format: CompressFormat.jpeg,
      );

      if (result == null) return file;
      return File(result.path);
    } catch (e) {
      // Fallback to original file if compression fails or is unimplemented
      debugPrint("Image compression failed or unsupported: $e");
      return file;
    }
  }
}
