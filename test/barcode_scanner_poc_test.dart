import 'package:flutter_test/flutter_test.dart';
import 'package:barcode_scanner_poc/barcode_scanner_poc.dart';
import 'package:barcode_scanner_poc/barcode_scanner_poc_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBarcodeScannerPocPlatform extends BarcodeScannerPocPlatform
    with MockPlatformInterfaceMixin {
  String? scannedValue;
  String? platformVersion;

  @override
  Future<String?> getPlatformVersion() async =>
      platformVersion ?? 'mock-version';

  @override
  Future<String?> scanBarcode() async => scannedValue ?? 'mock-barcode';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BarcodeScannerPoc', () {
    late MockBarcodeScannerPocPlatform mockPlatform;

    setUp(() {
      mockPlatform = MockBarcodeScannerPocPlatform();
      BarcodeScannerPocPlatform.instance = mockPlatform;
    });

    test('getPlatformVersion devuelve la versión mock', () async {
      mockPlatform.platformVersion = '1.2.3';
      final version = await BarcodeScannerPoc.platformVersion;
      expect(version, '1.2.3');
    });

    test('scanBarcode devuelve el valor mock', () async {
      mockPlatform.scannedValue = '123456789';
      final result = await BarcodeScannerPoc.scanBarcode();
      expect(result, '123456789');
    });

    test('scanBarcode maneja excepciones y retorna null', () async {
      mockPlatform.scannedValue = null;
      BarcodeScannerPocPlatform.instance = _ThrowingBarcodeScannerPocPlatform();
      final result = await BarcodeScannerPoc.scanBarcode();
      expect(result, isNull);
    });
  });
}

class _ThrowingBarcodeScannerPocPlatform extends BarcodeScannerPocPlatform {
  @override
  Future<String?> getPlatformVersion() async => throw Exception('error');

  @override
  Future<String?> scanBarcode() async => throw Exception('error');
}
