import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/labels.dart';
import '../models/weight_entry.dart';
import '../utils/format.dart';
import '../utils/trend.dart';

/// The recorded weights of the last [rangeDays] days, with a trend line
/// fitted to them.
class WeightChart extends StatelessWidget {
  const WeightChart({
    super.key,
    required this.entries,
    required this.rangeDays,
    this.goalKg,
    this.now,
  });

  /// All weights, oldest first.
  final List<WeightEntry> entries;
  final int rangeDays;
  final double? goalKg;

  /// The end of the time range; defaults to the current time.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final end = now ?? DateTime.now();
    final origin = end.subtract(Duration(days: rangeDays));
    final visible = entries.where((e) => !e.date.isBefore(origin)).toList();
    if (visible.isEmpty) {
      return Center(
          child: Text(context.l10n.noWeightsInRange,
              textAlign: TextAlign.center));
    }
    // The last weight before the range, so the line runs in from the left
    // edge instead of starting in mid-air. It's drawn but clipped off.
    final lead = entries.lastWhere((e) => e.date.isBefore(origin),
        orElse: () => visible.first);
    final shown = [if (lead != visible.first) lead, ...visible];
    final spots = shown
        .map((e) => FlSpot(daysSince(origin, e.date), e.weightKg))
        .toList();

    // Trend of the weights in view; drawn only where they are.
    final trend = calculateTrend(visible);
    final trendStart = daysSince(origin, visible.first.date);
    final trendEnd = daysSince(origin, visible.last.date);

    final maxX = rangeDays.toDouble();
    final weights = [...visible.map((e) => e.weightKg), ?goalKg];
    final minY = (weights.reduce(math.min) - 2).floorToDouble();
    final maxY = (weights.reduce(math.max) + 2).ceilToDouble();
    // Day and month for short ranges; month and year once the labels are
    // months apart, or they'd look like dates of the same year.
    final dateFormat = rangeDays > 180 ? DateFormat.yM() : DateFormat('d.M.');

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: colors.outlineVariant, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (goalKg != null)
              HorizontalLine(
                y: goalKg!,
                color: colors.tertiary,
                strokeWidth: 1.5,
                dashArray: [4, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: TextStyle(color: colors.tertiary, fontSize: 11),
                  labelResolver: (_) => context.l10n.chartGoal,
                ),
              ),
          ],
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              // Only the regular steps; the axis ends would crowd them.
              minIncluded: false,
              maxIncluded: false,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 11)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: math.max(1, (maxX / 4).ceilToDouble()),
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  dateFormat.format(
                      origin.add(Duration(minutes: (value * 1440).round()))),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touched) => touched.map((s) {
              // Only show tooltips for the measured points, not the trend line.
              if (s.barIndex != 0) return null;
              final entry = shown[s.spotIndex];
              return LineTooltipItem(
                '${formatFixed(entry.weightKg)} kg\n'
                '${DateFormat.yMMMd().format(entry.date)}',
                TextStyle(color: colors.onPrimary, fontSize: 12),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          // The user's measurements.
          LineChartBarData(
            spots: spots,
            color: colors.primary.withValues(alpha: 0.35),
            barWidth: 1.5,
            dotData: FlDotData(
              getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                radius: 4,
                color: colors.primary,
                strokeWidth: 0,
              ),
            ),
          ),
          // The calculated trend line.
          if (trend != null)
            LineChartBarData(
              // The trend's x is days since the first weight in view.
              spots: [
                FlSpot(trendStart, trend.weightAt(0)),
                FlSpot(trendEnd, trend.weightAt(trendEnd - trendStart)),
              ],
              color: trend.slopeKgPerDay <= 0 ? Colors.green : Colors.red,
              barWidth: 3,
              dashArray: [8, 4],
              dotData: const FlDotData(show: false),
            ),
        ],
      ),
    );
  }
}
