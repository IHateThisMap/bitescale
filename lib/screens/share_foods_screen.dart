import 'package:flutter/material.dart';

import '../l10n/labels.dart';
import '../models/food.dart';
import '../services/food_sharing.dart';
import '../utils/format.dart';
import '../widgets/food_image.dart';

/// Picks which saved foods to send to someone, then opens the share menu.
class ShareFoodsScreen extends StatefulWidget {
  const ShareFoodsScreen({super.key, required this.foods});

  final List<Food> foods;

  @override
  State<ShareFoodsScreen> createState() => _ShareFoodsScreenState();
}

class _ShareFoodsScreenState extends State<ShareFoodsScreen> {
  late final List<Food> _foods = [...widget.foods]
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  /// Everything is selected to start with: sharing all is the common case.
  late final Set<String> _selected = {for (final f in _foods) f.id};
  bool _sharing = false;

  Future<void> _share(BuildContext buttonContext) async {
    setState(() => _sharing = true);
    final foods = _foods.where((f) => _selected.contains(f.id)).toList();
    try {
      final shared = await shareFoods(buttonContext, foods);
      if (shared && mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.shareFailed)));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final allSelected = _selected.length == _foods.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shareFoods),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              if (allSelected) {
                _selected.clear();
              } else {
                _selected.addAll(_foods.map((f) => f.id));
              }
            }),
            child: Text(allSelected ? l10n.selectNone : l10n.selectAll),
          ),
        ],
      ),
      body: _foods.isEmpty
          ? Center(child: Text(l10n.noFoodsToExport))
          : ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(l10n.shareFoodsHelp,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                for (final food in _foods)
                  CheckboxListTile(
                    value: _selected.contains(food.id),
                    onChanged: (v) => setState(() => v!
                        ? _selected.add(food.id)
                        : _selected.remove(food.id)),
                    secondary: FoodImage(path: food.imagePath, size: 40),
                    title: Text(food.name),
                    subtitle: Text('${l10n.categoryLabel(food.category)} · '
                        '${l10n.kcalPer100(formatNumber(food.per100.kcal), food.unit)}'),
                  ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          // A Builder so the share menu can be placed next to this button.
          child: Builder(
            builder: (buttonContext) => FilledButton.icon(
              onPressed: _selected.isEmpty || _sharing
                  ? null
                  : () => _share(buttonContext),
              icon: const Icon(Icons.share),
              label: Text(l10n.shareButton(_selected.length)),
            ),
          ),
        ),
      ),
    );
  }
}
