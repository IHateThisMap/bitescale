import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Food files someone sent, opened with BiteScale or shared to it.
///
/// Only Android delivers these (see MainActivity.kt); elsewhere received
/// files are imported with "Import foods".
class IncomingFiles {
  static const _channel = MethodChannel('bitescale/incoming_file');

  /// Calls [onFile] with the file the app was opened with, if any, and
  /// with every file received while it's running.
  static Future<void> listen(ValueChanged<Uint8List> onFile) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'fileReceived') onFile(call.arguments as Uint8List);
    });
    final initial = await _channel.invokeMethod<Uint8List>('takeInitialFile');
    if (initial != null) onFile(initial);
  }
}
