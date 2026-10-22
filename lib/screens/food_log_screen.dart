import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/labels.dart';
import '../models/food.dart';
import '../models/user_profile.dart';
import '../services/food_storage.dart';
import '../utils/health.dart';
import '../widgets/amount_dialog.dart';
import '../widgets/calorie_profile_dialog.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/deficit_bar.dart';
import '../widgets/food_image.dart';
import '../widgets/language_button.dart';
import '../widgets/number_dialog.dart';
import 'food_library_screen.dart';

/// The food diary: what was eaten on a chosen day.
class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({
    super.key,
    required this.profile,
    required this.latestWeightKg,
    required this.onProfileChanged,
    required this.onShowWeightPage,
  });

  final UserProfile profile;
  final double? latestWeightKg;
  final ValueChanged<UserProfile> onProfileChanged;
  final VoidCallback onShowWeightPage;

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  final _storage = FoodStorage();
  List<FoodLogEntry> _log = [];
  List<Food> _foods = [];
  DateTime _day = dateOnly(DateTime.now());
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final log = await _storage.loadLog();
    final foods = await _storage.loadFoods();
    if (!mounted) return;
    setState(() {
      _log = log;
      _foods = foods;
      _loading = false;
    });
  }

  List<FoodLogEntry> get _dayEntries =>
      _log.where((e) => dateOnly(e.date) == _day).toList();

  /// Calories eaten per category. Uses the saved food's current category,
  /// or the one the entry was logged with if the food has been deleted.
  Map<String, double> _kcalByCategory(List<FoodLogEntry> entries) {
    final categoryOf = {for (final f in _foods) f.id: f.category};
    final totals = <String, double>{};
    for (final e in entries) {
      final category = categoryOf[e.foodId] ?? e.category ?? 'Other';
      totals[category] = (totals[category] ?? 0) + e.nutrients.kcal;
    }
    return totals;
  }

  List<Food> get _favourites => _foods.where((f) => f.favourite).toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  bool get _isToday => _day == dateOnly(DateTime.now());

  Future<void> _logFood(Food food, double amount) async {
    final entry = FoodLogEntry(
      id: newId(),
      // Today: use the current time. Other days: midday of that day.
      date: _isToday ? DateTime.now() : _day.add(const Duration(hours: 12)),
      foodId: food.id,
      foodName: food.name,
      amount: amount,
      unit: food.unit,
      nutrients: food.nutrientsFor(amount),
      category: food.category,
    );
    setState(() => _log = [..._log, entry]);
    await _storage.saveLog(_log);
  }

  Future<void> _openLibrary({required bool pickMode}) async {
    final pick = await Navigator.of(context).push<FoodPick>(MaterialPageRoute(
      builder: (_) => FoodLibraryScreen(pickMode: pickMode),
    ));
    if (pick != null) await _logFood(pick.food, pick.amount);
    await _reload();
  }

  Future<void> _logFavourite(Food food) async {
    final amount = await showAmountDialog(context, food);
    if (amount == null) return;
    await _storage.upsertFood(food.withUsage(amount));
    await _logFood(food, amount);
    await _reload();
  }

  /// Changes the amount of an eaten food.
  Future<void> _editEntry(FoodLogEntry entry) async {
    final saved = _foods.where((f) => f.id == entry.foodId).firstOrNull;
    // Use the nutrition the entry was logged with, so editing the amount
    // doesn't pick up later changes to the saved food (or fail if it was
    // deleted). The saved food still provides the photo and portion size.
    final food = Food(
      id: entry.foodId,
      name: entry.foodName,
      category: saved?.category ?? 'Other',
      unit: entry.unit,
      per100: entry.nutrients.scaled(100 / entry.amount),
      imagePath: saved?.imagePath,
      portionSize: saved?.unit == entry.unit ? saved?.portionSize : null,
      portionName: saved?.portionName,
    );
    final amount = await showAmountDialog(context, food,
        initialAmount: entry.amount, confirmLabel: context.l10n.save);
    if (amount == null) return;

    final updated =
        entry.copyWith(amount: amount, nutrients: food.nutrientsFor(amount));
    setState(() =>
        _log = [for (final e in _log) e.id == entry.id ? updated : e]);
    await _storage.saveLog(_log);
  }

  Future<void> _deleteEntry(FoodLogEntry entry) async {
    setState(() => _log = _log.where((e) => e.id != entry.id).toList());
    await _storage.saveLog(_log);
  }

  Future<bool> _confirmRemoveEntry(FoodLogEntry entry) => confirmYesNo(
      context, context.l10n.removeFromEatenTitle(entry.foodName));

  /// Removes via the ✕ button (swiping goes through the Dismissible).
  Future<void> _removeEntryWithConfirm(FoodLogEntry entry) async {
    if (await _confirmRemoveEntry(entry)) await _deleteEntry(entry);
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _day = dateOnly(picked));
  }

  Future<void> _editCalorieProfile() async {
    final updated = await showDialog<UserProfile>(
      context: context,
      builder: (_) => CalorieProfileDialog(profile: widget.profile),
    );
    if (updated != null) widget.onProfileChanged(updated);
  }

  void _shiftDay(int days) =>
      setState(() => _day = DateTime(_day.year, _day.month, _day.day + days));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = _dayEntries;
    final favourites = _favourites;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.food),
        actions: [
          IconButton(
            tooltip: l10n.myFoods,
            icon: const Icon(Icons.menu_book),
            onPressed: () => _openLibrary(pickMode: false),
          ),
          const LanguageButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addFood',
        onPressed: () => _openLibrary(pickMode: true),
        icon: const Icon(Icons.add),
        label: Text(l10n.addFood),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _shiftDay(-1),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: _pickDay,
                        child: Text(_isToday
                            ? l10n.today
                            : DateFormat.yMMMEd().format(_day)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _isToday ? null : () => _shiftDay(1),
                    ),
                  ],
                ),
                _CalorieTargetCard(
                  eatenKcal:
                      entries.fold<double>(0, (s, e) => s + e.nutrients.kcal),
                  profile: widget.profile,
                  latestWeightKg: widget.latestWeightKg,
                  onEditProfile: _editCalorieProfile,
                  onShowWeightPage: widget.onShowWeightPage,
                ),
                _NutrientTotals(entries: entries),
                if (favourites.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(l10n.favourites,
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final food in favourites)
                        ActionChip(
                          avatar: FoodImage(path: food.imagePath, size: 24),
                          label: Text(food.name),
                          onPressed: () => _logFavourite(food),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Text(l10n.eaten, style: Theme.of(context).textTheme.titleMedium),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text(l10n.nothingLogged)),
                  ),
                for (final entry in entries.reversed)
                  Dismissible(
                    key: ValueKey(entry.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) => _confirmRemoveEntry(entry),
                    onDismissed: (_) => _deleteEntry(entry),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: FoodImage(
                        path: _foods
                            .where((f) => f.id == entry.foodId)
                            .firstOrNull
                            ?.imagePath,
                        size: 40,
                      ),
                      title: Text(entry.foodName),
                      subtitle: Text(
                          '${formatNumber(entry.amount)} ${entry.unit} · '
                          '${DateFormat.Hm().format(entry.date)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${entry.nutrients.kcal.round()} kcal'),
                          const SizedBox(width: 8),
                          const Icon(Icons.edit_outlined, size: 18),
                          IconButton(
                            tooltip: l10n.removeFromEaten,
                            icon: const Icon(Icons.close),
                            onPressed: () => _removeEntryWithConfirm(entry),
                          ),
                        ],
                      ),
                      onTap: () => _editEntry(entry),
                    ),
                  ),
                if (entries.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  CategoryPieChart(kcalByCategory: _kcalByCategory(entries)),
                ],
              ],
            ),
    );
  }
}

/// Daily calorie target, how much has been eaten and how much is left.
class _CalorieTargetCard extends StatelessWidget {
  const _CalorieTargetCard({
    required this.eatenKcal,
    required this.profile,
    required this.latestWeightKg,
    required this.onEditProfile,
    required this.onShowWeightPage,
  });

  final double eatenKcal;
  final UserProfile profile;
  final double? latestWeightKg;
  final VoidCallback onEditProfile;
  final VoidCallback onShowWeightPage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final eaten = eatenKcal.round();
    final target = calculateCalorieTarget(profile, latestWeightKg);

    if (target == null) {
      final needsWeight = latestWeightKg == null;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.kcalEaten(eaten), style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(needsWeight
                  ? l10n.needWeightForTarget
                  : l10n.needInfoForTarget),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: needsWeight ? onShowWeightPage : onEditProfile,
                icon: Icon(needsWeight
                    ? Icons.monitor_weight_outlined
                    : Icons.local_fire_department_outlined),
                label: Text(needsWeight
                    ? l10n.goToWeightPage
                    : l10n.setUpCalorieTarget),
              ),
            ],
          ),
        ),
      );
    }

    final goal = target.target.round();
    final left = goal - eaten;
    final over = left < 0;
    final plan = target.plan;

    // Whether today's target means eating less than you burn.
    final aimsForDeficit = target.target < target.maintenance;
    final deficitLeft = target.maintenance.round() - eaten;
    final status = intakeStatus(
        eaten: eatenKcal,
        target: target.target,
        maintenance: target.maintenance);
    final statusColor = intakeStatusColor(status, colors);
    final (statusIcon, statusText) = switch (status) {
      IntakeStatus.withinGoal => (
          Icons.check_circle,
          aimsForDeficit ? l10n.statusWithinGoalDeficit : l10n.statusWithinGoal
        ),
      IntakeStatus.overGoal => (
          Icons.warning_amber_rounded,
          aimsForDeficit ? l10n.statusOverGoalDeficit : l10n.statusOverGoal
        ),
      IntakeStatus.noDeficit => (Icons.error, l10n.statusNoDeficit),
    };
    final deficit = (target.maintenance - target.target).round();

    final String goalText;
    if (plan == null) {
      goalText = profile.hasGoal ? l10n.targetGoalDone : l10n.targetNoGoal;
    } else {
      final goalKg = formatFixed(plan.goalKg);
      goalText = deficit >= 0
          ? l10n.targetDeficitToGoal(deficit, goalKg, plan.daysLeft)
          : l10n.targetSurplusToGoal(-deficit, goalKg, plan.daysLeft);
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
                  child: Text(l10n.dailyTarget(goal),
                      style: textTheme.titleMedium),
                ),
                IconButton(
                  tooltip: l10n.calorieProfileTooltip,
                  icon: const Icon(Icons.tune),
                  onPressed: onEditProfile,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DeficitBar(
                    eaten: eatenKcal,
                    target: target.target,
                    maintenance: target.maintenance,
                    status: status,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child:
                              _figure(textTheme, l10n.eaten, '$eaten kcal')),
                      Expanded(
                        child: _figure(
                          textTheme,
                          over ? l10n.overTarget : l10n.leftToEat,
                          '${left.abs()} kcal',
                        ),
                      ),
                      if (aimsForDeficit)
                        Expanded(
                          child: _figure(
                            textTheme,
                            deficitLeft > 0
                                ? l10n.deficitLeft
                                : l10n.overMaintenance,
                            '${deficitLeft.abs()} kcal',
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(statusText,
                            style: textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(l10n.maintenanceLine(target.maintenance.round())),
                  const SizedBox(height: 4),
                  Text(goalText),
                  if (target.limitedToMinimum) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.minimumWarning(
                          minimumDailyKcal(profile.sex!).round()),
                      style: textTheme.bodySmall
                          ?.copyWith(color: Colors.orange.shade800),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    target.usesBodyFat
                        ? l10n.estimateBodyFat
                        : l10n.estimateMifflin,
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _figure(TextTheme textTheme, String label, String value) {
    // Label and value each stay on one line, shrinking if needed, so three
    // fit side by side on a narrow phone with their values lined up.
    Widget oneLine(String text, TextStyle? style) => FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(text, style: style, maxLines: 1),
        );
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          oneLine(label, textTheme.labelMedium),
          oneLine(value, textTheme.titleLarge),
        ],
      ),
    );
  }
}

/// Totals of the optional nutrients eaten on the day.
class _NutrientTotals extends StatelessWidget {
  const _NutrientTotals({required this.entries});

  final List<FoodLogEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Sum each optional nutrient, skipping it if no entry has a value.
    final totals = <(Nutrient, double)>[];
    for (final nutrient in Nutrient.values) {
      final values = entries
          .map((e) => e.nutrients.optionalValues[nutrient.index].$2)
          .whereType<double>();
      if (values.isNotEmpty) {
        totals.add((nutrient, values.fold(0, (a, b) => a + b)));
      }
    }

    if (totals.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        children: [
          for (final (nutrient, value) in totals)
            Text('${l10n.nutrientLabel(nutrient)}: ${formatNumber(value)} g'),
        ],
      ),
    );
  }
}
