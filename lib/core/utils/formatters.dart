import 'package:intl/intl.dart';

/// Display formatting helpers. Pure functions, easy to unit test.
class Formatters {
  const Formatters._();

  // Locale is left unset so intl falls back to bundled data. The naira symbol
  // is supplied explicitly, which is what we actually care about.
  static final NumberFormat _currency = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
  );

  static final NumberFormat _compactCurrency = NumberFormat.compactCurrency(
    symbol: '₦',
    decimalDigits: 1,
  );

  static final NumberFormat _decimal = NumberFormat.decimalPattern();
  static final DateFormat _date = DateFormat('d MMM yyyy');
  static final DateFormat _dateTime = DateFormat('d MMM yyyy, h:mm a');

  /// `850000` becomes `₦850,000`.
  static String currency(num value) => _currency.format(value);

  /// `850000` becomes `₦850.0K`. Useful in tight card layouts.
  static String compactCurrency(num value) => _compactCurrency.format(value);

  /// `850000` becomes `850,000` with no symbol.
  static String number(num value) => _decimal.format(value);

  static String date(DateTime value) => _date.format(value);

  static String dateTime(DateTime value) => _dateTime.format(value);

  /// `12` becomes `12%`, `7.5` becomes `7.5%`.
  static String percent(num value) {
    final String body =
        value % 1 == 0 ? value.toInt().toString() : value.toString();
    return '$body%';
  }

  /// Time-of-day greeting for the dashboard header.
  static String greeting([DateTime? now]) {
    final int hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// `John Doe` becomes `JD`. Used by the profile avatar.
  static String initials(String fullName) {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Strips grouping separators before parsing user input.
  static double parseAmount(String value) {
    return double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
  }
}
