import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'barcode_scanner_poc_method_channel.dart';
import 'barcode_scan_result.dart';
import 'overlay_label_style.dart';

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

  /// Scans a barcode and returns a [BarcodeScanResult].
  ///
  /// If [overlayLabel] is non-null and non-empty, it is shown at the top-left of
  /// the scanner on supported platforms (Android, iOS).
  ///
  /// [overlayLabelStyle] customizes colors, typography, and corners of the chip.
  ///
  /// If [overlayLabelCloseOnTap] is true, tapping the label closes the scanner;
  /// [scanBarcodeResult] will then return [BarcodeScanOverlayBack].
  Future<BarcodeScanResult> scanBarcode({
    String? overlayLabel,
    OverlayLabelStyle? overlayLabelStyle,
    bool? overlayLabelCloseOnTap,
  });
}
