import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../l10n/labels.dart';
import '../models/food.dart';
import '../services/food_image_service.dart';
import '../services/food_storage.dart';
import '../services/food_transfer.dart';
import '../widgets/food_image.dart';
import '../widgets/number_dialog.dart';

/// Imports a food file, whether picked in the app or sent by someone:
/// compares it with the saved foods, lets the user review it, and reports
/// the outcome. Returns null if nothing was imported.
Future<ImportResult?> importFoodFile(
    BuildContext context, List<int> bytes) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  final List<TransferFood> incoming;
  try {
    incoming = decodeFoods(bytes);
  } on NotAFoodFileException {
    messenger.showSnackBar(SnackBar(content: Text(l10n.notAFoodFile)));
    return null;
  }

  final images = FoodImageService();
  final foods = await FoodStorage().loadFoods();
  final existingImages = {
    for (final f in foods) f.id: await images.readBytes(f.imagePath),
  };
  final items = planImport(incoming, foods, existingImages);
  if (items.every((i) => i.status == ImportStatus.duplicate)) {
    messenger.showSnackBar(
        SnackBar(content: Text(l10n.importNothingNew(items.length))));
    return null;
  }

  final result = await navigator.push<ImportResult>(
    MaterialPageRoute(builder: (_) => ImportFoodsScreen(items: items)),
  );
  if (result != null) {
    messenger.showSnackBar(SnackBar(
        content: Text(l10n.importDone(result.added, result.replaced))));
  }
  return result;
}

/// Shows what an import file contains and lets the user choose what to
/// import. Pops with an [ImportResult] once imported.
class ImportFoodsScreen extends StatefulWidget {
  const ImportFoodsScreen({super.key, required this.items});

  final List<ImportItem> items;

  @override
  State<ImportFoodsScreen> createState() => _ImportFoodsScreenState();
}

class _ImportFoodsScreenState extends State<ImportFoodsScreen> {
  bool _importing = false;

  List<ImportItem> _withStatus(ImportStatus s) =>
      widget.items.where((i) => i.status == s).toList();

  Future<void> _import() async {
    setState(() => _importing = true);
    final result =
        await applyImport(widget.items, FoodStorage(), FoodImageService());
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final newFoods = _withStatus(ImportStatus.newFood);
    final similar = _withStatus(ImportStatus.similar);
    final duplicates = _withStatus(ImportStatus.duplicate);
    final count = widget.items.where((i) => i.willImport).length;
    final allSelected = newFoods.every((i) => i.selected);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.importFoods)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(l10n.importFoundFoods(widget.items.length)),
          if (duplicates.isNotEmpty)
            Text(l10n.importSkippedDuplicates(duplicates.length),
                style: textTheme.bodySmall),
          if (newFoods.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child:
                        Text(l10n.importNewFoods, style: textTheme.titleMedium)),
                TextButton(
                  onPressed: () => setState(() {
                    for (final i in newFoods) {
                      i.selected = !allSelected;
                    }
                  }),
                  child: Text(allSelected ? l10n.selectNone : l10n.selectAll),
                ),
              ],
            ),
            for (final item in newFoods)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: item.selected,
                onChanged: (v) => setState(() => item.selected = v!),
                secondary: _Photo(item.incoming.image, size: 48),
                title: Text(item.incoming.food.name),
                subtitle: Text(_summary(l10n, item.incoming.food)),
              ),
          ],
          if (similar.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l10n.importSimilarFoods, style: textTheme.titleMedium),
            Text(l10n.importSimilarHelp, style: textTheme.bodySmall),
            const SizedBox(height: 8),
            for (final item in similar)
              _SimilarFoodCard(
                item: item,
                onChanged: (choice) => setState(() => item.choice = choice),
              ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: count == 0 || _importing ? null : _import,
            child: Text(l10n.importButton(count)),
          ),
        ),
      ),
    );
  }
}

String _summary(AppLocalizations l10n, Food food) =>
    '${l10n.categoryLabel(food.category)} · '
    '${l10n.kcalPer100(formatNumber(food.per100.kcal), food.unit)}';

/// A food in the file next to the similar one in the app, with their
/// differences and the choice of which to keep.
class _SimilarFoodCard extends StatelessWidget {
  const _SimilarFoodCard({required this.item, required this.onChanged});

  final ImportItem item;
  final ValueChanged<ConflictChoice> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final mine = item.existing!;
    final theirs = item.incoming.food;
    final rows = item.differences.where((f) => f != FoodField.photo);
    final photoDiffers = item.differences.contains(FoodField.photo);

    TableRow row(String label, String a, String b, {bool header = false}) {
      final style = header
          ? textTheme.labelMedium
          : textTheme.bodyMedium;
      Widget cell(String text) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Text(text, style: style),
          );
      return TableRow(children: [cell(label), cell(a), cell(b)]);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(theirs.name, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.1),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              border: TableBorder(
                horizontalInside: BorderSide(color: colors.outlineVariant),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                row('', l10n.yours, l10n.imported, header: true),
                for (final field in rows)
                  row(_fieldLabel(l10n, field, mine.unit),
                      _fieldValue(l10n, field, mine),
                      _fieldValue(l10n, field, theirs)),
                if (photoDiffers)
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(l10n.fieldPhoto),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: _Photo(item.existingImage, size: 56),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: _Photo(item.incoming.image, size: 56),
                    ),
                  ]),
              ],
            ),
            const SizedBox(height: 8),
            RadioGroup<ConflictChoice>(
              groupValue: item.choice,
              onChanged: (c) => onChanged(c!),
              child: Column(
                children: [
                  for (final (choice, label) in [
                    (ConflictChoice.keepMine, l10n.keepMine),
                    (ConflictChoice.useImported, l10n.useImported),
                    (ConflictChoice.keepBoth, l10n.keepBoth),
                  ])
                    RadioListTile<ConflictChoice>(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: choice,
                      title: Text(label),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fieldLabel(AppLocalizations l10n, FoodField field, String unit) =>
    switch (field) {
      FoodField.name => l10n.fieldName,
      FoodField.category => l10n.category,
      FoodField.unit => l10n.fieldUnit,
      FoodField.kcal => l10n.fieldCalories,
      FoodField.protein => l10n.nutrientProtein,
      FoodField.carbs => l10n.nutrientCarbs,
      FoodField.sugar => l10n.nutrientSugar,
      FoodField.fat => l10n.nutrientFat,
      FoodField.fiber => l10n.nutrientFiber,
      FoodField.salt => l10n.nutrientSalt,
      FoodField.portionSize => l10n.portionSize,
      FoodField.portionName => l10n.portionCalled,
      FoodField.photo => l10n.fieldPhoto,
    };

String _fieldValue(AppLocalizations l10n, FoodField field, Food food) {
  String grams(double? v) => v == null ? '–' : '${formatNumber(v)} g';
  return switch (field) {
    FoodField.name => food.name,
    FoodField.category => l10n.categoryLabel(food.category),
    FoodField.unit => food.unit,
    FoodField.kcal => '${formatNumber(food.per100.kcal)} kcal',
    FoodField.protein => grams(food.per100.protein),
    FoodField.carbs => grams(food.per100.carbs),
    FoodField.sugar => grams(food.per100.sugar),
    FoodField.fat => grams(food.per100.fat),
    FoodField.fiber => grams(food.per100.fiber),
    FoodField.salt => grams(food.per100.salt),
    FoodField.portionSize => food.portionSize == null
        ? '–'
        : '${formatNumber(food.portionSize!)} ${food.unit}',
    FoodField.portionName => food.portionName ?? '–',
    FoodField.photo => '',
  };
}

/// A photo from image bytes, or the usual placeholder.
class _Photo extends StatelessWidget {
  const _Photo(this.bytes, {required this.size});

  final Uint8List? bytes;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (bytes == null) return FoodImage(path: null, size: size);
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.2),
      child: Image.memory(bytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => FoodImage(path: null, size: size)),
    );
  }
}
