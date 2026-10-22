import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fi'),
  ];

  /// Name of this language in the language itself, shown in the language picker.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName;

  /// Flag emoji shown on the language button and in the language picker.
  ///
  /// In en, this message translates to:
  /// **'🇬🇧'**
  String get languageFlag;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BiteScale'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @valueBetween.
  ///
  /// In en, this message translates to:
  /// **'Enter a value between {min} and {max}'**
  String valueBetween(String min, String max);

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @heightQuestion.
  ///
  /// In en, this message translates to:
  /// **'How tall are you? Your height is used to calculate your BMI.'**
  String get heightQuestion;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @heightError.
  ///
  /// In en, this message translates to:
  /// **'Enter your height in centimetres'**
  String get heightError;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @editHeight.
  ///
  /// In en, this message translates to:
  /// **'Edit height'**
  String get editHeight;

  /// No description provided for @yourHeight.
  ///
  /// In en, this message translates to:
  /// **'Your height'**
  String get yourHeight;

  /// No description provided for @addWeight.
  ///
  /// In en, this message translates to:
  /// **'Add weight'**
  String get addWeight;

  /// No description provided for @noWeightEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries yet.\nTap \"Add weight\" to start.'**
  String get noWeightEntries;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noWeightsInRange.
  ///
  /// In en, this message translates to:
  /// **'No weights recorded in this period.\nDrag the slider left to see further back.'**
  String get noWeightsInRange;

  /// No description provided for @showingLastDays.
  ///
  /// In en, this message translates to:
  /// **'Last {days} days'**
  String showingLastDays(int days);

  /// No description provided for @rangeDays.
  ///
  /// In en, this message translates to:
  /// **'{days} d'**
  String rangeDays(int days);

  /// No description provided for @rangeMonths.
  ///
  /// In en, this message translates to:
  /// **'{months} mo'**
  String rangeMonths(int months);

  /// No description provided for @rangeYears.
  ///
  /// In en, this message translates to:
  /// **'{years} yr'**
  String rangeYears(String years);

  /// No description provided for @oneDayLess.
  ///
  /// In en, this message translates to:
  /// **'One day less'**
  String get oneDayLess;

  /// No description provided for @oneDayMore.
  ///
  /// In en, this message translates to:
  /// **'One day more'**
  String get oneDayMore;

  /// No description provided for @weightSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log your weight regularly to see your trend and BMI.'**
  String get weightSummaryEmpty;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @totalChange.
  ///
  /// In en, this message translates to:
  /// **'Total change: {change} kg'**
  String totalChange(String change);

  /// No description provided for @trendNeedsTwo.
  ///
  /// In en, this message translates to:
  /// **'Add at least two entries on different days to calculate a trend line.'**
  String get trendNeedsTwo;

  /// No description provided for @trendPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Trend: {change} kg / week'**
  String trendPerWeek(String change);

  /// No description provided for @estimatedDeficit.
  ///
  /// In en, this message translates to:
  /// **'Estimated deficit: {kcal} kcal / day'**
  String estimatedDeficit(int kcal);

  /// No description provided for @estimatedSurplus.
  ///
  /// In en, this message translates to:
  /// **'Estimated surplus: {kcal} kcal / day'**
  String estimatedSurplus(int kcal);

  /// No description provided for @enterValidWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight'**
  String get enterValidWeight;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @bmiUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmiUnderweight;

  /// No description provided for @bmiNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal weight'**
  String get bmiNormal;

  /// No description provided for @bmiOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmiOverweight;

  /// No description provided for @bmiObese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bmiObese;

  /// No description provided for @bodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body fat'**
  String get bodyFat;

  /// No description provided for @bodyFatEssential.
  ///
  /// In en, this message translates to:
  /// **'Essential fat'**
  String get bodyFatEssential;

  /// No description provided for @bodyFatAthletic.
  ///
  /// In en, this message translates to:
  /// **'Athletic'**
  String get bodyFatAthletic;

  /// No description provided for @bodyFatFit.
  ///
  /// In en, this message translates to:
  /// **'Fit'**
  String get bodyFatFit;

  /// No description provided for @bodyFatAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get bodyFatAverage;

  /// No description provided for @bodyFatObese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bodyFatObese;

  /// No description provided for @tapToAddMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Tap to add measurements'**
  String get tapToAddMeasurements;

  /// No description provided for @fatAndLean.
  ///
  /// In en, this message translates to:
  /// **'{fat} kg fat · {lean} kg lean'**
  String fatAndLean(String fat, String lean);

  /// No description provided for @measuredOn.
  ///
  /// In en, this message translates to:
  /// **'Measured {date}'**
  String measuredOn(String date);

  /// No description provided for @setGoal.
  ///
  /// In en, this message translates to:
  /// **'Set a weight goal'**
  String get setGoal;

  /// No description provided for @setGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See the daily calorie deficit you need'**
  String get setGoalSubtitle;

  /// No description provided for @goalNeedsWeight.
  ///
  /// In en, this message translates to:
  /// **'Add your weight to see what it takes to get there.'**
  String get goalNeedsWeight;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached! 🎉'**
  String get goalReached;

  /// No description provided for @goalOverdue.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg to go, but the goal date has passed. Set a new date.'**
  String goalOverdue(String kg);

  /// No description provided for @kgToLose.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{{kg} kg to lose in 1 day} other{{kg} kg to lose in {days} days}}'**
  String kgToLose(String kg, int days);

  /// No description provided for @kgToGain.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{{kg} kg to gain in 1 day} other{{kg} kg to gain in {days} days}}'**
  String kgToGain(String kg, int days);

  /// No description provided for @neededDeficit.
  ///
  /// In en, this message translates to:
  /// **'Needed: {kcal} kcal deficit / day'**
  String neededDeficit(int kcal);

  /// No description provided for @neededSurplus.
  ///
  /// In en, this message translates to:
  /// **'Needed: {kcal} kcal surplus / day'**
  String neededSurplus(int kcal);

  /// No description provided for @tooFastPace.
  ///
  /// In en, this message translates to:
  /// **'That is a very fast pace. Consider a later goal date.'**
  String get tooFastPace;

  /// No description provided for @currentTrendDeficit.
  ///
  /// In en, this message translates to:
  /// **'Your current trend: deficit of {kcal} kcal / day'**
  String currentTrendDeficit(int kcal);

  /// No description provided for @currentTrendSurplus.
  ///
  /// In en, this message translates to:
  /// **'Your current trend: surplus of {kcal} kcal / day'**
  String currentTrendSurplus(int kcal);

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal: {kg} kg by {date}'**
  String goalTitle(String kg, String date);

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get editGoal;

  /// No description provided for @removeGoal.
  ///
  /// In en, this message translates to:
  /// **'Remove goal'**
  String get removeGoal;

  /// No description provided for @weightGoal.
  ///
  /// In en, this message translates to:
  /// **'Weight goal'**
  String get weightGoal;

  /// No description provided for @goalWeight.
  ///
  /// In en, this message translates to:
  /// **'Goal weight'**
  String get goalWeight;

  /// No description provided for @goalDate.
  ///
  /// In en, this message translates to:
  /// **'Reach it by'**
  String get goalDate;

  /// No description provided for @chartGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get chartGoal;

  /// No description provided for @bodyComposition.
  ///
  /// In en, this message translates to:
  /// **'Body composition'**
  String get bodyComposition;

  /// No description provided for @tapeMeasure.
  ///
  /// In en, this message translates to:
  /// **'Tape measure'**
  String get tapeMeasure;

  /// No description provided for @bmiExplanation.
  ///
  /// In en, this message translates to:
  /// **'BMI is calculated from your height and latest weight. It doesn\'t tell fat and muscle apart.'**
  String get bmiExplanation;

  /// No description provided for @navyExplanation.
  ///
  /// In en, this message translates to:
  /// **'U.S. Navy method: estimates body fat percentage from tape measurements and your height.'**
  String get navyExplanation;

  /// No description provided for @neck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get neck;

  /// No description provided for @waist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get waist;

  /// No description provided for @hips.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get hips;

  /// No description provided for @neckHelp.
  ///
  /// In en, this message translates to:
  /// **'Just below the larynx (Adam\'s apple), tape sloping slightly down to the front'**
  String get neckHelp;

  /// No description provided for @waistHelpMale.
  ///
  /// In en, this message translates to:
  /// **'Horizontally at the level of the navel'**
  String get waistHelpMale;

  /// No description provided for @waistHelpFemale.
  ///
  /// In en, this message translates to:
  /// **'At the narrowest point of the waist'**
  String get waistHelpFemale;

  /// No description provided for @hipsHelp.
  ///
  /// In en, this message translates to:
  /// **'At the widest point of the buttocks'**
  String get hipsHelp;

  /// No description provided for @bodyFatPreview.
  ///
  /// In en, this message translates to:
  /// **'Body fat: {value}'**
  String bodyFatPreview(String value);

  /// No description provided for @heightUsed.
  ///
  /// In en, this message translates to:
  /// **'Height used: {cm} cm'**
  String heightUsed(String cm);

  /// No description provided for @chooseSex.
  ///
  /// In en, this message translates to:
  /// **'Choose male or female'**
  String get chooseSex;

  /// No description provided for @enterAllMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Enter all measurements in centimetres'**
  String get enterAllMeasurements;

  /// No description provided for @invalidMeasurements.
  ///
  /// In en, this message translates to:
  /// **'These measurements don\'t give a valid result. Check them again.'**
  String get invalidMeasurements;

  /// No description provided for @dailyCalorieNeeds.
  ///
  /// In en, this message translates to:
  /// **'Daily calorie needs'**
  String get dailyCalorieNeeds;

  /// No description provided for @calorieProfileIntro.
  ///
  /// In en, this message translates to:
  /// **'Used together with your height and latest weight to estimate how many calories you burn per day.'**
  String get calorieProfileIntro;

  /// No description provided for @birthYear.
  ///
  /// In en, this message translates to:
  /// **'Year of birth'**
  String get birthYear;

  /// No description provided for @invalidBirthYear.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid year of birth'**
  String get invalidBirthYear;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity level'**
  String get activityLevel;

  /// No description provided for @chooseActivity.
  ///
  /// In en, this message translates to:
  /// **'Choose your activity level'**
  String get chooseActivity;

  /// No description provided for @activitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get activitySedentary;

  /// No description provided for @activitySedentaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Little or no exercise, desk job'**
  String get activitySedentaryDesc;

  /// No description provided for @activityLight.
  ///
  /// In en, this message translates to:
  /// **'Lightly active'**
  String get activityLight;

  /// No description provided for @activityLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Light exercise 1–3 days a week'**
  String get activityLightDesc;

  /// No description provided for @activityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderately active'**
  String get activityModerate;

  /// No description provided for @activityModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'Exercise 3–5 days a week'**
  String get activityModerateDesc;

  /// No description provided for @activityActive.
  ///
  /// In en, this message translates to:
  /// **'Very active'**
  String get activityActive;

  /// No description provided for @activityActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Hard exercise 6–7 days a week'**
  String get activityActiveDesc;

  /// No description provided for @activityExtreme.
  ///
  /// In en, this message translates to:
  /// **'Extremely active'**
  String get activityExtreme;

  /// No description provided for @activityExtremeDesc.
  ///
  /// In en, this message translates to:
  /// **'Physical job plus hard training'**
  String get activityExtremeDesc;

  /// No description provided for @myFoods.
  ///
  /// In en, this message translates to:
  /// **'My foods'**
  String get myFoods;

  /// No description provided for @addFood.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get addFood;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @addToFavourites.
  ///
  /// In en, this message translates to:
  /// **'Add to favourites'**
  String get addToFavourites;

  /// No description provided for @removeFromFavourites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourites'**
  String get removeFromFavourites;

  /// No description provided for @eaten.
  ///
  /// In en, this message translates to:
  /// **'Eaten'**
  String get eaten;

  /// No description provided for @nothingLogged.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged for this day.'**
  String get nothingLogged;

  /// No description provided for @kcalEaten.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal eaten'**
  String kcalEaten(int kcal);

  /// No description provided for @needWeightForTarget.
  ///
  /// In en, this message translates to:
  /// **'Add your weight to see how much you should eat per day.'**
  String get needWeightForTarget;

  /// No description provided for @needInfoForTarget.
  ///
  /// In en, this message translates to:
  /// **'Tell the app a bit more about you to see how much you should eat per day.'**
  String get needInfoForTarget;

  /// No description provided for @goToWeightPage.
  ///
  /// In en, this message translates to:
  /// **'Go to weight page'**
  String get goToWeightPage;

  /// No description provided for @setUpCalorieTarget.
  ///
  /// In en, this message translates to:
  /// **'Set up daily calorie target'**
  String get setUpCalorieTarget;

  /// No description provided for @targetGoalDone.
  ///
  /// In en, this message translates to:
  /// **'Your goal is reached or its date has passed, so the target keeps your current weight.'**
  String get targetGoalDone;

  /// No description provided for @targetNoGoal.
  ///
  /// In en, this message translates to:
  /// **'No weight goal set, so the target keeps your current weight.'**
  String get targetNoGoal;

  /// No description provided for @targetDeficitToGoal.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{{kcal} kcal deficit / day to reach {kg} kg in 1 day} other{{kcal} kcal deficit / day to reach {kg} kg in {days} days}}'**
  String targetDeficitToGoal(int kcal, String kg, int days);

  /// No description provided for @targetSurplusToGoal.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{{kcal} kcal surplus / day to reach {kg} kg in 1 day} other{{kcal} kcal surplus / day to reach {kg} kg in {days} days}}'**
  String targetSurplusToGoal(int kcal, String kg, int days);

  /// No description provided for @dailyTarget.
  ///
  /// In en, this message translates to:
  /// **'Daily target: {kcal} kcal'**
  String dailyTarget(int kcal);

  /// No description provided for @calorieProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Age, sex and activity'**
  String get calorieProfileTooltip;

  /// No description provided for @overTarget.
  ///
  /// In en, this message translates to:
  /// **'Over target'**
  String get overTarget;

  /// No description provided for @leftToEat.
  ///
  /// In en, this message translates to:
  /// **'Left to eat'**
  String get leftToEat;

  /// No description provided for @deficitLeft.
  ///
  /// In en, this message translates to:
  /// **'Deficit left'**
  String get deficitLeft;

  /// No description provided for @overMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Over maintenance'**
  String get overMaintenance;

  /// No description provided for @barGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get barGoal;

  /// No description provided for @barDeficitEnds.
  ///
  /// In en, this message translates to:
  /// **'Deficit ends'**
  String get barDeficitEnds;

  /// No description provided for @statusWithinGoalDeficit.
  ///
  /// In en, this message translates to:
  /// **'Within your goal and in calorie deficit.'**
  String get statusWithinGoalDeficit;

  /// No description provided for @statusWithinGoal.
  ///
  /// In en, this message translates to:
  /// **'Within your goal.'**
  String get statusWithinGoal;

  /// No description provided for @statusOverGoalDeficit.
  ///
  /// In en, this message translates to:
  /// **'Over your goal, but still in calorie deficit.'**
  String get statusOverGoalDeficit;

  /// No description provided for @statusOverGoal.
  ///
  /// In en, this message translates to:
  /// **'Over your goal.'**
  String get statusOverGoal;

  /// No description provided for @statusNoDeficit.
  ///
  /// In en, this message translates to:
  /// **'No calorie deficit left: you have eaten as much as you burn.'**
  String get statusNoDeficit;

  /// No description provided for @maintenanceLine.
  ///
  /// In en, this message translates to:
  /// **'To keep your current weight: {kcal} kcal / day'**
  String maintenanceLine(int kcal);

  /// No description provided for @minimumWarning.
  ///
  /// In en, this message translates to:
  /// **'Reaching your goal by its date would need eating less than {kcal} kcal a day, which isn\'t recommended. The target is limited to that, so consider a later goal date.'**
  String minimumWarning(int kcal);

  /// No description provided for @estimateBodyFat.
  ///
  /// In en, this message translates to:
  /// **'Estimate based on your body fat (Katch-McArdle) and activity level.'**
  String get estimateBodyFat;

  /// No description provided for @estimateMifflin.
  ///
  /// In en, this message translates to:
  /// **'Estimate based on your age, sex, height, weight (Mifflin-St Jeor) and activity level.'**
  String get estimateMifflin;

  /// No description provided for @nutrientProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get nutrientProtein;

  /// No description provided for @nutrientCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get nutrientCarbs;

  /// No description provided for @nutrientSugar.
  ///
  /// In en, this message translates to:
  /// **'of which sugars'**
  String get nutrientSugar;

  /// No description provided for @nutrientFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get nutrientFat;

  /// No description provided for @nutrientFiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get nutrientFiber;

  /// No description provided for @nutrientSalt.
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get nutrientSalt;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @portionDefault.
  ///
  /// In en, this message translates to:
  /// **'portion'**
  String get portionDefault;

  /// No description provided for @portionCount.
  ///
  /// In en, this message translates to:
  /// **'Number of portions'**
  String get portionCount;

  /// No description provided for @kcalPer100.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal per 100 {unit}'**
  String kcalPer100(String kcal, String unit);

  /// No description provided for @newFood.
  ///
  /// In en, this message translates to:
  /// **'New food'**
  String get newFood;

  /// No description provided for @searchFoods.
  ///
  /// In en, this message translates to:
  /// **'Search foods'**
  String get searchFoods;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noSavedFoods.
  ///
  /// In en, this message translates to:
  /// **'No saved foods yet.\nTap \"New food\" to add one.'**
  String get noSavedFoods;

  /// No description provided for @noFoodsMatch.
  ///
  /// In en, this message translates to:
  /// **'No foods match.'**
  String get noFoodsMatch;

  /// No description provided for @deleteFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete food template \"{name}\"?'**
  String deleteFoodTitle(String name);

  /// No description provided for @deleteFoodBody.
  ///
  /// In en, this message translates to:
  /// **'It is removed from your saved foods. Days where you already logged it are not changed.'**
  String get deleteFoodBody;

  /// No description provided for @deleteFoodTemplate.
  ///
  /// In en, this message translates to:
  /// **'Delete food template'**
  String get deleteFoodTemplate;

  /// No description provided for @removeFromEaten.
  ///
  /// In en, this message translates to:
  /// **'Remove from eaten'**
  String get removeFromEaten;

  /// No description provided for @removeFromEatenTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from eaten?'**
  String removeFromEatenTitle(String name);

  /// No description provided for @editFood.
  ///
  /// In en, this message translates to:
  /// **'Edit food'**
  String get editFood;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get nameRequired;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @measuredIn.
  ///
  /// In en, this message translates to:
  /// **'Measured in'**
  String get measuredIn;

  /// No description provided for @grams.
  ///
  /// In en, this message translates to:
  /// **'grams'**
  String get grams;

  /// No description provided for @portionSize.
  ///
  /// In en, this message translates to:
  /// **'Portion / piece size'**
  String get portionSize;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @portionCalled.
  ///
  /// In en, this message translates to:
  /// **'Called'**
  String get portionCalled;

  /// No description provided for @portionCalledHelp.
  ///
  /// In en, this message translates to:
  /// **'e.g. slice, piece, glass'**
  String get portionCalledHelp;

  /// No description provided for @nutritionPer100.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per 100 {unit}'**
  String nutritionPer100(String unit);

  /// No description provided for @caloriesRequired.
  ///
  /// In en, this message translates to:
  /// **'Calories *'**
  String get caloriesRequired;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @enterSizeAboveZero.
  ///
  /// In en, this message translates to:
  /// **'Enter a size above 0'**
  String get enterSizeAboveZero;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @saveFood.
  ///
  /// In en, this message translates to:
  /// **'Save food'**
  String get saveFood;

  /// No description provided for @categoryFruitsVegetables.
  ///
  /// In en, this message translates to:
  /// **'Fruits & vegetables'**
  String get categoryFruitsVegetables;

  /// No description provided for @categoryMeatFish.
  ///
  /// In en, this message translates to:
  /// **'Meat & fish'**
  String get categoryMeatFish;

  /// No description provided for @categoryDairyEggs.
  ///
  /// In en, this message translates to:
  /// **'Dairy & eggs'**
  String get categoryDairyEggs;

  /// No description provided for @categoryBreadGrains.
  ///
  /// In en, this message translates to:
  /// **'Bread & grains'**
  String get categoryBreadGrains;

  /// No description provided for @categoryMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get categoryMeals;

  /// No description provided for @categorySnacksSweets.
  ///
  /// In en, this message translates to:
  /// **'Snacks & sweets'**
  String get categorySnacksSweets;

  /// No description provided for @categoryDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get categoryDrinks;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @exportFoods.
  ///
  /// In en, this message translates to:
  /// **'Export foods'**
  String get exportFoods;

  /// No description provided for @importFoods.
  ///
  /// In en, this message translates to:
  /// **'Import foods'**
  String get importFoods;

  /// No description provided for @noFoodsToExport.
  ///
  /// In en, this message translates to:
  /// **'You have no saved foods to export.'**
  String get noFoodsToExport;

  /// No description provided for @exportedFoods.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Exported 1 food.} other{Exported {count} foods.}}'**
  String exportedFoods(int count);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the file.'**
  String get exportFailed;

  /// No description provided for @notAFoodFile.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t a BiteScale food file.'**
  String get notAFoodFile;

  /// No description provided for @importNothingNew.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The food in the file is already in the app.} other{All {count} foods in the file are already in the app.}}'**
  String importNothingNew(int count);

  /// No description provided for @importFoundFoods.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 food in the file.} other{{count} foods in the file.}}'**
  String importFoundFoods(int count);

  /// No description provided for @importSkippedDuplicates.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 is already in the app exactly as it is, so it is skipped.} other{{count} are already in the app exactly as they are, so they are skipped.}}'**
  String importSkippedDuplicates(int count);

  /// No description provided for @importNewFoods.
  ///
  /// In en, this message translates to:
  /// **'New foods'**
  String get importNewFoods;

  /// No description provided for @importSimilarFoods.
  ///
  /// In en, this message translates to:
  /// **'Similar to foods you already have'**
  String get importSimilarFoods;

  /// No description provided for @importSimilarHelp.
  ///
  /// In en, this message translates to:
  /// **'Only the differences are shown.'**
  String get importSimilarHelp;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @selectNone.
  ///
  /// In en, this message translates to:
  /// **'Select none'**
  String get selectNone;

  /// No description provided for @yours.
  ///
  /// In en, this message translates to:
  /// **'Yours'**
  String get yours;

  /// No description provided for @imported.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get imported;

  /// No description provided for @keepMine.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get keepMine;

  /// No description provided for @useImported.
  ///
  /// In en, this message translates to:
  /// **'Replace mine with the imported one'**
  String get useImported;

  /// No description provided for @keepBoth.
  ///
  /// In en, this message translates to:
  /// **'Keep both'**
  String get keepBoth;

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing to import} =1{Import 1 food} other{Import {count} foods}}'**
  String importButton(int count);

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'Added {added}, replaced {replaced}.'**
  String importDone(int added, int replaced);

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get fieldUnit;

  /// No description provided for @fieldCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories per 100'**
  String get fieldCalories;

  /// No description provided for @fieldPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get fieldPhoto;

  /// No description provided for @noPhoto.
  ///
  /// In en, this message translates to:
  /// **'No photo'**
  String get noPhoto;

  /// No description provided for @caloriesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Calories by category'**
  String get caloriesByCategory;

  /// No description provided for @smallerCategories.
  ///
  /// In en, this message translates to:
  /// **'Smaller categories'**
  String get smallerCategories;

  /// No description provided for @allFromCategory.
  ///
  /// In en, this message translates to:
  /// **'All calories this day are from {category}.'**
  String allFromCategory(String category);

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get manageCategories;

  /// No description provided for @customCategoriesHelp.
  ///
  /// In en, this message translates to:
  /// **'Categories you have created. The built-in categories can\'t be removed.'**
  String get customCategoriesHelp;

  /// No description provided for @noCustomCategories.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any categories of your own. The built-in categories can\'t be removed.'**
  String get noCustomCategories;

  /// No description provided for @foodCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No foods} =1{1 food} other{{count} foods}}'**
  String foodCount(int count);

  /// No description provided for @removeCategory.
  ///
  /// In en, this message translates to:
  /// **'Remove category'**
  String get removeCategory;

  /// No description provided for @removeCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove category \"{name}\"?'**
  String removeCategoryTitle(String name);

  /// No description provided for @removeCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No foods use it.} =1{1 food will be moved to {other}.} other{{count} foods will be moved to {other}.}}'**
  String removeCategoryBody(int count, String other);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @shareFoods.
  ///
  /// In en, this message translates to:
  /// **'Share foods'**
  String get shareFoods;

  /// No description provided for @shareFood.
  ///
  /// In en, this message translates to:
  /// **'Share this food'**
  String get shareFood;

  /// No description provided for @shareFoodsHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose the foods to send. The other person opens the file with BiteScale and chooses which ones to add.'**
  String get shareFoodsHelp;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Choose foods to share} =1{Share 1 food} other{Share {count} foods}}'**
  String shareButton(int count);

  /// No description provided for @shareFoodsMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Here is a food for BiteScale. Open the attached file with BiteScale to add it.} other{Here are {count} foods for BiteScale. Open the attached file with BiteScale to add them.}}'**
  String shareFoodsMessage(int count);

  /// No description provided for @shareFoodsSubject.
  ///
  /// In en, this message translates to:
  /// **'BiteScale foods'**
  String get shareFoodsSubject;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share the foods.'**
  String get shareFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fi':
      return AppLocalizationsFi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
