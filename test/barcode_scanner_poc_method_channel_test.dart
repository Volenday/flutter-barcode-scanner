import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barcode_scanner_poc/barcode_scanner_poc_method_channel.dart';
import 'package:barcode_scanner_poc/barcode_scan_result.dart';
import 'package:barcode_scanner_poc/overlay_label_style.dart';

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
              return {'outcome': 'success', 'code': 'mock-barcode'};
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test(
      'getPlatformVersion invokes the correct method and returns value',
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

    test('scanBarcode invokes the correct method and returns value', () async {
      final barcode = await methodChannelBarcodeScannerPoc.scanBarcode();
      expect(barcode, isA<BarcodeScanSuccess>());
      expect((barcode as BarcodeScanSuccess).code, 'mock-barcode');
      expect(log, [
        isA<MethodCall>().having((m) => m.method, 'method', 'scanBarcode'),
      ]);
    });

    test('scanBarcode passes overlayLabel to channel when non-empty', () async {
      await methodChannelBarcodeScannerPoc.scanBarcode(
        overlayLabel: '  My store  ',
      );
      expect(log.length, 1);
      final call = log.single;
      expect(call.method, 'scanBarcode');
      expect(call.arguments, {'overlayLabel': 'My store'});
    });

    test('scanBarcode passes style and close-on-tap', () async {
      await methodChannelBarcodeScannerPoc.scanBarcode(
        overlayLabel: 'Back',
        overlayLabelStyle: const OverlayLabelStyle(
          backgroundColor: Colors.deepPurple,
          textColor: Colors.white,
          fontSize: 15,
          borderRadius: 10,
        ),
        overlayLabelCloseOnTap: true,
      );
      final call = log.single;
      expect(call.method, 'scanBarcode');
      final args = Map<String, dynamic>.from(call.arguments as Map);
      expect(args['overlayLabel'], 'Back');
      expect(args['overlayLabelCloseOnTap'], true);
      expect(args['overlayLabelStyle'], isA<Map>());
      expect(
        (args['overlayLabelStyle'] as Map).containsKey('backgroundColor'),
        isTrue,
      );
    });
  });
}
