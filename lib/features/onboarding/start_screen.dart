import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_providers.dart';
import '../../ui/animations/fade_slide.dart';
import '../../ui/animations/idle_breath.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';
import '../domain_selection/domains_data.dart';

/// Post-onboarding launchpad. Lets the user immediately start what they chose
/// (generate a program for a selected domain, or build their own), while still
/// offering a way to land on the regular home screen.
class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final firstName = profile.firstName.isNotEmpty ? profile.firstName : null;
    final domains = kDomains
        .where((d) => profile.domainIds.contains(d.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                children: [
                  FadeSlideIn(
                    child: Row(
                      children: [
                        IdleBreath(
                          active: true,
                          grow: 0.05,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: AppColors.brandGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brandStart.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.rocket_launch_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            firstName != null
                                ? 'Par où commence-t-on,\n$firstName ?'
                                : 'Par où commence-t-on ?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    child: Text(
                      'Lance directement un parcours basé sur tes choix, '
                      'ou explore l\'app à ton rythme.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.inkSoft,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (domains.isNotEmpty) ...[
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 140),
                      child: _Label('Démarrer un domaine'),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < domains.length; i++)
                      FadeSlideIn(
                        delay: Duration(milliseconds: 180 + i * 70),
                        child: _LaunchCard(
                          icon: domains[i].icon,
                          color: domains[i].color,
                          title: domains[i].label,
                          subtitle: domains[i].tagline,
                          onTap: () => context.go('/generate/${domains[i].id}'),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],

                  if (profile.wantsCustom) ...[
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 220),
                      child: _Label('Créer mon programme'),
                    ),
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 260),
                      child: _LaunchCard(
                        icon: Icons.auto_awesome_rounded,
                        color: AppColors.lavender,
                        title: 'Mon propre thème',
                        subtitle: 'Décris ce que tu veux apprendre',
                        onTap: () => context.go('/custom'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (domains.isEmpty && !profile.wantsCustom)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 140),
                      child: _LaunchCard(
                        icon: Icons.explore_rounded,
                        color: AppColors.mint,
                        title: 'Choisir un domaine',
                        subtitle: 'Parcours le catalogue depuis l\'accueil',
                        onTap: () => context.go('/'),
                      ),
                    ),
                ],
              ),
            ),

            // Always offer the regular home screen.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: _SecondaryButton(
                label: 'Aller à l\'accueil',
                icon: Icons.home_rounded,
                onPressed: () => context.go('/'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.inkSoft,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _LaunchCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LaunchCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        color: color.withValues(alpha: 0.20),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: AppColors.ink, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.ink, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
