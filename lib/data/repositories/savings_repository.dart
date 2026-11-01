import '../models/savings_plan_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// Raised when a plan was saved locally but could not reach the server.
///
/// This is deliberately not an [ApiException]. The write did not fail, it was
/// deferred: the plan is in Hive and queued in the outbox, and the sync
/// service will POST it as soon as the network comes back. The UI shows it as
/// a warning rather than a failure.
class PlanQueuedException implements Exception {
  const PlanQueuedException(this.plan, this.reason);

  final SavingsPlanModel plan;

  /// The underlying network error, kept for logging.
  final String reason;

  String get message =>
      'Saved offline. "${plan.name}" will sync automatically when you are '
      'back online.';

  @override
  String toString() => message;
}

/// Savings plans.
///
/// Flow: API Request -> JSON Data -> Hive -> read from Hive -> Show on UI.
///
/// Writes are offline-first. [createPlan] stores the plan before it attempts
/// the POST, so a failed request can never lose the user's input.
class SavingsRepository {
  const SavingsRepository(this._storage, this._api);

  final StorageService _storage;
  final ApiService _api;

  /// Gets from the server on first run, then always reads from Hive.
  ///
  /// A failed GET leaves the box empty, so the dashboard shows its empty
  /// state and the next refresh or launch tries again.
  Future<List<SavingsPlanModel>> getPlans() async {
    if (!_storage.hasSavingsPlans) {
      try {
        final List<Map<String, dynamic>> raw = await _api.fetchSavingsPlans();
        final List<SavingsPlanModel> seeded = raw
            .map(SavingsPlanModel.fromJson)
            .toList(growable: false);

        if (seeded.isNotEmpty) {
          await _storage.saveSavingsPlans(seeded);
        }
      } on ApiException {
        // Nothing to seed with. Fall through and return whatever is stored.
      }
    }

    return _storage.readSavingsPlans();
  }

  /// Creates a plan locally, then POSTs it.
  ///
  /// Throws [PlanQueuedException] when the POST fails. The plan still exists in Hive and has been added to the outbox.
  Future<SavingsPlanModel> createPlan({
    required String name,
    required String productType,
    required double targetAmount,
    required double monthlyContribution,
    required String duration,
    String frequency = 'Monthly',
  }) async {
    final SavingsPlanModel plan = SavingsPlanModel(
      id: 'plan_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      productType: productType,
      // A new plan starts funded with its first contribution.
      amount: monthlyContribution,
      targetAmount: targetAmount,
      monthlyContribution: monthlyContribution,
      frequency: frequency,
      duration: duration,
      createdAt: DateTime.now(),
      isSynced: false,
    );

    // Persist before the network call and queue in the outbox immediately.
    await _storage.saveSavingsPlan(plan);
    await _storage.queuePlan(plan.id);

    try {
      await _api.createSavingsPlan(plan.toCreateRequest());
    } catch (error) {
      final String reason = error is ApiException
          ? error.message
          : error.toString();
      throw PlanQueuedException(plan, reason);
    }

    final SavingsPlanModel synced = plan.copyWith(isSynced: true);
    await _storage.saveSavingsPlan(synced);
    await _storage.dequeuePlan(plan.id);
    return synced;
  }

  /// Drains the outbox. Returns how many plans reached the server.
  ///
  /// Stops at the first failure rather than hammering an endpoint that is still unreachable; the next connectivity change retries.
  Future<int> syncPendingPlans() async {
    int syncedCount = 0;

    // Self-healing: ensure any un-synced plan in Hive is queued in pendingBox.
    for (final SavingsPlanModel plan in _storage.readSavingsPlans()) {
      if (!plan.isSynced) {
        await _storage.queuePlan(plan.id);
      }
    }

    for (final String id in _storage.pendingPlanIds()) {
      final SavingsPlanModel? plan = _storage.readSavingsPlan(id);

      if (plan == null) {
        // Queued id with no plan behind it. Drop it.
        await _storage.dequeuePlan(id);
        continue;
      }

      try {
        await _api.createSavingsPlan(plan.toCreateRequest());
        await _storage.saveSavingsPlan(plan.copyWith(isSynced: true));
        await _storage.dequeuePlan(id);
        syncedCount++;
      } catch (_) {
        break;
      }
    }

    return syncedCount;
  }

  bool get hasPendingPlans => _storage.hasPendingPlans;

  int get pendingPlanCount => _storage.pendingPlanCount;

  Future<void> deletePlan(String id) async {
    await _storage.dequeuePlan(id);
    await _storage.deleteSavingsPlan(id);
  }
}
