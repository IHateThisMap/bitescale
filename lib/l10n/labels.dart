import 'package:flutter/widgets.dart';

import '../models/food.dart';
import '../models/user_profile.dart';
import '../utils/body_metrics.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  /// The texts of the current language.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Translated names for the app's enums and built-in categories.
extension Labels on AppLocalizations {
  String bmiCategoryLabel(BmiCategory c) => switch (c) {
        BmiCategory.underweight => bmiUnderweight,
        BmiCategory.normal => bmiNormal,
        BmiCategory.overweight => bmiOverweight,
        BmiCategory.obese => bmiObese,
      };

  String bodyFatCategoryLabel(BodyFatCategory c) => switch (c) {
        BodyFatCategory.essential => bodyFatEssential,
        BodyFatCategory.athletic => bodyFatAthletic,
        BodyFatCategory.fit => bodyFatFit,
        BodyFatCategory.average => bodyFatAverage,
        BodyFatCategory.obese => bodyFatObese,
      };

  String activityLabel(ActivityLevel a) => switch (a) {
        ActivityLevel.sedentary => activitySedentary,
        ActivityLevel.light => activityLight,
        ActivityLevel.moderate => activityModerate,
        ActivityLevel.active => activityActive,
        ActivityLevel.extreme => activityExtreme,
      };

  String activityDescription(ActivityLevel a) => switch (a) {
        ActivityLevel.sedentary => activitySedentaryDesc,
        ActivityLevel.light => activityLightDesc,
        ActivityLevel.moderate => activityModerateDesc,
        ActivityLevel.active => activityActiveDesc,
        ActivityLevel.extreme => activityExtremeDesc,
      };

  String nutrientLabel(Nutrient n) => switch (n) {
        Nutrient.protein => nutrientProtein,
        Nutrient.carbs => nutrientCarbs,
        Nutrient.sugar => nutrientSugar,
        Nutrient.fat => nutrientFat,
        Nutrient.fiber => nutrientFiber,
        Nutrient.salt => nutrientSalt,
      };

  /// What one portion of [food] is called.
  String portionLabel(Food food) {
    final name = food.portionName;
    return name == null || name.isEmpty ? portionDefault : name;
  }

  /// Shows a saved category: built-in ones translated, the user's own as is.
  String categoryLabel(String category) => switch (category) {
        'Fruits & vegetables' => categoryFruitsVegetables,
        'Meat & fish' => categoryMeatFish,
        'Dairy & eggs' => categoryDairyEggs,
        'Bread & grains' => categoryBreadGrains,
        'Meals' => categoryMeals,
        'Snacks & sweets' => categorySnacksSweets,
        'Drinks' => categoryDrinks,
        otherCategory => categoryOther,
        _ => category,
      };

  /// Turns what the user typed back into the category to save: a translated
  /// built-in name becomes its saved (English) form.
  String categoryToSave(String typed) {
    final text = typed.trim();
    for (final c in defaultFoodCategories) {
      if (categoryLabel(c).toLowerCase() == text.toLowerCase()) return c;
    }
    return text;
  }
}
