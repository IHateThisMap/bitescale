// How many calories to eat per day, and how the day's eating compares.
//
// 1. BMR (calories burned at rest) comes from body fat when tape
//    measurements exist (Katch-McArdle), otherwise from weight, height,
//    age and sex (Mifflin-St Jeor).
// 2. Maintenance = BMR × activity level: eating this keeps the weight.
// 3. Target = maintenance − the daily deficit needed to reach the weight
//    goal on time, but never below a safe minimum.

import '../models/user_profile.dart';
import 'body_metrics.dart';
import 'dates.dart';
import 'trend.dart';

/// What it takes to get from the current weight to the goal weight by the
/// goal date.
class GoalPlan {
  GoalPlan({
    required double currentKg,
    required this.goalKg,
    required DateTime goalDate,
    DateTime? today,
  }) : kgToGo = currentKg - goalKg,
       daysLeft = calendarDaysBetween(today ?? DateTime.now(), goalDate);

  final double goalKg;

  /// Positive = weight still to lose, negative = weight still to gain.
  final double kgToGo;
  final int daysLeft;

  bool get isReached => kgToGo.abs() < 0.05;
  bool get isOverdue => daysLeft <= 0;

  /// Average daily calorie deficit needed to hit the goal on time.
  /// Negative means a surplus is needed (goal is above current weight).
  double get dailyDeficit => isOverdue ? 0 : kgToGo * kcalPerKg / daysLeft;
}

/// Lowest daily intake the app recommends without medical supervision.
double minimumDailyKcal(Sex sex) => sex == Sex.male ? 1500 : 1200;

/// Recommended daily calories, from maintenance and the weight goal.
class CalorieTarget {
  const CalorieTarget({
    required this.bmr,
    required this.maintenance,
    required this.usesBodyFat,
    required this.plan,
    required this.target,
    required this.limitedToMinimum,
  });

  /// Basal metabolic rate: calories burned at complete rest.
  final double bmr;

  /// Calories that keep the current weight (TDEE).
  final double maintenance;

  /// True when BMR came from body fat (Katch-McArdle) rather than
  /// age and sex (Mifflin-St Jeor).
  final bool usesBodyFat;

  /// The active weight goal, or null when just maintaining.
  final GoalPlan? plan;

  /// Calories to eat per day.
  final double target;

  /// True when the goal would need fewer calories than is safe, so the
  /// target was raised to [minimumDailyKcal].
  final bool limitedToMinimum;
}

/// Returns null when [profile] lacks the data needed (see
/// [missingForCalorieTarget]).
CalorieTarget? calculateCalorieTarget(
  UserProfile profile,
  double? latestKg, {
  DateTime? today,
}) {
  if (missingForCalorieTarget(profile, latestKg).isNotEmpty) return null;
  final now = today ?? DateTime.now();
  final weight = latestKg!;
  final sex = profile.sex!;

  final bodyFat = profileBodyFat(profile);
  final double bmr;
  if (bodyFat != null) {
    // Katch-McArdle, based on lean body mass.
    bmr = 370 + 21.6 * weight * (1 - bodyFat / 100);
  } else {
    // Mifflin-St Jeor.
    final age = now.year - profile.birthYear!;
    bmr =
        10 * weight +
        6.25 * profile.heightCm! -
        5 * age +
        (sex == Sex.male ? 5 : -161);
  }
  final maintenance = bmr * profile.activityLevel!.factor;

  GoalPlan? plan;
  if (profile.hasGoal) {
    final p = GoalPlan(
      currentKg: weight,
      goalKg: profile.goalWeightKg!,
      goalDate: profile.goalDate!,
      today: now,
    );
    if (!p.isReached && !p.isOverdue) plan = p;
  }

  var target = maintenance - (plan?.dailyDeficit ?? 0);
  final minimum = minimumDailyKcal(sex);
  final limited = target < minimum;
  if (limited) target = minimum;

  return CalorieTarget(
    bmr: bmr,
    maintenance: maintenance,
    usesBodyFat: bodyFat != null,
    plan: plan,
    target: target,
    limitedToMinimum: limited,
  );
}

/// What's missing to calculate a calorie target (English, for debugging
/// and tests; the app shows its own translated hints).
List<String> missingForCalorieTarget(UserProfile profile, double? latestKg) => [
  if (latestKg == null) 'weight',
  if (profile.sex == null) 'sex',
  if (profile.birthYear == null) 'age',
  if (profile.activityLevel == null) 'activity level',
];

/// How the day's eating compares to the calorie target and maintenance.
enum IntakeStatus {
  /// At or under the target (green).
  withinGoal,

  /// Clearly over the target, but still under maintenance, i.e. still in
  /// calorie deficit (yellow). For weight gain goals: over the target.
  overGoal,

  /// Eaten at least as much as is burned: no calorie deficit left (red).
  noDeficit,
}

/// How far over the target still counts as "at the goal".
const goalToleranceKcal = 50.0;

IntakeStatus intakeStatus({
  required double eaten,
  required double target,
  required double maintenance,
}) {
  // Only when the target keeps you at or under maintenance does reaching
  // maintenance mean failing it. Maintaining gets the same small margin
  // as the goal itself.
  if (target <= maintenance) {
    final deficitEnds = target >= maintenance
        ? maintenance + goalToleranceKcal
        : maintenance;
    if (eaten >= deficitEnds) return IntakeStatus.noDeficit;
  }
  return eaten <= target + goalToleranceKcal
      ? IntakeStatus.withinGoal
      : IntakeStatus.overGoal;
}
