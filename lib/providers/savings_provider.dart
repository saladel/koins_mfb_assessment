import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/savings_plan_model.dart';
import '../data/repositories/savings_repository.dart';
import 'app_providers.dart';

/// The user's savings plans.
///
/// An [AsyncNotifier] because the list is both loaded asynchronously and
/// mutated by the Create Savings flow. `AsyncValue` gives the dashboard its
/// loading, error and empty states from one object.
class SavingsNotifier extends AsyncNotifier<List<SavingsPlanModel>> {
  @override
  Future<List<SavingsPlanModel>> build() {
    return ref.read(savingsRepositoryProvider).getPlans();
  }

  /// Backs pull-to-refresh on the dashboard.
  Future<void> refresh() async {
    state = const AsyncValue<List<SavingsPlanModel>>.loading();
    await ref.read(savingsRepositoryProvider).syncPendingPlans();
    state = await AsyncValue.guard(
      () => ref.read(savingsRepositoryProvider).getPlans(),
    );
  }

  /// Creates a plan and saves it to the in-memory list so the dashboard
  /// updates without a round trip to Hive.
  ///
  /// Rethrows [PlanQueuedException] when the POST could not go through. The
  /// plan is still added to the list first, because it exists in Hive and the
  /// outbox will sync it later. The screen turns that exception into a
  /// warning rather than a failure.
  Future<SavingsPlanModel> createPlan({
    required String name,
    required String productType,
    required double targetAmount,
    required double monthlyContribution,
    required String duration,
    String frequency = 'Monthly',
  }) async {
    try {
      final SavingsPlanModel plan = await ref
          .read(savingsRepositoryProvider)
          .createPlan(
            name: name,
            productType: productType,
            targetAmount: targetAmount,
            monthlyContribution: monthlyContribution,
            duration: duration,
            frequency: frequency,
          );

      _prepend(plan);
      return plan;
    } on PlanQueuedException catch (error) {
      _prepend(error.plan);
      rethrow;
    }
  }

  void _prepend(SavingsPlanModel plan) {
    final List<SavingsPlanModel> current =
        state.value ?? const <SavingsPlanModel>[];

    state = AsyncValue<List<SavingsPlanModel>>.data(<SavingsPlanModel>[
      plan,
      ...current.where((SavingsPlanModel p) => p.id != plan.id),
    ]);
  }
}

final AsyncNotifierProvider<SavingsNotifier, List<SavingsPlanModel>>
savingsProvider =
    AsyncNotifierProvider<SavingsNotifier, List<SavingsPlanModel>>(
      SavingsNotifier.new,
    );

/// Sum of every plan's balance. Drives the dashboard total.
final Provider<double> totalSavingsProvider = Provider<double>((ref) {
  final List<SavingsPlanModel> plans =
      ref.watch(savingsProvider).value ?? const <SavingsPlanModel>[];

  return plans.fold<double>(
    0,
    (double sum, SavingsPlanModel plan) => sum + plan.amount,
  );
});

/// Plans saved locally but not yet accepted by the server.
final Provider<List<SavingsPlanModel>> unsyncedPlansProvider =
    Provider<List<SavingsPlanModel>>((ref) {
      final List<SavingsPlanModel> plans =
          ref.watch(savingsProvider).value ?? const <SavingsPlanModel>[];

      return plans
          .where((SavingsPlanModel plan) => !plan.isSynced)
          .toList(growable: false);
    });

/// The three most recent plans shown on the dashboard.
final Provider<List<SavingsPlanModel>> recentSavingsProvider =
    Provider<List<SavingsPlanModel>>((ref) {
      final List<SavingsPlanModel> plans =
          ref.watch(savingsProvider).value ?? const <SavingsPlanModel>[];

      return plans.take(3).toList(growable: false);
    });
