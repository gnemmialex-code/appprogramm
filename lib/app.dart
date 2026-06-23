import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'state/app_providers.dart';
import 'ui/device/tablet_frame.dart';
import 'ui/theme/app_colors.dart';
import 'ui/theme/app_scroll_behavior.dart';
import 'ui/theme/app_theme.dart';

/// Root widget.  Wires the router and theme together, observes the app
/// lifecycle to record each foreground open for usage analytics, and wraps
/// the app in an iPhone 16 device frame for large (web/desktop) previews.
class LuminaApp extends ConsumerStatefulWidget {
  const LuminaApp({super.key});

  @override
  ConsumerState<LuminaApp> createState() => _LuminaAppState();
}

class _LuminaAppState extends ConsumerState<LuminaApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Record the initial cold-start open after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usageAnalyticsProvider.notifier).recordOpen();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Record when the app comes back to the foreground (hot resume).
    if (state == AppLifecycleState.resumed) {
      ref.read(usageAnalyticsProvider.notifier).recordOpen();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Drive the global semantic palette from the persisted preference, then
    // rebuild the theme to match. Watching the provider rebuilds on toggle.
    final isDark = ref.watch(darkModeProvider);
    AppColors.brightness = isDark ? Brightness.dark : Brightness.light;

    return MaterialApp.router(
      title: 'AppTok',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themed,
      scrollBehavior: const AppScrollBehavior(),
      routerConfig: ref.watch(goRouterProvider),
      builder: (context, child) =>
          TabletFrame(child: child ?? const SizedBox.shrink()),
    );
  }
}
