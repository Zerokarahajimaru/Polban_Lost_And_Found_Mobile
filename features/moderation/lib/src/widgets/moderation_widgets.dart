import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';

class ReporterAvatar extends StatelessWidget {
  final String initial;
  final double size;

  const ReporterAvatar({
    super.key,
    required this.initial,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.secondaryBlue,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryBlue, width: 1.5),
      ),
      child: Text(
        initial.toUpperCase(),
        style: TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.44,
        ),
      ),
    );
  }
}

class ReasonBadge extends StatelessWidget {
  final String reason;

  const ReasonBadge({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCDD2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Text(
        reason,
        style: const TextStyle(
          color: Color(0xFFC62828),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PostThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;

  const PostThumbnail({
    super.key,
    this.imageUrl,
    this.width = 80,
    this.height = 80,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFEECDD0),
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFFB71C1C),
        size: 28,
      ),
    );
  }
}