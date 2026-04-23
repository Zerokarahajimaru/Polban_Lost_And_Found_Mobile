import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Selects multiple images from the gallery, up to a maximum of 4.
  Future<List<File>> pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      imageQuality: 70, // Compress image quality
      maxWidth: 800, // Resize images for faster upload
    );

    if (pickedFiles.length > 4) {
      return pickedFiles
          .take(4)
          .map((xFile) => File(xFile.path))
          .toList();
    }
    return pickedFiles.map((xFile) => File(xFile.path)).toList();
  }

  /// Uploads a list of image files to Firebase Storage and returns their download URLs.
  Future<List<String>> uploadImages(List<File> images, String reportId) async {
    final List<String> imageUrls = [];
    for (final image in images) {
      final String fileName =
          'reports/$reportId/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
      final Reference storageRef = _storage.ref().child(fileName);
      final UploadTask uploadTask = storageRef.putFile(image);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }
}
