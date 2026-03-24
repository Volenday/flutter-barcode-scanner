import 'package:barcode_scanner_poc/barcode_scanner_poc_platform_interface.dart';
import 'package:flutter/material.dart';

/// Main entry point for the Barcode Scanner POC library.
///
/// Provides static methods to interact with the barcode scanner functionality.
class BarcodeScannerPoc {
  /// Scans a barcode and returns the result as a [String].
  ///
  /// Returns `null` if the scan fails or is cancelled.
  static Future<String?> scanBarcode() async {
    try {
      return await BarcodeScannerPocPlatform.instance.scanBarcode();
    } catch (e) {
      debugPrint("Error to process the barcode: '$e'");
      return null;
    }
  }

  /// Returns the platform version as a [String].
  static Future<String?> get platformVersion =>
      BarcodeScannerPocPlatform.instance.getPlatformVersion();
}
