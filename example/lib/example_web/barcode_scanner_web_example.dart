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
        const Text('Escanea un código usando la cámara web:'),
        Text('Valor escaneado: $_barcodeValue'),
        const SizedBox(height: 20),
        // Mostrar la configuración actual en pantalla
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
                Text('Config actual: ${webOptions.toWebConfig()}'),
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
