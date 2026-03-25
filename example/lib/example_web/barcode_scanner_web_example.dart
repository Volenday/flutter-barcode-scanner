import 'package:barcode_scanner_poc/barcode_scanner_poc.dart';
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
        const Text(
          'Top-left: styled label; tap to close the view (pop).',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        Text('Scanned value: $_barcodeValue'),
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
                Text('Current config: ${webOptions.toWebConfig()}'),
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
                    overlayLabel: '← Back (web)',
                    overlayLabelStyle: const OverlayLabelStyle(
                      backgroundColor: Color(0xCC004D40),
                      textColor: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      paddingHorizontal: 12,
                      paddingVertical: 8,
                      borderRadius: 8,
                    ),
                    overlayLabelCloseOnTap: true,
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
