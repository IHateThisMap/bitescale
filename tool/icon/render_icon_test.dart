// Draws the app icon and saves it as PNG files in assets/icon/.
//
// Regenerate the icon with:
//   flutter test tool/icon/render_icon_test.dart
//   dart run flutter_launcher_icons
//
// (It's a test only because that's the easiest way to run Flutter's
// drawing code from the command line. `flutter test` on its own doesn't
// run it, since it isn't in the test/ folder.)

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _size = 1024.0;

const _bgTop = Color(0xFF26A69A);
const _bgBottom = Color(0xFF00695C);
const _scaleBody = Colors.white;
const _dialFace = Color(0xFFE0F2F1);
const _dark = Color(0xFF004D40);
const _apple = Color(0xFFE53935);
const _appleDark = Color(0xFFB71C1C);
const _leaf = Color(0xFF66BB6A);
const _stem = Color(0xFF6D4C41);
const _tape = Color(0xFFFFD54F);
const _tapeEdge = Color(0xFFF9A825);
const _tapeCase = Color(0xFFFFB300);
const _tapeMarks = Color(0xFF5D4037);

/// Android adaptive icon background colour (the gradient's middle).
const adaptiveBackground = '#00897B';

void main() {
  testWidgets('render app icon', (tester) async {
    await tester.runAsync(() async {
      Directory('assets/icon').createSync(recursive: true);
      // Full icon: background + artwork (iOS, web, older Android).
      await _save('assets/icon/icon.png', (c) {
        _paintBackground(c);
        // Shrink a little and centre, so iOS's rounded corners don't clip.
        c.translate(_size / 2, _size / 2);
        c.scale(0.92);
        c.translate(-_size / 2, -_size / 2 - 30);
        _paintArtwork(c);
      });
      // Android adaptive icon foreground: artwork only, shrunk to fit the
      // circle Android may crop it to.
      await _save('assets/icon/icon_foreground.png', (c) {
        c.translate(_size / 2, _size / 2);
        c.scale(0.62);
        c.translate(-_size / 2, -_size / 2 - 30);
        _paintArtwork(c);
      });
    });
  });
}

Future<void> _save(String path, void Function(Canvas) paint) async {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder));
  final image =
      await recorder.endRecording().toImage(_size.toInt(), _size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void _paintBackground(Canvas c) {
  c.drawRect(
    const Rect.fromLTWH(0, 0, _size, _size),
    Paint()
      ..shader = ui.Gradient.linear(
          Offset.zero, const Offset(_size, _size), [_bgTop, _bgBottom]),
  );
}

void _paintArtwork(Canvas c) {
  _paintScale(c);
  _paintApple(c);
  _paintTapeMeasure(c);
}

/// A bathroom scale with a dial, seen from the front.
void _paintScale(Canvas c) {
  final body = RRect.fromLTRBR(220, 470, 804, 830, const Radius.circular(80));
  c.drawShadow(Path()..addRRect(body), Colors.black, 18, false);
  c.drawRRect(body, Paint()..color = _scaleBody);

  // Feet.
  final feet = Paint()..color = _dark;
  for (final x in [300.0, 724.0]) {
    c.drawRRect(
        RRect.fromLTRBR(x - 50, 815, x + 50, 855, const Radius.circular(20)),
        feet);
  }

  // Dial: a half circle with ticks and a needle pointing to "less".
  const center = Offset(512, 720);
  const r = 160.0;
  final dial = Path()
    ..addArc(Rect.fromCircle(center: center, radius: r), math.pi, math.pi)
    ..close();
  c.drawPath(dial, Paint()..color = _dialFace);
  c.drawPath(
      dial,
      Paint()
        ..color = _dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeJoin = StrokeJoin.round);

  final tick = Paint()
    ..color = _dark
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round;
  for (var i = 1; i < 8; i++) {
    final a = math.pi + math.pi * i / 8;
    final long = i.isEven;
    final dir = Offset(math.cos(a), math.sin(a));
    c.drawLine(center + dir * (r - (long ? 55 : 38)), center + dir * (r - 18),
        tick);
  }

  const needleAngle = math.pi * 1.3;
  c.drawLine(
    center,
    center + Offset(math.cos(needleAngle), math.sin(needleAngle)) * (r - 30),
    Paint()
      ..color = _apple
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round,
  );
  c.drawCircle(center, 20, Paint()..color = _dark);
}

/// An apple sitting on the scale.
void _paintApple(Canvas c) {
  final apple = Path()
    ..moveTo(512, 235)
    ..cubicTo(560, 200, 668, 205, 672, 315)
    ..cubicTo(676, 415, 610, 474, 560, 472)
    ..cubicTo(540, 471, 528, 462, 512, 462)
    ..cubicTo(496, 462, 484, 471, 464, 472)
    ..cubicTo(414, 474, 348, 415, 352, 315)
    ..cubicTo(356, 205, 464, 200, 512, 235)
    ..close();
  c.drawShadow(apple, Colors.black, 10, false);
  c.drawPath(
    apple,
    Paint()
      ..shader = ui.Gradient.radial(
          const Offset(450, 300), 260, [_apple, _appleDark]),
  );
  // Shine.
  c.save();
  c.translate(420, 300);
  c.rotate(-0.5);
  c.drawOval(const Rect.fromLTWH(-22, -45, 44, 90),
      Paint()..color = Colors.white.withValues(alpha: 0.45));
  c.restore();

  // Stem.
  c.drawPath(
    Path()
      ..moveTo(512, 245)
      ..quadraticBezierTo(510, 200, 535, 160),
    Paint()
      ..color = _stem
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round,
  );
  // Leaf.
  c.save();
  c.translate(590, 180);
  c.rotate(-0.45);
  final leaf = Path()
    ..moveTo(-55, 0)
    ..quadraticBezierTo(0, -45, 60, 0)
    ..quadraticBezierTo(0, 45, -55, 0)
    ..close();
  c.drawPath(leaf, Paint()..color = _leaf);
  c.restore();
}

/// A tape measure: a round case with the tape running out across the front.
void _paintTapeMeasure(Canvas c) {
  final tapePath = Path()
    ..moveTo(760, 850)
    ..quadraticBezierTo(470, 935, 150, 815);

  c.drawPath(
      tapePath,
      Paint()
        ..color = _tapeEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 80);
  c.drawPath(
      tapePath,
      Paint()
        ..color = _tape
        ..style = PaintingStyle.stroke
        ..strokeWidth = 62);

  // Marks along the tape, every other one longer.
  final mark = Paint()
    ..color = _tapeMarks
    ..strokeWidth = 7
    ..strokeCap = StrokeCap.round;
  final metric = tapePath.computeMetrics().first;
  var i = 0;
  for (var d = 40.0; d < metric.length - 20; d += 30, i++) {
    final t = metric.getTangentForOffset(d)!;
    final normal = Offset(-t.vector.dy, t.vector.dx);
    final len = i.isEven ? 26.0 : 14.0;
    final start = t.position - normal * 26;
    c.drawLine(start, start + normal * len, mark);
  }

  // Metal tab at the end of the tape.
  final end = metric.getTangentForOffset(metric.length)!;
  c.save();
  c.translate(end.position.dx, end.position.dy);
  c.rotate(end.angle * -1);
  c.drawRRect(
      RRect.fromLTRBR(-14, -44, 14, 44, const Radius.circular(6)),
      Paint()..color = const Color(0xFF90A4AE));
  c.restore();

  // Case.
  const caseCenter = Offset(800, 815);
  c.drawShadow(Path()..addOval(Rect.fromCircle(center: caseCenter, radius: 95)),
      Colors.black, 12, false);
  c.drawCircle(caseCenter, 95, Paint()..color = _tapeCase);
  c.drawCircle(
      caseCenter,
      95,
      Paint()
        ..color = _tapeEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10);
  c.drawCircle(caseCenter, 42, Paint()..color = _dark);
  c.drawCircle(caseCenter, 16, Paint()..color = _tapeCase);
}
