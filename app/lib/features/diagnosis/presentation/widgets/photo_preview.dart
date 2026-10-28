import 'dart:io';

import 'package:flutter/material.dart';

class PhotoPreview extends StatelessWidget {
  const PhotoPreview({super.key, required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final photoPath = path;

    final Widget content;
    if (photoPath != null && File(photoPath).existsSync()) {
      content = Image.file(File(photoPath), fit: BoxFit.cover, cacheWidth: 800);
    } else {
      content = ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.image_outlined, size: 48, color: scheme.outline),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(height: 220, width: double.infinity, child: content),
    );
  }
}
