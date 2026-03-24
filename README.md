
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

`barcode_scanner_poc` is a Flutter plugin that enables barcode and QR code scanning for both mobile (Android/iOS) and web platforms. It provides a unified API and easy integration for cross-platform barcode scanning in your Flutter apps.

## Contributors

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/Juniorwebprogrammer">
        <img src="https://res.cloudinary.com/dgekm2gqi/image/upload/v1731267442/ovznsjzcbvtrerzur6uy.jpg" width="100px;" alt="Junior García"/><br />
        <sub><b>Junior García</b></sub>
      </a>
      <br />
      <a href="https://github.com/Juniorwebprogrammer">github.com/Juniorwebprogrammer</a>
    </td>
  </tr>
</table>

## Used Libraries

- [html5-qrcode](https://github.com/mebjas/html5-qrcode) (Web)
- [camera](https://pub.dev/packages/camera) (Mobile)
- [flutter_web_plugins](https://pub.dev/packages/flutter_web_plugins)
- [js](https://pub.dev/packages/js) / [js_util](https://pub.dev/packages/js_util) (Web interop)

## Available Platforms

- Android
- iOS
- Web

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  barcode_scanner_poc: ^0.0.3
```

Then run:

```bash
flutter pub get
```


## Recommended Folder Structure

```
lib/
  barcode_scanner_poc.dart
  barcode_scanner_poc_method_channel.dart
  barcode_scanner_poc_platform_interface.dart
  barcode_scanner_poc_web.dart
  barcode_scanner_poc_web_stub.dart
  web/
    barcode_scanner.js
example/
  lib/
    main.dart
  test/
    widget_test.dart
  android/
  ios/
  web/
```

## Usage Examples



### Example Project (Multiplatform, using conditional exports)

You can run the provided example project for a ready-to-use multiplatform demo:

```bash
cd example
flutter run -d chrome   # For web
flutter run -d android  # For Android
flutter run -d ios      # For iOS
```

The example uses conditional exports to select the correct widget for each platform:

**example/lib/barcode_scanner_example.dart**
```dart
export 'barcode_scanner_example_stub.dart'
    if (dart.library.html) 'example_web/barcode_scanner_example_web_wrapper.dart'
    if (dart.library.io) 'example_mobile/barcode_scanner_example_mobile_wrapper.dart';
```

**example/lib/barcode_scanner_example_stub.dart**
```dart
import 'package:flutter/widgets.dart';

class BarcodeScannerExample extends StatelessWidget {
  const BarcodeScannerExample({super.key});
  @override
  Widget build(BuildContext context) {
    return const Text('Platform not supported');
  }
}
```

**example/lib/example_web/barcode_scanner_example_web_wrapper.dart**
```dart
import 'barcode_scanner_web_example.dart';

class BarcodeScannerExample extends BarcodeScannerWebExample {
  const BarcodeScannerExample({super.key});
}
```

**example/lib/example_web/barcode_scanner_web_example.dart**
```dart
import 'package:barcode_scanner_poc/barcode_scanner_poc_web.dart';
import 'package:flutter/material.dart';

class BarcodeScannerWebExample extends StatefulWidget {
  const BarcodeScannerWebExample({super.key});

  @override
  State<BarcodeScannerWebExample> createState() =>
      _BarcodeScannerWebExampleState();
}

class _BarcodeScannerWebExampleState extends State<BarcodeScannerWebExample> {
  String _barcodeValue = 'Unknown';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Scan a code using the web camera:'),
        Text('Scanned value: [4m_barcodeValue'),
        const SizedBox(height: 20),
        Builder(
          builder: (context) {
            const webOptions = BarcodeScannerPocWebOptions(
              width: 1280,
              height: 720,
              fps: 60,
              qrbox: 400,
              focusMode: 'continuous',
              extraOptions: {'showTorchButtonIfSupported': true},
            );
            return Column(
              children: [
                Text('Current config: [4mwebOptions.toWebConfig()'),
                const SizedBox(height: 10),
                SizedBox(
                  width: webOptions.width?.toDouble() ?? 800,
                  height: webOptions.height?.toDouble() ?? 800,
                  child: BarcodeScannerPocWebWidget(
                    onScan: (code) {
                      setState(() {
                        _barcodeValue = code;
                      });
                    },
                    web: webOptions,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
```

**example/lib/example_mobile/barcode_scanner_example_mobile_wrapper.dart**
```dart
import 'barcode_scanner_mobile_example.dart';

class BarcodeScannerExample extends BarcodeScannerMobileExample {
  const BarcodeScannerExample({super.key});
}
```

**example/lib/example_mobile/barcode_scanner_mobile_example.dart**
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scanner_poc/barcode_scanner_poc.dart';

class BarcodeScannerMobileExample extends StatefulWidget {
  const BarcodeScannerMobileExample({super.key});

  @override
  State<BarcodeScannerMobileExample> createState() =>
      _BarcodeScannerMobileExampleState();
}

class _BarcodeScannerMobileExampleState
    extends State<BarcodeScannerMobileExample> {
  String _barcodeValue = 'Unknown';

  Future<void> scanBarcode() async {
    String? barcodeValue;
    try {
      barcodeValue = await BarcodeScannerPoc.scanBarcode();
    } on PlatformException {
      barcodeValue = 'Failed to get barcode value.';
    }

    if (!mounted) return;
    setState(() {
      _barcodeValue = barcodeValue ?? 'Scan cancelled';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Press the button to scan a code:'),
        Text('Scanned value: [4m_barcodeValue'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: scanBarcode,
          child: const Text('Scan Barcode'),
        ),
      ],
    );
  }
}
```

**example/lib/main.dart**
```dart
import 'package:flutter/material.dart';
import 'barcode_scanner_example.dart';

void main() => runApp(const MaterialApp(
  home: Scaffold(
    body: Center(child: BarcodeScannerExample()),
  ),
));
```


### Example: Mobile Only

`example/lib/example_mobile/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:barcode_scanner_poc/barcode_scanner_poc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Barcode Scanner Mobile Example')),
        body: Center(
          child: BarcodeScannerPoc.scan(
            onScan: (code) {
              print('Scanned code: $code');
            },
          ),
        ),
      ),
    );
  }
}
```

### Example: Web Only

`example/lib/example_web/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:barcode_scanner_poc/barcode_scanner_poc_web.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Barcode Scanner Web Example')),
        body: Center(
          child: BarcodeScannerPocWebWidget(
            onScan: (code) {
              print('Scanned code: $code');
            },
            web: BarcodeScannerPocWebOptions(fps: 15, qrbox: 300),
          ),
        ),
      ),
    );
  }
}
```

### Mobile (Android/iOS)

```dart
import 'package:barcode_scanner_poc/barcode_scanner_poc.dart';

BarcodeScannerPoc.scan(
  onScan: (code) {
    print('Scanned code: $code');
  },
  // You can pass additional options if needed
);
```


### Web

```dart
import 'package:barcode_scanner_poc/barcode_scanner_poc_web.dart';

BarcodeScannerPocWebWidget(
  onScan: (code) {
    print('Scanned code: $code');
  },
  web: BarcodeScannerPocWebOptions(fps: 15, qrbox: 300),
);
```

## Contributors

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/Juniorwebprogrammer">
        <img src="https://res.cloudinary.com/dgekm2gqi/image/upload/v1731267442/ovznsjzcbvtrerzur6uy.jpg" width="100px;" alt="Junior García"/><br />
        <sub><b>Junior García</b></sub>
      </a>
      <br />
      <a href="https://github.com/Juniorwebprogrammer">github.com/Juniorwebprogrammer</a>
    </td>
  </tr>
</table>