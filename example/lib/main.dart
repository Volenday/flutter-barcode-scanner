import 'barcode_scanner_example.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin de Escáner de Códigos')),
        body: const Center(child: BarcodeScannerExample()),
      ),
    );
  }
}
