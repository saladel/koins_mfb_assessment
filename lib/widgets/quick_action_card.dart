import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import 'user_avatar.dart';

/// Dashboard quick action: Create Savings and View Products.
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Container(
          decoration: AppDecorations.card,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 21, color: color),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Balance summary card at the top of the dashboard.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.greeting,
    required this.fullName,
    required this.totalSavings,
    required this.planCount,
    this.avatarUrl,
  });

  final String greeting;
  final String fullName;
  final String totalSavings;
  final int planCount;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
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
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '$greeting, $fullName',
                  style: text.bodyMedium?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.75),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              UserAvatar(
                fullName: fullName,
                imageUrl: avatarUrl,
                size: 44,
                backgroundColor: AppColors.white.withValues(alpha: 0.14),
                foregroundColor: AppColors.white,
                borderColor: AppColors.white.withValues(alpha: 0.25),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Total Savings',
            style: text.bodySmall?.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              totalSavings,
              style: text.displaySmall?.copyWith(color: AppColors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.14),
              borderRadius: AppRadius.chip,
            ),
            child: Text(
              '$planCount active ${planCount == 1 ? 'plan' : 'plans'}',
              style: text.bodySmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
