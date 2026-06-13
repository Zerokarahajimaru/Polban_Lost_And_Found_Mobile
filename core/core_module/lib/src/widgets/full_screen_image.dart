import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../theme/color_service.dart';

class FullScreenImage extends StatelessWidget {
  final ImageProvider imageProvider;
  final String? tag;

  const FullScreenImage({
    super.key,
    required this.imageProvider,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Hero(
        tag: tag ?? 'image_hero',
        child: PhotoView(
          imageProvider: imageProvider,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }
}
