import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../l10n/labels.dart';
import '../models/food.dart';

// Colours: an 8-colour categorical palette checked for colour-blind
// separation and contrast, with separate steps for light and dark mode.
// Slices are drawn in slot order, so neighbouring slices follow the
// validated order. Built-in categories always get the same colour; the
// user's own categories take the slots not used that day.
const _lightPalette = [
  Color(0xFF2A78D6), // blue
  Color(0xFFEB6834), // orange
  Color(0xFF1BAF7A), // aqua
  Color(0xFFEDA100), // yellow
  Color(0xFFE87BA4), // magenta
  Color(0xFF008300), // green
  Color(0xFF6250D6), // violet
  Color(0xFFE34948), // red
];
const _darkPalette = [
  Color(0xFF3987E5),
  Color(0xFFD95926),
  Color(0xFF199E70),
  Color(0xFFC98500),
  Color(0xFFD55181),
  Color(0xFF008300),
  Color(0xFF9085E9),
  Color(0xFFE66767),
];

/// Palette slot of each built-in category.
const _builtInSlots = {
  'Drinks': 0,
  'Meals': 1,
  'Dairy & eggs': 2,
  'Bread & grains': 3,
  'Snacks & sweets': 4,
  'Fruits & vegetables': 5,
  otherCategory: 6,
  'Meat & fish': 7,
};

/// At most this many slices; smaller categories are combined.
const _maxSlices = 6;

/// Key of the slice that combines the smallest categories.
const _restKey = '\u0000rest';

/// Share of the day's calories per food category.
class CategoryPieChart extends StatefulWidget {
  const CategoryPieChart({super.key, required this.kcalByCategory});

  /// Calories per saved category name.
  final Map<String, double> kcalByCategory;

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  /// Category of the slice / legend row being touched.
  String? _highlighted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final shares = widget.kcalByCategory.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = shares.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) return const SizedBox.shrink();

    final title = Text(l10n.caloriesByCategory, style: textTheme.titleMedium);

    // A one-slice pie says nothing a sentence can't.
    if (shares.length == 1) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 4),
              Text(l10n.allFromCategory(l10n.categoryLabel(shares.first.key))),
            ],
          ),
        ),
      );
    }

    // Keep the biggest categories; combine the rest into one slice.
    final shown = shares.length > _maxSlices
        ? shares.take(_maxSlices - 1).toList()
        : shares;
    final rest = shares.length > _maxSlices
        ? shares.skip(_maxSlices - 1).fold<double>(0, (s, e) => s + e.value)
        : 0.0;

    final dark = theme.brightness == Brightness.dark;
    final palette = dark ? _darkPalette : _lightPalette;
    final slots = _assignSlots(shown.map((e) => e.key));
    final restColor = theme.colorScheme.outline;

    final slices = [
      for (final e in shown
        ..sort((a, b) => slots[a.key]!.compareTo(slots[b.key]!)))
        (key: e.key, label: l10n.categoryLabel(e.key), kcal: e.value,
            color: palette[slots[e.key]!]),
      if (rest > 0)
        (key: _restKey, label: l10n.smallerCategories, kcal: rest,
            color: restColor),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      // A gap of the card's colour between slices.
                      sectionsSpace: 2,
                      centerSpaceRadius: 52,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          final i =
                              response?.touchedSection?.touchedSectionIndex;
                          setState(() => _highlighted =
                              !event.isInterestedForInteractions ||
                                      i == null ||
                                      i < 0
                                  ? null
                                  : slices[i].key);
                        },
                      ),
                      sections: [
                        for (final s in slices)
                          PieChartSectionData(
                            value: s.kcal,
                            color: s.color,
                            radius: s.key == _highlighted ? 52 : 44,
                            showTitle: false,
                            borderSide: BorderSide.none,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${total.round()}', style: textTheme.titleLarge),
                      Text('kcal', style: textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Legend: also the exact values, so nothing relies on colour.
            for (final s in slices)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() =>
                    _highlighted = _highlighted == s.key ? null : s.key),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    color: s.key == _highlighted
                        ? theme.colorScheme.surfaceContainerHighest
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: s.color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s.label)),
                      Text('${s.kcal.round()} kcal',
                          style: textTheme.bodyMedium),
                      SizedBox(
                        width: 56,
                        child: Text(
                          '${(s.kcal / total * 100).round()} %',
                          textAlign: TextAlign.end,
                          style: textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Built-in categories get their fixed slot; the user's own categories
  /// get the free slots, in alphabetical order.
  static Map<String, int> _assignSlots(Iterable<String> categories) {
    final slots = <String, int>{};
    final custom = <String>[];
    for (final c in categories) {
      final slot = _builtInSlots[c];
      if (slot != null) {
        slots[c] = slot;
      } else {
        custom.add(c);
      }
    }
    final free = [
      for (var i = 0; i < _lightPalette.length; i++)
        if (!slots.containsValue(i)) i,
    ];
    custom.sort();
    for (final (i, c) in custom.indexed) {
      slots[c] = free[i];
    }
    return slots;
  }
}
