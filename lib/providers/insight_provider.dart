import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/insight_model.dart';
import 'app_providers.dart';

/// Money tips pulled from the public mock API.
///
/// This is the app's live network call. `ref.invalidate(insightsProvider)`
/// re-runs it, which is how retry and pull-to-refresh are wired up.
final FutureProvider<List<InsightModel>> insightsProvider =
    FutureProvider<List<InsightModel>>(
  (ref) => ref.watch(insightRepositoryProvider).getInsights(),
);
