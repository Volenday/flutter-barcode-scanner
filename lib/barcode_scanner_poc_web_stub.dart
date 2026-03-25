import 'package:flutter/widgets.dart';

/// A stub widget for the web barcode scanner, shown when not running on web.
class BarcodeScannerPocWebWidget extends StatelessWidget {
  /// Creates a [BarcodeScannerPocWebWidget].
  const BarcodeScannerPocWebWidget({
    super.key,
    required void Function(String) onScan,
    required dynamic config,
    this.overlayLabel,
    this.overlayLabelStyle,
    this.overlayLabelCloseOnTap = false,
    this.onOverlayLabelTap,
  });

  /// Ignored on non-web platforms; see the web implementation.
  final String? overlayLabel;

  /// Ignored on non-web platforms.
  final Object? overlayLabelStyle;

  /// Ignored on non-web platforms.
  final bool overlayLabelCloseOnTap;

  /// Ignored on non-web platforms.
  final VoidCallback? onOverlayLabelTap;

  @override
  Widget build(BuildContext context) {
    return const Text('The web scanner is only available on web.');
  }
}
