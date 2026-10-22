import 'package:flutter/material.dart';

import '../l10n/labels.dart';
import '../utils/format.dart';
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
