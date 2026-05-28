import 'package:flutter/material.dart';

/// A unified image widget that automatically uses [Image.asset] for paths
/// starting with "assets/" and [Image.network] for all other URLs.
class AppImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AppImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  bool get _isAsset => url.startsWith('assets/');

  Widget _defaultError(BuildContext ctx, Object e, StackTrace? st) =>
      const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40));

  @override
  Widget build(BuildContext context) {
    final onError = errorBuilder ?? _defaultError;

    if (_isAsset) {
      return Image.asset(
        url,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: onError,
      );
    }

    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: onError,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }
}
