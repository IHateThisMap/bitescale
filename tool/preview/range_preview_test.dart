// Renders the weight graph and time range slider to PNG files.
//   flutter test tool/preview/range_preview_test.dart --update-goldens

// This is run with `flutter test`, but lives outside test/ so the normal
// test run skips it; test-only helpers are fine here.
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_calorie_couinter_exercise_app/main.dart';

Future<void> loadFonts() async {
  Future<void> load(String family, String path) async {
    final bytes = File(path).readAsBytesSync();
    await (FontLoader(family)..addFont(Future.value(ByteData.view(bytes.buffer))))
        .load();
  }

  await load('Roboto', 'C:/Windows/Fonts/segoeui.ttf');
  await load('MaterialIcons',
      'C:/Flutter/SDK/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
}

void main() {
  for (final history in [1500, 1000]) {
    testWidgets('range preview $history', (tester) async {
      await loadFonts();
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final now = DateTime.now();
      SharedPreferences.setMockInitialValues({
        'user_profile': '{"heightCm":180}',
        'weight_entries': jsonEncode([
          for (var d = history; d >= 0; d -= 9)
            {
              'date': now.subtract(Duration(days: d)).toIso8601String(),
              'weightKg': 80 + d / 40 + math.sin(d / 5),
            }
        ]),
      });
      await tester.pumpWidget(const CalorieApp());
      await tester.pumpAndSettle();
      await expectLater(find.byType(ListView).first,
          matchesGoldenFile('range_$history.png'));
    });
  }
}
