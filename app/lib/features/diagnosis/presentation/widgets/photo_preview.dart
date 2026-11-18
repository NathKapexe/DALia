import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PhotoPreview extends StatelessWidget {
  const PhotoPreview({
    super.key,
    required this.path,
    this.onChangePhoto,
  });

  final String? path;
  final VoidCallback? onChangePhoto;

  void _openFullScreen(BuildContext context, String photoPath) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _FullScreenPhotoViewer(photoPath: photoPath),
      ),
    );
  }

  Widget _buildImage(String photoPath, BoxFit fit) {
    if (kIsWeb) {
      return Image.network(
        photoPath,
        fit: fit,
        filterQuality: FilterQuality.high,
      );
    }
    return Image.file(
      File(photoPath),
      fit: fit,
      filterQuality: FilterQuality.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final photoPath = path;
    final hasValidFile = photoPath != null &&
        photoPath.isNotEmpty &&
        (kIsWeb || File(photoPath).existsSync());

    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasValidFile)
            GestureDetector(
              onTap: () => _openFullScreen(context, photoPath),
              child: Hero(
                tag: 'plant_photo_preview',
                child: _buildImage(photoPath, BoxFit.cover),
              ),
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 48, color: scheme.outline),
                const SizedBox(height: 8),
                Text(
                  'Sin vista previa disponible',
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
              ],
            ),

          if (hasValidFile)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 68,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (hasValidFile)
            Positioned(
              left: 12,
              bottom: 12,
              child: Material(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openFullScreen(context, photoPath),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_in_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Ampliar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (onChangePhoto != null)
            Positioned(
              right: 12,
              bottom: 12,
              child: FilledButton.tonalIcon(
                onPressed: onChangePhoto,
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: scheme.surface.withValues(alpha: 0.92),
                  foregroundColor: scheme.onSurface,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Cambiar foto'),
              ),
            ),
        ],
      ),
    );
  }
}

class _FullScreenPhotoViewer extends StatelessWidget {
  const _FullScreenPhotoViewer({required this.photoPath});

  final String photoPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        foregroundColor: Colors.white,
        title: const Text('Inspeccionar hoja'),
        actions: [
          IconButton(
            tooltip: 'Cerrar',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5.0,
          child: Hero(
            tag: 'plant_photo_preview',
            child: kIsWeb
                ? Image.network(
                    photoPath,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  )
                : Image.file(
                    File(photoPath),
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
          ),
        ),
      ),
    );
  }
}