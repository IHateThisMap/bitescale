import 'package:flutter/material.dart';

import '../l10n/labels.dart';
import '../models/food.dart';

/// Asks whether to remove a category the user created, saying how many
/// foods will move to "Other".
Future<bool> confirmRemoveCategory(
    BuildContext context, String category, int foodCount) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = context.l10n;
      return AlertDialog(
        title: Text(l10n.removeCategoryTitle(category)),
        content: Text(
            l10n.removeCategoryBody(foodCount, l10n.categoryLabel(otherCategory))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.removeCategory),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}
