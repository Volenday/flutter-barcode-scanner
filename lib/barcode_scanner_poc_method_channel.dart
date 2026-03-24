import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'barcode_scanner_poc_platform_interface.dart';

/// An implementation of [BarcodeScannerPocPlatform] that uses method channels.
class MethodChannelBarcodeScannerPoc extends BarcodeScannerPocPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('barcode_scanner_poc');

  /// Returns the platform version as a [String].
  @override
  Future<String?> getPlatformVersion() =>
      methodChannel.invokeMethod<String>('getPlatformVersion');

  /// Scans a barcode and returns the result as a [String].
  @override
  Future<String?> scanBarcode() =>
      methodChannel.invokeMethod<String>('scanBarcode');
}
