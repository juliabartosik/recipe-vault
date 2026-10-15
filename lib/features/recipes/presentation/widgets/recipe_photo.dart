import 'package:flutter/material.dart';

class RecipePhoto extends StatelessWidget {
  const RecipePhoto({super.key, this.url, this.borderRadius = 20});

  final String? url;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = url != null && url!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: hasPhoto
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  const _PhotoPlaceholder(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const _PhotoPlaceholder(),
            )
          : const _PhotoPlaceholder(),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF0E5), Color(0xFFF5E9D6)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          color: Color(0xFF6C8B70),
          size: 46,
        ),
      ),
    );
  }
}
