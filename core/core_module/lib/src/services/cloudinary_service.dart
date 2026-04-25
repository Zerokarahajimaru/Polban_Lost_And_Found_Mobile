import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';

/// A service to handle image uploads to Cloudinary.
///
/// This class uses an unsigned upload method, which is safe to use on the
/// client-side as it does not require an API secret.
class CloudinaryService {
  // Private constructor for Singleton pattern
  CloudinaryService._();

  // The single, static instance of this class.
  static final CloudinaryService _instance = CloudinaryService._();

  /// The factory constructor that returns the singleton instance.
  factory CloudinaryService() => _instance;

  late final CloudinaryPublic _cloudinary;

  /// Initializes the service with your Cloudinary credentials.
  void init({required String cloudName, required String uploadPreset}) {
    _cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
  }

  /// Uploads an image file to Cloudinary and returns the secure URL.
  ///
  /// Takes a [File] object representing the image to be uploaded.
  /// Throws an [Exception] if the upload fails.
  Future<String> uploadImage(File imageFile) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      debugPrint('Cloudinary: Image uploaded successfully');
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      debugPrint('Cloudinary Error: ${e.message}');
      throw Exception('Failed to upload image: ${e.message}');
    } catch (e) {
      debugPrint('Unknown error during image upload: $e');
      throw Exception('An unknown error occurred during image upload.');
    }
  }
}