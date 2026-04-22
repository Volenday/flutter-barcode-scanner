import 'package:flutter/material.dart';
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
  final TextEditingController _overlayLabelController = TextEditingController(
    text: 'Demo label',
  );

  @override
  void dispose() {
    _overlayLabelController.dispose();
    super.dispose();
  }

  Future<void> scanBarcode() async {
    final label = _overlayLabelController.text.trim();
    final result = await BarcodeScannerPoc.scanBarcodeResult(
      overlayLabel: "",
      overlayLabelStyle: label.isEmpty
          ? null
          : const OverlayLabelStyle(
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

    final logLine = switch (result) {
      BarcodeScanSuccess(:final code) =>
        '[example] BarcodeScanSuccess — code: $code',
      BarcodeScanOverlayBack() => '[example] BarcodeScanOverlayBack()',
      BarcodeScanCancelled() => '[example] BarcodeScanCancelled()',
    };
    debugPrint(logLine);

    if (!mounted) return;
    setState(() {
      _barcodeValue = switch (result) {
        BarcodeScanSuccess(:final code) => code,
        BarcodeScanOverlayBack() => '(closed via overlay / back)',
        BarcodeScanCancelled() => '(cancelled: system back or other)',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Tap the button to scan a code:'),
        const Text(
          'Back arrow top-left; optional text beside it. Leave overlay empty for icon only.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            controller: _overlayLabelController,
            decoration: const InputDecoration(
              labelText: 'Overlay text',
              border: OutlineInputBorder(),
              hintText: 'Empty = arrow only',
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Scanned value: $_barcodeValue'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: scanBarcode,
          child: const Text('Scan barcode'),
        ),
      ],
    );
  }
}
