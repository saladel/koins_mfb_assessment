import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/navigation/main_navigation_wrapper.dart';
import '../../screens/products/product_details_screen.dart';
import '../../screens/products/products_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/savings/create_savings_screen.dart';

/// Every route in the app, in one place.
enum AppRoute {
  login('/login', 'login'),
  dashboard('/dashboard', 'dashboard'),
  products('/products', 'products'),
  productDetails('/product/:id', 'product-details'),
  createSavings('/create-savings', 'create-savings'),
  profile('/profile', 'profile');

  const AppRoute(this.path, this.routeName);

  final String path;
  final String routeName;
}

/// Bridges Riverpod auth state to go_router, which expects a [Listenable].
/// Every auth change nudges the router to re-evaluate [GoRouter.redirect].
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (AuthState? previous, AuthState next) {
      if (previous?.isAuthenticated != next.isAuthenticated) {
        notifyListeners();
      }
    });
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  final _AuthRefreshNotifier refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoute.login.path,
    refreshListenable: refreshNotifier,
    debugLogDiagnostics: kDebugMode,

    /// Single auth guard for the whole app. No screen checks the session itself.
    redirect: (BuildContext context, GoRouterState state) {
      final bool isAuthenticated = ref.read(authProvider).isAuthenticated;
      final bool isOnLogin = state.matchedLocation == AppRoute.login.path;

      if (!isAuthenticated) return isOnLogin ? null : AppRoute.login.path;
      if (isOnLogin) return AppRoute.dashboard.path;
      return null;
    },

    routes: <RouteBase>[
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),

      /// The three bottom-nav destinations share a shell so each tab keeps its own navigation stack and scroll position.
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) => MainNavigationWrapper(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoute.dashboard.path,
                name: AppRoute.dashboard.routeName,
                builder: (BuildContext context, GoRouterState state) =>
                    const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoute.products.path,
                name: AppRoute.products.routeName,
                builder: (BuildContext context, GoRouterState state) =>
                    const ProductsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoute.profile.path,
                name: AppRoute.profile.routeName,
                builder: (BuildContext context, GoRouterState state) =>
                    const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      /// Pushed full screen, above the bottom navigation.
      GoRoute(
        path: AppRoute.productDetails.path,
        name: AppRoute.productDetails.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          return ProductDetailsScreen(
            productId: state.pathParameters['id'] ?? '',
          );
        },
      ),
      GoRoute(
        path: AppRoute.createSavings.path,
        name: AppRoute.createSavings.routeName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          // Optional ?productId= pre-selects the dropdown when arriving from
          // a product details screen.
          return CreateSavingsScreen(
            initialProductId: state.uri.queryParameters['productId'],
          );
        },
      ),
    ],

    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Page not found:\n${state.uri}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    ),
  );
});
