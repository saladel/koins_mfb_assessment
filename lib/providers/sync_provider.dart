import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';
import 'savings_provider.dart';

/// Outbox state, surfaced to the UI.
class SyncState {
  const SyncState({
    this.isSyncing = false,
    this.pendingCount = 0,
    this.lastSyncedCount = 0,
  });

  final bool isSyncing;

  /// Plans still waiting to reach the server.
  final int pendingCount;

  /// How many plans the most recent drain pushed through.
  final int lastSyncedCount;

  bool get hasPending => pendingCount > 0;

  SyncState copyWith({
    bool? isSyncing,
    int? pendingCount,
    int? lastSyncedCount,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncedCount: lastSyncedCount ?? this.lastSyncedCount,
    );
  }
}

/// Drains the outbox whenever the device regains a network interface.
///
/// Connectivity is used as a *trigger*, not as a gate. `connectivity_plus`
/// reports whether an interface is up, not whether anything is reachable:
/// captive-portal Wi-Fi reports connected, and a VPN can report none while
/// traffic still flows. So writes always attempt the request and treat its
/// failure as the real signal. This listener only decides when it is worth
/// trying again.
class SyncNotifier extends Notifier<SyncState> {
  StreamSubscription<dynamic>? _subscription;

  @override
  SyncState build() {
    // The listener is typed loosely on purpose. connectivity_plus 6 and above
    // emit List<ConnectivityResult>; version 5 emitted a single result. This
    // handles both, so the package version does not break the build.
    _subscription = Connectivity().onConnectivityChanged.listen(
      (dynamic result) {
        final bool isOnline = result is List
            ? result.any((dynamic r) => r != ConnectivityResult.none)
            : result != ConnectivityResult.none;

        if (isOnline) unawaited(syncNow());
      },
    );

    ref.onDispose(() => _subscription?.cancel());

    // Drain anything left over from a previous session.
    Future<void>.microtask(syncNow);

    return SyncState(
      pendingCount: ref.read(savingsRepositoryProvider).pendingPlanCount,
    );
  }

  /// Attempts to push every queued plan. Safe to call repeatedly.
  Future<void> syncNow() async {
    if (state.isSyncing) return;

    final repository = ref.read(savingsRepositoryProvider);
    if (!repository.hasPendingPlans) {
      state = state.copyWith(pendingCount: 0);
      return;
    }

    state = state.copyWith(isSyncing: true);

    int syncedCount = 0;
    try {
      syncedCount = await repository.syncPendingPlans();
    } catch (_) {
      // Still unreachable. The next connectivity change retries.
    }

    state = SyncState(
      isSyncing: false,
      pendingCount: repository.pendingPlanCount,
      lastSyncedCount: syncedCount,
    );

    if (syncedCount > 0) {
      // Pull the newly synced plans back out of Hive so the UI drops its
      // pending badges.
      await ref.read(savingsProvider.notifier).refresh();
    }
  }
}

final NotifierProvider<SyncNotifier, SyncState> syncProvider =
    NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);
