import 'package:flutter/material.dart';

import '../l10n/labels.dart';
import '../models/user_profile.dart';

/// Asks for what's needed to estimate daily calorie needs.
/// Pops with the updated [UserProfile].
class CalorieProfileDialog extends StatefulWidget {
  const CalorieProfileDialog({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<CalorieProfileDialog> createState() => _CalorieProfileDialogState();
}

class _CalorieProfileDialogState extends State<CalorieProfileDialog> {
  late Sex? _sex = widget.profile.sex;
  late ActivityLevel? _activity = widget.profile.activityLevel;
  late final _birthYear =
      TextEditingController(text: widget.profile.birthYear?.toString() ?? '');
  String? _error;

  @override
  void dispose() {
    _birthYear.dispose();
    super.dispose();
  }

  void _submit() {
    final year = int.tryParse(_birthYear.text.trim());
    final thisYear = DateTime.now().year;
    if (_sex == null) {
      setState(() => _error = context.l10n.chooseSex);
      return;
    }
    if (year == null || year < thisYear - 110 || year > thisYear - 13) {
      setState(() => _error = context.l10n.invalidBirthYear);
      return;
    }
    if (_activity == null) {
      setState(() => _error = context.l10n.chooseActivity);
      return;
    }
    Navigator.of(context).pop(widget.profile
        .copyWith(sex: _sex, birthYear: year, activityLevel: _activity));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(l10n.dailyCalorieNeeds),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.calorieProfileIntro),
            const SizedBox(height: 16),
            SegmentedButton<Sex>(
              emptySelectionAllowed: true,
              segments: [
                ButtonSegment(value: Sex.male, label: Text(l10n.male)),
                ButtonSegment(value: Sex.female, label: Text(l10n.female)),
              ],
              selected: {?_sex},
              onSelectionChanged: (s) => setState(() {
                if (s.isNotEmpty) _sex = s.first;
                _error = null;
              }),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _birthYear,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.birthYear),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 16),
            Text(l10n.activityLevel, style: textTheme.titleSmall),
            RadioGroup<ActivityLevel>(
              groupValue: _activity,
              onChanged: (v) => setState(() {
                _activity = v;
                _error = null;
              }),
              child: Column(
                children: [
                  for (final level in ActivityLevel.values)
                    RadioListTile<ActivityLevel>(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: level,
                      title: Text(l10n.activityLabel(level)),
                      subtitle: Text(l10n.activityDescription(level)),
                    ),
                ],
              ),
            ),
            if (_error != null)
              Text(_error!,
                  style: textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error)),
          ],
        ),
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
