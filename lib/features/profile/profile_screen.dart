import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ai/generator.dart'
    show ProgramTier, tierFromMinutes, tierLabel, tierMinutesPerChapter;
import '../../core/analytics/usage_analytics.dart';
import '../../state/app_providers.dart';
import '../../ui/theme/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final settings = ref.watch(appSettingsProvider);
    final displayName = profile.firstName.isNotEmpty
        ? profile.firstName
        : (profile.pseudo.isNotEmpty ? profile.pseudo : 'Mon profil');
    final initial = displayName[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Personnel',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          const SizedBox(height: 16),
          _AvatarSection(
            initial: initial,
            displayName: displayName,
            email: profile.email,
          ),
          const SizedBox(height: 32),
          _SectionHeader('Mon compte'),
          const SizedBox(height: 8),
          _SectionCard(
            children: [
              _EditTile(
                icon: Icons.badge_rounded,
                title: 'Prénom',
                value: profile.firstName.isNotEmpty
                    ? profile.firstName
                    : (profile.pseudo.isNotEmpty ? profile.pseudo : '—'),
                onTap: () => _editField(
                  context,
                  'Prénom',
                  profile.firstName.isNotEmpty
                      ? profile.firstName
                      : profile.pseudo,
                  (v) {
                    // Keep firstName and the avatar pseudo in sync so the name
                    // stays consistent everywhere it's used.
                    ref
                        .read(userProfileProvider.notifier)
                        .update(firstName: v, pseudo: v);
                  },
                ),
              ),
              const _Divider(),
              _EditTile(
                icon: Icons.email_rounded,
                title: 'Email',
                value: profile.email.isNotEmpty ? profile.email : '—',
                onTap: () => _editField(context, 'Email', profile.email, (v) {
                  ref.read(userProfileProvider.notifier).update(email: v);
                }),
              ),
              const _Divider(),
              _DangerTile(
                icon: Icons.delete_forever_rounded,
                title: 'Supprimer mon compte',
                onTap: () => _confirmDeleteAccount(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionHeader('Apparence'),
          const SizedBox(height: 8),
          _SectionCard(
            children: [
              _DarkModeTile(
                isDark: ref.watch(darkModeProvider),
                onChanged: (v) => ref.read(darkModeProvider.notifier).set(v),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionHeader('Apprentissage'),
          const SizedBox(height: 8),
          _SectionCard(
            children: [
              _InfoTile(
                icon: Icons.mark_email_unread_rounded,
                iconColor: AppColors.sky,
                title: 'Newsletter perso',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      newsletterLabel(settings.newsletter),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.inkSoft,
                    ),
                  ],
                ),
                onTap: () => _pickNewsletter(context, ref, settings.newsletter),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionHeader('Mes notes'),
          const SizedBox(height: 8),
          _SectionCard(
            children: [
              _InfoTile(
                icon: Icons.sticky_note_2_rounded,
                iconColor: AppColors.lavender,
                title: 'Mes notes',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lavender.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '${ref.watch(notesProvider).length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lavender,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.inkSoft,
                    ),
                  ],
                ),
                onTap: () => context.push('/notes'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionHeader('Rappel intelligent'),
          const SizedBox(height: 8),
          _SmartReminderSection(
            analytics: ref.watch(usageAnalyticsProvider),
            onToggle: (v) =>
                ref.read(usageAnalyticsProvider.notifier).setReminderEnabled(v),
          ),
          const SizedBox(height: 20),
          _SectionHeader('Mon temps disponible'),
          const SizedBox(height: 8),
          _AvailabilitySection(
            availability: ref.watch(dailyAvailabilityProvider),
            onSetDay: (i, m) =>
                ref.read(dailyAvailabilityProvider.notifier).setDay(i, m),
          ),
          const SizedBox(height: 20),
          _SectionHeader('Légal & Confidentialité'),
          const SizedBox(height: 8),
          _SectionCard(
            children: [
              _InfoTile(
                icon: Icons.description_rounded,
                title: 'Conditions générales d\'utilisation',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.inkSoft,
                ),
                onTap: () => _showLegal(context, 'CGU', _kCgu),
              ),
              const _Divider(),
              _InfoTile(
                icon: Icons.privacy_tip_rounded,
                title: 'Politique de confidentialité',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.inkSoft,
                ),
                onTap: () => _showLegal(context, 'Confidentialité', _kPrivacy),
              ),
              const _Divider(),
              _InfoTile(
                icon: Icons.apple_rounded,
                title: 'Règles Apple (App Store)',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.inkSoft,
                ),
                onTap: () => _showLegal(context, 'Règles Apple', _kAppleRules),
              ),
              const _Divider(),
              _InfoTile(
                icon: Icons.gavel_rounded,
                title: 'Mentions légales',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.inkSoft,
                ),
                onTap: () =>
                    _showLegal(context, 'Mentions légales', _kMentions),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionHeader('Support'),
          const SizedBox(height: 8),
          _SectionCard(
            children: [
              _InfoTile(
                icon: Icons.help_rounded,
                title: 'Aide & FAQ',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.inkSoft,
                ),
                onTap: () => _showSnack(context, 'FAQ bientôt disponible'),
              ),
              const _Divider(),
              _InfoTile(
                icon: Icons.mail_rounded,
                title: 'Nous contacter',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.inkSoft,
                ),
                onTap: () => _showSnack(context, 'Support disponible bientôt'),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'apprentik v1.0.0',
              style: TextStyle(
                color: AppColors.inkSoft.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _editField(
    BuildContext ctx,
    String label,
    String current,
    void Function(String) onSave,
  ) {
    final ctrl = TextEditingController(text: current);
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Saisir $label',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandStart,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  onSave(ctrl.text.trim());
                  Navigator.pop(sheetCtx);
                },
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLegal(BuildContext ctx, String title, String body) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, sc) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                children: [
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.inkSoft,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickNewsletter(
    BuildContext ctx,
    WidgetRef ref,
    NewsletterFrequency current,
  ) {
    const options = [
      (
        freq: NewsletterFrequency.daily,
        emoji: '☀️',
        detail: 'Une dose chaque jour, selon tes thèmes',
      ),
      (
        freq: NewsletterFrequency.weekly,
        emoji: '🗓️',
        detail: 'Un récap personnalisé chaque semaine',
      ),
      (
        freq: NewsletterFrequency.off,
        emoji: '🚫',
        detail: 'Ne rien recevoir par e-mail',
      ),
    ];
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 14),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Rythme de la newsletter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final o in options)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ref.read(appSettingsProvider.notifier).setNewsletter(o.freq);
                  Navigator.pop(sheetCtx);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      Text(o.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              newsletterLabel(o.freq),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              o.detail,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (current == o.freq)
                        const Icon(
                          Icons.check_rounded,
                          color: AppColors.brandStart,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showSnack(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Permanently delete the account: wipe every locally-stored value, reset all
  /// in-memory state back to its defaults, and send the user back to the very
  /// first screen so they start over from scratch.
  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Supprimer mon compte ?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Toutes vos données (profil, programme, progression, notes) seront '
          'définitivement effacées et l\'application repartira de zéro. '
          'Cette action est irréversible.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppColors.inkSoft),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              'Supprimer',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Erase everything persisted on the device.
    await ref.read(appStorageProvider).wipe();

    // Reset every piece of in-memory state so nothing from the old account
    // lingers; each notifier rebuilds from the now-empty storage.
    ref.invalidate(programControllerProvider);
    ref.invalidate(expertProgramControllerProvider);
    ref.invalidate(progressControllerProvider);
    ref.invalidate(reminderControllerProvider);
    ref.invalidate(retentionControllerProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(onboardingCompleteProvider);
    ref.invalidate(appSettingsProvider);
    ref.invalidate(dailyAvailabilityProvider);
    ref.invalidate(usageAnalyticsProvider);
    ref.invalidate(notesProvider);
    ref.invalidate(quizProgressProvider);
    ref.invalidate(darkModeProvider);

    if (!context.mounted) return;
    // Back to square one: the intro flow.
    context.go('/intro');
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _AvatarSection extends StatelessWidget {
  final String initial;
  final String displayName;
  final String email;

  const _AvatarSection({
    required this.initial,
    required this.displayName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.line, width: 1.5),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(fontSize: 14, color: AppColors.inkSoft),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.inkSoft,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    this.iconColor,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor ?? AppColors.ink),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// Toggle row for switching the whole app between light and dark mode.
class _DarkModeTile extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _DarkModeTile({required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!isDark),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    RotationTransition(turns: anim, child: child),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  key: ValueKey(isDark),
                  size: 22,
                  color: isDark ? AppColors.lavender : AppColors.sun,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mode sombre',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      isDark ? 'Activé' : 'Désactivé',
                      style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isDark,
                activeThumbColor: AppColors.brandStart,
                activeTrackColor: AppColors.brandStart.withValues(alpha: 0.4),
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _EditTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.ink),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 14, color: AppColors.inkSoft),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.inkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, indent: 50, color: AppColors.line);
  }
}

/// Destructive action row (e.g. delete account): red icon + red label.
class _DangerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _DangerTile({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.danger),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.danger.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Smart reminder section
// ---------------------------------------------------------------------------

class _SmartReminderSection extends StatelessWidget {
  final UsageAnalyticsStateWrapper analytics;
  final ValueChanged<bool> onToggle;

  const _SmartReminderSection({
    required this.analytics,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final p = analytics.pattern;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.softShadow,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lavender.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.lavender,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rappel intelligent',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      p.isReady
                          ? 'Actif et personnalisé'
                          : 'En cours d\'apprentissage',
                      style: TextStyle(
                        fontSize: 12,
                        color: p.isReady
                            ? AppColors.success
                            : AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              if (p.isReady)
                Switch(
                  value: analytics.reminderEnabled,
                  activeThumbColor: AppColors.brandStart,
                  activeTrackColor: AppColors.brandStart.withValues(alpha: 0.4),
                  onChanged: onToggle,
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (p.isCollecting) ...[
            // Progress bar
            _CollectionProgress(pattern: p),
          ] else if (!p.isReady) ...[
            // Pattern not clear enough
            _PatternUnclear(),
          ] else ...[
            // Pattern detected
            _PatternReady(pattern: p, enabled: analytics.reminderEnabled),
          ],

          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppColors.inkSoft,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  p.statusMessage,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.inkSoft,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CollectionProgress extends StatelessWidget {
  final UsagePattern pattern;
  const _CollectionProgress({required this.pattern});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🕐', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${pattern.daysCollected} / ${pattern.daysNeeded} jours collectés',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'apprentik analyse tes habitudes de connexion',
                    style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: pattern.collectionProgress,
            minHeight: 8,
            backgroundColor: AppColors.line,
            valueColor: const AlwaysStoppedAnimation(AppColors.lavender),
          ),
        ),
        const SizedBox(height: 8),
        // Day dots
        Row(
          children: [
            for (int i = 0; i < pattern.daysNeeded; i++)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < pattern.daysCollected
                        ? AppColors.lavender
                        : AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Encore ${pattern.daysRemaining} jour(s) avant l\'activation automatique',
          style: TextStyle(fontSize: 11, color: AppColors.inkSoft),
        ),
      ],
    );
  }
}

class _PatternUnclear extends StatelessWidget {
  const _PatternUnclear();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sun.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('📊', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Tes horaires sont variés. Continue d\'utiliser l\'app régulièrement pour affiner l\'analyse.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternReady extends StatelessWidget {
  final UsagePattern pattern;
  final bool enabled;
  const _PatternReady({required this.pattern, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Predicted time card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.lavender.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.lavender.withValues(alpha: 0.30),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu te connectes habituellement',
                    style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        pattern.predictedTimeLabel,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lavender,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lavender.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          pattern.periodLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.lavender,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rappel envoyé à',
                    style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.notifications_rounded,
                        size: 18,
                        color: AppColors.brandStart,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pattern.notifyTimeLabel,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandStart,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Confidence + days
        Row(
          children: [
            _ConfidencePill(confidence: pattern.confidence),
            const SizedBox(width: 8),
            Text(
              '${pattern.daysCollected} jours analysés',
              style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
            ),
            const Spacer(),
            if (!enabled)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Désactivé',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ConfidencePill extends StatelessWidget {
  final int confidence;
  const _ConfidencePill({required this.confidence});

  Color get _color {
    if (confidence >= 70) return AppColors.success;
    if (confidence >= 50) return AppColors.sun;
    return AppColors.peach;
  }

  String get _label {
    if (confidence >= 70) return 'Fiable';
    if (confidence >= 50) return 'Bonne';
    return 'En apprentissage';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_graph_rounded, size: 13, color: _color),
          const SizedBox(width: 4),
          Text(
            '$_label · $confidence%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Daily availability section
// ---------------------------------------------------------------------------

typedef _OnSetDay = void Function(int dayIndex, int minutes);

class _AvailabilitySection extends StatelessWidget {
  final DailyAvailabilityState availability;
  final _OnSetDay onSetDay;

  const _AvailabilitySection({
    required this.availability,
    required this.onSetDay,
  });

  static const _timeOptions = [
    (minutes: 0, emoji: '😴', label: 'Repos', detail: 'Aucun contenu ce jour'),
    (
      minutes: 5,
      emoji: '⚡',
      label: 'Express',
      detail: '3 étapes · l\'essentiel seulement',
    ),
    (
      minutes: 10,
      emoji: '🎯',
      label: 'Rapide',
      detail: '5 étapes · les points clés',
    ),
    (
      minutes: 20,
      emoji: '📚',
      label: 'Standard',
      detail: '7 étapes · contenu équilibré',
    ),
    (
      minutes: 30,
      emoji: '🔥',
      label: 'Approfondi',
      detail: '8 étapes · programme complet',
    ),
    (
      minutes: 45,
      emoji: '🚀',
      label: 'Intensif',
      detail: '8 étapes + tous les exercices',
    ),
  ];

  Color _colorForMinutes(int m) {
    if (m == 0) return AppColors.line;
    if (m <= 9) return AppColors.sky.withValues(alpha: 0.55);
    if (m <= 19) return AppColors.mint.withValues(alpha: 0.55);
    if (m <= 29) return AppColors.sun.withValues(alpha: 0.55);
    if (m <= 44) return AppColors.peach.withValues(alpha: 0.55);
    return AppColors.rose.withValues(alpha: 0.55);
  }

  String _labelForMinutes(int m) {
    if (m == 0) return '😴';
    return '$m';
  }

  void _showPicker(BuildContext ctx, int dayIndex) {
    final current = availability.minutesPerDay[dayIndex];
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 14),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${kDayNames[dayIndex]} — Temps disponible',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          for (final opt in _timeOptions)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  onSetDay(dayIndex, opt.minutes);
                  Navigator.pop(ctx);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      Text(opt.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt.minutes == 0
                                  ? opt.label
                                  : '${opt.label} · ${opt.minutes} min',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              opt.detail,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (current == opt.minutes)
                        const Icon(
                          Icons.check_rounded,
                          color: AppColors.brandStart,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avg = availability.averageActiveMinutes;
    final tier = tierFromMinutes(avg);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.softShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 7-day cards row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < 7; i++)
                _DayCard(
                  dayShort: kDayShort[i],
                  minutes: availability.minutesPerDay[i],
                  color: _colorForMinutes(availability.minutesPerDay[i]),
                  label: _labelForMinutes(availability.minutesPerDay[i]),
                  onTap: () => _showPicker(context, i),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 12),
          // Average + tier
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Moyenne : $avg min/jour',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Niveau généré : ${tierLabel(tier)} · ~${tierMinutesPerChapter(tier)} min/chapitre',
                      style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              _TierBadge(tier: tier),
            ],
          ),
          const SizedBox(height: 12),
          // Step count info
          _TierDetail(tier: tier),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final String dayShort;
  final int minutes;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _DayCard({
    required this.dayShort,
    required this.minutes,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            dayShort,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 5),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 38,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (minutes > 0)
                  Text(
                    'min',
                    style: TextStyle(fontSize: 9, color: AppColors.inkSoft),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final ProgramTier tier;
  const _TierBadge({required this.tier});

  Color get _color => switch (tier) {
    ProgramTier.express => AppColors.sky,
    ProgramTier.rapide => AppColors.mint,
    ProgramTier.standard => AppColors.sun,
    ProgramTier.complet => AppColors.peach,
    ProgramTier.intensif => AppColors.rose,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tierLabel(tier),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color.lerp(_color, Colors.black, 0.3),
        ),
      ),
    );
  }
}

class _TierDetail extends StatelessWidget {
  final ProgramTier tier;
  const _TierDetail({required this.tier});

  @override
  Widget build(BuildContext context) {
    const details = {
      ProgramTier.express: (
        '3 étapes par chapitre',
        'Introduction · Action immédiate · Ancrage final',
        '2 exercices',
      ),
      ProgramTier.rapide: (
        '5 étapes par chapitre',
        'Intro · Fait · Action · Astuce · Ancrage',
        '3 exercices',
      ),
      ProgramTier.standard: (
        '7 étapes par chapitre',
        'Toutes sauf le Défi du chapitre',
        '4 exercices',
      ),
      ProgramTier.complet: (
        '8 étapes par chapitre',
        'Programme complet avec le Défi',
        '5 exercices',
      ),
      ProgramTier.intensif: (
        '8 étapes par chapitre',
        'Programme complet avec le Défi',
        '6 exercices (tous)',
      ),
    };
    final (title, steps, exos) = details[tier]!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: AppColors.inkSoft),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$steps · $exos',
                  style: TextStyle(fontSize: 11, color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Legal texts (placeholders)
// ---------------------------------------------------------------------------

const _kCgu = '''
Conditions Générales d'Utilisation – apprentik

En utilisant l'application apprentik, vous acceptez les présentes conditions. L'application est destinée à un usage éducatif personnel.

1. Utilisation
apprentik est réservé à un usage personnel et non commercial. Toute reproduction ou distribution du contenu est interdite sans autorisation.

2. Contenu généré par l'IA
Les contenus pédagogiques sont générés automatiquement et fournis à titre informatif. Ils ne constituent pas un avis professionnel.

3. Données personnelles
Vos données sont stockées localement sur votre appareil. Aucune donnée personnelle n'est transmise à des tiers sans votre consentement.

4. Modifications
Nous nous réservons le droit de modifier ces conditions à tout moment.

Dernière mise à jour : juin 2025
''';

const _kPrivacy = '''
Politique de Confidentialité – apprentik

Données collectées
• Préférences d'apprentissage (stockées localement)
• Progression et résultats de quiz (stockés localement)

Données non collectées
• Aucune donnée personnelle n'est transmise à nos serveurs.
• Aucun suivi publicitaire.

Stockage
Toutes les données sont stockées sur votre appareil via un stockage local sécurisé.

Suppression
Vous pouvez effacer toutes vos données depuis les paramètres.

Contact : support@apprentik.app
''';

const _kAppleRules = '''
Conformité App Store – apprentik

L'application est conforme aux directives de l'App Store d'Apple :

• Directives de révision App Store (Section 5.1 – Confidentialité)
• Conditions d'utilisation des services Apple
• Directives relatives aux achats intégrés

En téléchargeant cette application via l'App Store, vous acceptez également les Conditions d'utilisation d'Apple.

Pour tout achat intégré (abonnement Premium), les paiements sont traités par Apple conformément à leurs politiques.
''';

const _kMentions = '''
Mentions Légales – apprentik

Éditeur : apprentik
Pays : France

Directeur de publication : Alekspcs

L'application apprentik est une œuvre originale protégée par le droit d'auteur. Toute reproduction partielle ou totale est interdite sans autorisation préalable.

Contact : support@apprentik.app
''';
