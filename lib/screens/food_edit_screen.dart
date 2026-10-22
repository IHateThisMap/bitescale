import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/labels.dart';
import '../models/food.dart';
import '../services/food_image_service.dart';
import '../services/food_sharing.dart';
import '../services/food_storage.dart';
import '../utils/format.dart';
import '../widgets/food_image.dart';
import '../widgets/remove_category_dialog.dart';

/// Creates a new saved food, or edits [food] if given.
/// Pops with the saved [Food].
class FoodEditScreen extends StatefulWidget {
  const FoodEditScreen({super.key, this.food, required this.categories});

  final Food? food;

  /// Existing categories (as saved), offered as suggestions.
  final List<String> categories;

  @override
  State<FoodEditScreen> createState() => _FoodEditScreenState();
}

class _FoodEditScreenState extends State<FoodEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _images = FoodImageService();

  late final Food? _food = widget.food;

  /// Saved categories offered as suggestions; the user's own can be removed.
  late final List<String> _categories = [...widget.categories];
  late final _name = TextEditingController(text: _food?.name);
  // The category is shown translated; it's turned back into its saved form
  // when saving.
  late final _category = TextEditingController(
      text: _food == null ? '' : context.l10n.categoryLabel(_food.category));
  late String _unit = _food?.unit ?? 'g';
  late final _kcal = _numberController(_food?.per100.kcal);
  late final _protein = _numberController(_food?.per100.protein);
  late final _carbs = _numberController(_food?.per100.carbs);
  late final _sugar = _numberController(_food?.per100.sugar);
  late final _fat = _numberController(_food?.per100.fat);
  late final _fiber = _numberController(_food?.per100.fiber);
  late final _salt = _numberController(_food?.per100.salt);
  late final _portionSize = _numberController(_food?.portionSize);
  late final _portionName = TextEditingController(text: _food?.portionName);

  /// A newly picked photo that hasn't been saved yet.
  String? _pickedImagePath;
  bool _removeImage = false;
  bool _saving = false;

  static TextEditingController _numberController(double? v) =>
      TextEditingController(text: v == null ? '' : formatNumber(v, decimals: 2));

  @override
  void dispose() {
    for (final c in [
      _name, _category, _kcal, _protein, _carbs, _sugar, _fat, _fiber, _salt,
      _portionSize, _portionName,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? get _shownImagePath =>
      _pickedImagePath ?? (_removeImage ? null : _food?.imagePath);

  Future<void> _choosePhoto() async {
    final hasImage = _shownImagePath != null;
    final source = await showModalBottomSheet<Object>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_images.canUseCamera)
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text(l10n.takePhoto),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.chooseFromGallery),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              if (hasImage)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(l10n.removePhoto),
                  onTap: () => Navigator.pop(context, 'remove'),
                ),
            ],
          ),
        );
      },
    );
    if (source == null) return;
    if (source == 'remove') {
      setState(() {
        _pickedImagePath = null;
        _removeImage = true;
      });
      return;
    }
    final path = await _images.pick(source as ImageSource);
    if (path != null) setState(() => _pickedImagePath = path);
  }

  /// Removes a category the user created. Its foods (this one included)
  /// move to "Other".
  Future<void> _removeCategory(String category) async {
    final storage = FoodStorage();
    final count =
        (await storage.loadFoods()).where((f) => f.category == category).length;
    if (!mounted || !await confirmRemoveCategory(context, category, count)) {
      return;
    }
    await storage.removeCategory(category);
    if (!mounted) return;
    final l10n = context.l10n;
    setState(() {
      _categories.remove(category);
      if (l10n.categoryToSave(_category.text) == category) {
        _category.text = l10n.categoryLabel(otherCategory);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final category = context.l10n.categoryToSave(_category.text);
    setState(() => _saving = true);

    final id = _food?.id ?? newId();
    var imagePath = _food?.imagePath;
    if (_pickedImagePath != null) {
      final saved = await _images.persist(_pickedImagePath!, id);
      await _images.delete(imagePath);
      imagePath = saved;
    } else if (_removeImage) {
      await _images.delete(imagePath);
      imagePath = null;
    }

    final food = Food(
      id: id,
      name: _name.text.trim(),
      category: category.isEmpty ? otherCategory : category,
      unit: _unit,
      per100: Nutrients(
        kcal: parseNumber(_kcal.text)!,
        protein: parseNumber(_protein.text),
        carbs: parseNumber(_carbs.text),
        sugar: parseNumber(_sugar.text),
        fat: parseNumber(_fat.text),
        fiber: parseNumber(_fiber.text),
        salt: parseNumber(_salt.text),
      ),
      imagePath: imagePath,
      portionSize: parseNumber(_portionSize.text),
      portionName: _portionName.text.trim().isEmpty
          ? null
          : _portionName.text.trim(),
      lastAmount: _food?.lastAmount,
      lastUsed: _food?.lastUsed,
      favourite: _food?.favourite ?? false,
    );
    if (mounted) Navigator.of(context).pop(food);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    // (saved name, shown name), sorted by what's shown.
    final suggestions = {...defaultFoodCategories, ..._categories}
        .map((c) => (saved: c, label: l10n.categoryLabel(c)))
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    return Scaffold(
      appBar: AppBar(
        title: Text(_food == null ? l10n.newFood : l10n.editFood),
        actions: [
          // Shares the food as saved, so unsaved edits aren't sent.
          if (_food != null)
            Builder(
              builder: (buttonContext) => IconButton(
                tooltip: l10n.shareFood,
                icon: const Icon(Icons.share),
                onPressed: () => shareFoods(buttonContext, [_food]),
              ),
            ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          // Extra room at the bottom for Android's navigation bar, which
          // the app draws under, so the save button can be scrolled clear.
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
          children: [
            if (FoodImageService.isSupported)
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _choosePhoto,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _pickedImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.file(File(_pickedImagePath!),
                                  width: 120, height: 120, fit: BoxFit.cover),
                            )
                          : FoodImage(path: _shownImagePath, size: 120),
                      const Padding(
                        padding: EdgeInsets.all(6),
                        child: CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.add_a_photo, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.nameRequired),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.enterName : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _category,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.category),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 0,
              children: [
                for (final (:saved, :label) in suggestions)
                  if (defaultFoodCategories.contains(saved))
                    ChoiceChip(
                      label: Text(label),
                      selected: _category.text.trim() == label,
                      onSelected: (_) =>
                          setState(() => _category.text = label),
                    )
                  else
                    // The user's own category: can also be removed.
                    InputChip(
                      label: Text(label),
                      selected: _category.text.trim() == label,
                      onSelected: (_) =>
                          setState(() => _category.text = label),
                      deleteButtonTooltipMessage: l10n.removeCategory,
                      onDeleted: () => _removeCategory(saved),
                    ),
              ],
            ),
            const SizedBox(height: 16),
            // Wraps onto two lines on narrow screens.
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(l10n.measuredIn),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'g', label: Text(l10n.grams)),
                    const ButtonSegment(value: 'ml', label: Text('ml')),
                  ],
                  selected: {_unit},
                  onSelectionChanged: (s) => setState(() => _unit = s.first),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _numberField(_portionSize, l10n.portionSize, _unit,
                      helper: l10n.optional),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _portionName,
                    decoration: InputDecoration(
                      labelText: l10n.portionCalled,
                      hintText: l10n.portionDefault,
                      helperText: l10n.portionCalledHelp,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.nutritionPer100(_unit), style: textTheme.titleMedium),
            const SizedBox(height: 8),
            _numberField(_kcal, l10n.caloriesRequired, 'kcal', required: true),
            const SizedBox(height: 8),
            Text(l10n.optional, style: textTheme.labelMedium),
            _numberField(_protein, l10n.nutrientProtein, 'g'),
            _numberField(_carbs, l10n.nutrientCarbs, 'g'),
            _numberField(_sugar, l10n.nutrientSugar, 'g'),
            _numberField(_fat, l10n.nutrientFat, 'g'),
            _numberField(_fiber, l10n.nutrientFiber, 'g'),
            _numberField(_salt, l10n.nutrientSalt, 'g'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(l10n.saveFood),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField(TextEditingController c, String label, String suffix,
      {bool required = false, String? helper}) {
    final l10n = context.l10n;
    final isPortion = c == _portionSize;
    return TextFormField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          labelText: label, suffixText: suffix, helperText: helper),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return required ? l10n.required : null;
        }
        final n = parseNumber(v);
        if (isPortion) {
          return n == null || n <= 0 ? l10n.enterSizeAboveZero : null;
        }
        return n == null || n < 0 ? l10n.enterValidNumber : null;
      },
    );
  }
}
