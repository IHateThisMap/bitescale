import 'package:flutter/material.dart';

import '../l10n/labels.dart';
import '../models/food.dart';
import '../utils/format.dart';
import 'food_image.dart';

/// Asks how many grams / millilitres of [food] were eaten. Foods with a
/// portion size can also be entered as a number of portions.
///
/// Starts at [initialAmount], or else the amount used last time. The
/// confirm button says [confirmLabel] (default "Add").
Future<double?> showAmountDialog(
  BuildContext context,
  Food food, {
  double? initialAmount,
  String? confirmLabel,
}) {
  return showDialog<double>(
    context: context,
    builder: (_) => _AmountDialog(
        food: food, initialAmount: initialAmount, confirmLabel: confirmLabel),
  );
}

class _AmountDialog extends StatefulWidget {
  const _AmountDialog(
      {required this.food, this.initialAmount, this.confirmLabel});

  final Food food;
  final double? initialAmount;
  final String? confirmLabel;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  late final double _initialAmount = widget.initialAmount ??
      widget.food.lastAmount ??
      widget.food.portionSize ??
      100;
  late final _amount =
      TextEditingController(text: formatNumber(_initialAmount));
  late final _portions = TextEditingController(
      text: _portionSize == null
          ? ''
          : formatNumber(_initialAmount / _portionSize!, decimals: 2));
  String? _amountError;
  String? _portionsError;

  double? get _portionSize => widget.food.portionSize;

  @override
  void dispose() {
    _amount.dispose();
    _portions.dispose();
    super.dispose();
  }

  // The two fields are kept in step: typing in one updates the other.
  // (Setting a controller's text doesn't call onChanged, so no loop.)

  void _portionsChanged(String text) {
    final count = parseNumber(text);
    setState(() {
      _portionsError = null;
      _amountError = null;
      if (count != null && count > 0) {
        _amount.text = formatNumber(count * _portionSize!);
      }
    });
  }

  void _amountChanged(String text) {
    final amount = parseNumber(text);
    setState(() {
      _amountError = null;
      _portionsError = null;
      if (amount != null && _portionSize != null) {
        _portions.text = formatNumber(amount / _portionSize!, decimals: 2);
      }
    });
  }

  void _submit() {
    final l10n = context.l10n;
    if (_portionSize != null) {
      final count = parseNumber(_portions.text);
      if (count == null || count <= 0) {
        setState(() => _portionsError = l10n.enterValidAmount);
        return;
      }
    }
    final value = parseNumber(_amount.text);
    if (value == null || value <= 0 || value > 10000) {
      setState(() => _amountError = l10n.enterValidAmount);
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final food = widget.food;
    final portion = _portionSize;
    final portionName = l10n.portionLabel(food);
    final amount = parseNumber(_amount.text);
    final kcal = amount == null ? null : food.nutrientsFor(amount).kcal;

    return AlertDialog(
      title: Row(
        children: [
          FoodImage(path: food.imagePath, size: 40),
          const SizedBox(width: 12),
          Expanded(child: Text(food.name)),
        ],
      ),
      // Scrollable so it still fits when the keyboard takes up the screen.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (portion != null) ...[
              TextField(
                controller: _portions,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.portionCount,
                  suffixText: portionName,
                  helperText:
                      '1 $portionName = ${formatNumber(portion)} ${food.unit}',
                  errorText: _portionsError,
                ),
                onChanged: _portionsChanged,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: _amount,
              autofocus: portion == null,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: food.unit == 'ml' ? l10n.volume : l10n.weight,
                suffixText: food.unit,
                errorText: _amountError,
              ),
              onChanged: _amountChanged,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            Text(
              kcal == null ? '–' : '${kcal.round()} kcal',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(l10n.kcalPer100(formatNumber(food.per100.kcal), food.unit)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
            onPressed: _submit, child: Text(widget.confirmLabel ?? l10n.add)),
      ],
    );
  }
}
