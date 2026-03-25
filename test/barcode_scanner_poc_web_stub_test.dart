import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:barcode_scanner_poc/barcode_scanner_poc_web_stub.dart';

void main() {
  group('BarcodeScannerPocWebWidget (stub)', () {
    testWidgets('shows web-only message', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: BarcodeScannerPocWebWidget(onScan: _dummyOnScan, config: null),
        ),
      );
      expect(
        find.text('The web scanner is only available on web.'),
        findsOneWidget,
      );
    });
  });
}

void _dummyOnScan(String code) {}
