import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'barcode_scanner_poc_platform_interface.dart';
import 'barcode_scan_result.dart';
import 'overlay_label_style.dart';

/// An implementation of [BarcodeScannerPocPlatform] that uses method channels.
class MethodChannelBarcodeScannerPoc extends BarcodeScannerPocPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('barcode_scanner_poc');

  /// Returns the platform version as a [String].
  @override
  Future<String?> getPlatformVersion() =>
      methodChannel.invokeMethod<String>('getPlatformVersion');

  /// Scans a barcode and returns a structured [BarcodeScanResult].
  @override
  Future<BarcodeScanResult> scanBarcode({
    String? overlayLabel,
    OverlayLabelStyle? overlayLabelStyle,
    bool? overlayLabelCloseOnTap,
  }) async {
    final trimmed = overlayLabel?.trim();
    final hasLabel = trimmed != null && trimmed.isNotEmpty;
    final styleMap = overlayLabelStyle?.toMap();
    final hasStyle = styleMap != null && styleMap.isNotEmpty;

    final dynamic raw;
    if (!hasLabel && !hasStyle && overlayLabelCloseOnTap == null) {
      raw = await methodChannel.invokeMethod<dynamic>('scanBarcode');
    } else {
      final args = <String, dynamic>{};
      if (hasLabel) args['overlayLabel'] = trimmed;
      if (hasStyle) args['overlayLabelStyle'] = styleMap;
      if (overlayLabelCloseOnTap != null) {
        args['overlayLabelCloseOnTap'] = overlayLabelCloseOnTap;
      }
      raw = await methodChannel.invokeMethod<dynamic>('scanBarcode', args);
    }

    return barcodeScanResultFromChannel(raw);
  }
}
