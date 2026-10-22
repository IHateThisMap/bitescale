import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/labels.dart';
import '../utils/health.dart';

/// Colour for each [IntakeStatus], shared by the bar and the status line.
Color intakeStatusColor(IntakeStatus status, ColorScheme colors) =>
    switch (status) {
      IntakeStatus.withinGoal => Colors.green.shade600,
      IntakeStatus.overGoal => Colors.amber.shade700,
      IntakeStatus.noDeficit => colors.error,
    };

/// A bar from 0 to where the calorie deficit ends (maintenance), filled
/// with what has been eaten, with the day's target marked on it.
class DeficitBar extends StatelessWidget {
  const DeficitBar({
    super.key,
    required this.eaten,
    required this.target,
    required this.maintenance,
    required this.status,
  });

  final double eaten;
  final double target;
  final double maintenance;
  final IntakeStatus status;

  static const _barHeight = 16.0;
  static const _markerOverhang = 6.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final small = theme.textTheme.labelSmall;
    // Normally maintenance is the end; for a weight gain goal the target is.
    final end = math.max(target, maintenance);
    double fraction(double v) => end <= 0 ? 0 : (v / end).clamp(0.0, 1.0);
    // Align's x runs from -1 (left edge) to 1 (right edge).
    Alignment at(double v) => Alignment(fraction(v) * 2 - 1, 0);

    return Semantics(
      label: '${l10n.eaten} ${eaten.round()} kcal, '
          '${l10n.barGoal} ${target.round()} kcal, '
          '${l10n.barDeficitEnds} ${maintenance.round()} kcal',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Goal label above its marker.
            Align(
              alignment: at(target),
              child: Text('${l10n.barGoal} ${target.round()}',
                  style: small?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: _barHeight + 2 * _markerOverhang,
              child: LayoutBuilder(builder: (context, constraints) {
                final width = constraints.maxWidth;
                double x(double v) => fraction(v) * width;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Track: the whole way to the end of the deficit.
                    Positioned(
                      left: 0,
                      right: 0,
                      top: _markerOverhang,
                      height: _barHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(_barHeight / 2),
                        ),
                      ),
                    ),
                    // Eaten.
                    Positioned(
                      left: 0,
                      top: _markerOverhang,
                      height: _barHeight,
                      width: x(eaten),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: intakeStatusColor(status, colors),
                          borderRadius: BorderRadius.circular(_barHeight / 2),
                        ),
                      ),
                    ),
                    // Goal marker: taller than the bar, with a ring of the
                    // card colour so it stands out on any fill.
                    Positioned(
                      left: (x(target) - 2.5).clamp(0, width - 5),
                      top: 0,
                      bottom: 0,
                      width: 5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.onSurface,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                              color: colors.surfaceContainerLow, width: 1),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 2),
            // Where the deficit ends, under that point of the bar.
            Align(
              alignment: at(maintenance),
              child: Text(
                  '${l10n.barDeficitEnds} ${maintenance.round()}',
                  style: small?.copyWith(color: colors.onSurfaceVariant)),
            ),
          ],
        ),
      ),
    );
  }
}
