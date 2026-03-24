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
        const Text('Presiona el botón para escanear un código:'),
        Text('Valor escaneado: $_barcodeValue'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: scanBarcode,
          child: const Text('Escanear Código de Barras'),
        ),
      ],
    );
  }
}
