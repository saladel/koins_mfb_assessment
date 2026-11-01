import 'package:flutter_test/flutter_test.dart';
import 'package:koins_mfb_assessment/data/models/savings_plan_model.dart';

SavingsPlanModel buildPlan({double amount = 120000, double target = 300000}) {
  return SavingsPlanModel(
    id: 'plan_1',
    name: 'Emergency Fund',
    productType: 'Target Savings',
    amount: amount,
    targetAmount: target,
    monthlyContribution: 25000,
    frequency: 'Monthly',
    duration: '12 Months',
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('SavingsPlanModel.progress', () {
    test('is the ratio of amount to target', () {
      expect(buildPlan(amount: 150000, target: 300000).progress, 0.5);
    });

    test('is clamped to 1 when the target is exceeded', () {
      expect(buildPlan(amount: 400000, target: 300000).progress, 1.0);
    });

    test('is zero when there is no target', () {
      expect(buildPlan(amount: 100000, target: 0).progress, 0);
    });
  });

  group('SavingsPlanModel serialisation', () {
    test('survives a round trip through the Hive string format', () {
      final SavingsPlanModel original = buildPlan();
      final SavingsPlanModel restored =
          SavingsPlanModel.fromRaw(original.toRaw());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.amount, original.amount);
      expect(restored.targetAmount, original.targetAmount);
      expect(restored.frequency, original.frequency);
      expect(restored.createdAt, original.createdAt);
    });

    test('falls back to safe defaults on malformed json', () {
      final SavingsPlanModel plan =
          SavingsPlanModel.fromJson(<String, dynamic>{});

      expect(plan.id, '');
      expect(plan.amount, 0);
      expect(plan.frequency, 'Monthly');
    });
  });
}
