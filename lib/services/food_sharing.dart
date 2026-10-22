import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/labels.dart';
import '../models/food.dart';
import 'food_image_service.dart';
import 'food_transfer.dart';

/// Opens the phone's share menu (messaging apps, email, cloud drives...)
/// with [foods] as a file the other person can open with BiteScale.
///
/// [context] should be the button that was tapped; tablets show the share
/// menu next to it. Returns false if the user closed the menu without
/// sharing.
Future<bool> shareFoods(BuildContext context, List<Food> foods) async {
  final l10n = context.l10n;
  final box = context.findRenderObject() as RenderBox?;
  final origin =
      box == null ? null : box.localToGlobal(Offset.zero) & box.size;

  final bytes = await buildExport(foods, FoodImageService());
  final name = exportFileName(DateTime.now());
  final result = await SharePlus.instance.share(ShareParams(
    files: [XFile.fromData(bytes, mimeType: 'application/json', name: name)],
    fileNameOverrides: [name],
    text: l10n.shareFoodsMessage(foods.length),
    subject: l10n.shareFoodsSubject,
    sharePositionOrigin: origin,
  ));
  return result.status != ShareResultStatus.dismissed;
}
