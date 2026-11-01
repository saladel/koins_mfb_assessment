import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';

/// Bottom navigation shell for Dashboard, Products and Profile.
///
/// [StatefulNavigationShell] keeps a separate navigator per tab, so each one
/// holds its own stack and scroll position when you switch away and back.
class MainNavigationWrapper extends StatelessWidget {
  const MainNavigationWrapper({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      // Tapping the active tab pops it back to its first route.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(AppIcons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(AppIcons.products),
              label: 'Products',
            ),
            NavigationDestination(
              icon: Icon(AppIcons.profile),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
