import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_calorie_couinter_exercise_app/services/food_transfer.dart';

/// The ready-made food lists in food_files/ must import, and the language
/// versions must only differ in their texts.
void main() {
  List<TransferFood> load(String language) => decodeFoods(
      File('food_files/bitescale-foods-$language.json').readAsBytesSync());

  test('every food file can be imported', () {
    for (final file in Directory('food_files').listSync()) {
      expect(decodeFoods((file as File).readAsBytesSync()), isNotEmpty,
          reason: file.path);
    }
  });

  test('English and Finnish food lists have the same values', () {
    final fi = load('fi');
    final en = load('en');
    expect(en.length, fi.length);
    for (var i = 0; i < fi.length; i++) {
      final a = fi[i].food;
      final b = en[i].food;
      expect(b.unit, a.unit, reason: a.name);
      expect(b.per100.toJson(), a.per100.toJson(), reason: a.name);
      expect(b.portionSize, a.portionSize, reason: a.name);
      expect(listEquals(en[i].image, fi[i].image), isTrue, reason: a.name);
    }
  });
}
