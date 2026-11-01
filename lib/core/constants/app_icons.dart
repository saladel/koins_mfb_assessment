import 'package:flutter/material.dart';

/// Every icon the app uses, named once.
class AppIcons {
  const AppIcons._();

  // Navigation
  static const IconData dashboard = Icons.home_rounded;
  static const IconData products = Icons.grid_view_rounded;
  static const IconData profile = Icons.person_rounded;
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded;

  // Auth
  static const IconData email = Icons.mail_outline_rounded;
  static const IconData lock = Icons.lock_outline_rounded;
  static const IconData eyeOpen = Icons.visibility_outlined;
  static const IconData eyeClosed = Icons.visibility_off_outlined;

  // Actions
  static const IconData addSavings = Icons.add_circle_outline_rounded;
  static const IconData viewProducts = Icons.account_balance_wallet_outlined;
  static const IconData search = Icons.search_rounded;
  static const IconData clear = Icons.close_rounded;
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData logout = Icons.logout_rounded;

  // Content
  static const IconData wallet = Icons.savings_outlined;
  static const IconData interest = Icons.trending_up_rounded;
  static const IconData duration = Icons.schedule_rounded;
  static const IconData deposit = Icons.payments_outlined;
  static const IconData insight = Icons.lightbulb_outline_rounded;
  static const IconData phone = Icons.phone_outlined;
  static const IconData visibility = Icons.visibility_outlined;

  // States
  static const IconData empty = Icons.inbox_outlined;
  static const IconData error = Icons.error_outline_rounded;
  static const IconData success = Icons.check_circle_outline_rounded;
}
