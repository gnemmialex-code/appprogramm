import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_providers.dart';
import '../../ui/animations/fade_slide.dart';
import '../../ui/animations/idle_breath.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';
import 'domains_data.dart';

/// Home screen — "Choisis ton domaine".
///
/// A staggered grid of animated domain cards with Hero transitions, plus two
/// central action buttons that gently enlarge after 5 s of inactivity so the
/// screen never feels static.
class DomainSelectionScreen extends ConsumerStatefulWidget {
  const DomainSelectionScreen({super.key});

  @override
  ConsumerState<DomainSelectionScreen> createState() =>
      _DomainSelectionScreenState();
}

class _DomainSelectionScreenState
    extends ConsumerState<DomainSelectionScreen> {
  final ScrollController _scroll = ScrollController();
  Timer? _idleTimer;
  Timer? _retentionTimer;
  bool _idle = false;

  @override
  void initState() {
    super.initState();
    _wake();
    // Watch for a due retention check and open it in priority.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkRetention());
    _retentionTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _checkRetention(),
    );
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _retentionTimer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  /// If a retention check has become due, open the questionnaire in priority.
  void _checkRetention() {
    if (!mounted) return;
    if (ref.read(programControllerProvider) == null) return;
    final retention = ref.read(retentionControllerProvider);
    if (retention.shouldAnnounce) {
      ref.read(retentionControllerProvider.notifier).markAnnounced();
      context.push('/retention');
    } else {
      setState(() {}); // refresh the due banner
    }
  }

  /// Any interaction resets the 5 s idle countdown.
  void _wake() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _idle = true);
    });
    if (_idle) setState(() => _idle = false);
  }

  void _scrollToThemes() {
    _wake();
    _scroll.animateTo(
      320,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasProgram = ref.watch(programControllerProvider) != null;
    final retentionDue = hasProgram && ref.watch(retentionControllerProvider).isDue;

    return Scaffold(
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _wake(),
        onPointerSignal: (_) => _wake(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n is ScrollStartNotification || n is UserScrollNotification) {
              _wake();
            }
            return false;
          },
          child: SafeArea(
            child: CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (retentionDue)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: IdleBreath(
                              active: true,
                              grow: 0.02,
                              child: SoftCard(
                                color: AppColors.sun.withValues(alpha: 0.30),
                                onTap: () => context.push('/retention'),
                                child: Row(
                                  children: [
                                    const Icon(Icons.psychology_alt_rounded,
                                        color: AppColors.ink, size: 30),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Quiz de rétention dispo',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w800)),
                                          SizedBox(height: 2),
                                          Text(
                                              'Vérifions ce que tu as retenu 🧠',
                                              style: TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios_rounded,
                                        size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const FadeSlideIn(
                          child: Text(
                            'Choisis ton domaine',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 80),
                          child: Text(
                            'Sélectionne un thème et laisse Lumina créer ton '
                            'programme sur mesure.',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.inkSoft,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // --- Central button #1: learning feed ---
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 100),
                          child: IdleBreath(
                            active: _idle,
                            child: _feedCard(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // --- Central button #2: resume / create ---
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 120),
                          child: IdleBreath(
                            active: _idle,
                            child: _programCard(context, hasProgram),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 140),
                          child: _customCard(context),
                        ),
                        if (_idle)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Center(
                              child: Text(
                                'Touche un bouton pour commencer ✨',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.inkSoft),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                    child: Row(
                      children: [
                        const Text('Thèmes populaires',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text('ou crée le tien ↑',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.inkSoft)),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.92,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final d = kDomains[i];
                        return FadeSlideIn(
                          delay: Duration(milliseconds: 140 + i * 60),
                          child: _DomainCard(domain: d),
                        );
                      },
                      childCount: kDomains.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customCard(BuildContext context) {
    return SoftCard(
      color: AppColors.mint.withValues(alpha: 0.20),
      onTap: () {
        _wake();
        context.push('/custom');
      },
      child: Row(
        children: [
          AmbientBob(
            period: const Duration(milliseconds: 2600),
            child: TintedIcon(
              icon: Icons.auto_awesome_rounded,
              color: AppColors.mint,
              size: 44,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mon propre programme',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text('Décris un thème, l\'IA construit tout',
                    style: TextStyle(fontSize: 13, color: AppColors.inkSoft)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: AppColors.inkSoft),
        ],
      ),
    );
  }

  Widget _feedCard(BuildContext context) {
    return SoftCard(
      color: AppColors.ink,
      onTap: () {
        _wake();
        context.push('/feed');
      },
      child: Row(
        children: [
          AmbientBob(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.swipe_up_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fil d\'apprentissage',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    )),
                SizedBox(height: 2),
                Text('Swipe ↑ • un peu de tout ou par thème',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _programCard(BuildContext context, bool hasProgram) {
    return SoftCard(
      gradient: AppColors.brandGradient,
      onTap: () {
        if (hasProgram) {
          _wake();
          context.push('/program');
        } else {
          _scrollToThemes();
        }
      },
      child: Row(
        children: [
          Icon(
            hasProgram
                ? Icons.play_circle_fill_rounded
                : Icons.add_circle_rounded,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasProgram
                      ? 'Reprendre mon programme'
                      : 'Crée ton programme',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasProgram
                      ? 'Continue là où tu t\'es arrêté'
                      : 'Choisis un thème juste en dessous',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(
            hasProgram
                ? Icons.arrow_forward_ios_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: hasProgram ? 16 : 24,
          ),
        ],
      ),
    );
  }
}

class _DomainCard extends StatelessWidget {
  final DomainItem domain;
  const _DomainCard({required this.domain});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'domain-${domain.id}',
      child: SoftCard(
        color: domain.color.withValues(alpha: 0.16),
        padding: const EdgeInsets.all(18),
        onTap: () => context.push('/generate/${domain.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AmbientBob(
              distance: 3,
              // Slightly different rhythm per card so the grid breathes
              // organically instead of in unison.
              period: Duration(milliseconds: 2000 + domain.id.length * 130),
              child: TintedIcon(
                  icon: domain.icon, color: domain.color, size: 54),
            ),
            const Spacer(),
            Text(
              domain.label,
              style: const TextStyle(
                  fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              domain.tagline,
              style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
