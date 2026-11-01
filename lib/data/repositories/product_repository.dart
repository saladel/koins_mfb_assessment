import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// Savings product catalogue, cache-then-network.
///
/// [getProducts] fetches from the server and writes every success to Hive. If
/// the request fails it serves the last cached catalogue, and only throws when
/// there is no cache to fall back on. That keeps the products screen's error
/// state reachable (first launch with no connection) while still working
/// offline on every launch after that.
class ProductRepository {
  const ProductRepository(this._api, this._storage);

  final ApiService _api;
  final StorageService _storage;

  static const List<ProductModel> _bundledCatalogue = <ProductModel>[
    ProductModel(
      id: 'target_savings',
      name: 'Target Savings',
      interestRate: 12,
      duration: '12 Months',
      minimumDeposit: 5000,
      description:
          'Lock in a goal, fund it on your own schedule and earn 12% a year '
          'while you get there.',
    ),
    ProductModel(
      id: 'fixed_deposit',
      name: 'Fixed Deposit',
      interestRate: 18,
      duration: '6 Months',
      minimumDeposit: 100000,
      description:
          'Park a lump sum for six months at our highest rate. Funds stay '
          'locked until maturity.',
    ),
    ProductModel(
      id: 'education_savings',
      name: 'Education Savings',
      interestRate: 10,
      duration: 'Flexible',
      minimumDeposit: 10000,
      description:
          'Build up school fees over time with flexible withdrawals each '
          'term.',
    ),
    ProductModel(
      id: 'vacation_savings',
      name: 'Vacation Savings',
      interestRate: 8,
      duration: 'Flexible',
      minimumDeposit: 5000,
      description:
          'Save towards your next trip and withdraw whenever you are ready '
          'to travel.',
    ),
  ];

  /// Cached catalogue if one exists, otherwise the bundled copy. Used by the
  /// Create Savings dropdown, which cannot wait on a future.
  List<ProductModel> get offlineCatalogue {
    final List<ProductModel> cached = _storage.readCachedProducts();
    return cached.isNotEmpty ? cached : _bundledCatalogue;
  }

  /// Fetches, caches on success, falls back to the cache on failure.
  ///
  /// Throws [ApiException] only when the request fails and nothing has ever
  /// been cached. The products screen renders that as an error with a retry.
  Future<List<ProductModel>> getProducts() async {
    try {
      final List<Map<String, dynamic>> raw = await _api.fetchProducts();
      final List<ProductModel> products = raw
          .map(ProductModel.fromJson)
          .toList(growable: false);

      if (products.isNotEmpty) {
        await _storage.saveCachedProducts(products);
      }
      return products;
    } on ApiException {
      final List<ProductModel> cached = _storage.readCachedProducts();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }
}
