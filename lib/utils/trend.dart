import '../models/weight_entry.dart';

/// Roughly 7700 kcal of energy is stored in 1 kg of body fat.
const double kcalPerKg = 7700;

/// A straight line `weight = intercept + slope * days` fitted to the entries.
class WeightTrend {
  const WeightTrend({required this.slopeKgPerDay, required this.intercept});

  final double slopeKgPerDay;
  final double intercept;

  double weightAt(double days) => intercept + slopeKgPerDay * days;

  double get kgPerWeek => slopeKgPerDay * 7;

  /// Average daily calorie balance implied by the trend.
  /// Negative = deficit (losing weight), positive = surplus.
  double get dailyCalorieBalance => slopeKgPerDay * kcalPerKg;
}

/// Days elapsed since [origin], as a fractional number.
double daysSince(DateTime origin, DateTime date) =>
    date.difference(origin).inMinutes / (60 * 24);

/// Fits a least-squares line through the entries.
/// Returns null when there isn't enough data to fit a line.
WeightTrend? calculateTrend(List<WeightEntry> entries) {
  if (entries.length < 2) return null;
  final origin = entries.first.date;
  final xs = entries.map((e) => daysSince(origin, e.date)).toList();
  final ys = entries.map((e) => e.weightKg).toList();
  final n = entries.length;

  final meanX = xs.reduce((a, b) => a + b) / n;
  final meanY = ys.reduce((a, b) => a + b) / n;

  var num = 0.0;
  var den = 0.0;
  for (var i = 0; i < n; i++) {
    num += (xs[i] - meanX) * (ys[i] - meanY);
    den += (xs[i] - meanX) * (xs[i] - meanX);
  }
  // All entries on the same moment: no meaningful slope.
  if (den == 0) return null;

  final slope = num / den;
  return WeightTrend(slopeKgPerDay: slope, intercept: meanY - slope * meanX);
}
