// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageName => 'English';

  @override
  String get languageFlag => '🇬🇧';

  @override
  String get appTitle => 'BiteScale';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System default';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get edit => 'Edit';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get weight => 'Weight';

  @override
  String get food => 'Food';

  @override
  String valueBetween(String min, String max) {
    return 'Enter a value between $min and $max';
  }

  @override
  String get welcome => 'Welcome!';

  @override
  String get heightQuestion =>
      'How tall are you? Your height is used to calculate your BMI.';

  @override
  String get height => 'Height';

  @override
  String get heightError => 'Enter your height in centimetres';

  @override
  String get continueButton => 'Continue';

  @override
  String get editHeight => 'Edit height';

  @override
  String get yourHeight => 'Your height';

  @override
  String get addWeight => 'Add weight';

  @override
  String get noWeightEntries => 'No entries yet.\nTap \"Add weight\" to start.';

  @override
  String get history => 'History';

  @override
  String get noWeightsInRange =>
      'No weights recorded in this period.\nDrag the slider left to see further back.';

  @override
  String showingLastDays(int days) {
    return 'Last $days days';
  }

  @override
  String rangeDays(int days) {
    return '$days d';
  }

  @override
  String rangeMonths(int months) {
    return '$months mo';
  }

  @override
  String rangeYears(String years) {
    return '$years yr';
  }

  @override
  String get oneDayLess => 'One day less';

  @override
  String get oneDayMore => 'One day more';

  @override
  String get weightSummaryEmpty =>
      'Log your weight regularly to see your trend and BMI.';

  @override
  String get current => 'Current';

  @override
  String totalChange(String change) {
    return 'Total change: $change kg';
  }

  @override
  String get trendNeedsTwo =>
      'Add at least two entries on different days to calculate a trend line.';

  @override
  String trendPerWeek(String change) {
    return 'Trend: $change kg / week';
  }

  @override
  String estimatedDeficit(int kcal) {
    return 'Estimated deficit: $kcal kcal / day';
  }

  @override
  String estimatedSurplus(int kcal) {
    return 'Estimated surplus: $kcal kcal / day';
  }

  @override
  String get enterValidWeight => 'Enter a valid weight';

  @override
  String get bmi => 'BMI';

  @override
  String get bmiUnderweight => 'Underweight';

  @override
  String get bmiNormal => 'Normal weight';

  @override
  String get bmiOverweight => 'Overweight';

  @override
  String get bmiObese => 'Obese';

  @override
  String get bodyFat => 'Body fat';

  @override
  String get bodyFatEssential => 'Essential fat';

  @override
  String get bodyFatAthletic => 'Athletic';

  @override
  String get bodyFatFit => 'Fit';

  @override
  String get bodyFatAverage => 'Average';

  @override
  String get bodyFatObese => 'Obese';

  @override
  String get tapToAddMeasurements => 'Tap to add measurements';

  @override
  String fatAndLean(String fat, String lean) {
    return '$fat kg fat · $lean kg lean';
  }

  @override
  String measuredOn(String date) {
    return 'Measured $date';
  }

  @override
  String get setGoal => 'Set a weight goal';

  @override
  String get setGoalSubtitle => 'See the daily calorie deficit you need';

  @override
  String get goalNeedsWeight =>
      'Add your weight to see what it takes to get there.';

  @override
  String get goalReached => 'Goal reached! 🎉';

  @override
  String goalOverdue(String kg) {
    return '$kg kg to go, but the goal date has passed. Set a new date.';
  }

  @override
  String kgToLose(String kg, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$kg kg to lose in $days days',
      one: '$kg kg to lose in 1 day',
    );
    return '$_temp0';
  }

  @override
  String kgToGain(String kg, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$kg kg to gain in $days days',
      one: '$kg kg to gain in 1 day',
    );
    return '$_temp0';
  }

  @override
  String neededDeficit(int kcal) {
    return 'Needed: $kcal kcal deficit / day';
  }

  @override
  String neededSurplus(int kcal) {
    return 'Needed: $kcal kcal surplus / day';
  }

  @override
  String get tooFastPace =>
      'That is a very fast pace. Consider a later goal date.';

  @override
  String currentTrendDeficit(int kcal) {
    return 'Your current trend: deficit of $kcal kcal / day';
  }

  @override
  String currentTrendSurplus(int kcal) {
    return 'Your current trend: surplus of $kcal kcal / day';
  }

  @override
  String goalTitle(String kg, String date) {
    return 'Goal: $kg kg by $date';
  }

  @override
  String get editGoal => 'Edit goal';

  @override
  String get removeGoal => 'Remove goal';

  @override
  String get weightGoal => 'Weight goal';

  @override
  String get goalWeight => 'Goal weight';

  @override
  String get goalDate => 'Reach it by';

  @override
  String get chartGoal => 'Goal';

  @override
  String get bodyComposition => 'Body composition';

  @override
  String get tapeMeasure => 'Tape measure';

  @override
  String get bmiExplanation =>
      'BMI is calculated from your height and latest weight. It doesn\'t tell fat and muscle apart.';

  @override
  String get navyExplanation =>
      'U.S. Navy method: estimates body fat percentage from tape measurements and your height.';

  @override
  String get neck => 'Neck';

  @override
  String get waist => 'Waist';

  @override
  String get hips => 'Hips';

  @override
  String get neckHelp =>
      'Just below the larynx (Adam\'s apple), tape sloping slightly down to the front';

  @override
  String get waistHelpMale => 'Horizontally at the level of the navel';

  @override
  String get waistHelpFemale => 'At the narrowest point of the waist';

  @override
  String get hipsHelp => 'At the widest point of the buttocks';

  @override
  String bodyFatPreview(String value) {
    return 'Body fat: $value';
  }

  @override
  String heightUsed(String cm) {
    return 'Height used: $cm cm';
  }

  @override
  String get chooseSex => 'Choose male or female';

  @override
  String get enterAllMeasurements => 'Enter all measurements in centimetres';

  @override
  String get invalidMeasurements =>
      'These measurements don\'t give a valid result. Check them again.';

  @override
  String get dailyCalorieNeeds => 'Daily calorie needs';

  @override
  String get calorieProfileIntro =>
      'Used together with your height and latest weight to estimate how many calories you burn per day.';

  @override
  String get birthYear => 'Year of birth';

  @override
  String get invalidBirthYear => 'Enter a valid year of birth';

  @override
  String get activityLevel => 'Activity level';

  @override
  String get chooseActivity => 'Choose your activity level';

  @override
  String get activitySedentary => 'Sedentary';

  @override
  String get activitySedentaryDesc => 'Little or no exercise, desk job';

  @override
  String get activityLight => 'Lightly active';

  @override
  String get activityLightDesc => 'Light exercise 1–3 days a week';

  @override
  String get activityModerate => 'Moderately active';

  @override
  String get activityModerateDesc => 'Exercise 3–5 days a week';

  @override
  String get activityActive => 'Very active';

  @override
  String get activityActiveDesc => 'Hard exercise 6–7 days a week';

  @override
  String get activityExtreme => 'Extremely active';

  @override
  String get activityExtremeDesc => 'Physical job plus hard training';

  @override
  String get myFoods => 'My foods';

  @override
  String get addFood => 'Add food';

  @override
  String get today => 'Today';

  @override
  String get favourites => 'Favourites';

  @override
  String get addToFavourites => 'Add to favourites';

  @override
  String get removeFromFavourites => 'Remove from favourites';

  @override
  String get eaten => 'Eaten';

  @override
  String get nothingLogged => 'Nothing logged for this day.';

  @override
  String kcalEaten(int kcal) {
    return '$kcal kcal eaten';
  }

  @override
  String get needWeightForTarget =>
      'Add your weight to see how much you should eat per day.';

  @override
  String get needInfoForTarget =>
      'Tell the app a bit more about you to see how much you should eat per day.';

  @override
  String get goToWeightPage => 'Go to weight page';

  @override
  String get setUpCalorieTarget => 'Set up daily calorie target';

  @override
  String get targetGoalDone =>
      'Your goal is reached or its date has passed, so the target keeps your current weight.';

  @override
  String get targetNoGoal =>
      'No weight goal set, so the target keeps your current weight.';

  @override
  String targetDeficitToGoal(int kcal, String kg, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$kcal kcal deficit / day to reach $kg kg in $days days',
      one: '$kcal kcal deficit / day to reach $kg kg in 1 day',
    );
    return '$_temp0';
  }

  @override
  String targetSurplusToGoal(int kcal, String kg, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$kcal kcal surplus / day to reach $kg kg in $days days',
      one: '$kcal kcal surplus / day to reach $kg kg in 1 day',
    );
    return '$_temp0';
  }

  @override
  String dailyTarget(int kcal) {
    return 'Daily target: $kcal kcal';
  }

  @override
  String get calorieProfileTooltip => 'Age, sex and activity';

  @override
  String get overTarget => 'Over target';

  @override
  String get leftToEat => 'Left to eat';

  @override
  String get deficitLeft => 'Deficit left';

  @override
  String get overMaintenance => 'Over maintenance';

  @override
  String get barGoal => 'Goal';

  @override
  String get barDeficitEnds => 'Deficit ends';

  @override
  String get statusWithinGoalDeficit =>
      'Within your goal and in calorie deficit.';

  @override
  String get statusWithinGoal => 'Within your goal.';

  @override
  String get statusOverGoalDeficit =>
      'Over your goal, but still in calorie deficit.';

  @override
  String get statusOverGoal => 'Over your goal.';

  @override
  String get statusNoDeficit =>
      'No calorie deficit left: you have eaten as much as you burn.';

  @override
  String maintenanceLine(int kcal) {
    return 'To keep your current weight: $kcal kcal / day';
  }

  @override
  String minimumWarning(int kcal) {
    return 'Reaching your goal by its date would need eating less than $kcal kcal a day, which isn\'t recommended. The target is limited to that, so consider a later goal date.';
  }

  @override
  String get estimateBodyFat =>
      'Estimate based on your body fat (Katch-McArdle) and activity level.';

  @override
  String get estimateMifflin =>
      'Estimate based on your age, sex, height, weight (Mifflin-St Jeor) and activity level.';

  @override
  String get nutrientProtein => 'Protein';

  @override
  String get nutrientCarbs => 'Carbohydrates';

  @override
  String get nutrientSugar => 'of which sugars';

  @override
  String get nutrientFat => 'Fat';

  @override
  String get nutrientFiber => 'Fiber';

  @override
  String get nutrientSalt => 'Salt';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get volume => 'Volume';

  @override
  String get portionDefault => 'portion';

  @override
  String get portionCount => 'Number of portions';

  @override
  String kcalPer100(String kcal, String unit) {
    return '$kcal kcal per 100 $unit';
  }

  @override
  String get newFood => 'New food';

  @override
  String get searchFoods => 'Search foods';

  @override
  String get all => 'All';

  @override
  String get noSavedFoods =>
      'No saved foods yet.\nTap \"New food\" to add one.';

  @override
  String get noFoodsMatch => 'No foods match.';

  @override
  String deleteFoodTitle(String name) {
    return 'Delete food template \"$name\"?';
  }

  @override
  String get deleteFoodBody =>
      'It is removed from your saved foods. Days where you already logged it are not changed.';

  @override
  String get deleteFoodTemplate => 'Delete food template';

  @override
  String get removeFromEaten => 'Remove from eaten';

  @override
  String removeFromEatenTitle(String name) {
    return 'Remove \"$name\" from eaten?';
  }

  @override
  String get editFood => 'Edit food';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get nameRequired => 'Name *';

  @override
  String get enterName => 'Enter a name';

  @override
  String get category => 'Category';

  @override
  String get measuredIn => 'Measured in';

  @override
  String get grams => 'grams';

  @override
  String get portionSize => 'Portion / piece size';

  @override
  String get optional => 'Optional';

  @override
  String get portionCalled => 'Called';

  @override
  String get portionCalledHelp => 'e.g. slice, piece, glass';

  @override
  String nutritionPer100(String unit) {
    return 'Nutrition per 100 $unit';
  }

  @override
  String get caloriesRequired => 'Calories *';

  @override
  String get required => 'Required';

  @override
  String get enterSizeAboveZero => 'Enter a size above 0';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get saveFood => 'Save food';

  @override
  String get categoryFruitsVegetables => 'Fruits & vegetables';

  @override
  String get categoryMeatFish => 'Meat & fish';

  @override
  String get categoryDairyEggs => 'Dairy & eggs';

  @override
  String get categoryBreadGrains => 'Bread & grains';

  @override
  String get categoryMeals => 'Meals';

  @override
  String get categorySnacksSweets => 'Snacks & sweets';

  @override
  String get categoryDrinks => 'Drinks';

  @override
  String get categoryOther => 'Other';

  @override
  String get exportFoods => 'Export foods';

  @override
  String get importFoods => 'Import foods';

  @override
  String get noFoodsToExport => 'You have no saved foods to export.';

  @override
  String exportedFoods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exported $count foods.',
      one: 'Exported 1 food.',
    );
    return '$_temp0';
  }

  @override
  String get exportFailed => 'Couldn\'t save the file.';

  @override
  String get notAFoodFile => 'This isn\'t a BiteScale food file.';

  @override
  String importNothingNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All $count foods in the file are already in the app.',
      one: 'The food in the file is already in the app.',
    );
    return '$_temp0';
  }

  @override
  String importFoundFoods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foods in the file.',
      one: '1 food in the file.',
    );
    return '$_temp0';
  }

  @override
  String importSkippedDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count are already in the app exactly as they are, so they are skipped.',
      one: '1 is already in the app exactly as it is, so it is skipped.',
    );
    return '$_temp0';
  }

  @override
  String get importNewFoods => 'New foods';

  @override
  String get importSimilarFoods => 'Similar to foods you already have';

  @override
  String get importSimilarHelp => 'Only the differences are shown.';

  @override
  String get selectAll => 'Select all';

  @override
  String get selectNone => 'Select none';

  @override
  String get yours => 'Yours';

  @override
  String get imported => 'Imported';

  @override
  String get keepMine => 'Keep mine';

  @override
  String get useImported => 'Replace mine with the imported one';

  @override
  String get keepBoth => 'Keep both';

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count foods',
      one: 'Import 1 food',
      zero: 'Nothing to import',
    );
    return '$_temp0';
  }

  @override
  String importDone(int added, int replaced) {
    return 'Added $added, replaced $replaced.';
  }

  @override
  String get fieldName => 'Name';

  @override
  String get fieldUnit => 'Unit';

  @override
  String get fieldCalories => 'Calories per 100';

  @override
  String get fieldPhoto => 'Photo';

  @override
  String get noPhoto => 'No photo';

  @override
  String get caloriesByCategory => 'Calories by category';

  @override
  String get smallerCategories => 'Smaller categories';

  @override
  String allFromCategory(String category) {
    return 'All calories this day are from $category.';
  }

  @override
  String get manageCategories => 'Manage categories';

  @override
  String get customCategoriesHelp =>
      'Categories you have created. The built-in categories can\'t be removed.';

  @override
  String get noCustomCategories =>
      'You haven\'t created any categories of your own. The built-in categories can\'t be removed.';

  @override
  String foodCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foods',
      one: '1 food',
      zero: 'No foods',
    );
    return '$_temp0';
  }

  @override
  String get removeCategory => 'Remove category';

  @override
  String removeCategoryTitle(String name) {
    return 'Remove category \"$name\"?';
  }

  @override
  String removeCategoryBody(int count, String other) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foods will be moved to $other.',
      one: '1 food will be moved to $other.',
      zero: 'No foods use it.',
    );
    return '$_temp0';
  }

  @override
  String get close => 'Close';

  @override
  String get shareFoods => 'Share foods';

  @override
  String get shareFood => 'Share this food';

  @override
  String get shareFoodsHelp =>
      'Choose the foods to send. The other person opens the file with BiteScale and chooses which ones to add.';

  @override
  String shareButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Share $count foods',
      one: 'Share 1 food',
      zero: 'Choose foods to share',
    );
    return '$_temp0';
  }

  @override
  String shareFoodsMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Here are $count foods for BiteScale. Open the attached file with BiteScale to add them.',
      one: 'Here is a food for BiteScale. Open the attached file with BiteScale to add it.',
    );
    return '$_temp0';
  }

  @override
  String get shareFoodsSubject => 'BiteScale foods';

  @override
  String get shareFailed => 'Couldn\'t share the foods.';
}
