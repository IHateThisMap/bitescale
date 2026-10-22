// Renders the food page's calorie card in its three states to PNG files.
//   flutter test tool/preview/deficit_preview_test.dart --update-goldens

// This is run with `flutter test`, but lives outside test/ so the normal
// test run skips it; test-only helpers are fine here.
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calorie_couinter_exercise_app/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> loadFonts() async {
  for (final (family, file) in [
    ('Roboto', 'segoeui.ttf'),
    ('MaterialIcons', null),
  ]) {
    if (file == null) continue;
    final bytes = File('C:/Windows/Fonts/$file').readAsBytesSync();
    await (FontLoader(family)..addFont(Future.value(ByteData.view(bytes.buffer))))
        .load();
  }
  // Real icons instead of boxes.
  final icons = File(
          '${Platform.environment['FLUTTER_ROOT'] ?? 'C:/Flutter/SDK/flutter'}'
          '/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf')
      .readAsBytesSync();
  await (FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.view(icons.buffer))))
      .load();
}

void main() {
  for (final (name, kcal) in [
    ('green', 2000.0),
    ('yellow', 2600.0),
    ('red', 12900.0),
  ]) {
    testWidgets('deficit card $name', (tester) async {
      await loadFonts();
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final goalDate = DateTime.now().add(const Duration(days: 100));
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode({
          'heightCm': 180,
          'sex': 'male',
          'birthYear': DateTime.now().year - 30,
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
            'nutrients': {'kcal': kcal},
          }
        ]),
      });
      await tester.pumpWidget(const CalorieApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      await expectLater(
          find.byType(Card).first, matchesGoldenFile('deficit_$name.png'));
    });
  }
}
