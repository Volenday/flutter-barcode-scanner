import 'package:barcode_scanner_poc/barcode_scanner_poc_platform_interface.dart';
import 'package:barcode_scanner_poc/barcode_scan_result.dart';
import 'package:barcode_scanner_poc/overlay_label_style.dart';
import 'package:flutter/material.dart';

export 'barcode_scan_result.dart';
export 'overlay_label_style.dart';

/// Main entry point for the Barcode Scanner POC library.
///
/// Provides static methods to interact with the barcode scanner functionality.
class BarcodeScannerPoc {
  /// Scans and returns only the decoded text, or `null` if there was no successful read.
  ///
  /// Use [scanBarcodeResult] to distinguish **overlay back**, **cancel**, and other cases.
  static Future<String?> scanBarcode({
    String? overlayLabel,
    OverlayLabelStyle? overlayLabelStyle,
    bool? overlayLabelCloseOnTap,
  }) async {
    try {
      final r = await scanBarcodeResult(
        overlayLabel: overlayLabel,
        overlayLabelStyle: overlayLabelStyle,
        overlayLabelCloseOnTap: overlayLabelCloseOnTap,
      );
      return switch (r) {
        BarcodeScanSuccess(:final code) => code,
        _ => null,
      };
    } catch (e) {
      debugPrint("Error to process the barcode: '$e'");
      return null;
    }
  }

  /// Scans and returns a detailed [BarcodeScanResult] (success, overlay "back",
  /// system cancellation, etc.).
  static Future<BarcodeScanResult> scanBarcodeResult({
    String? overlayLabel,
    OverlayLabelStyle? overlayLabelStyle,
    bool? overlayLabelCloseOnTap,
  }) async {
    try {
      return await BarcodeScannerPocPlatform.instance.scanBarcode(
        overlayLabel: overlayLabel,
        overlayLabelStyle: overlayLabelStyle,
        overlayLabelCloseOnTap: overlayLabelCloseOnTap,
      );
    } catch (e) {
      debugPrint("Error to process the barcode: '$e'");
      return const BarcodeScanCancelled();
    }
  }

  /// Returns the platform version as a [String].
  static Future<String?> get platformVersion =>
      BarcodeScannerPocPlatform.instance.getPlatformVersion();
}
