import 'package:flutter/material.dart';

import '../core/constants/app_icons.dart';
import '../core/constants/app_styles.dart';
import '../data/models/insight_model.dart';

/// Card for a single money tip fetched from the remote API.
class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.insight,
    required this.accent,
    this.onTap,
  });

  final InsightModel insight;
  final Color accent;

  /// The body truncates at three lines, which promises more text. Without a
  /// tap target that promise is broken, so the dashboard passes a handler
  /// that opens the full tip.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      decoration: AppDecorations.outlinedCard,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(AppIcons.insight, size: 17, color: accent),
                    ),
                    const SizedBox(width: AppSpacing.sm),
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
                const SizedBox(height: AppSpacing.md),
                Text(
                  insight.title,
                  style: text.titleMedium?.copyWith(fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Expanded(
                  child: Text(
                    insight.body,
                    style: text.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
