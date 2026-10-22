import 'package:flutter/material.dart';

import '../l10n/labels.dart';

/// Asks a yes/no question. Returns true only if the user taps "Yes".
Future<bool> confirmYesNo(BuildContext context, String title,
    {String? message}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = context.l10n;
      return AlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yes),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}
