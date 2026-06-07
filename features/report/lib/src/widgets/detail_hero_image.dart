import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';

class DetailHeroImage extends StatelessWidget {
  final ImageProvider? imageProvider;
  final VoidCallback onBack;

  const DetailHeroImage({
    super.key,
    required this.imageProvider,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: imageProvider != null
              ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImage(
                        imageProvider: imageProvider!,
                        tag: 'detail_hero',
                      ),
                    ),
                  )
              : null,
          child: Hero(
            tag: 'detail_hero',
            child: Container(
              height: 300,
              width: double.infinity,
              color: AppColors.softGrey,
              child: imageProvider != null
                  ? Stack(
                      children: [
                        Positioned.fill(child: Image(image: imageProvider!, fit: BoxFit.cover)),
                        Positioned.fill(
                            child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                child: Container(color: Colors.black.withOpacity(0.2)))),
                        Center(child: Image(image: imageProvider!, fit: BoxFit.contain)),
                      ],
                    )
                  : const Center(
                      child: Icon(Icons.image_not_supported_outlined, color: AppColors.textGrey, size: 48)),
            ),
          ),
        ),
        Container(
          height: 100,
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.5), Colors.transparent])),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue), onPressed: onBack)),
          ),
        ),
      ],
    );
  }
}
