import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/main.dart';

void main() {
  testWidgets('Susadım smoke test - renders title and water section',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SusadimApp());

    expect(find.text('SUSADIM'), findsOneWidget);
    expect(find.text('İçilen'), findsOneWidget);
    expect(find.text('Kalan Hedef'), findsOneWidget);
  });

  testWidgets('Susadım smoke test - can switch to competition tab',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SusadimApp());

    await tester.tap(find.text('Yarışma'));
    await tester.pump();

    expect(find.text('Haftalık Podyum 🏆'), findsOneWidget);
    expect(find.text('Tüm Sıralama'), findsOneWidget);
  });
}
