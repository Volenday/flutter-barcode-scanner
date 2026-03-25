/// Result of [BarcodeScannerPoc.scanBarcodeResult].
///
/// Distinguishes a successful read, closing via the "back" overlay label, and
/// other cancellations (system back, etc.).
sealed class BarcodeScanResult {
  const BarcodeScanResult();
}

/// Successful barcode read.
final class BarcodeScanSuccess extends BarcodeScanResult {
  const BarcodeScanSuccess(this.code);
  final String code;
}

/// The user tapped the overlay label with [overlayLabelCloseOnTap] enabled.
final class BarcodeScanOverlayBack extends BarcodeScanResult {
  const BarcodeScanOverlayBack();
}

/// Closed without a code (e.g. system back button or dismiss gesture).
final class BarcodeScanCancelled extends BarcodeScanResult {
  const BarcodeScanCancelled();
}

/// Converts the method channel response into a [BarcodeScanResult].
BarcodeScanResult barcodeScanResultFromChannel(dynamic raw) {
  if (raw == null) {
    return const BarcodeScanCancelled();
  }
  if (raw is String) {
    return BarcodeScanSuccess(raw);
  }
  if (raw is! Map) {
    return const BarcodeScanCancelled();
  }
  final m = Map<String, dynamic>.from(raw);
  final outcome = m['outcome'] as String?;
  switch (outcome) {
    case 'success':
      return BarcodeScanSuccess(m['code'] as String? ?? '');
    case 'overlay_back':
      return const BarcodeScanOverlayBack();
    case 'cancelled':
      return const BarcodeScanCancelled();
    default:
      return const BarcodeScanCancelled();
  }
}
