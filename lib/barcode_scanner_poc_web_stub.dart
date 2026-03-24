import 'package:flutter/widgets.dart';

/// A stub widget for the web barcode scanner, shown when not running on web.
class BarcodeScannerPocWebWidget extends StatelessWidget {
  /// Creates a [BarcodeScannerPocWebWidget].
  const BarcodeScannerPocWebWidget({
    super.key,
    required void Function(String) onScan,
    required config,
  });

  @override
  Widget build(BuildContext context) {
    return const Text('The web scanner is only available on web.');
  }
}
