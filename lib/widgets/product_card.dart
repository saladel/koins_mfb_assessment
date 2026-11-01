import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_icons.dart';
import '../core/constants/app_styles.dart';
import '../core/utils/formatters.dart';
import '../data/models/product_model.dart';

/// Savings product card used on the products list.
///
/// Shows product name, interest rate, a short description and a View Details
/// action, which is exactly what the brief specifies.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onViewDetails,
    this.accentColor,
  });

  final ProductModel product;
  final VoidCallback onViewDetails;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final Color accent = accentColor ?? AppColors.primary;
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(AppIcons.wallet, size: 22, color: accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.name,
                      style: text.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.duration,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: AppRadius.chip,
                ),
                child: Text(
                  '${Formatters.percent(product.interestRate)} p.a.',
                  style: text.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            product.description,
            style: text.bodySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Minimum deposit', style: text.bodySmall),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.currency(product.minimumDeposit),
                    style: text.titleMedium,
                  ),
                ],
              ),
              TextButton(
                onPressed: onViewDetails,
                style: TextButton.styleFrom(foregroundColor: accent),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('View Details'),
                    SizedBox(width: 2),
                    Icon(AppIcons.chevronRight, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
