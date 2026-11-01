import 'package:flutter_test/flutter_test.dart';
import 'package:koins_mfb_assessment/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects an empty value', () {
      expect(Validators.email(''), 'Email address is required');
      expect(Validators.email(null), 'Email address is required');
      expect(Validators.email('   '), 'Email address is required');
    });

    test('rejects malformed addresses', () {
      expect(Validators.email('test'), isNotNull);
      expect(Validators.email('test@'), isNotNull);
      expect(Validators.email('test@bank'), isNotNull);
      expect(Validators.email('@bank.com'), isNotNull);
    });

    test('accepts well formed addresses', () {
      expect(Validators.email('test@bank.com'), isNull);
      expect(Validators.email('  test@bank.com  '), isNull);
      expect(Validators.email('john.doe+savings@koins.co.uk'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects an empty value', () {
      expect(Validators.password(''), 'Password is required');
      expect(Validators.password(null), 'Password is required');
    });

    test('enforces the eight character minimum', () {
      expect(Validators.password('Pass12'), isNotNull);
      expect(Validators.password('Pass123'), isNotNull);
      expect(Validators.password('Password123'), isNull);
    });
  });

  group('Validators.requiredField', () {
    test('uses the supplied label in the message', () {
      expect(
        Validators.requiredField('', label: 'Savings name'),
        'Savings name is required',
      );
    });

    test('passes on any non-blank value', () {
      expect(Validators.requiredField('Emergency Fund'), isNull);
    });
  });

  group('Validators.amount', () {
    test('rejects blanks and non-numbers', () {
      expect(Validators.amount(''), isNotNull);
      expect(Validators.amount('abc'), isNotNull);
    });

    test('enforces the minimum', () {
      expect(Validators.amount('4000', minimum: 5000), isNotNull);
      expect(Validators.amount('5000', minimum: 5000), isNull);
    });

    test('tolerates grouping separators', () {
      expect(Validators.amount('500,000', minimum: 5000), isNull);
    });
  });

  group('Validators.selection', () {
    test('rejects null and accepts a value', () {
      expect(Validators.selection(null, label: 'duration'), isNotNull);
      expect(Validators.selection('12 Months'), isNull);
    });
  });
}
