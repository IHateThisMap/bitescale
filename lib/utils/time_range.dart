import 'dart:math' as math;

/// Shortest time range the weight graph can show, in days.
const minRangeDays = 4;
const _week = 7;
const _month = 30;
const _sixMonths = 182;
const _twoYears = 730;
const _standardMarks = [minRangeDays, _month, _sixMonths, _twoYears];

/// Maps a slider position (0 = shortest, 1 = longest) to a number of days.
///
/// The marks (4 days, 1 month, 6 months, 2 years) that the recorded
/// weights reach sit at equal distances on the slider. The longest range
/// is the whole recorded history, but at least a month; history older
/// than 2 years continues past the 2 year mark. Moving along the slider,
/// the range grows faster and faster: the first section (4 days to 1
/// month) grows geometrically for fine control, and each later section
/// steadily, at least as fast as the section before ended.
class TimeRangeScale {
  /// [historyDays] is how far back the oldest recorded weight is.
  factory TimeRangeScale(int historyDays) {
    final maxDays = math.max(historyDays, _month);
    final days = <int>[minRangeDays];
    for (final mark in [_month, _sixMonths, _twoYears]) {
      if (maxDays > mark) days.add(mark);
    }
    days.add(maxDays);

    // Section widths: one each for full sections between standard marks.
    // A shorter last section (e.g. 6 months to 200 days) gets a width that
    // keeps its speed at least the previous section's, so it never slows.
    final widths = <double>[];
    var endSpeed = 0.0; // days per slider unit at the end of the last section
    for (var i = 1; i < days.length; i++) {
      final from = days[i - 1], to = days[i];
      final full = _standardMarks.contains(to);
      if (i == 1) {
        widths.add(1);
        endSpeed = to * math.log(to / from); // geometric section
      } else {
        final width = full ? 1.0 : math.min(1.0, (to - from) / endSpeed);
        widths.add(width);
        endSpeed = (to - from) / width; // steady section
      }
    }
    final total = widths.fold<double>(0, (a, b) => a + b);
    final positions = <double>[0];
    for (final w in widths) {
      positions.add(positions.last + w / total);
    }
    positions[positions.length - 1] = 1;
    return TimeRangeScale._(days, positions);
  }

  TimeRangeScale._(this.markDays, this.markPositions);

  /// The marked numbers of days, from shortest to longest. The last one is
  /// the longest range, set by how far back the recorded weights go.
  final List<int> markDays;

  /// Where each of [markDays] sits on the slider, from 0 to 1.
  final List<double> markPositions;

  int get maxDays => markDays.last;

  /// Number of days at slider position [t].
  int daysAt(double t) {
    t = t.clamp(0.0, 1.0);
    for (var i = 1; i < markPositions.length; i++) {
      if (t <= markPositions[i]) {
        final from = markDays[i - 1].toDouble();
        final to = markDays[i].toDouble();
        final local = (t - markPositions[i - 1]) /
            (markPositions[i] - markPositions[i - 1]);
        final days = i == 1
            ? from * math.pow(to / from, local)
            : from + (to - from) * local;
        return days.round();
      }
    }
    return maxDays;
  }

  /// Slider position showing [days]; the reverse of [daysAt]. Ranges longer
  /// than the longest available give 1.
  double positionOf(int days) {
    if (days >= maxDays) return 1;
    if (days <= minRangeDays) return 0;
    for (var i = 1; i < markDays.length; i++) {
      if (days <= markDays[i]) {
        final from = markDays[i - 1].toDouble();
        final to = markDays[i].toDouble();
        final local = i == 1
            ? math.log(days / from) / math.log(to / from)
            : (days - from) / (to - from);
        return markPositions[i - 1] +
            local * (markPositions[i] - markPositions[i - 1]);
      }
    }
    return 1;
  }

  /// Every point marked on the slider as (days, position): the section
  /// ends, plus one week at its natural place in the first section.
  List<(int, double)> get marks {
    final all = [
      for (final (i, d) in markDays.indexed) (d, markPositions[i]),
      if (_week < maxDays) (_week, positionOf(_week)),
    ];
    return all..sort((a, b) => a.$1.compareTo(b.$1));
  }

  /// [t], moved onto a mark if it's very close to one, so the marks are
  /// easy to hit exactly.
  double snap(double t) {
    for (final (_, p) in marks) {
      if ((t - p).abs() < 0.025) return p;
    }
    return t;
  }
}
