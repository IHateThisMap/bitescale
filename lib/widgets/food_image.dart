import 'dart:io';

import 'package:flutter/material.dart';

import '../services/food_image_service.dart';

/// A food's photo, or a placeholder icon when it has none.
class FoodImage extends StatelessWidget {
  const FoodImage({super.key, required this.path, this.size = 48});

  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: size,
      height: size,
      color: colors.secondaryContainer,
      child: Icon(Icons.restaurant,
          size: size * 0.5, color: colors.onSecondaryContainer),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.2),
      child: path == null || !FoodImageService.isSupported
          ? placeholder
          : Image.file(
              File(path!),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}
