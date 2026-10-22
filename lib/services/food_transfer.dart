import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/food.dart';
import 'food_image_service.dart';
import 'food_storage.dart';

// Exporting and importing saved foods as a JSON file.
//
// The file contains the foods' details and photos (base64), but not the
// user's own usage data such as the last amount eaten.

const _fileFormat = 'bitescale-foods';
const _fileVersion = 1;

/// A food as stored in an export file, with its photo.
class TransferFood {
  const TransferFood(this.food, {this.image, this.imageExtension = '.jpg'});

  final Food food;
  final Uint8List? image;
  final String imageExtension;
}

/// The chosen file isn't a food export file.
class NotAFoodFileException implements Exception {}

String exportFileName(DateTime now) =>
    'bitescale-foods-${now.year}-${_two(now.month)}-${_two(now.day)}.json';

String _two(int n) => n.toString().padLeft(2, '0');

/// Reads the saved foods and their photos into an export file's contents.
Future<Uint8List> buildExport(
    List<Food> foods, FoodImageService images) async {
  final items = [
    for (final f in foods)
      TransferFood(
        f,
        image: await images.readBytes(f.imagePath),
        imageExtension: f.imagePath == null
            ? '.jpg'
            : FoodImageService.extensionOf(f.imagePath!),
      ),
  ];
  return utf8.encode(encodeFoods(items));
}

String encodeFoods(List<TransferFood> foods) => const JsonEncoder.withIndent(' ')
    .convert({
  'format': _fileFormat,
  'version': _fileVersion,
  'foods': [
    for (final t in foods)
      {
        'name': t.food.name,
        'category': t.food.category,
        'unit': t.food.unit,
        'per100': t.food.per100.toJson(),
        'portionSize': t.food.portionSize,
        'portionName': t.food.portionName,
        if (t.image != null) 'image': base64Encode(t.image!),
        if (t.image != null) 'imageExtension': t.imageExtension,
      },
  ],
});

/// Reads an export file. Throws [NotAFoodFileException] for anything else.
List<TransferFood> decodeFoods(List<int> bytes) {
  try {
    final json = jsonDecode(utf8.decode(bytes));
    if (json is! Map || json['format'] != _fileFormat) {
      throw NotAFoodFileException();
    }
    return [
      for (final (i, f) in (json['foods'] as List).cast<Map>().indexed)
        TransferFood(
          Food(
            id: 'import$i',
            name: (f['name'] as String).trim(),
            category: f['category'] as String? ?? 'Other',
            unit: f['unit'] == 'ml' ? 'ml' : 'g',
            per100: Nutrients.fromJson(
                (f['per100'] as Map).cast<String, dynamic>()),
            portionSize: (f['portionSize'] as num?)?.toDouble(),
            portionName: f['portionName'] as String?,
          ),
          image: f['image'] == null ? null : base64Decode(f['image'] as String),
          imageExtension: f['imageExtension'] as String? ?? '.jpg',
        ),
    ];
  } on NotAFoodFileException {
    rethrow;
  } catch (_) {
    throw NotAFoodFileException();
  }
}

/// The parts of a food that can differ between two versions of it.
enum FoodField {
  name,
  category,
  unit,
  kcal,
  protein,
  carbs,
  sugar,
  fat,
  fiber,
  salt,
  portionSize,
  portionName,
  photo,
}

Object? _valueOf(FoodField field, Food f) => switch (field) {
      FoodField.name => f.name,
      FoodField.category => f.category,
      FoodField.unit => f.unit,
      FoodField.kcal => f.per100.kcal,
      FoodField.protein => f.per100.protein,
      FoodField.carbs => f.per100.carbs,
      FoodField.sugar => f.per100.sugar,
      FoodField.fat => f.per100.fat,
      FoodField.fiber => f.per100.fiber,
      FoodField.salt => f.per100.salt,
      FoodField.portionSize => f.portionSize,
      FoodField.portionName => f.portionName,
      FoodField.photo => null, // Compared separately, by image bytes.
    };

/// The fields in which [a] and [b] differ.
List<FoodField> foodDifferences(
    Food a, Uint8List? imageA, Food b, Uint8List? imageB) {
  return [
    for (final field in FoodField.values)
      if (field == FoodField.photo
          ? !listEquals(imageA, imageB)
          : _valueOf(field, a) != _valueOf(field, b))
        field,
  ];
}

String _normalizeName(String name) =>
    name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

/// Number of single-letter edits needed to turn [a] into [b].
int _editDistance(String a, String b) {
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = [i, ...List<int>.filled(b.length, 0)];
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      current[j] = math.min(math.min(current[j - 1] + 1, previous[j] + 1),
          previous[j - 1] + cost);
    }
    previous = current;
  }
  return previous[b.length];
}

/// How different two names are, or null if they aren't similar.
/// Same name ignoring case and spaces is 0; a small typo is 1–2.
int? nameDistance(String a, String b) {
  final x = _normalizeName(a);
  final y = _normalizeName(b);
  final d = _editDistance(x, y);
  final allowed = math.max(x.length, y.length) <= 6 ? 1 : 2;
  return d <= allowed ? d : null;
}

enum ImportStatus {
  /// Not in the app yet.
  newFood,

  /// In the app exactly as is; not imported.
  duplicate,

  /// A food with a similar name is in the app, with some differences.
  similar,
}

/// What to do with an imported food that's similar to one in the app.
enum ConflictChoice { keepMine, useImported, keepBoth }

/// One food from the file and what will happen to it.
class ImportItem {
  ImportItem.newFood(this.incoming)
      : status = ImportStatus.newFood,
        existing = null,
        existingImage = null,
        differences = const [];

  ImportItem.duplicate(this.incoming, this.existing)
      : status = ImportStatus.duplicate,
        existingImage = null,
        differences = const [];

  ImportItem.similar(
      this.incoming, this.existing, this.existingImage, this.differences)
      : status = ImportStatus.similar;

  final TransferFood incoming;
  final ImportStatus status;

  /// The matching food in the app, for duplicates and similar foods.
  final Food? existing;
  final Uint8List? existingImage;
  final List<FoodField> differences;

  /// For new foods: whether to import it.
  bool selected = true;

  /// For similar foods. Keeping the user's own is the safe default.
  ConflictChoice choice = ConflictChoice.keepMine;

  /// Whether applying the import will change anything for this item.
  bool get willImport => switch (status) {
        ImportStatus.newFood => selected,
        ImportStatus.duplicate => false,
        ImportStatus.similar => choice != ConflictChoice.keepMine,
      };
}

/// Compares the foods in a file with the foods in the app.
/// [existingImages] holds the photos of the app's foods by food id.
List<ImportItem> planImport(
  List<TransferFood> incoming,
  List<Food> existing,
  Map<String, Uint8List?> existingImages,
) {
  final items = <ImportItem>[];
  final seen = <TransferFood>[];

  bool sameAs(TransferFood t, Food f, Uint8List? image) =>
      foodDifferences(t.food, t.image, f, image).isEmpty;

  for (final t in incoming) {
    // The same food twice in the file: only the first one counts.
    if (seen.any((s) => sameAs(t, s.food, s.image))) continue;
    seen.add(t);

    final exact = existing
        .where((f) => sameAs(t, f, existingImages[f.id]))
        .firstOrNull;
    if (exact != null) {
      items.add(ImportItem.duplicate(t, exact));
      continue;
    }

    Food? closest;
    int? closestDistance;
    for (final f in existing) {
      final d = nameDistance(t.food.name, f.name);
      if (d != null && (closestDistance == null || d < closestDistance)) {
        closest = f;
        closestDistance = d;
      }
    }
    if (closest != null) {
      final image = existingImages[closest.id];
      items.add(ImportItem.similar(t, closest, image,
          foodDifferences(closest, image, t.food, t.image)));
    } else {
      items.add(ImportItem.newFood(t));
    }
  }
  return items;
}

class ImportResult {
  const ImportResult(this.added, this.replaced);
  final int added;
  final int replaced;
}

/// Adds and replaces foods as chosen in [items]. Never removes a food.
Future<ImportResult> applyImport(
  List<ImportItem> items,
  FoodStorage storage,
  FoodImageService images,
) async {
  final foods = await storage.loadFoods();
  var added = 0;
  var replaced = 0;

  Future<String?> saveImage(TransferFood t, String id) async =>
      t.image == null || !FoodImageService.isSupported
          ? null
          : images.persistBytes(t.image!, id, t.imageExtension);

  for (final item in items.where((i) => i.willImport)) {
    final t = item.incoming;
    final replace = item.status == ImportStatus.similar &&
        item.choice == ConflictChoice.useImported;
    final index =
        replace ? foods.indexWhere((f) => f.id == item.existing!.id) : -1;

    if (index != -1) {
      // Replace the details, but keep the food's id and usage history so
      // it stays a favourite and keeps its default amount.
      final old = foods[index];
      await images.delete(old.imagePath);
      foods[index] = Food(
        id: old.id,
        name: t.food.name,
        category: t.food.category,
        unit: t.food.unit,
        per100: t.food.per100,
        portionSize: t.food.portionSize,
        portionName: t.food.portionName,
        imagePath: await saveImage(t, old.id),
        lastAmount: old.lastAmount,
        lastUsed: old.lastUsed,
        favourite: old.favourite,
      );
      replaced++;
    } else {
      final id = newId();
      foods.add(Food(
        id: id,
        name: t.food.name,
        category: t.food.category,
        unit: t.food.unit,
        per100: t.food.per100,
        portionSize: t.food.portionSize,
        portionName: t.food.portionName,
        imagePath: await saveImage(t, id),
      ));
      added++;
    }
  }

  await storage.saveFoods(foods);
  return ImportResult(added, replaced);
}
