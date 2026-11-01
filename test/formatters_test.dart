import 'package:flutter_test/flutter_test.dart';
import 'package:koins_mfb_assessment/core/utils/formatters.dart';

void main() {
  group('Formatters.currency', () {
    test('prefixes the naira symbol and groups thousands', () {
      final String result = Formatters.currency(850000);
      expect(result, contains('₦'));
      expect(result, contains('850,000'));
    });

    test('drops decimals', () {
      expect(Formatters.currency(5000.4), isNot(contains('.')));
    });
  });

  group('Formatters.percent', () {
    test('renders whole numbers without a decimal point', () {
      expect(Formatters.percent(12), '12%');
      expect(Formatters.percent(18.0), '18%');
    });

    test('keeps a meaningful decimal', () {
      expect(Formatters.percent(7.5), '7.5%');
    });
  });

  group('Formatters.greeting', () {
    test('changes with the time of day', () {
      expect(Formatters.greeting(DateTime(2026, 1, 1, 8)), 'Good Morning');
      expect(Formatters.greeting(DateTime(2026, 1, 1, 13)), 'Good Afternoon');
      expect(Formatters.greeting(DateTime(2026, 1, 1, 20)), 'Good Evening');
    });
  });

  group('Formatters.initials', () {
    test('takes the first and last name', () {
      expect(Formatters.initials('John Doe'), 'JD');
      expect(Formatters.initials('john  adebayo  doe'), 'JD');
    });

    test('handles a single name and blanks', () {
      expect(Formatters.initials('John'), 'J');
      expect(Formatters.initials('   '), '?');
    });
  });

  group('Formatters.parseAmount', () {
    test('strips grouping separators', () {
      expect(Formatters.parseAmount('500,000'), 500000);
    });

    test('falls back to zero on junk input', () {
      expect(Formatters.parseAmount('abc'), 0);
    });
  });
}
