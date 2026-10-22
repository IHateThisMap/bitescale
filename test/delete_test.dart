import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_calorie_couinter_exercise_app/main.dart';
import 'package:flutter_calorie_couinter_exercise_app/services/food_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const foods = '[{"id":"a","name":"Banana","category":"Other","unit":"g",'
    '"per100":{"kcal":89}},{"id":"b","name":"Pizza","category":"Meals",'
    '"unit":"g","per100":{"kcal":250}}]';

String log() => jsonEncode([
      for (final (id, food) in [('1', 'b'), ('2', 'a')])
        {
          'id': id,
          'date': DateTime.now().toIso8601String(),
          'foodId': food,
          'foodName': food == 'a' ? 'Banana' : 'Pizza',
          'amount': 100,
          'unit': 'g',
          'nutrients': {'kcal': food == 'a' ? 89 : 250},
        },
    ]);

/// A narrow phone, to also catch rows that don't fit.
Future<void> openFoodPage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    'user_profile': '{"heightCm":180}',
    'foods': foods,
    'food_log': log(),
  });
  await tester.pumpWidget(const CalorieApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text('Food'));
  await tester.pumpAndSettle();
}

Finder eatenRow(String name) => find.widgetWithText(ListTile, name);

Finder xButton(Finder row, String tooltip) =>
    find.descendant(of: row, matching: find.byTooltip(tooltip));

void main() {
  testWidgets('eaten food: x button asks before removing', (tester) async {
    await openFoodPage(tester);

    await tester.tap(xButton(eatenRow('Pizza'), 'Remove from eaten'));
    await tester.pumpAndSettle();
    expect(find.text('Remove "Pizza" from eaten?'), findsOneWidget);

    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    expect(eatenRow('Pizza'), findsOneWidget);

    await tester.tap(xButton(eatenRow('Pizza'), 'Remove from eaten'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(eatenRow('Pizza'), findsNothing);
    expect(eatenRow('Banana'), findsOneWidget);
    expect((await FoodStorage().loadLog()).map((e) => e.foodName),
        ['Banana']);
  });

  testWidgets('eaten food: swiping also asks first', (tester) async {
    await openFoodPage(tester);

    await tester.drag(eatenRow('Banana'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Remove "Banana" from eaten?'), findsOneWidget);
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    expect(eatenRow('Banana'), findsOneWidget);

    await tester.drag(eatenRow('Banana'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(eatenRow('Banana'), findsNothing);
  });

  for (final (screen, open) in [
    ('Add food', (WidgetTester t) => t.tap(find.text('Add food'))),
    ('My foods', (WidgetTester t) => t.tap(find.byTooltip('My foods'))),
  ]) {
    testWidgets('$screen: x button asks before deleting a food template',
        (tester) async {
      await openFoodPage(tester);
      await open(tester);
      await tester.pumpAndSettle();
      final row = find.widgetWithText(ListTile, 'Banana');

      await tester.tap(xButton(row, 'Delete food template'));
      await tester.pumpAndSettle();
      expect(find.text('Delete food template "Banana"?'), findsOneWidget);
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      expect(row, findsOneWidget);

      await tester.tap(xButton(row, 'Delete food template'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(row, findsNothing);
      expect((await FoodStorage().loadFoods()).map((f) => f.name), ['Pizza']);

      // Swiping asks too.
      await tester.drag(
          find.widgetWithText(ListTile, 'Pizza'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('Delete food template "Pizza"?'), findsOneWidget);
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Pizza'), findsOneWidget);
    });
  }
}
