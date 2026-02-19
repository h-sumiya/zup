import 'package:flutter_test/flutter_test.dart';

import 'package:zup/src/app.dart';

void main() {
  testWidgets('Zup title renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ZupApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('ZUP'), findsOneWidget);
    expect(find.text('GitHub Release ZIP Installer'), findsOneWidget);
  });
}
