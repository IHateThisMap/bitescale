import 'package:flutter/material.dart';

import '../l10n/labels.dart';
import '../utils/format.dart';
import '../utils/time_range.dart';

/// Chooses how far back the weight graph goes. Like a timeline, the past
/// is on the left: dragging left shows a longer time.
class TimeRangeSlider extends StatelessWidget {
  const TimeRangeSlider({
    super.key,
    required this.scale,
    required this.position,
    required this.onChanged,
    this.onChangeEnd,
  });

  final TimeRangeScale scale;

  /// 0 = shortest range, 1 = longest.
  final double position;
  final ValueChanged<double> onChanged;

  /// Called with the final position when the user lets go of the slider.
  final ValueChanged<double>? onChangeEnd;

  static const _sidePadding = 16.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final days = scale.daysAt(position);
    // The slider runs right-to-left: its value is the reverse of position.
    double xOf(double position) => 1 - position;
    final marks = scale.marks;
    // The end of the slider (the longest range) can sit right next to the
    // last marker, e.g. 6 months and 200 days. Then only the marker is
    // labelled; the text above the slider still shows the exact range.
    final labelEnd = marks.length < 3 ||
        marks.last.$2 - marks[marks.length - 2].$2 >= 0.15;

    bool hasLabel(int i) {
      // The shortest range is obvious from the slider's end.
      if (marks[i].$1 == minRangeDays) return false;
      return labelEnd || i < marks.length - 1;
    }

    /// Moves one day shorter or longer, for exact adjustment.
    void step(int delta) {
      final position = scale.positionOf(days + delta);
      onChanged(position);
      onChangeEnd?.call(position);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Same order as the slider: longer ranges to the left.
            IconButton(
              tooltip: l10n.oneDayMore,
              visualDensity: VisualDensity.compact,
              iconSize: 18,
              icon: const Icon(Icons.add),
              onPressed: days < scale.maxDays ? () => step(1) : null,
            ),
            Text(l10n.showingLastDays(days), style: theme.textTheme.labelLarge),
            IconButton(
              tooltip: l10n.oneDayLess,
              visualDensity: VisualDensity.compact,
              iconSize: 18,
              icon: const Icon(Icons.remove),
              onPressed: days > minRangeDays ? () => step(-1) : null,
            ),
          ],
        ),
        Slider(
          value: xOf(position),
          padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
          onChanged: (v) => onChanged(scale.snap(1 - v)),
          onChangeEnd: onChangeEnd == null
              ? null
              : (v) => onChangeEnd!(scale.snap(1 - v)),
          semanticFormatterCallback: (v) =>
              l10n.showingLastDays(scale.daysAt(1 - v)),
        ),
        // Marks under the track.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
          child: SizedBox(
            height: 30,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Stack(
                  children: [
                    for (final (i, (markDays, p)) in marks.indexed) ...[
                      Positioned(
                        left: xOf(p) * width - 1,
                        top: 0,
                        width: 2,
                        height: 6,
                        child: ColoredBox(color: theme.colorScheme.outline),
                      ),
                      if (hasLabel(i))
                        Positioned.fill(
                          top: 8,
                          child: Align(
                            alignment: Alignment(xOf(p) * 2 - 1, -1),
                            child: Text(
                              rangeLabel(l10n, markDays),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Short name for a number of days: "7 d", "1 mo", "6 mo", "2 yr",
/// "2.7 yr".
String rangeLabel(AppLocalizations l10n, int days) {
  if (days >= 365) return l10n.rangeYears(formatNumber(days / 365));
  if (days >= 30) return l10n.rangeMonths((days / 30.4).round());
  return l10n.rangeDays(days);
}
