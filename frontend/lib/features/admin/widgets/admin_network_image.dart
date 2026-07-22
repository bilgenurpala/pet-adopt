import 'package:flutter/material.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';

class AdminNetworkImage extends StatelessWidget {
  const AdminNetworkImage({
    required this.url,
    this.size = 56,
    super.key,
  });

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolved = _resolve(url);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: resolved == null
            ? _placeholder()
            : Image.network(
                resolved,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: const Icon(Icons.pets, color: AppColors.disabled),
    );
  }

  static String? _resolve(String? raw) {
    final value = raw?.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final path = value.startsWith('/') ? value : '/$value';

    return '${ApiEndpoints.baseUrl}$path';
  }
}
