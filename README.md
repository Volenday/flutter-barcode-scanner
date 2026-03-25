
<div align="center">
  <h1>barcode_scanner_poc</h1>
  
  <!-- Tech icons -->
  <p>
    <img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white&style=for-the-badge" alt="Flutter"/>
    <img src="https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white&style=for-the-badge" alt="Dart"/>
    <img src="https://img.shields.io/badge/JS-F7DF1E?logo=javascript&logoColor=black&style=for-the-badge" alt="JavaScript"/>
    <img src="https://img.shields.io/badge/html5--qrcode-2.3.8-orange?style=for-the-badge" alt="html5-qrcode"/>
  </p>
  <!-- Platform icons -->
  <p>
    <img src="https://img.shields.io/badge/Android-3DDC84?logo=android&logoColor=white&style=for-the-badge" alt="Android"/>
    <img src="https://img.shields.io/badge/iOS-000000?logo=apple&logoColor=white&style=for-the-badge" alt="iOS"/>
    <img src="https://img.shields.io/badge/Web-4285F4?logo=google-chrome&logoColor=white&style=for-the-badge" alt="Web"/>
  </p>
</div>

# barcode_scanner_poc


## Introduction

`barcode_scanner_poc` is a Flutter plugin for barcode and QR scanning on **Android**, **iOS**, and **Web**. It exposes a small Dart API on mobile (`BarcodeScannerPoc`) and a web widget (`BarcodeScannerPocWebWidget`) that wraps [html5-qrcode](https://github.com/mebjas/html5-qrcode).

**Highlights**

- Native camera scanning on Android (CameraX + ML Kit) and iOS (AVFoundation + Vision).
- Optional **overlay label** at the top-left (below the status bar), with optional **styling** (`OverlayLabelStyle`).
- Optional **tap-to-close** on that label (`overlayLabelCloseOnTap`) to leave the scanner without a read.
- **Structured results** via `scanBarcodeResult()` (`BarcodeScanResult`): distinguish a successful decode, overlay "back", and other cancellations. `scanBarcode()` still returns `String?` (code or `null`) for simple use cases.

## Used Libraries

- [html5-qrcode](https://github.com/mebjas/html5-qrcode) (Web)
- [Google ML Kit Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning) (Android)
- [Vision](https://developer.apple.com/documentation/vision) (iOS barcodes)
- [flutter_web_plugins](https://pub.dev/packages/flutter_web_plugins)
- [js](https://pub.dev/packages/js) / `dart:js_util` (Web interop)

## Available Platforms

- Android
- iOS
- Web

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  barcode_scanner_poc: ^0.0.12
```

Then run:

```bash
flutter pub get
```

## Overlay label, styling, and structured results (mobile)

On **Android** and **iOS**, pass optional arguments to `scanBarcode` / `scanBarcodeResult`:

| Parameter | Purpose |
|-----------|---------|
| `overlayLabel` | Text shown in a chip at the **top-left** (below the status bar). |
| `overlayLabelStyle` | `OverlayLabelStyle` for background/text color, font, padding, corner radius. |
| `overlayLabelCloseOnTap` | If `true`, tapping the chip closes the scanner (see `BarcodeScanOverlayBack` below). |

Use **`scanBarcodeResult()`** when you need to tell **why** the screen closed:

| `BarcodeScanResult` | Meaning |
|---------------------|---------|
| `BarcodeScanSuccess(code)` | A code was read successfully. |
| `BarcodeScanOverlayBack()` | User tapped the overlay label with `overlayLabelCloseOnTap: true`. |
| `BarcodeScanCancelled()` | Closed without a decode (e.g. system back, permission flow, etc.). |

`scanBarcode()` returns only the decoded `String`, or `null` for any non-success outcome (no distinction).

**Example**

```dart
import 'package:flutter/material.dart';
import 'package:barcode_scanner_poc/barcode_scanner_poc.dart';

final result = await BarcodeScannerPoc.scanBarcodeResult(
  overlayLabel: 'Back',
  overlayLabelStyle: const OverlayLabelStyle(
    backgroundColor: Color(0xCC1A237E),
    textColor: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 8,
  ),
  overlayLabelCloseOnTap: true,
);

switch (result) {
  case BarcodeScanSuccess(:final code):
    print('Decoded: $code');
  case BarcodeScanOverlayBack():
    print('User closed via overlay');
  case BarcodeScanCancelled():
    print('Cancelled without code');
}
```

## Web: overlay on `BarcodeScannerPocWebWidget`

The same styling and tap behavior are available on web via widget parameters:

- `overlayLabel`, `overlayLabelStyle`, `overlayLabelCloseOnTap`
- Optional `onOverlayLabelTap`  if omitted and `overlayLabelCloseOnTap` is true, `Navigator.maybePop()` is used.

See `example/lib/example_web/barcode_scanner_web_example.dart`.

## Recommended folder structure (package)

```
lib/
  barcode_scanner_poc.dart
  barcode_scanner_poc_method_channel.dart
  barcode_scanner_poc_platform_interface.dart
  barcode_scan_result.dart
  overlay_label_style.dart
  barcode_scanner_poc_web.dart
  barcode_scanner_poc_web_stub.dart
  web/
    barcode_scanner.js
example/
  lib/
    main.dart
    ...
```

## Usage examples

### Run the bundled example

```bash
cd example
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS
```

The example uses **conditional exports** (`barcode_scanner_example.dart`) to load the mobile or web UI. Inspect:

- `example/lib/example_mobile/barcode_scanner_mobile_example.dart`  `scanBarcodeResult`, overlay, logging.
- `example/lib/example_web/barcode_scanner_web_example.dart`  `BarcodeScannerPocWebWidget` with overlay.

### Mobile (Android / iOS)

```dart
import 'package:barcode_scanner_poc/barcode_scanner_poc.dart';

// Simple: code or null
final String? code = await BarcodeScannerPoc.scanBarcode();

// With overlay (optional)
final String? code2 = await BarcodeScannerPoc.scanBarcode(
  overlayLabel: 'Back',
  overlayLabelCloseOnTap: true,
);
```

### Web

```dart
import 'package:barcode_scanner_poc/barcode_scanner_poc_web.dart';

BarcodeScannerPocWebWidget(
  onScan: (code) => print('Scanned: $code'),
  web: BarcodeScannerPocWebOptions(fps: 15, qrbox: 300),
  overlayLabel: 'Back',
  overlayLabelCloseOnTap: true,
);
```

## Contributors

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/Juniorwebprogrammer">
        <img src="https://res.cloudinary.com/dgekm2gqi/image/upload/v1731267442/ovznsjzcbvtrerzur6uy.jpg" width="100px;" alt="Junior Garcia"/><br />
        <sub><b>Junior Garcia</b></sub>
      </a>
      <br />
      <a href="https://github.com/Juniorwebprogrammer">github.com/Juniorwebprogrammer</a>
    </td>
  </tr>
</table>
