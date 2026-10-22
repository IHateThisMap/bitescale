/// The optional nutrients a food can have.
enum Nutrient { protein, carbs, sugar, fat, fiber, salt }

/// Nutritional values. For a [Food] these are per 100 g / 100 ml;
/// for a [FoodLogEntry] they are for the amount that was eaten.
class Nutrients {
  const Nutrients({
    required this.kcal,
    this.protein,
    this.carbs,
    this.sugar,
    this.fat,
    this.fiber,
    this.salt,
  });

  final double kcal;
  final double? protein;
  final double? carbs;
  final double? sugar;
  final double? fat;
  final double? fiber;
  final double? salt;

  /// The optional values, all in grams.
  List<(Nutrient, double?)> get optionalValues => [
        (Nutrient.protein, protein),
        (Nutrient.carbs, carbs),
        (Nutrient.sugar, sugar),
        (Nutrient.fat, fat),
        (Nutrient.fiber, fiber),
        (Nutrient.salt, salt),
      ];

  Nutrients scaled(double factor) {
    double? s(double? v) => v == null ? null : v * factor;
    return Nutrients(
      kcal: kcal * factor,
      protein: s(protein),
      carbs: s(carbs),
      sugar: s(sugar),
      fat: s(fat),
      fiber: s(fiber),
      salt: s(salt),
    );
  }

  Map<String, dynamic> toJson() => {
        'kcal': kcal,
        'protein': protein,
        'carbs': carbs,
        'sugar': sugar,
        'fat': fat,
        'fiber': fiber,
        'salt': salt,
      };

  factory Nutrients.fromJson(Map<String, dynamic> json) {
    double? d(String key) => (json[key] as num?)?.toDouble();
    return Nutrients(
      kcal: d('kcal') ?? 0,
      protein: d('protein'),
      carbs: d('carbs'),
      sugar: d('sugar'),
      fat: d('fat'),
      fiber: d('fiber'),
      salt: d('salt'),
    );
  }
}

/// A saved food that can be quickly logged again.
class Food {
  const Food({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.per100,
    this.imagePath,
    this.portionSize,
    this.portionName,
    this.lastAmount,
    this.lastUsed,
    this.favourite = false,
  });

  final String id;
  final String name;
  final String category;

  /// 'g' or 'ml'.
  final String unit;
  final Nutrients per100;
  final String? imagePath;

  /// Size of one portion / piece in [unit], e.g. 120 for a 120 g banana.
  final double? portionSize;

  /// What one portion is called, e.g. "slice". Null means the translated
  /// word for "portion" is used.
  final String? portionName;

  /// The amount used the last time this food was logged, used as the default.
  final double? lastAmount;
  final DateTime? lastUsed;

  /// Shown under "Favourites" on the food page.
  final bool favourite;

  Nutrients nutrientsFor(double amount) => per100.scaled(amount / 100);

  Food withUsage(double amount) =>
      _copyWith(lastAmount: amount, lastUsed: DateTime.now());

  Food withFavourite(bool favourite) => _copyWith(favourite: favourite);

  Food withCategory(String category) => _copyWith(category: category);

  Food _copyWith({
    double? lastAmount,
    DateTime? lastUsed,
    bool? favourite,
    String? category,
  }) =>
      Food(
        id: id,
        name: name,
        category: category ?? this.category,
        unit: unit,
        per100: per100,
        imagePath: imagePath,
        portionSize: portionSize,
        portionName: portionName,
        lastAmount: lastAmount ?? this.lastAmount,
        lastUsed: lastUsed ?? this.lastUsed,
        favourite: favourite ?? this.favourite,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'unit': unit,
        'per100': per100.toJson(),
        'imagePath': imagePath,
        'portionSize': portionSize,
        'portionName': portionName,
        'lastAmount': lastAmount,
        'lastUsed': lastUsed?.toIso8601String(),
        'favourite': favourite,
      };

  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        unit: json['unit'] as String,
        per100: Nutrients.fromJson(json['per100'] as Map<String, dynamic>),
        imagePath: json['imagePath'] as String?,
        portionSize: (json['portionSize'] as num?)?.toDouble(),
        portionName: json['portionName'] as String?,
        lastAmount: (json['lastAmount'] as num?)?.toDouble(),
        lastUsed: json['lastUsed'] == null
            ? null
            : DateTime.parse(json['lastUsed'] as String),
        favourite: json['favourite'] as bool? ?? false,
      );
}

/// One food eaten on a given day. Keeps its own copy of the values so the
/// history stays correct even if the saved food is edited or deleted later.
class FoodLogEntry {
  const FoodLogEntry({
    required this.id,
    required this.date,
    required this.foodId,
    required this.foodName,
    required this.amount,
    required this.unit,
    required this.nutrients,
    this.category,
  });

  final String id;
  final DateTime date;
  final String foodId;
  final String foodName;
  final double amount;
  final String unit;
  final Nutrients nutrients;

  /// The food's category when it was logged. Null for entries logged
  /// before categories were remembered.
  final String? category;

  FoodLogEntry copyWith(
          {double? amount, Nutrients? nutrients, String? category}) =>
      FoodLogEntry(
        id: id,
        date: date,
        foodId: foodId,
        foodName: foodName,
        amount: amount ?? this.amount,
        unit: unit,
        nutrients: nutrients ?? this.nutrients,
        category: category ?? this.category,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'foodId': foodId,
        'foodName': foodName,
        'amount': amount,
        'unit': unit,
        'nutrients': nutrients.toJson(),
        'category': category,
      };

  factory FoodLogEntry.fromJson(Map<String, dynamic> json) => FoodLogEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        foodId: json['foodId'] as String,
        foodName: json['foodName'] as String,
        amount: (json['amount'] as num).toDouble(),
        unit: json['unit'] as String,
        nutrients:
            Nutrients.fromJson(json['nutrients'] as Map<String, dynamic>),
        category: json['category'] as String?,
      );
}

/// Built-in categories. These English names are what gets saved; the app
/// shows them translated (see `categoryLabel` in lib/l10n/labels.dart).
/// Categories the user types themselves are saved and shown as typed.
const defaultFoodCategories = [
  'Fruits & vegetables',
  'Meat & fish',
  'Dairy & eggs',
  'Bread & grains',
  'Meals',
  'Snacks & sweets',
  'Drinks',
  'Other',
];

var _idCounter = 0;

/// A unique id. The counter keeps ids apart when many are made at once,
/// e.g. when importing foods.
String newId() =>
    '${DateTime.now().microsecondsSinceEpoch}${(_idCounter++ % 1000).toString().padLeft(3, '0')}';
