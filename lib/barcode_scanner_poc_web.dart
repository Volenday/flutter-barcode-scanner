// ignore_for_file: deprecated_member_use

/// Web implementation of the BarcodeScannerPoc plugin.
///
/// This file contains the logic required to integrate barcode scanning into Flutter Web applications
/// using the [html5-qrcode](https://github.com/mebjas/html5-qrcode) library and a custom JS file.
///
/// Main components:
/// - Dynamic injection of required JS scripts for scanning.
/// - Widget to render the camera view and handle scan results.
/// - Configurable options for the web scanner.
///
/// Usage:
///
/// ```dart
/// BarcodeScannerPocWebWidget(
///   onScan: (code) => print('Scanned code: $code'),
///   web: BarcodeScannerPocWebOptions(fps: 15, qrbox: 300),
/// )
/// ```
///
/// Make sure the JS assets are correctly referenced in your Flutter Web project.
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'package:js/js_util.dart' as js_util;
import 'dart:ui_web' as ui_web;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Main entry point for the web implementation of the plugin.
class BarcodeScannerPocWeb {
  /// Registers the plugin with the Flutter web plugin registrar.
  static void registerWith(Registrar registrar) {}
}

/// Injects the required JS scripts for barcode scanning into the web page.
///
/// Loads html5-qrcode from CDN if not present, then loads the custom barcode_scanner.js.
void _injectBarcodeScannerJs() {
  const html5QrcodeId = 'html5-qrcode-js';
  const scannerId = 'barcode-scanner-js';

  final doc = web.window.document;
  if (doc.getElementById(scannerId) != null) return;

  if (doc.getElementById(html5QrcodeId) != null) {
    final scannerScript = doc.createElement('script') as web.HTMLScriptElement;
    scannerScript.id = scannerId;
    scannerScript.type = 'application/javascript';
    scannerScript.src =
        'assets/packages/barcode_scanner_poc/lib/web/barcode_scanner.js';
    doc.body!.appendChild(scannerScript);
    return;
  }

  final html5QrcodeScript =
      doc.createElement('script') as web.HTMLScriptElement;
  html5QrcodeScript.id = html5QrcodeId;
  html5QrcodeScript.type = 'application/javascript';
  html5QrcodeScript.defer = true;
  html5QrcodeScript.src =
      'https://unpkg.com/html5-qrcode@2.3.8/html5-qrcode.min.js';
  html5QrcodeScript.onLoad.listen((event) {
    final scannerScript = doc.createElement('script') as web.HTMLScriptElement;
    scannerScript.id = scannerId;
    scannerScript.type = 'application/javascript';
    scannerScript.src =
        'assets/packages/barcode_scanner_poc/lib/web/barcode_scanner.js';
    doc.body!.appendChild(scannerScript);
  });
  doc.body!.appendChild(html5QrcodeScript);
}

@JS('startHtml5Qrcode')
external void startHtml5Qrcode(
  JSString elementId,
  JSFunction onScan,
  JSFunction onError, [
  JSAny? config,
]);

/// Options for configuring the web barcode scanner.
class BarcodeScannerPocWebOptions {
  /// Preferred video width in pixels.
  final int? width;

  /// Preferred video height in pixels.
  final int? height;

  /// Frames per second for the scanner (default: 10).
  final int fps;

  /// Size of the QR/barcode scanning box (default: 250).
  final int qrbox;

  /// Camera focus mode (if supported).
  final String? focusMode;

  /// Additional custom options for html5-qrcode.
  final Map<String, dynamic>? extraOptions;

  const BarcodeScannerPocWebOptions({
    this.width,
    this.height,
    this.fps = 10,
    this.qrbox = 250,
    this.focusMode,
    this.extraOptions,
  });

  /// Converts the Dart options to a JS-friendly configuration map.
  Map<String, dynamic> toWebConfig() {
    final videoConstraints = <String, dynamic>{};
    if (width != null) videoConstraints['width'] = {'ideal': width};
    if (height != null) videoConstraints['height'] = {'ideal': height};
    if (focusMode != null) videoConstraints['focusMode'] = focusMode;

    final options = {
      'fps': fps,
      'qrbox': qrbox,
      'videoConstraints': videoConstraints,
      ...?extraOptions,
    };
    return {
      'cameraConfig': {'facingMode': 'environment'},
      'options': options,
    };
  }
}

/// Widget that displays the camera view and handles barcode scanning on Flutter Web.
class BarcodeScannerPocWebWidget extends StatefulWidget {
  /// Callback called when a barcode is successfully scanned.
  final void Function(String code) onScan;

  /// Web-specific scanner options.
  final BarcodeScannerPocWebOptions? web;

  const BarcodeScannerPocWebWidget({required this.onScan, this.web, super.key});

  @override
  State<BarcodeScannerPocWebWidget> createState() =>
      _BarcodeScannerPocWebWidgetState();
}

/// State for [BarcodeScannerPocWebWidget]. Handles view registration and JS integration.
class _BarcodeScannerPocWebWidgetState
    extends State<BarcodeScannerPocWebWidget> {
  /// The HTML element ID for the scanner container.
  final String _elementId = 'html5-qrcode-element';
  static bool _registered = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb && !_registered) {
      ui_web.platformViewRegistry.registerViewFactory(_elementId, (int viewId) {
        final div =
            web.window.document.createElement('div') as web.HTMLDivElement;
        div.id = _elementId;
        return div;
      });
      _registered = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kIsWeb) {
        _injectBarcodeScannerJs();
        // Waits a bit longer and checks that the JS function is available
        Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 200));
          final hasFunction =
              (js_util.getProperty(js_util.globalThis, 'startHtml5Qrcode') !=
              null);
          return !hasFunction;
        }).then((_) {
          final webConfig = widget.web?.toWebConfig();
          final jsConfig = webConfig != null
              ? {'web': webConfig}.jsify()
              : null;
          startHtml5Qrcode(
            _elementId.toJS,
            ((JSString code) {
              widget.onScan(code.toDart);
            }).toJS,
            ((JSString error) {}).toJS,
            jsConfig,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _elementId);
  }
}
