/// How body composition is shown on the weight page.
enum BodyMetric { bmi, navyBodyFat }

enum Sex { male, female }

/// Multipliers that turn BMR into total daily energy expenditure.
/// Display names are in the translations (see lib/l10n/labels.dart).
enum ActivityLevel {
  sedentary(1.2),
  light(1.375),
  moderate(1.55),
  active(1.725),
  extreme(1.9);

  const ActivityLevel(this.factor);
  final double factor;
}

class UserProfile {
  const UserProfile({
    this.heightCm,
    this.goalWeightKg,
    this.goalDate,
    this.bodyMetric = BodyMetric.bmi,
    this.sex,
    this.neckCm,
    this.waistCm,
    this.hipCm,
    this.measuredAt,
    this.birthYear,
    this.activityLevel,
  });

  final double? heightCm;
  final int? birthYear;
  final ActivityLevel? activityLevel;
  final double? goalWeightKg;
  final DateTime? goalDate;

  final BodyMetric bodyMetric;

  // Tape measurements for the U.S. Navy body fat method.
  final Sex? sex;
  final double? neckCm;
  final double? waistCm;

  /// Only used for women.
  final double? hipCm;
  final DateTime? measuredAt;

  bool get hasGoal => goalWeightKg != null && goalDate != null;

  UserProfile copyWith({
    double? heightCm,
    BodyMetric? bodyMetric,
    Sex? sex,
    double? neckCm,
    double? waistCm,
    double? hipCm,
    DateTime? measuredAt,
    int? birthYear,
    ActivityLevel? activityLevel,
  }) =>
      UserProfile(
        heightCm: heightCm ?? this.heightCm,
        goalWeightKg: goalWeightKg,
        goalDate: goalDate,
        bodyMetric: bodyMetric ?? this.bodyMetric,
        sex: sex ?? this.sex,
        neckCm: neckCm ?? this.neckCm,
        waistCm: waistCm ?? this.waistCm,
        hipCm: hipCm ?? this.hipCm,
        measuredAt: measuredAt ?? this.measuredAt,
        birthYear: birthYear ?? this.birthYear,
        activityLevel: activityLevel ?? this.activityLevel,
      );

  UserProfile withHeight(double heightCm) => copyWith(heightCm: heightCm);

  /// Sets or (with nulls) clears the goal.
  UserProfile withGoal(double? goalWeightKg, DateTime? goalDate) =>
      UserProfile(
        heightCm: heightCm,
        goalWeightKg: goalWeightKg,
        goalDate: goalDate,
        bodyMetric: bodyMetric,
        sex: sex,
        neckCm: neckCm,
        waistCm: waistCm,
        hipCm: hipCm,
        measuredAt: measuredAt,
        birthYear: birthYear,
        activityLevel: activityLevel,
      );

  Map<String, dynamic> toJson() => {
        'heightCm': heightCm,
        'goalWeightKg': goalWeightKg,
        'goalDate': goalDate?.toIso8601String(),
        'bodyMetric': bodyMetric.name,
        'sex': sex?.name,
        'neckCm': neckCm,
        'waistCm': waistCm,
        'hipCm': hipCm,
        'measuredAt': measuredAt?.toIso8601String(),
        'birthYear': birthYear,
        'activityLevel': activityLevel?.name,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    double? d(String key) => (json[key] as num?)?.toDouble();
    DateTime? date(String key) =>
        json[key] == null ? null : DateTime.parse(json[key] as String);
    return UserProfile(
      heightCm: d('heightCm'),
      goalWeightKg: d('goalWeightKg'),
      goalDate: date('goalDate'),
      bodyMetric: BodyMetric.values.asNameMap()[json['bodyMetric']] ??
          BodyMetric.bmi,
      sex: Sex.values.asNameMap()[json['sex']],
      neckCm: d('neckCm'),
      waistCm: d('waistCm'),
      hipCm: d('hipCm'),
      measuredAt: date('measuredAt'),
      birthYear: (json['birthYear'] as num?)?.toInt(),
      activityLevel: ActivityLevel.values.asNameMap()[json['activityLevel']],
    );
  }
}
