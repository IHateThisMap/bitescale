// Reading and showing numbers.
//
// Numbers use the app language's decimal separator (e.g. "72,5" in
// Finnish). No thousands separators, so the text can be parsed back.

import 'package:intl/intl.dart';

/// Parses user input, accepting both "72.5" and "72,5".
double? parseNumber(String text) =>
    double.tryParse(text.trim().replaceAll(',', '.'));

/// Formats a number with up to [decimals] decimals, without trailing zeros.
String formatNumber(double v, {int decimals = 1}) =>
    NumberFormat(_pattern('#', decimals)).format(v);

/// Formats a number with exactly [decimals] decimals.
String formatFixed(double v, {int decimals = 1}) =>
    NumberFormat(_pattern('0', decimals)).format(v);

String _pattern(String digit, int decimals) =>
    decimals == 0 ? '0' : '0.${digit * decimals}';

/// Like [formatFixed], with a "+" in front of positive numbers.
String formatSigned(double v, {int decimals = 2}) =>
    '${v > 0 ? '+' : ''}${formatFixed(v, decimals: decimals)}';
