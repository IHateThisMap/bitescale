import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_calorie_couinter_exercise_app/main.dart';
import 'package:flutter_calorie_couinter_exercise_app/models/food.dart';
import 'package:flutter_calorie_couinter_exercise_app/services/food_storage.dart';
import 'package:flutter_calorie_couinter_exercise_app/services/food_transfer.dart';

/// Records what would be shared instead of opening the share menu.
class FakeSharePlatform extends SharePlatform {
  final shared = <ShareParams>[];
  ShareResultStatus answer = ShareResultStatus.success;

  @override
  Future<ShareResult> share(ShareParams params) async {
    shared.add(params);
    return ShareResult('app', answer);
  }
}

const foods = '[{"id":"a","name":"Banana","category":"Other","unit":"g",'
    '"per100":{"kcal":89}},{"id":"b","name":"Oats","category":"Other",'
    '"unit":"g","per100":{"kcal":380}},{"id":"c","name":"Pizza",'
    '"category":"Meals","unit":"g","per100":{"kcal":250}}]';

Future<void> openMyFoods(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(
      {'user_profile': '{"heightCm":180}', 'foods': foods});
  await tester.pumpWidget(const CalorieApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text('Food'));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('My foods'));
  await tester.pumpAndSettle();
}

/// The foods inside a shared file.
Future<List<String>> sharedNames(ShareParams params) async {
  final bytes = await params.files!.single.readAsBytes();
  return decodeFoods(bytes).map((t) => t.food.name).toList();
}

void main() {
  final fake = FakeSharePlatform();
  SharePlatform.instance = fake;
  setUp(fake.shared.clear);

  testWidgets('share chosen foods from My foods', (tester) async {
    await openMyFoods(tester);
    await tester.tap(find.byTooltip('Share foods'));
    await tester.pumpAndSettle();

    // All foods are chosen to start with.
    expect(find.text('Share 3 foods'), findsOneWidget);
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Oats'));
    await tester.pump();
    expect(find.text('Share 2 foods'), findsOneWidget);

    await tester.tap(find.text('Share 2 foods'));
    await tester.pumpAndSettle();

    final params = fake.shared.single;
    expect(await sharedNames(params), ['Banana', 'Pizza']);
    expect(params.text, contains('Open the attached file with BiteScale'));
    expect(params.fileNameOverrides!.single, endsWith('.json'));
    expect(params.files!.single.mimeType, 'application/json');
    // Done: back on My foods.
    expect(find.text('My foods'), findsOneWidget);
  });

  testWidgets('select none and all', (tester) async {
    await openMyFoods(tester);
    await tester.tap(find.byTooltip('Share foods'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select none'));
    await tester.pump();
    expect(find.text('Choose foods to share'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.ancestor(
                of: find.text('Choose foods to share'),
                matching: find.byWidgetPredicate((w) => w is FilledButton)))
            .onPressed,
        isNull);
    await tester.tap(find.text('Select all'));
    await tester.pump();
    expect(find.text('Share 3 foods'), findsOneWidget);
  });

  testWidgets('closing the share menu stays on the share screen',
      (tester) async {
    fake.answer = ShareResultStatus.dismissed;
    addTearDown(() => fake.answer = ShareResultStatus.success);
    await openMyFoods(tester);
    await tester.tap(find.byTooltip('Share foods'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Share 3 foods'));
    await tester.pumpAndSettle();
    expect(find.text('Share 3 foods'), findsOneWidget);
  });

  testWidgets('share a single food from its edit screen', (tester) async {
    await openMyFoods(tester);
    await tester.tap(find.text('Pizza'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Share this food'));
    await tester.pumpAndSettle();
    expect(await sharedNames(fake.shared.single), ['Pizza']);
    expect(fake.shared.single.text, contains('Here is a food'));
  });

  group('receiving on Android', () {
    const channel = MethodChannel('bitescale/incoming_file');

    Uint8List fileWith(List<Food> foods) =>
        utf8.encode(encodeFoods([for (final f in foods) TransferFood(f)]));

    const mango = Food(
        id: 'x',
        name: 'Mango',
        category: 'Fruits & vegetables',
        unit: 'g',
        per100: Nutrients(kcal: 60));

    Future<void> startOnAndroid(WidgetTester tester, Uint8List? initial) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        return call.method == 'takeInitialFile' ? initial : null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null));
      SharedPreferences.setMockInitialValues(
          {'user_profile': '{"heightCm":180}', 'foods': foods});
      await tester.pumpWidget(const CalorieApp());
      await tester.pumpAndSettle();
    }

    testWidgets('opening a shared file shows the import review',
        (tester) async {
      await startOnAndroid(tester, fileWith([mango]));
      expect(find.text('Import foods'), findsOneWidget);
      expect(find.widgetWithText(CheckboxListTile, 'Mango'), findsOneWidget);

      await tester.tap(find.text('Import 1 food'));
      await tester.pumpAndSettle();
      expect(find.text('Added 1, replaced 0.'), findsOneWidget);
      final names = (await FoodStorage().loadFoods()).map((f) => f.name);
      expect(names, contains('Mango'));
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('a file shared while the app is open', (tester) async {
      await startOnAndroid(tester, null);
      expect(find.text('Import foods'), findsNothing);

      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(
            MethodCall('fileReceived', fileWith([mango]))),
        (_) {},
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(CheckboxListTile, 'Mango'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('a file that is not a food file says so', (tester) async {
      await startOnAndroid(tester, utf8.encode('{"something": "else"}'));
      expect(find.text("This isn't a BiteScale food file."), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
