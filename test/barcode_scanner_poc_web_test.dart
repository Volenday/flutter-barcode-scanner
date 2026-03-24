import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:barcode_scanner_poc/barcode_scanner_poc_web_stub.dart'
    if (dart.library.html) 'package:barcode_scanner_poc/barcode_scanner_poc_web.dart';

void main() {
  group('BarcodeScannerPocWebWidget', () {
    testWidgets('muestra mensaje en plataformas no web', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: BarcodeScannerPocWebWidget(onScan: (_) {}, config: null),
        ),
      );
      expect(
        find.text('El escáner web solo está disponible en la web.'),
        findsOneWidget,
      );
    });

    // Solo ejecutable en web real, pero se deja como referencia:
    // testWidgets('llama a onScan cuando se escanea un código', (tester) async {
    //   String? scannedCode;
    //   await tester.pumpWidget(Directionality(
    //     textDirection: TextDirection.ltr,
    //     child: BarcodeScannerPocWebWidget(onScan: (code) {
    //       scannedCode = code;
    //     }),
    //   ));
    //   // Aquí deberías simular el escaneo, pero depende de la implementación JS.
    //   // expect(scannedCode, isNotNull);
    // });
  });
}
