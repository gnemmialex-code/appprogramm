import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'ui/device/phone_frame.dart';
import 'ui/theme/app_theme.dart';

/// Root widget. Wires the router and theme together, and wraps the app in an
/// iPhone 16 device frame for large (web/desktop) previews.
class LuminaApp extends StatelessWidget {
  const LuminaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lumina',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      builder: (context, child) =>
          PhoneFrame(child: child ?? const SizedBox.shrink()),
    );
  }
}
