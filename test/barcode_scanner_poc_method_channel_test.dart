import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barcode_scanner_poc/barcode_scanner_poc_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelBarcodeScannerPoc', () {
    const MethodChannel channel = MethodChannel('barcode_scanner_poc');
    final List<MethodCall> log = <MethodCall>[];
    late MethodChannelBarcodeScannerPoc methodChannelBarcodeScannerPoc;

    setUp(() {
      methodChannelBarcodeScannerPoc = MethodChannelBarcodeScannerPoc();
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            log.add(methodCall);
            if (methodCall.method == 'getPlatformVersion') {
              return 'mock-version';
            }
            if (methodCall.method == 'scanBarcode') {
              return 'mock-barcode';
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test(
      'getPlatformVersion llama al método correcto y retorna valor',
      () async {
        final version = await methodChannelBarcodeScannerPoc
            .getPlatformVersion();
        expect(version, 'mock-version');
        expect(log, [
          isA<MethodCall>().having(
            (m) => m.method,
            'method',
            'getPlatformVersion',
          ),
        ]);
      },
    );

    test('scanBarcode llama al método correcto y retorna valor', () async {
      final barcode = await methodChannelBarcodeScannerPoc.scanBarcode();
      expect(barcode, 'mock-barcode');
      expect(log, [
        isA<MethodCall>().having((m) => m.method, 'method', 'scanBarcode'),
      ]);
    });
  });
}
