import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/state_views.dart';

/// Full detail for one savings product, with the Create Savings action.
class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ProductModel> product =
        ref.watch(productByIdProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Details')),
      body: SafeArea(
        top: false,
        child: product.when(
          loading: () => const LoadingView(message: 'Loading plan details'),
          error: (Object error, StackTrace _) => Padding(
            padding: AppSpacing.page,
            child: ErrorView(
              message: error.toString(),
              title: 'Could not load this plan',
              onRetry: () => ref.invalidate(productsProvider),
            ),
          ),
          data: (ProductModel item) => _ProductDetailBody(product: item),
        ),
      ),
    );
  }
}

class _ProductDetailBody extends StatelessWidget {
  const _ProductDetailBody({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: AppColors.balanceGradient,
                  borderRadius: AppRadius.card,
                  boxShadow: AppShadows.raised,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        AppIcons.wallet,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      product.name,
                      style: text.headlineSmall
                          ?.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${Formatters.percent(product.interestRate)} per annum',
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                decoration: AppDecorations.outlinedCard,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  children: <Widget>[
                    _DetailRow(
                      icon: AppIcons.wallet,
                      label: 'Plan Name',
                      value: product.name,
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      icon: AppIcons.interest,
                      label: 'Interest Rate',
                      value: Formatters.percent(product.interestRate),
                      valueColor: AppColors.success,
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      icon: AppIcons.deposit,
                      label: 'Minimum Deposit',
                      value: Formatters.currency(product.minimumDeposit),
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      icon: AppIcons.duration,
                      label: 'Duration',
                      value: product.duration,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('About this plan', style: text.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(product.description, style: text.bodyMedium),
            ],
          ),
        ),

        // Pinned action so the primary CTA is always reachable.
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: PrimaryButton(
              label: 'Create Savings',
              icon: AppIcons.addSavings,
              onPressed: () => context.pushNamed(
                AppRoute.createSavings.routeName,
                queryParameters: <String, String>{'productId': product.id},
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: text.bodyMedium)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            textAlign: TextAlign.end,
            style: text.titleMedium?.copyWith(
              fontSize: 15,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
