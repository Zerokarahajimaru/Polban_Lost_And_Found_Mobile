import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as p;

class ImageCompressService {
  static Future<File?> compressImage(File file) async {
    final tempDir = await path_provider.getTemporaryDirectory();
    final path = tempDir.path;
    final targetPath = p.join(path, "${DateTime.now().millisecondsSinceEpoch}_compressed.jpg");

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // 70% quality balance between size and clarity
      format: CompressFormat.jpeg,
    );

    if (result == null) return null;
    return File(result.path);
  }
}
