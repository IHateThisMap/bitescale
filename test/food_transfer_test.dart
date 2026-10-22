import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_calorie_couinter_exercise_app/l10n/app_localizations.dart';
import 'package:flutter_calorie_couinter_exercise_app/models/food.dart';
import 'package:flutter_calorie_couinter_exercise_app/screens/import_foods_screen.dart';
import 'package:flutter_calorie_couinter_exercise_app/services/food_image_service.dart';
import 'package:flutter_calorie_couinter_exercise_app/services/food_storage.dart';
import 'package:flutter_calorie_couinter_exercise_app/services/food_transfer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Food food(
  String name, {
  String id = 'x',
  double kcal = 100,
  double? protein,
  double? portionSize,
  DateTime? lastUsed,
}) =>
    Food(
      id: id,
      name: name,
      category: 'Other',
      unit: 'g',
      per100: Nutrients(kcal: kcal, protein: protein),
      portionSize: portionSize,
      lastUsed: lastUsed,
      lastAmount: lastUsed == null ? null : 50,
    );

void main() {
  test('export file can be read back, photos included', () {
    final photo = Uint8List.fromList([1, 2, 3]);
    final text = encodeFoods([
      TransferFood(food('Oats', kcal: 380, protein: 13, portionSize: 40),
          image: photo, imageExtension: '.png'),
      TransferFood(food('Milk', kcal: 64)),
    ]);
    final back = decodeFoods(utf8.encode(text));

    expect(back, hasLength(2));
    expect(back[0].food.name, 'Oats');
    expect(back[0].food.per100.kcal, 380);
    expect(back[0].food.per100.protein, 13);
    expect(back[0].food.portionSize, 40);
    expect(back[0].image, photo);
    expect(back[0].imageExtension, '.png');
    expect(back[1].image, isNull);
    // The user's own usage data is not exported.
    expect(text, isNot(contains('lastUsed')));
  });

  test('other files are rejected', () {
    for (final text in ['not json', '{"foods": []}', '[1, 2]', '']) {
      expect(() => decodeFoods(utf8.encode(text)),
          throwsA(isA<NotAFoodFileException>()),
          reason: text);
    }
  });

  test('names are similar when they differ by a small typo', () {
    expect(nameDistance('Rye bread', 'rye  bread '), 0);
    expect(nameDistance('Ruisleipä', 'Ruisleipa'), 1);
    expect(nameDistance('Milk 1%', 'Milk 3%'), 1);
    expect(nameDistance('Milk', 'Banana'), isNull);
    expect(nameDistance('Oats', 'Rice'), isNull);
  });

  test('import plan sorts foods into new, duplicate and similar', () {
    final mine = [
      food('Oats', id: 'a', kcal: 380),
      food('Rye bread', id: 'b', kcal: 250),
    ];
    final items = planImport(
      [
        TransferFood(food('Oats', kcal: 380)), // exactly the same
        TransferFood(food('Rye bred', kcal: 240)), // similar, different
        TransferFood(food('Banana', kcal: 89)), // new
        TransferFood(food('Banana', kcal: 89)), // same food twice in file
      ],
      mine,
      {},
    );

    expect(items.map((i) => i.status), [
      ImportStatus.duplicate,
      ImportStatus.similar,
      ImportStatus.newFood,
    ]);
    final similar = items[1];
    expect(similar.existing!.id, 'b');
    expect(similar.differences, [FoodField.name, FoodField.kcal]);
    // Safe defaults: new foods selected, conflicts keep the user's own.
    expect(items[2].selected, isTrue);
    expect(similar.choice, ConflictChoice.keepMine);
    expect(similar.willImport, isFalse);
  });

  test('a different photo makes a food differ', () {
    final items = planImport(
      [TransferFood(food('Oats'), image: Uint8List.fromList([9]))],
      [food('Oats', id: 'a')],
      {'a': Uint8List.fromList([1])},
    );
    expect(items.single.status, ImportStatus.similar);
    expect(items.single.differences, [FoodField.photo]);
  });

  test('applying adds and replaces as chosen, never removes', () async {
    final used = DateTime(2026, 10, 1);
    SharedPreferences.setMockInitialValues({});
    final storage = FoodStorage();
    await storage.saveFoods([
      food('Oats', id: 'a', kcal: 380),
      food('Rye bread', id: 'b', kcal: 250, lastUsed: used),
      food('Milk 1%', id: 'c', kcal: 40),
      food('Untouched', id: 'd'),
    ]);

    final items = planImport(
      [
        TransferFood(food('Banana', kcal: 89)),
        TransferFood(food('Apple', kcal: 52)),
        TransferFood(food('Rye bread', kcal: 240)),
        TransferFood(food('Milk 3%', kcal: 64)),
        TransferFood(food('Oats', kcal: 370)),
      ],
      await storage.loadFoods(),
      {},
    );
    items[1].selected = false; // Apple: deselected
    items[2].choice = ConflictChoice.useImported; // Rye bread: replace
    items[3].choice = ConflictChoice.keepBoth; // Milk 3%: keep both
    // Oats: left at "keep mine"

    final result = await applyImport(items, storage, FoodImageService());
    expect(result.added, 2);
    expect(result.replaced, 1);

    final foods = {for (final f in await storage.loadFoods()) f.name: f};
    expect(foods.keys.toSet(),
        {'Oats', 'Rye bread', 'Milk 1%', 'Milk 3%', 'Untouched', 'Banana'});
    expect(foods['Oats']!.per100.kcal, 380);
    // Replaced in place: same id and usage history, new details.
    expect(foods['Rye bread']!.id, 'b');
    expect(foods['Rye bread']!.per100.kcal, 240);
    expect(foods['Rye bread']!.lastUsed, used);
    expect(foods['Milk 1%']!.per100.kcal, 40);
    expect(foods['Banana']!.id, isNot(foods['Milk 3%']!.id));
  });

  testWidgets('import screen: deselect, choose and import', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final storage = FoodStorage();
    await storage.saveFoods([food('Rye bread', id: 'b', kcal: 250)]);

    final items = planImport(
      [
        TransferFood(food('Banana', kcal: 89)),
        TransferFood(food('Apple', kcal: 52)),
        TransferFood(food('Rye bread', kcal: 240, protein: 8)),
        TransferFood(food('Rye bread', id: 'b', kcal: 250)),
      ],
      await storage.loadFoods(),
      {},
    );

    ImportResult? result;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await Navigator.of(context).push<ImportResult>(
                MaterialPageRoute(
                    builder: (_) => ImportFoodsScreen(items: items)));
          },
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('4 foods in the file.'), findsOneWidget);
    expect(find.textContaining('1 is already in the app'), findsOneWidget);
    expect(find.text('Import 2 foods'), findsOneWidget);

    // Only the differences are shown: calories and protein.
    expect(find.text('250 kcal'), findsOneWidget);
    expect(find.text('240 kcal'), findsOneWidget);
    expect(find.text('–'), findsOneWidget);
    expect(find.text('8 g'), findsOneWidget);

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Apple'));
    await tester.pump();
    await tester.tap(find.text('Replace mine with the imported one'));
    await tester.pump();
    expect(find.text('Import 2 foods'), findsOneWidget);

    await tester.tap(find.text('Import 2 foods'));
    await tester.pumpAndSettle();

    expect(result!.added, 1);
    expect(result!.replaced, 1);
    final names = (await storage.loadFoods()).map((f) => f.name);
    expect(names, unorderedEquals(['Rye bread', 'Banana']));
  });
}
