import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritmia/features/habits/models/habit.dart';
import 'package:ritmia/features/habits/views/widgets/habit_card.dart';

void main() {
  testWidgets('HabitCard başlık, seri ve tamamlama etkileşimini doğru çizer', (WidgetTester tester) async {
    final habit = Habit(
      id: 'h1',
      userId: 'u1',
      name: 'Günlük 2 Litre Su',
      description: 'Sağlıklı kal',
      category: 'Sağlık',
      targetType: 'check',
      targetValue: 1.0,
      startDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool toggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabitCard(
            habit: habit,
            progress: null,
            streak: 5,
            onToggle: () => toggled = true,
            onIncrement: () {},
            onDecrement: () {},
            onEdit: () {},
          ),
        ),
      ),
    );

    // Başlık ve açıklama kontrolü
    expect(find.text('Günlük 2 Litre Su'), findsOneWidget);
    expect(find.text('Sağlıklı kal'), findsOneWidget);

    // Streak göstergesi (5 gün)
    expect(find.text('5 gün'), findsOneWidget);

    // Tamamla butonu
    expect(find.text('Tamamla'), findsOneWidget);

    // Butona dokunulması
    await tester.tap(find.text('Tamamla'));
    await tester.pump();

    expect(toggled, true);
  });
}
