import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/storage_service.dart';
import 'providers/app_providers.dart';
import 'providers/sync_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hive must be open before the first widget builds, because the auth provider reads the persisted session synchronously during `build()`.
  final StorageService storageService = await StorageService.initialise();

  runApp(
    ProviderScope(
      overrides: <Override>[
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const KoinsApp(),
    ),
  );
}

class KoinsApp extends ConsumerWidget {
  const KoinsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    ref.watch(syncProvider);

    return MaterialApp.router(
      title: 'Koins MFB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (BuildContext context, Widget? child) {
        // Caps accessibility text scaling so large-font settings cannot break
        // card layouts.
        return MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
