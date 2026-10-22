import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_calorie_couinter_exercise_app/main.dart';
import 'package:flutter_calorie_couinter_exercise_app/services/food_storage.dart';

String foodJson(String id, String name, String category, {double kcal = 100}) =>
    '{"id":"$id","name":"$name","category":"$category","unit":"g",'
    '"per100":{"kcal":$kcal}}';

String entryJson(String id, String foodId, double kcal, {String? category}) =>
    jsonEncode({
      'id': id,
      'date': DateTime.now().toIso8601String(),
      'foodId': foodId,
      'foodName': foodId,
      'amount': 100,
      'unit': 'g',
      'nutrients': {'kcal': kcal},
      'category': ?category,
    });

Future<void> openFoodPage(WidgetTester tester, Map<String, Object> prefs) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(
      {'user_profile': '{"heightCm":180}', ...prefs});
  await tester.pumpWidget(const CalorieApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text('Food'));
  await tester.pumpAndSettle();
}

void main() {
  test('removing a category moves its foods and eaten foods to Other',
      () async {
    SharedPreferences.setMockInitialValues({
      'foods': '[${foodJson('a', 'Protein bar', 'Gym food')},'
          '${foodJson('b', 'Shake', 'Gym food')},'
          '${foodJson('c', 'Apple', 'Fruits & vegetables')}]',
      'food_log':
          '[${entryJson('1', 'a', 200, category: 'Gym food')},'
          '${entryJson('2', 'c', 50, category: 'Fruits & vegetables')}]',
    });
    final storage = FoodStorage();

    expect(await storage.removeCategory('Gym food'), 2);

    final categories = {
      for (final f in await storage.loadFoods()) f.name: f.category
    };
    expect(categories, {
      'Protein bar': 'Other',
      'Shake': 'Other',
      'Apple': 'Fruits & vegetables',
    });
    final log = await storage.loadLog();
    expect(log.map((e) => e.category), ['Other', 'Fruits & vegetables']);
  });

  testWidgets('pie chart shows calories per category', (tester) async {
    await openFoodPage(tester, {
      'foods': '[${foodJson('a', 'Apple', 'Fruits & vegetables')},'
          '${foodJson('b', 'Pizza', 'Meals')},'
          '${foodJson('c', 'Bar', 'Gym food')}]',
      'food_log': '[${entryJson('1', 'a', 100)},${entryJson('2', 'b', 600)},'
          '${entryJson('3', 'c', 300)},'
          // Food deleted since: uses the category it was logged with.
          '${entryJson('4', 'gone', 0.0001, category: 'Drinks')}]',
    });

    expect(find.text('Calories by category'), findsOneWidget);
    Finder legendRow(String category) => find.ancestor(
        of: find.text(category), matching: find.byType(InkWell));
    void expectRow(String category, String kcal, String percent) {
      expect(
          find.descendant(of: legendRow(category), matching: find.text(kcal)),
          findsOneWidget,
          reason: category);
      expect(
          find.descendant(
              of: legendRow(category), matching: find.text(percent)),
          findsOneWidget,
          reason: category);
    }

    expectRow('Meals', '600 kcal', '60 %');
    expectRow('Gym food', '300 kcal', '30 %');
    expectRow('Fruits & vegetables', '100 kcal', '10 %');
    expectRow('Drinks', '0 kcal', '0 %');
  });

  testWidgets('one category is a sentence, not a pie', (tester) async {
    await openFoodPage(tester, {
      'foods': '[${foodJson('a', 'Apple', 'Fruits & vegetables')}]',
      'food_log': '[${entryJson('1', 'a', 100)},${entryJson('2', 'a', 50)}]',
    });
    expect(find.text('All calories this day are from Fruits & vegetables.'),
        findsOneWidget);
  });

  testWidgets('more than six categories: the smallest are combined',
      (tester) async {
    final cats = ['Meals', 'Drinks', 'Dairy & eggs', 'Bread & grains',
        'Snacks & sweets', 'Meat & fish', 'Other'];
    await openFoodPage(tester, {
      'foods': '[${[
        for (final (i, c) in cats.indexed) foodJson('f$i', 'Food $i', c)
      ].join(',')}]',
      'food_log': '[${[
        for (var i = 0; i < cats.length; i++)
          entryJson('$i', 'f$i', 700.0 - i * 100)
      ].join(',')}]',
    });
    // The two smallest (Meat & fish 200, Other 100) are combined.
    expect(find.text('Smaller categories'), findsOneWidget);
    expect(find.text('300 kcal'), findsWidgets);
    expect(find.text('Meat & fish'), findsNothing);
  });

  testWidgets('a created category can be removed in the edit screen',
      (tester) async {
    await openFoodPage(tester, {
      'foods': '[${foodJson('a', 'Protein bar', 'Gym food')},'
          '${foodJson('b', 'Shake', 'Gym food')}]',
    });
    await tester.tap(find.byTooltip('My foods'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Protein bar'));
    await tester.pumpAndSettle();

    // Built-in categories can't be removed; the user's own can.
    expect(find.byTooltip('Remove category'), findsOneWidget);
    expect(
        find.descendant(
            of: find.widgetWithText(InputChip, 'Gym food'),
            matching: find.byTooltip('Remove category')),
        findsOneWidget);

    await tester.tap(find.byTooltip('Remove category'));
    await tester.pumpAndSettle();
    expect(find.text('2 foods will be moved to Other.'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Remove category'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InputChip, 'Gym food'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Other'), findsOneWidget);

    // Saving this food must not bring the category back for the other one.
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    final foods = await FoodStorage().loadFoods();
    expect(foods.map((f) => f.category), ['Other', 'Other']);
    expect(find.widgetWithText(ChoiceChip, 'Gym food'), findsNothing);
  });

  testWidgets('save button can be scrolled above the navigation bar',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    // Android's three-button navigation bar, drawn over the app.
    tester.view.padding = const FakeViewPadding(bottom: 48);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'user_profile': '{"heightCm":180}',
      'foods': '[${foodJson('a', 'Apple', 'Fruits & vegetables')}]',
    });
    await tester.pumpWidget(const CalorieApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('My foods'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();

    // Scroll to the very end.
    await tester.drag(
        find.descendant(of: find.byType(Form), matching: find.byType(ListView)),
        const Offset(0, -3000));
    await tester.pumpAndSettle();

    final button = tester.getRect(find.widgetWithText(FilledButton, 'Save food'));
    expect(button.bottom, lessThanOrEqualTo(800 - 48));
  });

  testWidgets('a created category can be removed from My foods',
      (tester) async {
    await openFoodPage(tester, {
      'foods': '[${foodJson('a', 'Protein bar', 'Gym food')},'
          '${foodJson('b', 'Apple', 'Fruits & vegetables')}]',
    });
    await tester.tap(find.byTooltip('My foods'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ChoiceChip, 'Gym food'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manage categories'));
    await tester.pumpAndSettle();

    // Only the user's own category is listed.
    expect(find.widgetWithText(ListTile, 'Gym food'), findsOneWidget);
    expect(find.text('1 food'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Fruits & vegetables'), findsNothing);

    await tester.tap(find.byTooltip('Remove category'));
    await tester.pumpAndSettle();
    expect(find.text('1 food will be moved to Other.'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Remove category'));
    await tester.pumpAndSettle();
    expect(find.textContaining("haven't created any categories"),
        findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ChoiceChip, 'Gym food'), findsNothing);
    expect(find.textContaining('Other · 100 kcal'), findsOneWidget);
  });
}
