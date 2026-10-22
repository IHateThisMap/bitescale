import 'package:flutter/material.dart';

import '../l10n/labels.dart';
import '../widgets/language_button.dart';
import '../widgets/number_dialog.dart';

/// Shown on first launch to ask for the user's height.
class HeightSetupScreen extends StatefulWidget {
  const HeightSetupScreen({super.key, required this.onSaved});

  final ValueChanged<double> onSaved;

  @override
  State<HeightSetupScreen> createState() => _HeightSetupScreenState();
}

class _HeightSetupScreenState extends State<HeightSetupScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = parseNumber(_controller.text);
    if (value == null || value < 50 || value > 272) {
      setState(() => _error = context.l10n.heightError);
      return;
    }
    widget.onSaved(value);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(actions: const [LanguageButton()]),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.height,
                      size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(context.l10n.welcome,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.heightQuestion,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: context.l10n.height,
                      suffixText: 'cm',
                      errorText: _error,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(context.l10n.continueButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
