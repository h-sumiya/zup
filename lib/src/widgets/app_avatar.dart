import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.iconPath, this.size = 48});

  final String? iconPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF42E2B8).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    final path = iconPath;
    if (path == null ||
        path.isEmpty ||
        !_renderableExtensions.contains(p.extension(path).toLowerCase())) {
      return const Icon(Icons.apps, color: Colors.white);
    }

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Icon(Icons.apps, color: Colors.white),
    );
  }

  static const Set<String> _renderableExtensions = <String>{
    '.png',
    '.jpg',
    '.jpeg',
    '.webp',
    '.bmp',
    '.gif',
  };
}
