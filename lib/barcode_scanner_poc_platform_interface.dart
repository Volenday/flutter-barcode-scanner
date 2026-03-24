import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'barcode_scanner_poc_method_channel.dart';

/// The platform interface for the Barcode Scanner POC plugin.
///
/// Platform-specific implementations should extend this class.
abstract class BarcodeScannerPocPlatform extends PlatformInterface {
  BarcodeScannerPocPlatform() : super(token: _token);

  static final Object _token = Object();
  static BarcodeScannerPocPlatform _instance = MethodChannelBarcodeScannerPoc();

  /// The current instance of [BarcodeScannerPocPlatform].
  static BarcodeScannerPocPlatform get instance => _instance;

  /// Sets the current instance of [BarcodeScannerPocPlatform].
  static set instance(BarcodeScannerPocPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the platform version as a [String].
  Future<String?> getPlatformVersion();

  /// Scans a barcode and returns the result as a [String].
  Future<String?> scanBarcode();
}
