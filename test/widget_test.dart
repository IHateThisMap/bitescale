import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_calorie_couinter_exercise_app/l10n/app_localizations.dart';
import 'package:flutter_calorie_couinter_exercise_app/main.dart';
import 'package:flutter_calorie_couinter_exercise_app/models/food.dart';
import 'package:flutter_calorie_couinter_exercise_app/models/user_profile.dart';
import 'package:flutter_calorie_couinter_exercise_app/models/weight_entry.dart';
import 'package:flutter_calorie_couinter_exercise_app/utils/body_metrics.dart';
import 'package:flutter_calorie_couinter_exercise_app/utils/calorie_target.dart';
import 'package:flutter_calorie_couinter_exercise_app/utils/trend.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The food form is long; make the whole form fit so every field is built.
void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  test('trend line fits a steady weight loss', () {
    final start = DateTime(2026, 1, 1);
    final entries = [
      for (var i = 0; i < 5; i++)
        WeightEntry(
            date: start.add(Duration(days: i * 7)), weightKg: 90 - i * 0.5),
    ];
    final trend = calculateTrend(entries)!;
    expect(trend.kgPerWeek, closeTo(-0.5, 1e-9));
    expect(trend.weightAt(0), closeTo(90, 1e-9));
    expect(trend.dailyCalorieBalance, closeTo(-550, 1e-6));
  });

  test('no trend with fewer than two entries', () {
    expect(calculateTrend([]), isNull);
    expect(
        calculateTrend([WeightEntry(date: DateTime(2026), weightKg: 80)]),
        isNull);
  });

  test('BMI', () {
    expect(calculateBmi(80, 180), closeTo(24.69, 0.01));
    expect(bmiCategory(24.69), BmiCategory.normal);
    expect(bmiCategory(31), BmiCategory.obese);
  });

  test('U.S. Navy body fat', () {
    // Reference values from the published Navy formula (metric).
    final male = navyBodyFat(
        sex: Sex.male, heightCm: 180, neckCm: 38, waistCm: 90)!;
    expect(male, closeTo(19.8, 0.05));
    expect(bodyFatCategory(Sex.male, male), BodyFatCategory.average);

    final female = navyBodyFat(
        sex: Sex.female, heightCm: 165, neckCm: 32, waistCm: 75, hipCm: 100)!;
    expect(female, closeTo(29.9, 0.05));
    expect(bodyFatCategory(Sex.female, female), BodyFatCategory.average);

    // Waist smaller than neck can't be valid.
    expect(navyBodyFat(sex: Sex.male, heightCm: 180, neckCm: 40, waistCm: 35),
        isNull);
    // Women need a hip measurement.
    expect(navyBodyFat(sex: Sex.female, heightCm: 165, neckCm: 32, waistCm: 75),
        isNull);
  });

  testWidgets('tape measure method replaces BMI', (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_profile': '{"heightCm":180}',
      'weight_entries': '[{"date":"2026-10-01T08:00:00.000","weightKg":80}]',
    });
    await tester.pumpWidget(const CalorieApp());
    await tester.pumpAndSettle();
    expect(find.text('BMI'), findsOneWidget);

    await tester.tap(find.text('BMI'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tape measure'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Male'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Neck'), '38');
    await tester.enterText(find.widgetWithText(TextField, 'Waist'), '90');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('BMI'), findsNothing);
    expect(find.text('Body fat'), findsOneWidget);
    expect(find.text('19.8 %'), findsOneWidget);
    expect(find.textContaining('15.8 kg fat · 64.2 kg lean'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('user_profile'), contains('navyBodyFat'));
  });

  test('goal plan gives the daily deficit needed', () {
    final plan = GoalPlan(
      currentKg: 85,
      goalKg: 80,
      goalDate: DateTime(2026, 3, 11),
      today: DateTime(2026, 1, 1, 18, 30),
    );
    expect(plan.daysLeft, 69);
    // 5 kg * 7700 kcal / 69 days
    expect(plan.dailyDeficit, closeTo(557.97, 0.01));
  });

  group('daily calorie target', () {
    final today = DateTime(2026, 1, 1);
    const base = UserProfile(
      heightCm: 180,
      sex: Sex.male,
      birthYear: 1996, // 30 years old
      activityLevel: ActivityLevel.moderate,
    );

    test('maintenance without a goal', () {
      final t = calculateCalorieTarget(base, 80, today: today)!;
      // Mifflin-St Jeor: 10*80 + 6.25*180 - 5*30 + 5 = 1780
      expect(t.bmr, 1780);
      expect(t.maintenance, closeTo(2759, 0.01));
      expect(t.target, closeTo(2759, 0.01));
      expect(t.plan, isNull);
    });

    test('subtracts the goal deficit', () {
      // 100 days later; crosses the spring daylight saving change.
      final p = base.withGoal(75, DateTime(2026, 4, 11));
      final t = calculateCalorieTarget(p, 80, today: today)!;
      // 5 kg * 7700 / 100 days = 385 kcal deficit
      expect(t.target, closeTo(2759 - 385, 0.01));
      expect(t.limitedToMinimum, isFalse);
    });

    test('never goes below the safe minimum', () {
      final p = base.withGoal(60, DateTime(2026, 1, 31));
      final t = calculateCalorieTarget(p, 80, today: today)!;
      expect(t.target, 1500);
      expect(t.limitedToMinimum, isTrue);
    });

    test('uses body fat when tape measurements exist', () {
      final p = base.copyWith(neckCm: 38, waistCm: 90);
      final t = calculateCalorieTarget(p, 80, today: today)!;
      expect(t.usesBodyFat, isTrue);
      // Katch-McArdle: 370 + 21.6 * lean mass (80 kg at 19.81 % fat)
      expect(t.bmr, closeTo(370 + 21.6 * 80 * (1 - 0.19812), 0.1));
    });

    test('needs sex, age, activity and weight', () {
      expect(calculateCalorieTarget(base, null, today: today), isNull);
      expect(
          missingForCalorieTarget(const UserProfile(heightCm: 180), 80),
          ['sex', 'age', 'activity level']);
    });
  });

  testWidgets('food page shows target, eaten and remaining calories',
      (tester) async {
    final age30 = DateTime.now().year - 30;
    SharedPreferences.setMockInitialValues({
      'user_profile': '{"heightCm":180,"sex":"male","birthYear":$age30,'
          '"activityLevel":"moderate"}',
      'weight_entries': '[{"date":"2026-10-01T08:00:00.000","weightKg":80}]',
      'food_log': '[{"id":"1","date":"${DateTime.now().toIso8601String()}",'
          '"foodId":"f","foodName":"Pizza","amount":300,"unit":"g",'
          '"nutrients":{"kcal":759}}]',
    });
    await tester.pumpWidget(const CalorieApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();

    expect(find.text('Daily target: 2759 kcal'), findsOneWidget);
    expect(find.text('Left to eat'), findsOneWidget);
    expect(find.text('2000 kcal'), findsOneWidget);
    expect(find.textContaining('keep your current weight: 2759'),
        findsOneWidget);
  });

  testWidgets('food page asks for missing calorie info', (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_profile': '{"heightCm":180}',
      'weight_entries': '[{"date":"2026-10-01T08:00:00.000","weightKg":80}]',
    });
    await tester.pumpWidget(const CalorieApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Set up daily calorie target'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Male'));
    await tester.enterText(find.byType(TextField),
        '${DateTime.now().year - 30}');
    await tester.tap(find.text('Moderately active'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Daily target: 2759 kcal'), findsOneWidget);
  });

  testWidgets('portion size is saved and offered when logging',
      (tester) async {
    useTallScreen(tester);
    SharedPreferences.setMockInitialValues({
      'user_profile': '{"heightCm":180}',
    });
    await tester.pumpWidget(const CalorieApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New food'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Name *'), 'Rye bread');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Portion / piece size'), '30');
    await tester.enterText(find.widgetWithText(TextFormField, 'Called'), 'slice');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Calories *'), '250');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    // Amount dialog starts at one portion.
    final portions = find.widgetWithText(TextField, 'Number of portions');
    final grams = find.widgetWithText(TextField, 'Weight');
    expect(find.text('75 kcal'), findsOneWidget);
    expect(tester.widget<TextField>(portions).controller!.text, '1');
    expect(tester.widget<TextField>(grams).controller!.text, '30');

    // Any number of portions fills in the grams...
    await tester.enterText(portions, '12');
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(grams).controller!.text, '360');
    expect(find.text('900 kcal'), findsOneWidget);

    // ...and grams update the number of portions.
    await tester.enterText(grams, '45');
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(portions).controller!.text, '1.5');
    expect(find.text('113 kcal'), findsOneWidget);

    await tester.enterText(portions, '2');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Rye bread'), findsWidgets);
    expect(find.text('60 g · ${DateFormat.Hm().format(DateTime.now())}'),
        findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('foods'), contains('"portionSize":30.0'));
    expect(prefs.getString('foods'), contains('"portionName":"slice"'));
  });

  group('Finnish', () {
    testWidgets('app can be switched to Finnish and remembers it',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'user_profile': '{"heightCm":180}',
        'weight_entries': '[{"date":"2026-10-01T08:00:00.000","weightKg":72.5}]',
      });
      await tester.pumpWidget(const CalorieApp());
      await tester.pumpAndSettle();
      expect(find.text('Add weight'), findsOneWidget);

      await tester.tap(find.byTooltip('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Suomi'));
      await tester.pumpAndSettle();

      expect(find.text('Lisää paino'), findsOneWidget);
      expect(find.text('Ruoka'), findsOneWidget);
      // Decimal comma in Finnish.
      expect(find.text('72,5 kg'), findsWidgets);
      expect(find.text('22,4'), findsOneWidget); // BMI
      expect(find.text('Normaali paino'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('language'), 'fi');

      // Back to following the phone's language.
      await tester.tap(find.byTooltip('Kieli'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Järjestelmän oletus'));
      await tester.pumpAndSettle();
      expect(find.text('Add weight'), findsOneWidget);
      expect(prefs.getString('language'), isNull);
    });

    testWidgets('first start asks height in Finnish', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const CalorieApp(initialLanguage: 'fi'));
      await tester.pumpAndSettle();
      expect(find.text('Tervetuloa!'), findsOneWidget);
      expect(find.text('Jatka'), findsOneWidget);
    });

    testWidgets('built-in categories are shown translated but saved as is',
        (tester) async {
      useTallScreen(tester);
      SharedPreferences.setMockInitialValues({
        'user_profile': '{"heightCm":180}',
        'foods': '[{"id":"1","name":"Omena","category":"Fruits & vegetables",'
            '"unit":"g","per100":{"kcal":52}}]',
      });
      await tester.pumpWidget(const CalorieApp(initialLanguage: 'fi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ruoka'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Omat ruoat'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ChoiceChip, 'Hedelmät ja vihannekset'),
          findsOneWidget);

      // Open and re-save the food; the category stays in its saved form.
      await tester.tap(find.text('Omena'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, 'Hedelmät ja vihannekset'),
          findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Tallenna'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('foods'),
          contains('"category":"Fruits & vegetables"'));
    });

    test('every language has every text', () {
      // A text missing from a translation would quietly show in English;
      // compare each app_xx.arb against the English one.
      Set<String> keys(File f) =>
          (jsonDecode(f.readAsStringSync()) as Map<String, dynamic>)
              .keys
              .where((k) => !k.startsWith('@'))
              .toSet();
      final english = keys(File('lib/l10n/app_en.arb'));
      final arbs = Directory('lib/l10n')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.arb'));
      expect(arbs.length, AppLocalizations.supportedLocales.length);
      for (final arb in arbs) {
        final k = keys(arb);
        expect(english.difference(k), isEmpty,
            reason: 'Missing from ${arb.path}');
        expect(k.difference(english), isEmpty,
            reason: 'Not in app_en.arb, but in ${arb.path}');
      }
    });
  });

  testWidgets('amount dialog fits a small screen with the keyboard open',
      (tester) async {
    // A small phone (360 x 640) with the keyboard covering ~300 px. The
    // dialog used to overflow ("BOTTOM OVERFLOWED BY 26 PIXELS") here;
    // an overflow fails the test.
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'user_profile': '{"heightCm":180}',
      'foods': '[{"id":"1","name":"Rye bread","category":"Bread & grains",'
          '"unit":"g","per100":{"kcal":250},"portionSize":30,'
          '"portionName":"slice","favourite":true}]',
    });
    await tester.pumpWidget(const CalorieApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ActionChip, 'Rye bread'));
    await tester.pumpAndSettle();
    // The keyboard opens for the focused field.
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Number of portions'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('food nutrients scale with amount', () {
    const food = Food(
      id: '1',
      name: 'Oats',
      category: 'Bread & grains',
      unit: 'g',
      per100: Nutrients(kcal: 380, protein: 13),
    );
    final n = food.nutrientsFor(50);
    expect(n.kcal, 190);
    expect(n.protein, 6.5);
    expect(n.fat, isNull);
  });

  testWidgets('asks height on first start, then shows weight page',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CalorieApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome!'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '180');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No entries yet'), findsOneWidget);

    await tester.tap(find.text('Add weight'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '81');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('81.0 kg'), findsWidgets);
    expect(find.text('25.0'), findsOneWidget); // BMI
  });

  testWidgets('a new food is saved and logged', (tester) async {
    useTallScreen(tester);
    SharedPreferences.setMockInitialValues({
      'user_profile': '{"heightCm":180}',
    });
    await tester.pumpWidget(const CalorieApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add food'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New food'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Name *'), 'Banana');
    await tester.tap(find.text('Fruits & vegetables'));
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Calories *'), '89');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    // Amount dialog: 120 g of banana.
    await tester.enterText(find.byType(TextField).last, '120');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('107 kcal'), findsWidgets);
    // No favourites yet, so no favourites list.
    expect(find.text('Favourites'), findsNothing);
    expect(find.byType(ActionChip), findsNothing);
  });

  testWidgets('starred foods show up as favourites', (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_profile': '{"heightCm":180}',
      'foods': '[{"id":"1","name":"Banana","category":"Other","unit":"g",'
          '"per100":{"kcal":89},"portionSize":120},'
          '{"id":"2","name":"Oats","category":"Other","unit":"g",'
          '"per100":{"kcal":380}}]',
    });
    await tester.pumpWidget(const CalorieApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    expect(find.text('Favourites'), findsNothing);

    // Star Banana in the "Add food" list.
    await tester.tap(find.text('Add food'));
    await tester.pumpAndSettle();
    final bananaStar = find.descendant(
      of: find.widgetWithText(ListTile, 'Banana'),
      matching: find.byTooltip('Add to favourites'),
    );
    await tester.tap(bananaStar);
    await tester.pumpAndSettle();
    expect(
        find.descendant(
            of: find.widgetWithText(ListTile, 'Banana'),
            matching: find.byTooltip('Remove from favourites')),
        findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Favourites'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Banana'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Oats'), findsNothing);

    // A favourite is logged in two taps.
    await tester.tap(find.widgetWithText(ActionChip, 'Banana'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('107 kcal'), findsWidgets);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('foods'), contains('"favourite":true'));
  });

  testWidgets('an eaten food can be edited', (tester) async {
    SharedPreferences.setMockInitialValues({
      'user_profile': '{"heightCm":180}',
      'foods': '[{"id":"f","name":"Pizza","category":"Meals","unit":"g",'
          '"per100":{"kcal":300},"portionSize":100,"portionName":"slice"}]',
      // Logged at 253 kcal / 100 g, before the saved food was changed.
      'food_log': '[{"id":"1","date":"${DateTime.now().toIso8601String()}",'
          '"foodId":"f","foodName":"Pizza","amount":300,"unit":"g",'
          '"nutrients":{"kcal":759,"protein":30}}]',
    });
    await tester.pumpWidget(const CalorieApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    expect(find.text('759 kcal'), findsWidgets);

    await tester.tap(find.text('Pizza'));
    await tester.pumpAndSettle();
    // Starts at the eaten amount, shown in portions too.
    final grams = find.widgetWithText(TextField, 'Weight');
    expect(tester.widget<TextField>(grams).controller!.text, '300');
    expect(
        tester
            .widget<TextField>(
                find.widgetWithText(TextField, 'Number of portions'))
            .controller!
            .text,
        '3');

    await tester.enterText(grams, '200');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Uses the nutrition it was logged with (253 kcal / 100 g).
    expect(find.text('506 kcal'), findsWidgets);
    expect(find.textContaining('200 g'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final log = prefs.getString('food_log')!;
    expect(log, contains('"amount":200.0'));
    expect(log, contains('"protein":20.0'));
  });

  testWidgets('language button shows the current language flag',
      (tester) async {
    SharedPreferences.setMockInitialValues({'user_profile': '{"heightCm":180}'});
    await tester.pumpWidget(const CalorieApp(initialLanguage: 'fi'));
    await tester.pumpAndSettle();
    expect(
        find.descendant(
            of: find.byTooltip('Kieli'), matching: find.text('🇫🇮')),
        findsOneWidget);

    await tester.tap(find.byTooltip('Kieli'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(
        find.descendant(
            of: find.byTooltip('Language'), matching: find.text('🇬🇧')),
        findsOneWidget);
  });
}
