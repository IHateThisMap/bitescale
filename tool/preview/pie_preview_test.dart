// Renders the category pie chart to PNG files for a visual check.
//   flutter test tool/preview/pie_preview_test.dart --update-goldens

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calorie_couinter_exercise_app/l10n/app_localizations.dart';
import 'package:flutter_calorie_couinter_exercise_app/widgets/category_pie_chart.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> loadFont() async {
  final bytes = File('C:/Windows/Fonts/segoeui.ttf').readAsBytesSync();
  final loader = FontLoader('Preview')
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('pie preview ${brightness.name}', (tester) async {
      await loadFont();
      tester.view.physicalSize = const Size(400, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: ThemeData(
          fontFamily: 'Preview',
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal, brightness: brightness),
        ),
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: CategoryPieChart(kcalByCategory: {
                'Meals': 620,
                'Bread & grains': 310,
                'Fruits & vegetables': 180,
                'Snacks & sweets': 240,
                'Dairy & eggs': 150,
                'Gym food': 90,
                'Drinks': 60,
              }),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await expectLater(
          find.byType(Scaffold), matchesGoldenFile('pie_${brightness.name}.png'));
    });
  }
}
