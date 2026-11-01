import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/product_model.dart';
import 'app_providers.dart';

/// The full savings product catalogue.
final FutureProvider<List<ProductModel>> productsProvider =
    FutureProvider<List<ProductModel>>(
  (ref) => ref.watch(productRepositoryProvider).getProducts(),
);

/// Current text in the products search field.
class ProductQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;

  void clear() => state = '';
}

final NotifierProvider<ProductQueryNotifier, String> productQueryProvider =
    NotifierProvider<ProductQueryNotifier, String>(ProductQueryNotifier.new);

/// Catalogue filtered by the search query.
///
/// Derived state: the screen watches this one provider and gets loading,
/// error and filtered data from a single `switch`. An empty result here is
/// what drives the "no products match" empty state.
final Provider<AsyncValue<List<ProductModel>>> filteredProductsProvider =
    Provider<AsyncValue<List<ProductModel>>>((ref) {
  final String query = ref.watch(productQueryProvider);

  return ref.watch(productsProvider).whenData(
        (List<ProductModel> products) => products
            .where((ProductModel product) => product.matches(query))
            .toList(growable: false),
      );
});

/// Single product lookup for the details screen.
///
/// Returns an [AsyncValue] rather than throwing, so a missing id renders the
/// error state instead of crashing the route.
final productByIdProvider =
    Provider.family<AsyncValue<ProductModel>, String>((ref, String id) {
  return ref.watch(productsProvider).when(
        loading: () => const AsyncValue<ProductModel>.loading(),
        error: (Object error, StackTrace stackTrace) =>
            AsyncValue<ProductModel>.error(error, stackTrace),
        data: (List<ProductModel> products) {
          for (final ProductModel product in products) {
            if (product.id == id) return AsyncValue<ProductModel>.data(product);
          }
          return AsyncValue<ProductModel>.error(
            StateError('Savings product "$id" was not found.'),
            StackTrace.current,
          );
        },
      );
});

/// Synchronous catalogue for the Create Savings dropdown.
///
/// Prefers the fetched catalogue and falls back to the bundled copy while the
/// request is in flight or after it has failed, so the create flow never ends
/// up with an empty dropdown.
final Provider<List<ProductModel>> productCatalogueProvider =
    Provider<List<ProductModel>>((ref) {
  return ref.watch(productsProvider).value ??
      ref.watch(productRepositoryProvider).offlineCatalogue;
});

/// Duration options for the Create Savings form.
///
/// Derived from the catalogue rather than hardcoded in the screen, so the form
/// can only offer terms the products actually support. Add a product with a
/// new term and the dropdown picks it up with no code change.
///
/// Sorted shortest first, with open-ended terms such as "Flexible" last.
final Provider<List<String>> durationOptionsProvider =
    Provider<List<String>>((ref) {
  final List<ProductModel> catalogue = ref.watch(productCatalogueProvider);

  final Set<String> unique = <String>{
    for (final ProductModel product in catalogue)
      if (product.duration.trim().isNotEmpty) product.duration.trim(),
  };

  final List<String> options = unique.toList()..sort(_compareDurations);
  return List<String>.unmodifiable(options);
});

/// Fixed terms ascending by length, then anything open-ended alphabetically.
int _compareDurations(String a, String b) {
  final int? monthsA = _monthsIn(a);
  final int? monthsB = _monthsIn(b);

  if (monthsA != null && monthsB != null) return monthsA.compareTo(monthsB);
  if (monthsA != null) return -1;
  if (monthsB != null) return 1;
  return a.compareTo(b);
}

/// Pulls the leading number out of `"12 Months"`. Returns null for terms with
/// no number in them, such as `"Flexible"`.
int? _monthsIn(String duration) {
  final RegExpMatch? match = RegExp(r'\d+').firstMatch(duration);
  if (match == null) return null;
  return int.tryParse(match.group(0)!);
}
