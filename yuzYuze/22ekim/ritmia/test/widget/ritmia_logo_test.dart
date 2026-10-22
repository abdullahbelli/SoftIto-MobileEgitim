import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritmia/core/widgets/ritmia_logo.dart';

void main() {
  testWidgets('RitmiaLogo başlık ve sloganı doğru çizer', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RitmiaLogo(
            size: 80,
            showText: true,
            showSlogan: true,
          ),
        ),
      ),
    );

    expect(find.text('Ritmia'), findsOneWidget);
    expect(find.text('Küçük adımlar, güçlü alışkanlıklar.'), findsOneWidget);
  });
}
