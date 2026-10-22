import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Picks food photos and keeps copies of them in the app's own folder.
class FoodImageService {
  final _picker = ImagePicker();

  /// Photos are stored as files, which the web version can't do.
  static bool get isSupported => !kIsWeb;

  bool get canUseCamera => _picker.supportsImageSource(ImageSource.camera);

  /// Returns the path of a temporary file, or null if the user cancelled.
  Future<String?> pick(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    return file?.path;
  }

  /// Copies a picked image into app storage and returns the new path.
  Future<String> persist(String tempPath, String foodId) async {
    final target = await _newPath(foodId, extensionOf(tempPath));
    await File(tempPath).copy(target);
    return target;
  }

  /// Saves image bytes (e.g. from an imported file) into app storage and
  /// returns the new path.
  Future<String> persistBytes(
      Uint8List bytes, String foodId, String extension) async {
    final target = await _newPath(foodId, extension);
    await File(target).writeAsBytes(bytes);
    return target;
  }

  Future<Uint8List?> readBytes(String? path) async {
    if (path == null || !isSupported) return null;
    final file = File(path);
    return await file.exists() ? file.readAsBytes() : null;
  }

  /// The extension of [path] including the dot, e.g. ".jpg".
  static String extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    return dot == -1 || dot < path.lastIndexOf(RegExp(r'[/\\]'))
        ? '.jpg'
        : path.substring(dot);
  }

  Future<String> _newPath(String foodId, String extension) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/food_images');
    await dir.create(recursive: true);
    // A unique name per version, so Flutter doesn't show a cached old image.
    return '${dir.path}/${foodId}_${DateTime.now().microsecondsSinceEpoch}'
        '$extension';
  }

  Future<void> delete(String? path) async {
    if (path == null || !isSupported) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
