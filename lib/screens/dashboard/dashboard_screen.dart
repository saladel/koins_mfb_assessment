import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/insight_model.dart';
import '../../data/models/savings_plan_model.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/insight_provider.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/quick_action_card.dart';
import '../../widgets/savings_plan_tile.dart';
import '../../widgets/section_header.dart';
import '../../widgets/state_views.dart';

import '../../providers/sync_provider.dart';

/// Home screen: greeting, total savings, quick actions, recent plans and a
/// live Insights strip loaded from the remote API.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(insightsProvider);
    await ref.read(syncProvider.notifier).syncNow();
    await ref.read(savingsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserModel? user = ref.watch(currentUserProvider);
    final AsyncValue<List<SavingsPlanModel>> savings = ref.watch(
      savingsProvider,
    );
    final List<SavingsPlanModel> recent = ref.watch(recentSavingsProvider);
    final double total = ref.watch(totalSavingsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _refresh(ref),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: <Widget>[
              BalanceCard(
                greeting: Formatters.greeting(),
                fullName: user?.fullName ?? 'there',
                totalSavings: Formatters.currency(total),
                planCount: savings.value?.length ?? 0,
                avatarUrl: user?.avatarUrl,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Quick actions
              Row(
                children: <Widget>[
                  Expanded(
                    child: QuickActionCard(
                      label: 'Create Savings',
                      icon: AppIcons.addSavings,
                      color: AppColors.primary,
                      onTap: () =>
                          context.pushNamed(AppRoute.createSavings.routeName),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: QuickActionCard(
                      label: 'View Products',
                      icon: AppIcons.viewProducts,
                      color: AppColors.success,
                      onTap: () => context.goNamed(AppRoute.products.routeName),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Recent savings
              SectionHeader(
                title: 'Recent Savings',
                actionLabel: recent.isEmpty ? null : 'New plan',
                onAction: recent.isEmpty
                    ? null
                    : () => context.pushNamed(AppRoute.createSavings.routeName),
              ),
              const SizedBox(height: AppSpacing.md),
              _RecentSavingsSection(savings: savings, recent: recent),
              const SizedBox(height: AppSpacing.xl),

              // Live API section
              const SectionHeader(title: 'Money Insights'),
              const SizedBox(height: AppSpacing.md),
              const _InsightsSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSavingsSection extends StatelessWidget {
  const _RecentSavingsSection({required this.savings, required this.recent});

  final AsyncValue<List<SavingsPlanModel>> savings;
  final List<SavingsPlanModel> recent;

  @override
  Widget build(BuildContext context) {
    return savings.when(
      loading: () => const LoadingView(message: 'Loading your savings plans'),
      error: (Object error, StackTrace _) => ErrorView(
        message: error.toString(),
        title: 'Could not load your plans',
        compact: true,
      ),
      data: (_) {
        if (recent.isEmpty) {
          return EmptyView(
            title: 'No savings plans yet',
            message: 'Create your first plan and start growing your money.',
            icon: AppIcons.wallet,
            actionLabel: 'Create Savings',
            onAction: () => context.pushNamed(AppRoute.createSavings.routeName),
          );
        }

        return Column(
          children: <Widget>[
            for (int i = 0; i < recent.length; i++) ...<Widget>[
              SavingsPlanTile(
                plan: recent[i],
                accentColor: AppColors.accentAt(i),
              ),
              if (i != recent.length - 1) const SizedBox(height: AppSpacing.md),
            ],
          ],
        );
      },
    );
  }
}

/// The app's live network section. Loading, error with retry, and empty are
/// all handled here.
class _InsightsSection extends ConsumerWidget {
  const _InsightsSection();

  /// The card truncates the tip. Tapping opens the whole thing rather than
  /// pushing a route, because a single paragraph does not warrant a screen of
  /// its own or an entry in the back stack.
  void _showInsightSheet(
    BuildContext context,
    InsightModel insight,
    Color accent,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (BuildContext sheetContext) {
        final TextTheme text = Theme.of(sheetContext).textTheme;

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(AppIcons.insight, size: 19, color: accent),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          insight.tags.isEmpty
                              ? 'INSIGHT'
                              : insight.tags.first.toUpperCase(),
                          style: text.bodySmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    insight.title,
                    style: text.headlineSmall?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(insight.body, style: text.bodyLarge),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<InsightModel>> insights = ref.watch(insightsProvider);

    return insights.when(
      loading: () => const SizedBox(
        height: 150,
        child: LoadingView(padding: EdgeInsets.zero),
      ),
      error: (Object error, StackTrace _) => ErrorView(
        message: error.toString(),
        title: 'Insights unavailable',
        compact: true,
        onRetry: () => ref.invalidate(insightsProvider),
      ),
      data: (List<InsightModel> items) {
        if (items.isEmpty) {
          return const EmptyView(
            title: 'No insights right now',
            message: 'Pull down to refresh and try again.',
            icon: AppIcons.insight,
          );
        }

        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              final InsightModel insight = items[index];
              final Color accent = AppColors.accentAt(index);

              return InsightCard(
                insight: insight,
                accent: accent,
                onTap: () => _showInsightSheet(context, insight, accent),
              );
            },
          ),
        );
      },
    );
  }
}
