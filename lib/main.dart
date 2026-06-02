import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'core/storage/app_storage.dart';
import 'state/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Open local storage and init notifications before building the UI.
  final storage = await AppStorage.open();
  await NotificationService.instance.init();

  runApp(
    ProviderScope(
      overrides: [appStorageProvider.overrideWithValue(storage)],
      child: const LuminaApp(),
    ),
  );
}
