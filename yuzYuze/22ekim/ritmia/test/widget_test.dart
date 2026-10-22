import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritmia/core/widgets/custom_button.dart';

void main() {
  testWidgets('CustomButton metin ve yükleme durumunu doğru gösterir', (WidgetTester tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'Giriş Yap',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Giriş Yap'), findsOneWidget);
    await tester.tap(find.text('Giriş Yap'));
    expect(pressed, true);
  });
}
