// Body composition shown on the weight page: BMI, or body fat percentage
// from tape measurements (U.S. Navy method).

import 'dart:math' as math;

import '../models/user_profile.dart';

double calculateBmi(double weightKg, double heightCm) {
  final m = heightCm / 100;
  return weightKg / (m * m);
}

enum BmiCategory { underweight, normal, overweight, obese }

BmiCategory bmiCategory(double bmi) {
  if (bmi < 18.5) return BmiCategory.underweight;
  if (bmi < 25) return BmiCategory.normal;
  if (bmi < 30) return BmiCategory.overweight;
  return BmiCategory.obese;
}

enum BodyFatCategory { essential, athletic, fit, average, obese }

double _log10(double x) => math.log(x) / math.ln10;

/// Body fat percentage with the U.S. Navy circumference method.
/// All measurements in centimetres; [hipCm] is needed for women only.
/// Returns null if the measurements can't produce a valid result.
double? navyBodyFat({
  required Sex sex,
  required double heightCm,
  required double neckCm,
  required double waistCm,
  double? hipCm,
}) {
  final double result;
  if (sex == Sex.male) {
    if (waistCm <= neckCm) return null;
    result =
        495 /
            (1.0324 -
                0.19077 * _log10(waistCm - neckCm) +
                0.15456 * _log10(heightCm)) -
        450;
  } else {
    if (hipCm == null || waistCm + hipCm <= neckCm) return null;
    result =
        495 /
            (1.29579 -
                0.35004 * _log10(waistCm + hipCm - neckCm) +
                0.22100 * _log10(heightCm)) -
        450;
  }
  return result.isFinite && result > 0 && result < 75 ? result : null;
}

/// Body fat percentage for the measurements stored in [profile].
double? profileBodyFat(UserProfile profile) {
  final sex = profile.sex;
  final height = profile.heightCm;
  final neck = profile.neckCm;
  final waist = profile.waistCm;
  if (sex == null || height == null || neck == null || waist == null) {
    return null;
  }
  return navyBodyFat(
    sex: sex,
    heightCm: height,
    neckCm: neck,
    waistCm: waist,
    hipCm: profile.hipCm,
  );
}

/// Categories from the American Council on Exercise.
BodyFatCategory bodyFatCategory(Sex sex, double percent) {
  final limits = sex == Sex.male ? [6, 14, 18, 25] : [14, 21, 25, 32];
  if (percent < limits[0]) return BodyFatCategory.essential;
  if (percent < limits[1]) return BodyFatCategory.athletic;
  if (percent < limits[2]) return BodyFatCategory.fit;
  if (percent < limits[3]) return BodyFatCategory.average;
  return BodyFatCategory.obese;
}
