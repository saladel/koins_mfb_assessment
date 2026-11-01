import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';

/// Circular profile picture with a three-stage fallback.
///
/// 1. No URL, or a blank one, renders initials immediately.
/// 2. While the image downloads, initials stay on screen, so there is no
///    empty hole and no layout shift.
/// 3. If the request fails (no internet, dead URL, non-image response), it
///    falls back to initials permanently.
///
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.fullName,
    this.imageUrl,
    this.size = 72,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  final String fullName;
  final String? imageUrl;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  bool get _hasUrl => imageUrl != null && imageUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final Color background = backgroundColor ?? AppColors.surfaceMuted;

    return Container(
      height: size,
      width: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 1.5),
      ),
      child: _hasUrl ? _buildNetworkImage(context) : _buildInitials(context),
    );
  }

  Widget _buildNetworkImage(BuildContext context) {
    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      width: size,
      height: size,
      // Shown while bytes are still arriving.
      loadingBuilder:
          (BuildContext context, Widget child, ImageChunkEvent? progress) {
            if (progress == null) return child;
            return _buildInitials(context);
          },
      // Shown when the request fails outright.
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        return _buildInitials(context);
      },
    );
  }

  Widget _buildInitials(BuildContext context) {
    return Center(
      child: Text(
        Formatters.initials(fullName),
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          color: foregroundColor ?? AppColors.textSecondary,
          height: 1,
        ),
      ),
    );
  }
}
