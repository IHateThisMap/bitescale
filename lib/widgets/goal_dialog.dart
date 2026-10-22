import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/labels.dart';
import '../utils/format.dart';

class GoalResult {
  const GoalResult(this.weightKg, this.date);
  final double weightKg;
  final DateTime date;
}

/// Asks for a goal weight and the date it should be reached by.
class GoalDialog extends StatefulWidget {
  const GoalDialog({super.key, this.initialWeight, this.initialDate});

  final double? initialWeight;
  final DateTime? initialDate;

  @override
  State<GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<GoalDialog> {
  late final _controller = TextEditingController(
      text: widget.initialWeight == null
          ? ''
          : formatNumber(widget.initialWeight!));
  late DateTime _date = widget.initialDate ??
      DateTime.now().add(const Duration(days: 12 * 7));
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(tomorrow) ? tomorrow : _date,
      firstDate: tomorrow,
      lastDate: DateTime(now.year + 5),
      helpText: context.l10n.goalDate,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final value = parseNumber(_controller.text);
    if (value == null || value < 20 || value > 500) {
      setState(() => _error = context.l10n.enterValidWeight);
      return;
    }
    Navigator.of(context).pop(GoalResult(value, _date));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.weightGoal),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: context.l10n.goalWeight,
              suffixText: 'kg',
              errorText: _error,
            ),
          ),
          const SizedBox(height: 16),
          Text(context.l10n.goalDate),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.flag_outlined),
            label: Text(DateFormat.yMMMd().format(_date)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(context.l10n.save)),
      ],
    );
  }
}
