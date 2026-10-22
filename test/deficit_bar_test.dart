import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_calorie_couinter_exercise_app/main.dart';
import 'package:flutter_calorie_couinter_exercise_app/utils/calorie_target.dart';
import 'package:flutter_calorie_couinter_exercise_app/widgets/deficit_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('intake status', () {
    IntakeStatus s(double eaten, {double target = 2000}) =>
        intakeStatus(eaten: eaten, target: target, maintenance: 2500);

    test('losing weight: green, yellow, then red at maintenance', () {
      expect(s(0), IntakeStatus.withinGoal);
      expect(s(2000), IntakeStatus.withinGoal);
      expect(s(2040), IntakeStatus.withinGoal); // a little over is "at" goal
      expect(s(2100), IntakeStatus.overGoal);
      expect(s(2499), IntakeStatus.overGoal);
      expect(s(2500), IntakeStatus.noDeficit);
      expect(s(3000), IntakeStatus.noDeficit);
    });

    test('a target just under maintenance turns red at maintenance', () {
      // The goal margin must not hide that the deficit is gone.
      expect(s(2480, target: 2470), IntakeStatus.withinGoal);
      expect(s(2510, target: 2470), IntakeStatus.noDeficit);
    });

    test('maintaining: red once clearly over', () {
      expect(s(2540, target: 2500), IntakeStatus.withinGoal);
      expect(s(2600, target: 2500), IntakeStatus.noDeficit);
    });

    test('gaining weight: never red, yellow when over the goal', () {
      expect(s(2800, target: 3000), IntakeStatus.withinGoal);
      expect(s(3200, target: 3000), IntakeStatus.overGoal);
    });
  });

  group('food page', () {
    final age30 = DateTime.now().year - 30;
    // 30-year-old man, 80 kg, 180 cm, moderately active: maintenance 2759.
    // Goal 75 kg in 100 days: 385 kcal deficit, target 2374.
    Future<void> open(WidgetTester tester, double eatenKcal) async {
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final goalDate = DateTime.now().add(const Duration(days: 100));
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode({
          'heightCm': 180,
          'sex': 'male',
          'birthYear': age30,
          'activityLevel': 'moderate',
          'goalWeightKg': 75,
          'goalDate': DateTime(goalDate.year, goalDate.month, goalDate.day)
              .toIso8601String(),
        }),
        'weight_entries': '[{"date":"2026-10-01T08:00:00.000","weightKg":80}]',
        'food_log': jsonEncode([
          {
            'id': '1',
            'date': DateTime.now().toIso8601String(),
            'foodId': 'f',
            'foodName': 'Food',
            'amount': 100,
            'unit': 'g',
            'nutrients': {'kcal': eatenKcal},
          }
        ]),
      });
      await tester.pumpWidget(const CalorieApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
    }

    IntakeStatus barStatus(WidgetTester tester) =>
        tester.widget<DeficitBar>(find.byType(DeficitBar)).status;

    testWidgets('under the goal: green, goal and deficit end marked',
        (tester) async {
      await open(tester, 2000);
      expect(find.text('Daily target: 2374 kcal'), findsOneWidget);
      expect(find.text('Goal 2374'), findsOneWidget);
      expect(find.text('Deficit ends 2759'), findsOneWidget);
      expect(barStatus(tester), IntakeStatus.withinGoal);
      expect(find.text('Within your goal and in calorie deficit.'),
          findsOneWidget);
      expect(find.text('Left to eat'), findsOneWidget);
      expect(find.text('374 kcal'), findsOneWidget);
      expect(find.text('Deficit left'), findsOneWidget);
      expect(find.text('759 kcal'), findsOneWidget);
    });

    testWidgets('over the goal but in deficit: yellow', (tester) async {
      await open(tester, 2600);
      expect(barStatus(tester), IntakeStatus.overGoal);
      expect(find.text('Over your goal, but still in calorie deficit.'),
          findsOneWidget);
      expect(find.text('Over target'), findsOneWidget);
      expect(find.text('226 kcal'), findsOneWidget);
      expect(find.text('159 kcal'), findsOneWidget); // deficit left
    });

    testWidgets('past maintenance: red', (tester) async {
      await open(tester, 2900);
      expect(barStatus(tester), IntakeStatus.noDeficit);
      expect(find.textContaining('No calorie deficit left'), findsOneWidget);
      expect(find.text('Over maintenance'), findsOneWidget);
      expect(find.text('141 kcal'), findsOneWidget);
    });
  });
}
