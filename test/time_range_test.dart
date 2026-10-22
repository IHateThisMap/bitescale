import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_calorie_couinter_exercise_app/main.dart';
import 'package:flutter_calorie_couinter_exercise_app/utils/time_range.dart';
import 'package:flutter_calorie_couinter_exercise_app/widgets/weight_chart.dart';

/// Days at evenly spaced slider positions.
List<int> sample(TimeRangeScale s, [int steps = 200]) =>
    [for (var i = 0; i <= steps; i++) s.daysAt(i / steps)];

void main() {
  group('time range scale', () {
    test('short history: 4 days to 1 month, no markers between', () {
      final s = TimeRangeScale(10);
      expect(s.markDays, [4, 30]);
      expect(s.daysAt(0), 4);
      expect(s.daysAt(1), 30);
    });

    test('two years: markers equally spaced, 2 years at the end', () {
      final s = TimeRangeScale(730);
      expect(s.markDays, [4, 30, 182, 730]);
      expect(s.markPositions[1], closeTo(1 / 3, 1e-9));
      expect(s.markPositions[2], closeTo(2 / 3, 1e-9));
      expect(s.daysAt(1 / 3), 30);
      expect(s.daysAt(2 / 3), 182);
      expect(s.daysAt(1), 730);
    });

    test('older history: the slider goes past 2 years to all of it', () {
      final s = TimeRangeScale(1000);
      expect(s.markDays, [4, 30, 182, 730, 1000]);
      expect(s.daysAt(1), 1000);
      // 1 month, 6 months and 2 years stay equally spaced.
      expect(s.markPositions[2], closeTo(2 * s.markPositions[1], 1e-9));
      expect(s.markPositions[3], closeTo(3 * s.markPositions[1], 1e-9));
      expect(TimeRangeScale(5000).maxDays, 5000);
    });

    test('markers only for what the history reaches', () {
      expect(TimeRangeScale(100).markDays, [4, 30, 100]);
      expect(TimeRangeScale(200).markDays, [4, 30, 182, 200]);
      expect(TimeRangeScale(400).markDays, [4, 30, 182, 400]);
      expect(TimeRangeScale(30).markDays, [4, 30]);
    });

    test('1 month and 6 months markers stay equally spaced', () {
      final s = TimeRangeScale(200);
      // 4 d → 1 mo and 1 mo → 6 mo take equal room.
      expect(s.markPositions[1], closeTo(s.markPositions[2] / 2, 1e-9));
    });

    for (final history in [
      2, 20, 31, 40, 100, 181, 183, 200, 300, 365, 729, 731, 800, 900, 1500,
      5000,
    ]) {
      test('expands faster and faster (history $history days)', () {
        final days = sample(TimeRangeScale(history));
        final steps = [
          for (var i = 1; i < days.length; i++) days[i] - days[i - 1]
        ];
        expect(steps.every((d) => d >= 0), isTrue, reason: 'never shrinks');
        // Speed over each twentieth of the slider never decreases
        // (allowing 1 day for rounding to whole days). Small windows, so a
        // slowdown right after a marker can't hide in an average.
        final windows = [
          for (var w = 0; w < 20; w++)
            steps.sublist(w * 10, w * 10 + 10).reduce((a, b) => a + b)
        ];
        for (var i = 1; i < windows.length; i++) {
          expect(windows[i], greaterThanOrEqualTo(windows[i - 1] - 1),
              reason: 'days per window: $windows');
        }
      });
    }

    test('a 7 day mark sits in the first section, scale unchanged', () {
      final s = TimeRangeScale(730);
      final week = s.marks.firstWhere((m) => m.$1 == 7).$2;
      expect(s.daysAt(week), 7);
      expect(week, greaterThan(0));
      expect(week, lessThan(s.markPositions[1]));
      // The main marks are still equally spaced.
      expect(s.markPositions[1], closeTo(1 / 3, 1e-9));
      expect(s.marks.map((m) => m.$1), [4, 7, 30, 182, 730]);
      expect(TimeRangeScale(10).marks.map((m) => m.$1), [4, 7, 30]);
      // The slider snaps to it too.
      expect(s.snap(week + 0.01), week);
    });

    for (final history in [10, 100, 200, 900, 3000]) {
      test('positionOf reverses daysAt (history $history days)', () {
        final s = TimeRangeScale(history);
        for (var d = minRangeDays; d <= s.maxDays; d++) {
          expect(s.daysAt(s.positionOf(d)), d, reason: '$d days');
        }
        expect(s.positionOf(99999), 1);
      });
    }

    test('values close to a marker snap onto it', () {
      final s = TimeRangeScale(730);
      expect(s.snap(0.34), s.markPositions[1]);
      expect(s.snap(0.5), 0.5);
    });
  });

  group('weight page', () {
    Future<void> open(WidgetTester tester, List<int> daysAgo) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final now = DateTime.now();
      SharedPreferences.setMockInitialValues({
        'user_profile': '{"heightCm":180}',
        'weight_entries': jsonEncode([
          for (final (i, d) in daysAgo.indexed)
            {
              'date': now.subtract(Duration(days: d)).toIso8601String(),
              'weightKg': 90 - i,
            }
        ]),
      });
      await tester.pumpWidget(const CalorieApp());
      await tester.pumpAndSettle();
    }

    int chartDays(WidgetTester tester) =>
        tester.widget<WeightChart>(find.byType(WeightChart)).rangeDays;

    testWidgets('slider with month and 6 month marks; past is to the left',
        (tester) async {
      await open(tester, [1500, 400, 200, 100, 20, 2]);

      // Starts at the longest range: all of the history.
      expect(find.text('Last 1501 days'), findsOneWidget);
      expect(chartDays(tester), 1501);
      for (final mark in ['4.1 yr', '2 yr', '6 mo', '1 mo', '7 d']) {
        expect(find.text(mark), findsOneWidget);
      }
      expect(find.text('1 yr'), findsNothing);
      // The shortest end isn't labelled.
      expect(find.text('4 d'), findsNothing);
      // Like a timeline: longer ranges on the left.
      final x = {
        for (final m in ['4.1 yr', '2 yr', '6 mo', '1 mo', '7 d'])
          m: tester.getCenter(find.text(m)).dx
      };
      expect(x['4.1 yr']! < x['2 yr']!, isTrue);
      expect(x['2 yr']! < x['6 mo']!, isTrue);
      expect(x['6 mo']! < x['1 mo']!, isTrue);
      expect(x['1 mo']! < x['7 d']!, isTrue);

      // Drag all the way right: 4 days.
      await tester.drag(find.byType(Slider), const Offset(1000, 0));
      await tester.pumpAndSettle();
      expect(find.text('Last 4 days'), findsOneWidget);
      expect(chartDays(tester), 4);
    });

    testWidgets('+ and - change the range by one day', (tester) async {
      await open(tester, [400, 2]);
      final prefs = await SharedPreferences.getInstance();
      final more = find.byTooltip('One day more');
      final less = find.byTooltip('One day less');

      // At the longest range, + is disabled.
      expect(chartDays(tester), 401);
      expect(tester.widget<IconButton>(find.ancestor(
          of: find.byIcon(Icons.add), matching: find.byType(IconButton)))
          .onPressed, isNull);

      await tester.tap(less);
      await tester.pumpAndSettle();
      expect(find.text('Last 400 days'), findsOneWidget);
      expect(chartDays(tester), 400);
      expect(prefs.getInt('weight_graph_range_days'), 400);

      for (final button in [less, less, more]) {
        await tester.tap(button);
        await tester.pumpAndSettle();
      }
      expect(find.text('Last 399 days'), findsOneWidget);

      // Precise steps in the fine end too, down to the 4 day minimum.
      await tester.drag(find.byType(Slider), const Offset(1000, 0));
      await tester.pumpAndSettle();
      expect(find.text('Last 4 days'), findsOneWidget);
      expect(tester.widget<IconButton>(find.ancestor(
          of: find.byIcon(Icons.remove), matching: find.byType(IconButton)))
          .onPressed, isNull);
      for (var i = 0; i < 3; i++) {
        await tester.tap(more);
        await tester.pumpAndSettle();
      }
      expect(find.text('Last 7 days'), findsOneWidget);
      expect(prefs.getInt('weight_graph_range_days'), 7);
    });

    testWidgets('the chosen range is remembered after a restart',
        (tester) async {
      await open(tester, [400, 200, 100, 20, 2]);
      // Tap the middle of the slider.
      await tester.tap(find.byType(Slider));
      await tester.pumpAndSettle();
      final chosen = chartDays(tester);
      expect(chosen, inExclusiveRange(30, 365));

      // "Restart": a fresh app reading the saved settings.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(const CalorieApp());
      await tester.pumpAndSettle();
      expect(chartDays(tester), chosen);
      expect(find.text('Last $chosen days'), findsOneWidget);
    });

    testWidgets('the longest range follows a growing history',
        (tester) async {
      // Left at the longest range (the default), it's saved as "longest",
      // not as a number of days.
      await open(tester, [100, 2]);
      expect(chartDays(tester), 101);
      final prefs = await SharedPreferences.getInstance();

      // A shorter range is saved as days...
      await tester.drag(find.byType(Slider), const Offset(200, 0));
      await tester.pumpAndSettle();
      expect(prefs.getInt('weight_graph_range_days'), chartDays(tester));

      // ...and going back to the far end saves "longest".
      await tester.drag(find.byType(Slider), const Offset(-1000, 0));
      await tester.pumpAndSettle();
      expect(chartDays(tester), 101);
      expect(prefs.getInt('weight_graph_range_days'), isNull);
    });

    testWidgets('short history: 1 month max, no extra marks', (tester) async {
      await open(tester, [10, 3]);
      expect(find.text('Last 30 days'), findsOneWidget);
      expect(find.text('1 mo'), findsOneWidget);
      expect(find.text('6 mo'), findsNothing);
      expect(find.text('1 yr'), findsNothing);
    });

    testWidgets('no weights in the range: says so', (tester) async {
      await open(tester, [20]);
      await tester.drag(find.byType(Slider), const Offset(1000, 0));
      await tester.pumpAndSettle();
      expect(find.textContaining('No weights recorded in this period'),
          findsOneWidget);
    });
  });
}
