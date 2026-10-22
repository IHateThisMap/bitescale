import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../l10n/labels.dart';
import '../models/food.dart';
import '../services/food_image_service.dart';
import '../services/food_storage.dart';
import '../services/food_transfer.dart';
import '../utils/format.dart';
import '../widgets/amount_dialog.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/food_image.dart';
import '../widgets/remove_category_dialog.dart';
import 'food_edit_screen.dart';
import 'import_foods_screen.dart';
import 'share_foods_screen.dart';

/// A food and the amount the user chose to log.
class FoodPick {
  const FoodPick(this.food, this.amount);
  final Food food;
  final double amount;
}

/// Lists saved foods with search and category filters.
///
/// With [pickMode] tapping a food asks for an amount and pops with a
/// [FoodPick]; otherwise tapping opens the food for editing.
class FoodLibraryScreen extends StatefulWidget {
  const FoodLibraryScreen({super.key, this.pickMode = false});

  final bool pickMode;

  @override
  State<FoodLibraryScreen> createState() => _FoodLibraryScreenState();
}

class _FoodLibraryScreenState extends State<FoodLibraryScreen> {
  final _storage = FoodStorage();
  final _images = FoodImageService();
  List<Food> _foods = [];
  bool _loading = true;
  String _query = '';

  /// Selected category filter (as saved), or null for all.
  String? _category;

  @override
  void initState() {
    super.initState();
    _storage.loadFoods().then((foods) {
      if (!mounted) return;
      setState(() {
        _foods = foods;
        _loading = false;
      });
    });
  }

  /// Saved categories that are in use, sorted by their shown name.
  List<String> _categories(AppLocalizations l10n) =>
      _foods.map((f) => f.category).toSet().toList()
        ..sort((a, b) => l10n.categoryLabel(a).compareTo(l10n.categoryLabel(b)));

  List<Food> _visibleFoods(AppLocalizations l10n) {
    final q = _query.trim().toLowerCase();
    final list = _foods
        .where((f) => _category == null || f.category == _category)
        .where((f) =>
            q.isEmpty ||
            f.name.toLowerCase().contains(q) ||
            l10n.categoryLabel(f.category).toLowerCase().contains(q))
        .toList();
    // Most recently used first, then alphabetically.
    list.sort((a, b) {
      final byUse = (b.lastUsed ?? DateTime(0)).compareTo(a.lastUsed ?? DateTime(0));
      return byUse != 0
          ? byUse
          : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  Future<void> _saveFood(Food food) async {
    setState(() {
      final i = _foods.indexWhere((f) => f.id == food.id);
      if (i == -1) {
        _foods = [..._foods, food];
      } else {
        _foods = [..._foods]..[i] = food;
      }
    });
    await _storage.saveFoods(_foods);
  }

  Future<Food?> _openEditor([Food? food]) async {
    final categories = _foods.map((f) => f.category).toSet().toList();
    final saved = await Navigator.of(context).push<Food>(MaterialPageRoute(
      builder: (_) => FoodEditScreen(food: food, categories: categories),
    ));
    // The editor can remove categories, which changes other foods too, so
    // start from what's stored rather than this screen's copy.
    final foods = await _storage.loadFoods();
    if (mounted) setState(() => _foods = foods);
    if (saved != null) await _saveFood(saved);
    return saved;
  }

  Future<void> _pick(Food food) async {
    final amount = await showAmountDialog(context, food);
    if (amount == null) return;
    final used = food.withUsage(amount);
    await _saveFood(used);
    if (mounted) Navigator.of(context).pop(FoodPick(used, amount));
  }

  Future<void> _createFood() async {
    final food = await _openEditor();
    if (food != null && widget.pickMode && mounted) await _pick(food);
  }

  Future<bool> _confirmDelete(Food food) => confirmYesNo(
      context, context.l10n.deleteFoodTitle(food.name),
      message: context.l10n.deleteFoodBody);

  /// Deletes via the ✕ button (swiping goes through the Dismissible).
  Future<void> _deleteWithConfirm(Food food) async {
    if (await _confirmDelete(food)) await _delete(food);
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _export() async {
    final l10n = context.l10n;
    if (_foods.isEmpty) {
      _showMessage(l10n.noFoodsToExport);
      return;
    }
    try {
      final bytes = await buildExport(_foods, _images);
      final saved = await FilePicker.saveFile(
        fileName: exportFileName(DateTime.now()),
        bytes: bytes,
        mimeType: 'application/json',
        dialogTitle: l10n.exportFoods,
      );
      if (saved != null) _showMessage(l10n.exportedFoods(_foods.length));
    } catch (_) {
      _showMessage(l10n.exportFailed);
    }
  }

  Future<void> _import() async {
    final l10n = context.l10n;
    final file = await FilePicker.pickFile(
      dialogTitle: l10n.importFoods,
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;
    final result = await importFoodFile(context, bytes);
    if (result == null || !mounted) return;
    final foods = await _storage.loadFoods();
    if (mounted) setState(() => _foods = foods);
  }

  Future<void> _share() async {
    await Navigator.of(context).push<void>(MaterialPageRoute(
      builder: (_) => ShareFoodsScreen(foods: _foods),
    ));
  }

  Future<void> _manageCategories() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _ManageCategoriesDialog(
        foods: _foods,
        onRemove: (category) async {
          await _storage.removeCategory(category);
          final foods = await _storage.loadFoods();
          if (mounted) setState(() => _foods = foods);
          return foods;
        },
      ),
    );
  }

  Future<void> _delete(Food food) async {
    setState(() => _foods = _foods.where((f) => f.id != food.id).toList());
    await _storage.saveFoods(_foods);
    await _images.delete(food.imagePath);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final foods = _visibleFoods(l10n);
    final categories = _categories(l10n);
    if (_category != null && !categories.contains(_category)) _category = null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pickMode ? l10n.addFood : l10n.myFoods),
        actions: [
          IconButton(
            tooltip: l10n.shareFoods,
            icon: const Icon(Icons.share),
            onPressed: _foods.isEmpty ? null : _share,
          ),
          PopupMenuButton<VoidCallback>(
            onSelected: (action) => action(),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _share,
                enabled: _foods.isNotEmpty,
                child: ListTile(
                  leading: const Icon(Icons.share),
                  title: Text(l10n.shareFoods),
                ),
              ),
              PopupMenuItem(
                value: _export,
                child: ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: Text(l10n.exportFoods),
                ),
              ),
              PopupMenuItem(
                value: _import,
                child: ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(l10n.importFoods),
                ),
              ),
              PopupMenuItem(
                value: _manageCategories,
                child: ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: Text(l10n.manageCategories),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'newFood',
        onPressed: _createFood,
        icon: const Icon(Icons.add),
        label: Text(l10n.newFood),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SearchBar(
                    hintText: l10n.searchFoods,
                    leading: const Icon(Icons.search),
                    elevation: const WidgetStatePropertyAll(0),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                if (categories.isNotEmpty)
                  SizedBox(
                    height: 56,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(l10n.all),
                            selected: _category == null,
                            onSelected: (_) => setState(() => _category = null),
                          ),
                        ),
                        for (final c in categories)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(l10n.categoryLabel(c)),
                              selected: _category == c,
                              onSelected: (_) => setState(() => _category = c),
                            ),
                          ),
                      ],
                    ),
                  ),
                Expanded(
                  child: foods.isEmpty
                      ? Center(
                          child: Text(
                            _foods.isEmpty
                                ? l10n.noSavedFoods
                                : l10n.noFoodsMatch,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          // Room for the button, and for Android's
                          // navigation bar when the app draws under it.
                          padding: EdgeInsets.only(
                              bottom:
                                  96 + MediaQuery.paddingOf(context).bottom),
                          itemCount: foods.length,
                          itemBuilder: (context, i) => _tile(l10n, foods[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _tile(AppLocalizations l10n, Food food) {
    final portion = food.portionSize;
    final per100 = l10n.kcalPer100(formatNumber(food.per100.kcal), food.unit);
    final portionLine = portion == null
        ? ''
        : '\n1 ${l10n.portionLabel(food)} = ${formatNumber(portion)} '
            '${food.unit} · ${food.nutrientsFor(portion).kcal.round()} kcal';

    return Dismissible(
      key: ValueKey(food.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(food),
      onDismissed: (_) => _delete(food),
      child: ListTile(
        leading: FoodImage(path: food.imagePath),
        title: Text(food.name),
        subtitle: Text(
            '${l10n.categoryLabel(food.category)} · $per100$portionLine'),
        isThreeLine: portion != null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: food.favourite
                  ? l10n.removeFromFavourites
                  : l10n.addToFavourites,
              isSelected: food.favourite,
              icon: const Icon(Icons.star_border),
              selectedIcon: const Icon(Icons.star, color: Colors.amber),
              onPressed: () => _saveFood(food.withFavourite(!food.favourite)),
            ),
            // In "My foods" tapping the food opens it for editing; in
            // "Add food" tapping logs it, so editing needs its own button.
            if (widget.pickMode)
              IconButton(
                tooltip: l10n.edit,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _openEditor(food),
              ),
            IconButton(
              tooltip: l10n.deleteFoodTemplate,
              icon: const Icon(Icons.close),
              onPressed: () => _deleteWithConfirm(food),
            ),
          ],
        ),
        onTap: () => widget.pickMode ? _pick(food) : _openEditor(food),
      ),
    );
  }
}

/// Lists the categories the user has created and lets them be removed.
/// Foods in a removed category move to "Other".
class _ManageCategoriesDialog extends StatefulWidget {
  const _ManageCategoriesDialog({required this.foods, required this.onRemove});

  final List<Food> foods;

  /// Removes the category and returns the updated foods.
  final Future<List<Food>> Function(String category) onRemove;

  @override
  State<_ManageCategoriesDialog> createState() =>
      _ManageCategoriesDialogState();
}

class _ManageCategoriesDialogState extends State<_ManageCategoriesDialog> {
  late List<Food> _foods = widget.foods;

  /// The user's own categories with how many foods use each.
  List<(String, int)> get _customCategories {
    final counts = <String, int>{};
    for (final f in _foods) {
      if (!defaultFoodCategories.contains(f.category)) {
        counts[f.category] = (counts[f.category] ?? 0) + 1;
      }
    }
    return counts.entries.map((e) => (e.key, e.value)).toList()
      ..sort((a, b) => a.$1.toLowerCase().compareTo(b.$1.toLowerCase()));
  }

  Future<void> _remove(String category, int count) async {
    if (!await confirmRemoveCategory(context, category, count)) return;
    final foods = await widget.onRemove(category);
    if (mounted) setState(() => _foods = foods);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = _customCategories;

    return AlertDialog(
      title: Text(l10n.manageCategories),
      content: SizedBox(
        width: double.maxFinite,
        child: categories.isEmpty
            ? Text(l10n.noCustomCategories)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.customCategoriesHelp,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final (category, count) in categories)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(category),
                            subtitle: Text(l10n.foodCount(count)),
                            trailing: IconButton(
                              tooltip: l10n.removeCategory,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _remove(category, count),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
