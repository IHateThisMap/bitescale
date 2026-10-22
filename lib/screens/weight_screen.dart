import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/labels.dart';
import '../models/user_profile.dart';
import '../models/weight_entry.dart';
import '../services/settings_storage.dart';
import '../services/weight_storage.dart';
import '../utils/body_metrics.dart';
import '../utils/calorie_target.dart';
import '../utils/format.dart';
import '../utils/time_range.dart';
import '../utils/trend.dart';
import '../widgets/body_metric_dialog.dart';
import '../widgets/goal_dialog.dart';
import '../widgets/language_button.dart';
import '../widgets/number_dialog.dart';
import '../widgets/time_range_slider.dart';
import '../widgets/weight_chart.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    this.onEntriesChanged,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileChanged;

  /// Called whenever the weight entries are loaded or changed.
  final ValueChanged<List<WeightEntry>>? onEntriesChanged;

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  final _storage = WeightStorage();
  List<WeightEntry> _entries = [];
  bool _loading = true;

  final _settings = SettingsStorage();

  /// How many days the graph shows; null for the longest range available.
  /// Remembered between app starts.
  int? _rangeDays;

  TimeRangeScale get _rangeScale => TimeRangeScale(_entries.isEmpty
      ? 0
      : DateTime.now().difference(_entries.first.date).inHours ~/ 24 + 1);

  double get _rangePosition =>
      _rangeDays == null ? 1 : _rangeScale.positionOf(_rangeDays!);

  void _setRangePosition(double position) => setState(() =>
      _rangeDays = position >= 1 ? null : _rangeScale.daysAt(position));

  @override
  void initState() {
    super.initState();
    Future.wait([_storage.load(), _settings.loadGraphRangeDays()])
        .then((results) {
      if (!mounted) return;
      final entries = results[0] as List<WeightEntry>;
      setState(() {
        _entries = entries;
        _rangeDays = results[1] as int?;
        _loading = false;
      });
      widget.onEntriesChanged?.call(entries);
    });
  }

  Future<void> _addWeight() async {
    final entry = await showDialog<WeightEntry>(
      context: context,
      builder: (_) => const _AddWeightDialog(),
    );
    if (entry == null) return;
    setState(() {
      _entries = [..._entries, entry]..sort((a, b) => a.date.compareTo(b.date));
    });
    widget.onEntriesChanged?.call(_entries);
    await _storage.save(_entries);
  }

  Future<void> _deleteEntry(WeightEntry entry) async {
    setState(() => _entries = _entries.where((e) => e != entry).toList());
    widget.onEntriesChanged?.call(_entries);
    await _storage.save(_entries);
  }

  Future<void> _editHeight() async {
    final height = await showNumberDialog(
      context,
      title: context.l10n.yourHeight,
      label: context.l10n.height,
      suffix: 'cm',
      min: 50,
      max: 272,
      initial: widget.profile.heightCm,
    );
    if (height != null) widget.onProfileChanged(widget.profile.withHeight(height));
  }

  Future<void> _editGoal() async {
    final result = await showDialog<GoalResult>(
      context: context,
      builder: (_) => GoalDialog(
        initialWeight: widget.profile.goalWeightKg,
        initialDate: widget.profile.goalDate,
      ),
    );
    if (result != null) {
      widget.onProfileChanged(
          widget.profile.withGoal(result.weightKg, result.date));
    }
  }

  Future<void> _editBodyMetric() async {
    final updated = await showDialog<UserProfile>(
      context: context,
      builder: (_) => BodyMetricDialog(profile: widget.profile),
    );
    if (updated != null) widget.onProfileChanged(updated);
  }

  void _clearGoal() => widget.onProfileChanged(widget.profile.withGoal(null, null));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trend = calculateTrend(_entries);
    final profile = widget.profile;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.weight),
        actions: [
          IconButton(
            tooltip: l10n.editHeight,
            icon: const Icon(Icons.height),
            onPressed: _editHeight,
          ),
          const LanguageButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addWeight',
        onPressed: _addWeight,
        icon: const Icon(Icons.monitor_weight_outlined),
        label: Text(l10n.addWeight),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _SummaryCard(
                  entries: _entries,
                  trend: trend,
                  profile: profile,
                  onEditBodyMetric: _editBodyMetric,
                ),
                const SizedBox(height: 12),
                _GoalCard(
                  profile: profile,
                  currentKg: _entries.isEmpty ? null : _entries.last.weightKg,
                  trend: trend,
                  onEdit: _editGoal,
                  onClear: _clearGoal,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 24, 24, 8),
                    child: SizedBox(
                      height: 260,
                      child: _entries.isEmpty
                          ? Center(
                              child: Text(
                                l10n.noWeightEntries,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : WeightChart(
                              entries: _entries,
                              // A saved range can be longer than what's
                              // available now, e.g. after deleting weights.
                              rangeDays: (_rangeDays ?? _rangeScale.maxDays)
                                  .clamp(minRangeDays, _rangeScale.maxDays),
                              goalKg: profile.goalWeightKg,
                            ),
                    ),
                  ),
                ),
                if (_entries.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TimeRangeSlider(
                      scale: _rangeScale,
                      position: _rangePosition,
                      onChanged: _setRangePosition,
                      onChangeEnd: (_) =>
                          _settings.saveGraphRangeDays(_rangeDays),
                    ),
                  ),
                const SizedBox(height: 16),
                if (_entries.isNotEmpty)
                  Text(l10n.history,
                      style: Theme.of(context).textTheme.titleMedium),
                for (final entry in _entries.reversed)
                  Dismissible(
                    key: ObjectKey(entry),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => _deleteEntry(entry),
                    child: ListTile(
                      leading: const Icon(Icons.scale),
                      title: Text('${formatFixed(entry.weightKg)} kg'),
                      subtitle: Text(DateFormat.yMMMd().format(entry.date)),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.entries,
    required this.trend,
    required this.profile,
    required this.onEditBodyMetric,
  });

  final List<WeightEntry> entries;
  final WeightTrend? trend;
  final UserProfile profile;
  final VoidCallback onEditBodyMetric;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    if (entries.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.weightSummaryEmpty),
        ),
      );
    }

    final latest = entries.last.weightKg;
    final change = latest - entries.first.weightKg;
    final t = trend;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.current, style: textTheme.labelMedium),
                      Text('${formatFixed(latest)} kg',
                          style: textTheme.headlineSmall),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onEditBodyMetric,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _bodyMetric(l10n, textTheme, latest),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.totalChange(formatSigned(change))),
            const SizedBox(height: 8),
            if (t == null)
              Text(l10n.trendNeedsTwo)
            else ...[
              Text(
                l10n.trendPerWeek(formatSigned(t.kgPerWeek)),
                style: textTheme.titleMedium?.copyWith(
                  color: t.slopeKgPerDay <= 0 ? Colors.green : Colors.red,
                ),
              ),
              Text(
                t.dailyCalorieBalance <= 0
                    ? l10n.estimatedDeficit((-t.dailyCalorieBalance).round())
                    : l10n.estimatedSurplus(t.dailyCalorieBalance.round()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// BMI or Navy body fat, depending on the user's choice.
  Widget _bodyMetric(
      AppLocalizations l10n, TextTheme textTheme, double latestKg) {
    String label, value, category;
    Color? color;
    String? detail;

    final bodyFat = profileBodyFat(profile);
    if (profile.bodyMetric == BodyMetric.navyBodyFat && bodyFat != null) {
      final fatKg = latestKg * bodyFat / 100;
      final fatCategory = bodyFatCategory(profile.sex!, bodyFat);
      label = l10n.bodyFat;
      value = '${formatFixed(bodyFat)} %';
      category = l10n.bodyFatCategoryLabel(fatCategory);
      color = _bodyFatColor(fatCategory);
      detail = l10n.fatAndLean(
          formatFixed(fatKg), formatFixed(latestKg - fatKg));
      if (profile.measuredAt != null) {
        detail += '\n${l10n.measuredOn(
            DateFormat.yMMMd().format(profile.measuredAt!))}';
      }
    } else if (profile.bodyMetric == BodyMetric.navyBodyFat) {
      label = l10n.bodyFat;
      value = '–';
      category = l10n.tapToAddMeasurements;
    } else {
      final bmi = calculateBmi(latestKg, profile.heightCm!);
      label = l10n.bmi;
      value = formatFixed(bmi);
      category = l10n.bmiCategoryLabel(bmiCategory(bmi));
      color = _bmiColor(bmiCategory(bmi));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: textTheme.labelMedium),
            const SizedBox(width: 4),
            const Icon(Icons.tune, size: 14),
          ],
        ),
        Text(value, style: textTheme.headlineSmall?.copyWith(color: color)),
        Text(category, style: textTheme.bodySmall),
        if (detail != null)
          Text(detail, textAlign: TextAlign.end, style: textTheme.bodySmall),
      ],
    );
  }

  static Color _bodyFatColor(BodyFatCategory category) => switch (category) {
        BodyFatCategory.athletic || BodyFatCategory.fit => Colors.green,
        BodyFatCategory.average => Colors.orange,
        BodyFatCategory.essential || BodyFatCategory.obese => Colors.red,
      };

  static Color _bmiColor(BmiCategory category) => switch (category) {
        BmiCategory.normal => Colors.green,
        BmiCategory.underweight || BmiCategory.overweight => Colors.orange,
        BmiCategory.obese => Colors.red,
      };
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.profile,
    required this.currentKg,
    required this.trend,
    required this.onEdit,
    required this.onClear,
  });

  final UserProfile profile;
  final double? currentKg;
  final WeightTrend? trend;
  final VoidCallback onEdit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    if (!profile.hasGoal) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.flag_outlined),
          title: Text(l10n.setGoal),
          subtitle: Text(l10n.setGoalSubtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onEdit,
        ),
      );
    }

    final goalKg = profile.goalWeightKg!;
    final goalDate = profile.goalDate!;
    final lines = <Widget>[];

    if (currentKg == null) {
      lines.add(Text(l10n.goalNeedsWeight));
    } else {
      final plan =
          GoalPlan(currentKg: currentKg!, goalKg: goalKg, goalDate: goalDate);
      final kgToGo = formatFixed(plan.kgToGo.abs());
      if (plan.isReached) {
        lines.add(Text(l10n.goalReached,
            style: textTheme.titleMedium?.copyWith(color: Colors.green)));
      } else if (plan.isOverdue) {
        lines.add(Text(l10n.goalOverdue(kgToGo)));
      } else {
        final losing = plan.kgToGo > 0;
        final kcal = plan.dailyDeficit.abs().round();
        lines.addAll([
          Text(losing
              ? l10n.kgToLose(kgToGo, plan.daysLeft)
              : l10n.kgToGain(kgToGo, plan.daysLeft)),
          const SizedBox(height: 4),
          Text(
            losing ? l10n.neededDeficit(kcal) : l10n.neededSurplus(kcal),
            style: textTheme.titleMedium,
          ),
          if (losing && kcal > 1000)
            Text(
              l10n.tooFastPace,
              style: textTheme.bodySmall?.copyWith(color: Colors.orange),
            ),
          if (trend != null) ...[
            const SizedBox(height: 4),
            Text(
              trend!.dailyCalorieBalance <= 0
                  ? l10n.currentTrendDeficit(
                      trend!.dailyCalorieBalance.abs().round())
                  : l10n.currentTrendSurplus(
                      trend!.dailyCalorieBalance.round()),
              style: textTheme.bodySmall,
            ),
          ],
        ]);
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 4, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.goalTitle(formatNumber(goalKg),
                        DateFormat.yMMMd().format(goalDate)),
                    style: textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: l10n.editGoal,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: l10n.removeGoal,
                  icon: const Icon(Icons.close),
                  onPressed: onClear,
                ),
              ],
            ),
            ...lines,
          ],
        ),
      ),
    );
  }
}

class _AddWeightDialog extends StatefulWidget {
  const _AddWeightDialog();

  @override
  State<_AddWeightDialog> createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends State<_AddWeightDialog> {
  final _controller = TextEditingController();
  DateTime _date = DateTime.now();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final value = parseNumber(_controller.text);
    if (value == null || value <= 0 || value > 500) {
      setState(() => _error = context.l10n.enterValidWeight);
      return;
    }
    Navigator.of(context).pop(WeightEntry(date: _date, weightKg: value));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.addWeight),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.weight,
              suffixText: 'kg',
              errorText: _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(DateFormat.yMMMd().format(_date)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}
