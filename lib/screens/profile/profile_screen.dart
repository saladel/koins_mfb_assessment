import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/savings_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/user_avatar.dart';

/// User details and logout.
///
/// Logout clears the Hive session; the router's redirect then returns the
/// user to the login screen automatically.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You will need to sign in again to view your savings.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout ?? false) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserModel? user = ref.watch(currentUserProvider);
    final double total = ref.watch(totalSavingsProvider);
    final TextTheme text = Theme.of(context).textTheme;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: EmptyView(
            title: 'No profile to show',
            message: 'Sign in to view your account details.',
            icon: AppIcons.profile,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
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
                children: <Widget>[
                  UserAvatar(
                    fullName: user.fullName,
                    imageUrl: user.avatarUrl,
                    size: 88,
                    backgroundColor: AppColors.white.withValues(alpha: 0.14),
                    foregroundColor: AppColors.white,
                    borderColor: AppColors.white.withValues(alpha: 0.25),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    user.fullName,
                    style: text.titleLarge?.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Total saved ${Formatters.currency(total)}',
                    style: text.bodySmall?.copyWith(color: AppColors.gold),
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
                  _ProfileRow(
                    icon: AppIcons.profile,
                    label: 'Full Name',
                    value: user.fullName,
                  ),
                  const Divider(height: 1),
                  _ProfileRow(
                    icon: AppIcons.email,
                    label: 'Email',
                    value: user.email,
                  ),
                  const Divider(height: 1),
                  _ProfileRow(
                    icon: AppIcons.phone,
                    label: 'Phone Number',
                    value: user.phoneNumber,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            SecondaryButton(
              label: 'Logout',
              icon: AppIcons.logout,
              onPressed: () => _confirmLogout(context, ref),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                'Koins MFB Assessment · v1.0.0',
                style: text.bodySmall?.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: text.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: text.titleMedium?.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
