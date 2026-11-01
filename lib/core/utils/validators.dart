class Validators {
  const Validators._();

  static final RegExp _emailPattern = RegExp(
    r'^[\w.+-]+@([\w-]+\.)+[a-zA-Z]{2,}$',
  );

  /// Email is required and must look like a real address.
  static String? email(String? value) {
    final String input = value?.trim() ?? '';
    if (input.isEmpty) return 'Email address is required';
    if (!_emailPattern.hasMatch(input)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Password is required and must be at least 8 characters.
  static String? password(String? value) {
    final String input = value ?? '';
    if (input.isEmpty) return 'Password is required';
    if (input.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Generic "this field cannot be empty" check.
  static String? requiredField(String? value, {String label = 'This field'}) {
    if ((value?.trim() ?? '').isEmpty) return '$label is required';
    return null;
  }

  /// Required numeric amount, optionally with a minimum.
  static String? amount(
    String? value, {
    String label = 'Amount',
    double minimum = 1,
  }) {
    final String input = (value ?? '').replaceAll(',', '').trim();
    if (input.isEmpty) return '$label is required';

    final double? parsed = double.tryParse(input);
    if (parsed == null) return 'Enter a valid number';
    if (parsed < minimum) {
      return '$label must be at least ${minimum.toStringAsFixed(0)}';
    }
    return null;
  }

  /// Dropdown selection check.
  static String? selection(Object? value, {String label = 'Selection'}) {
    if (value == null) return 'Please select a $label';
    return null;
  }
}
