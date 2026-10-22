import 'package:flutter/material.dart';

import '../l10n/labels.dart';
import '../models/user_profile.dart';
import '../utils/body_metrics.dart';
import '../utils/format.dart';

/// Chooses between BMI and the U.S. Navy tape measure method, and takes the
/// tape measurements. Pops with the updated [UserProfile].
class BodyMetricDialog extends StatefulWidget {
  const BodyMetricDialog({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<BodyMetricDialog> createState() => _BodyMetricDialogState();
}

class _BodyMetricDialogState extends State<BodyMetricDialog> {
  late BodyMetric _metric = widget.profile.bodyMetric;
  late Sex? _sex = widget.profile.sex;
  late final _neck = _controller(widget.profile.neckCm);
  late final _waist = _controller(widget.profile.waistCm);
  late final _hip = _controller(widget.profile.hipCm);
  String? _error;

  static TextEditingController _controller(double? v) =>
      TextEditingController(text: v == null ? '' : formatNumber(v));

  @override
  void dispose() {
    _neck.dispose();
    _waist.dispose();
    _hip.dispose();
    super.dispose();
  }

  bool get _isFemale => _sex == Sex.female;

  /// Body fat % for what's currently typed in, for a live preview.
  double? get _preview {
    final neck = parseNumber(_neck.text);
    final waist = parseNumber(_waist.text);
    final hip = parseNumber(_hip.text);
    if (_sex == null || neck == null || waist == null) return null;
    return navyBodyFat(
      sex: _sex!,
      heightCm: widget.profile.heightCm!,
      neckCm: neck,
      waistCm: waist,
      hipCm: hip,
    );
  }

  void _submit() {
    var profile = widget.profile.copyWith(bodyMetric: _metric);
    if (_metric == BodyMetric.navyBodyFat) {
      final neck = parseNumber(_neck.text);
      final waist = parseNumber(_waist.text);
      final hip = parseNumber(_hip.text);
      final l10n = context.l10n;
      if (_sex == null) {
        setState(() => _error = l10n.chooseSex);
        return;
      }
      bool valid(double? v) => v != null && v >= 10 && v <= 250;
      if (!valid(neck) || !valid(waist) || (_isFemale && !valid(hip))) {
        setState(() => _error = l10n.enterAllMeasurements);
        return;
      }
      if (_preview == null) {
        setState(() => _error = l10n.invalidMeasurements);
        return;
      }
      final changed = neck != widget.profile.neckCm ||
          waist != widget.profile.waistCm ||
          (_isFemale && hip != widget.profile.hipCm) ||
          _sex != widget.profile.sex;
      profile = profile.copyWith(
        sex: _sex,
        neckCm: neck,
        waistCm: waist,
        hipCm: _isFemale ? hip : null,
        measuredAt: changed ? DateTime.now() : null,
      );
    }
    Navigator.of(context).pop(profile);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final preview = _preview;

    return AlertDialog(
      title: Text(l10n.bodyComposition),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<BodyMetric>(
              segments: [
                ButtonSegment(value: BodyMetric.bmi, label: Text(l10n.bmi)),
                ButtonSegment(
                    value: BodyMetric.navyBodyFat,
                    label: Text(l10n.tapeMeasure)),
              ],
              selected: {_metric},
              onSelectionChanged: (s) => setState(() {
                _metric = s.first;
                _error = null;
              }),
            ),
            const SizedBox(height: 12),
            if (_metric == BodyMetric.bmi)
              Text(l10n.bmiExplanation)
            else ...[
              Text(l10n.navyExplanation),
              const SizedBox(height: 12),
              SegmentedButton<Sex>(
                emptySelectionAllowed: true,
                segments: [
                  ButtonSegment(value: Sex.male, label: Text(l10n.male)),
                  ButtonSegment(value: Sex.female, label: Text(l10n.female)),
                ],
                selected: {?_sex},
                onSelectionChanged: (s) => setState(() {
                  if (s.isNotEmpty) _sex = s.first;
                  _error = null;
                }),
              ),
              _field(_neck, l10n.neck, l10n.neckHelp),
              _field(_waist, l10n.waist,
                  _isFemale ? l10n.waistHelpFemale : l10n.waistHelpMale),
              if (_isFemale) _field(_hip, l10n.hips, l10n.hipsHelp),
              const SizedBox(height: 12),
              Text(
                l10n.bodyFatPreview(
                    preview == null ? '–' : '${formatFixed(preview)} %'),
                style: textTheme.titleMedium,
              ),
              Text(l10n.heightUsed(formatNumber(widget.profile.heightCm!)),
                  style: textTheme.bodySmall),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }

  Widget _field(TextEditingController c, String label, String help) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration:
          InputDecoration(labelText: label, suffixText: 'cm', helperText: help, helperMaxLines: 2),
      onChanged: (_) => setState(() => _error = null),
    );
  }
}
