import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/labels.dart';

/// Parses user input, accepting both "72.5" and "72,5".
double? parseNumber(String text) =>
    double.tryParse(text.trim().replaceAll(',', '.'));

// Numbers use the app language's decimal separator (e.g. "72,5" in
// Finnish). No thousands separators, so the text can be parsed back.

/// Formats a number with up to [decimals] decimals, without trailing zeros.
String formatNumber(double v, {int decimals = 1}) =>
    NumberFormat(_pattern('#', decimals)).format(v);

/// Formats a number with exactly [decimals] decimals.
String formatFixed(double v, {int decimals = 1}) =>
    NumberFormat(_pattern('0', decimals)).format(v);

String _pattern(String digit, int decimals) =>
    decimals == 0 ? '0' : '0.${digit * decimals}';

/// Like [formatFixed], with a "+" in front of positive numbers.
String formatSigned(double v, {int decimals = 2}) =>
    '${v > 0 ? '+' : ''}${formatFixed(v, decimals: decimals)}';

/// Asks for a single number between [min] and [max].
Future<double?> showNumberDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String suffix,
  required double min,
  required double max,
  double? initial,
}) {
  return showDialog<double>(
    context: context,
    builder: (_) => _NumberDialog(
      title: title,
      label: label,
      suffix: suffix,
      min: min,
      max: max,
      initial: initial,
    ),
  );
}

class _NumberDialog extends StatefulWidget {
  const _NumberDialog({
    required this.title,
    required this.label,
    required this.suffix,
    required this.min,
    required this.max,
    this.initial,
  });

  final String title;
  final String label;
  final String suffix;
  final double min;
  final double max;
  final double? initial;

  @override
  State<_NumberDialog> createState() => _NumberDialogState();
}

class _NumberDialogState extends State<_NumberDialog> {
  late final _controller = TextEditingController(
      text: widget.initial == null ? '' : formatNumber(widget.initial!));
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = parseNumber(_controller.text);
    if (value == null || value < widget.min || value > widget.max) {
      setState(() => _error =
          context.l10n.valueBetween(
              formatNumber(widget.min), formatNumber(widget.max)));
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: widget.label,
          suffixText: widget.suffix,
          errorText: _error,
        ),
        onSubmitted: (_) => _submit(),
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
