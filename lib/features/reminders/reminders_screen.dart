import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_providers.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';

/// Lets the user enable a daily local notification at a chosen time.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = ref.watch(reminderControllerProvider);
    final ctrl = ref.read(reminderControllerProvider.notifier);
    final time = TimeOfDay(hour: reminder.hour, minute: reminder.minute);
    final autoTime = TimeOfDay(
      hour: reminder.autoHour,
      minute: reminder.autoMinute,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rappels'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SoftCard(
              color: AppColors.peach.withValues(alpha: 0.18),
              child: Row(
                children: [
                  TintedIcon(
                    icon: Icons.notifications_active_rounded,
                    color: AppColors.peach,
                    size: 54,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Reçois un petit rappel chaque jour pour garder le cap.',
                      style: TextStyle(fontSize: 15, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SoftCard(
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Activer le rappel quotidien',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    value: reminder.enabled,
                    activeThumbColor: AppColors.brandStart,
                    onChanged: (v) => ctrl.setEnabled(v),
                  ),
                  Divider(height: 1, color: AppColors.line),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: reminder.enabled,
                    title: const Text('Heure du rappel'),
                    trailing: Text(
                      time.format(context),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: reminder.enabled
                        ? () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: time,
                            );
                            if (picked != null) {
                              ctrl.setTime(picked.hour, picked.minute);
                            }
                          }
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (reminder.enabled)
              Center(
                child: Text(
                  'Rappel programmé à ${time.format(context)} chaque jour.',
                  style: TextStyle(color: AppColors.inkSoft),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Rappel automatique',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            SoftCard(
              color: AppColors.mint.withValues(alpha: 0.16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_mode_rounded, color: AppColors.ink),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tant que ton programme n\'est pas terminé, Lumina te '
                          'relance chaque jour — même sans le réglage ci-dessus.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.ink,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 22, color: AppColors.line),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Heure du rappel automatique'),
                    trailing: Text(
                      autoTime.format(context),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: autoTime,
                      );
                      if (picked != null) {
                        ctrl.setAutoTime(picked.hour, picked.minute);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
