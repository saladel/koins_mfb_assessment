import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/insight_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/savings_repository.dart';
import '../data/services/api_service.dart';
import '../data/services/storage_service.dart';

/// Dependency injection root.
///
/// Services and repositories are declared here once, so every feature provider
/// resolves its dependencies through `ref` instead of constructing them. Tests
/// override these with fakes and the rest of the app is unchanged.

/// Overridden in `main()` with the instance returned by
/// `StorageService.initialise()`. Hive must be open before the app runs, which
/// is why this cannot build itself lazily.
final Provider<StorageService> storageServiceProvider =
    Provider<StorageService>(
  (ref) => throw UnimplementedError(
    'storageServiceProvider must be overridden in main().',
  ),
);

final Provider<ApiService> apiServiceProvider =
    Provider<ApiService>((ref) => ApiService());

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(storageServiceProvider),
    ref.watch(apiServiceProvider),
  ),
);

final Provider<ProductRepository> productRepositoryProvider =
    Provider<ProductRepository>(
  (ref) => ProductRepository(
    ref.watch(apiServiceProvider),
    ref.watch(storageServiceProvider),
  ),
);

final Provider<SavingsRepository> savingsRepositoryProvider =
    Provider<SavingsRepository>(
  (ref) => SavingsRepository(
    ref.watch(storageServiceProvider),
    ref.watch(apiServiceProvider),
  ),
);

final Provider<InsightRepository> insightRepositoryProvider =
    Provider<InsightRepository>(
  (ref) => InsightRepository(ref.watch(apiServiceProvider)),
);
