import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:barcode_scanner_poc/barcode_scanner_poc_web_stub.dart'
    if (dart.library.html) 'package:barcode_scanner_poc/barcode_scanner_poc_web.dart';

void main() {
  group('BarcodeScannerPocWebWidget', () {
    testWidgets('shows message on non-web platforms', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: BarcodeScannerPocWebWidget(onScan: (_) {}, config: null),
        ),
      );
      expect(
        find.text('The web scanner is only available on web.'),
        findsOneWidget,
      );
    });

    // Only runnable on real web; kept as reference:
    // testWidgets('calls onScan when a code is scanned', (tester) async {
    //   String? scannedCode;
    //   await tester.pumpWidget(Directionality(
    //     textDirection: TextDirection.ltr,
    //     child: BarcodeScannerPocWebWidget(onScan: (code) {
    //       scannedCode = code;
    //     }),
    //   ));
    //   // Simulate scanning here; depends on the JS implementation.
    //   // expect(scannedCode, isNotNull);
    // });
  });
}
