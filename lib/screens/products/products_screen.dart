import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_styles.dart';
import '../../core/router/app_router.dart';
import '../../data/models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/state_views.dart';

/// Savings products list with a search field.
///
/// Search is the bonus "Search Savings Products" item. Filtering happens in
/// [filteredProductsProvider], so this screen only renders.
class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ProductModel>> products =
        ref.watch(filteredProductsProvider);
    final String query = ref.watch(productQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Products'),
        toolbarHeight: 64,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(productsProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: <Widget>[
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: (String value) =>
                    ref.read(productQueryProvider.notifier).update(value),
                decoration: InputDecoration(
                  hintText: 'Search savings products',
                  prefixIcon: const Icon(AppIcons.search, size: 20),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(AppIcons.clear, size: 20),
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            ref.read(productQueryProvider.notifier).clear();
                          },
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              products.when(
                loading: () =>
                    const LoadingView(message: 'Loading savings products'),
                error: (Object error, StackTrace _) => ErrorView(
                  message: error.toString(),
                  title: 'Could not load products',
                  onRetry: () => ref.invalidate(productsProvider),
                ),
                data: (List<ProductModel> items) {
                  if (items.isEmpty) {
                    return EmptyView(
                      title: 'No products found',
                      message: query.isEmpty
                          ? 'There are no savings products available yet.'
                          : 'Nothing matches "$query". Try a different '
                              'search term.',
                      icon: AppIcons.search,
                      actionLabel: query.isEmpty ? null : 'Clear search',
                      onAction: query.isEmpty
                          ? null
                          : () {
                              _searchController.clear();
                              ref
                                  .read(productQueryProvider.notifier)
                                  .clear();
                            },
                    );
                  }

                  return Column(
                    children: <Widget>[
                      for (int i = 0; i < items.length; i++) ...<Widget>[
                        ProductCard(
                          product: items[i],
                          accentColor: AppColors.accentAt(i),
                          onViewDetails: () => context.pushNamed(
                            AppRoute.productDetails.routeName,
                            pathParameters: <String, String>{
                              'id': items[i].id,
                            },
                          ),
                        ),
                        if (i != items.length - 1)
                          const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
