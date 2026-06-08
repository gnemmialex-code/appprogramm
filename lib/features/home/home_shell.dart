import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_providers.dart';
import '../../ui/animations/domain_hero.dart';
import '../../ui/animations/fade_slide.dart';
import '../../ui/animations/idle_breath.dart';
import '../../ui/animations/reveal_on_scroll.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';
import '../domain_selection/domains_data.dart';
import '../feed/feed_screen.dart';

/// Root shell: TikTok-style 4-tab layout with a floating dark pill nav bar.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _tab = 0;

  void _setTab(int t) {
    if (t == _tab) return;
    setState(() => _tab = t);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Tab bodies (all always mounted, cross-fade — no black flash) ─
          for (int i = 0; i < 4; i++)
            AnimatedOpacity(
              opacity: _tab == i ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              child: IgnorePointer(
                ignoring: _tab != i,
                child: TickerMode(
                  enabled: _tab == i,
                  child: const [
                    FeedScreen(showClose: false),
                    _QuizTab(),
                    _ProgramTab(),
                    _ProfileTab(),
                  ][i],
                ),
              ),
            ),

          // ── Floating bottom nav ─────────────────────────────────────────
          Positioned(
            bottom: bottomPad + 10,
            left: 14,
            right: 14,
            child: _BottomNav(tab: _tab, onChanged: _setTab),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom navigation bar ────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onChanged;
  const _BottomNav({required this.tab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.isDark
                ? Colors.black.withValues(alpha: 0.48)
                : Colors.white.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.line, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 32,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.swipe_up_rounded,
                label: 'Fil',
                active: tab == 0,
                onTap: () => onChanged(0),
              ),
              _NavItem(
                icon: Icons.psychology_rounded,
                label: 'Quiz',
                active: tab == 1,
                onTap: () => onChanged(1),
              ),
              _NavItem(
                icon: Icons.school_rounded,
                label: 'Programme',
                active: tab == 2,
                onTap: () => onChanged(2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                active: tab == 3,
                onTap: () => onChanged(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF0C0C14) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AnimatedScale(
                  scale: active ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    size: 22,
                    color: active
                        ? Colors.white
                        : AppColors.ink.withValues(alpha: 0.40),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active
                    ? Colors.black
                    : AppColors.ink.withValues(alpha: 0.40),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Programme tab ────────────────────────────────────────────────────────────

class _ProgramTab extends ConsumerStatefulWidget {
  const _ProgramTab();

  @override
  ConsumerState<_ProgramTab> createState() => _ProgramTabState();
}

class _ProgramTabState extends ConsumerState<_ProgramTab> {
  final _scroll = ScrollController();
  Timer? _retentionTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkRetention());
    _retentionTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _checkRetention(),
    );
  }

  @override
  void dispose() {
    _retentionTimer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _checkRetention() {
    if (!mounted) return;
    if (ref.read(programControllerProvider) == null) return;
    final r = ref.read(retentionControllerProvider);
    if (r.shouldAnnounce) {
      ref.read(retentionControllerProvider.notifier).markAnnounced();
      context.push('/retention');
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasProgram = ref.watch(programControllerProvider) != null;
    final retentionDue =
        hasProgram && ref.watch(retentionControllerProvider).isDue;
    final profile = ref.watch(userProfileProvider);
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final firstName = profile.firstName.isNotEmpty
        ? profile.firstName
        : (profile.pseudo.isNotEmpty ? profile.pseudo : null);
    final initial = (firstName ?? 'A')[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, topPad + 18, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstName != null
                              ? 'Bonjour, $firstName 👋'
                              : 'Bonjour 👋',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Que veux-tu apprendre ?',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: AppColors.brandGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: Column(
                children: [
                  // Retention banner
                  if (retentionDue)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GestureDetector(
                        onTap: () => context.push('/retention'),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.isDark
                                ? const Color(0xFF201C0E)
                                : AppColors.sun.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppColors.sun.withValues(
                                  alpha: AppColors.isDark ? 0.30 : 0.45),
                              width: 1,
                            ),
                            boxShadow: AppColors.isDark
                                ? [
                                    BoxShadow(
                                      color:
                                          AppColors.sun.withValues(alpha: 0.28),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.40),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : AppColors.softShadow,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.psychology_alt_rounded,
                                color: AppColors.sun,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quiz de rétention dispo',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Vérifions ce que tu as retenu 🧠',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.inkSoft,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: AppColors.inkSoft,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Resume / start program
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: GestureDetector(
                      onTap: () {
                        if (hasProgram) {
                          context.push('/program');
                        } else {
                          _scroll.animateTo(
                            360,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandStart.withValues(alpha: 0.45),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.40),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
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
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Custom program
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 80),
                    child: GestureDetector(
                      onTap: () => context.push('/custom'),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.isDark
                              ? const Color(0xFF141F1A)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.mint.withValues(
                                alpha: AppColors.isDark ? 0.28 : 0.45),
                            width: 1,
                          ),
                          boxShadow: AppColors.isDark
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.mint.withValues(alpha: 0.22),
                                    blurRadius: 22,
                                    offset: const Offset(0, 7),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.40),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : AppColors.softShadow,
                        ),
                        child: Row(
                          children: [
                            AmbientBob(
                              period: const Duration(milliseconds: 2600),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.mint.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppColors.mint,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mon propre programme',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Décris un thème, l\'IA construit tout',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.inkSoft,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: AppColors.inkSoft,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Flash + Expert
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                context.push('/domain/${kDomains.first.id}'),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.isDark
                                    ? const Color(0xFF1A1708)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: AppColors.sun.withValues(
                                      alpha: AppColors.isDark ? 0.28 : 0.45),
                                  width: 1,
                                ),
                                boxShadow: AppColors.isDark
                                    ? [
                                        BoxShadow(
                                          color: AppColors.sun
                                              .withValues(alpha: 0.25),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6),
                                        ),
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.40),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : AppColors.softShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '⚡',
                                    style: TextStyle(fontSize: 26),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Flash',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '5 min · l\'essentiel',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.inkSoft,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                context.push('/domain/${kDomains.first.id}'),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.isDark
                                    ? const Color(0xFF130F1E)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: AppColors.deepPurple.withValues(
                                      alpha: AppColors.isDark ? 0.35 : 0.55),
                                  width: 1,
                                ),
                                boxShadow: AppColors.isDark
                                    ? [
                                        BoxShadow(
                                          color: AppColors.deepPurple
                                              .withValues(alpha: 0.30),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6),
                                        ),
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.40),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : AppColors.softShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '🎓',
                                    style: TextStyle(fontSize: 26),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Expert',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '15 ch. · pro',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.inkSoft,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Domain section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 4),
              child: Row(
                children: [
                  Text(
                    'Choisis ton domaine',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ou crée le tien ↑',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Domain grid
          SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, bottomPad + 96),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.92,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final d = kDomains[i];
                  return RevealOnScroll(child: _TabDomainCard(domain: d));
                },
                childCount: kDomains.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabDomainCard extends StatelessWidget {
  final DomainItem domain;
  const _TabDomainCard({required this.domain});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/domain/${domain.id}'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.isDark
              ? Color.lerp(domain.color, Colors.black, 0.72)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: domain.color.withValues(
                alpha: AppColors.isDark ? 0.35 : 0.28),
            width: 1,
          ),
          boxShadow: AppColors.isDark
              ? [
                  BoxShadow(
                    color: domain.color.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Hero(
              tag: 'domain-${domain.id}',
              flightShuttleBuilder: domainHeroShuttle(domain.icon, domain.color),
              child: AmbientBob(
                distance: 3,
                period: Duration(milliseconds: 2000 + domain.id.length * 130),
                child: TintedIcon(
                  icon: domain.icon,
                  color: domain.color,
                  size: 54,
                ),
              ),
            ),
            const Spacer(),
            Text(
              domain.label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              domain.tagline,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quiz tab ─────────────────────────────────────────────────────────────────

class _QuizTab extends ConsumerWidget {
  const _QuizTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProgram = ref.watch(programControllerProvider) != null;
    final retentionDue =
        hasProgram && ref.watch(retentionControllerProvider).isDue;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, topPad + 22, 24, bottomPad + 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Quiz',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Teste tes connaissances',
              style: TextStyle(
                color: AppColors.inkSoft,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 30),

            // Program quiz
            if (hasProgram) ...[
              _QuizOptionCard(
                icon: Icons.star_rounded,
                color: AppColors.brandStart,
                title: 'Quiz de mon programme',
                subtitle: 'Teste tes connaissances sur ton programme actuel',
                tag: 'Mon programme',
                onTap: () => context.push('/quiz'),
              ),
              const SizedBox(height: 14),
            ],

            // Retention quiz
            if (retentionDue) ...[
              _QuizOptionCard(
                icon: Icons.psychology_alt_rounded,
                color: AppColors.sun,
                title: 'Quiz de rétention',
                subtitle: 'Vérifie ce que tu as retenu',
                tag: 'À faire',
                onTap: () => context.push('/retention'),
              ),
              const SizedBox(height: 14),
            ],

            // Section: by domain
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 6),
              child: Text(
                'PAR DOMAINE',
                style: TextStyle(
                  color: AppColors.inkSoft,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            // Domain rows — each opens the TikTok quiz screen
            for (final d in kDomains) ...[
              _DomainQuizRow(domain: d),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuizOptionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String tag;
  final VoidCallback onTap;

  const _QuizOptionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: color.withValues(alpha: 0.28),
            width: 1,
          ),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.inkSoft,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.inkSoft,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}

class _DomainQuizRow extends StatelessWidget {
  final DomainItem domain;
  const _DomainQuizRow({required this.domain});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/domain-quiz/${domain.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: domain.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(domain.icon, color: domain.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    domain.label,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    domain.tagline,
                    style: TextStyle(
                      color: AppColors.inkSoft,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: domain.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '4 Q',
                style: TextStyle(
                  color: domain.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
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
      ),
    );
  }
}

// ─── Profile tab (mini, classy) ───────────────────────────────────────────────

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final isDark = ref.watch(darkModeProvider);
    final notesCount = ref.watch(notesProvider).length;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final displayName = profile.firstName.isNotEmpty
        ? profile.firstName
        : (profile.pseudo.isNotEmpty ? profile.pseudo : 'Mon profil');
    final initial = displayName[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, topPad + 24, 24, bottomPad + 100),
        child: Column(
          children: [
            // ── Avatar ───────────────────────────────────────────────────
            const SizedBox(height: 16),
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              displayName,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (profile.email.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                profile.email,
                style: TextStyle(color: AppColors.inkSoft, fontSize: 14),
              ),
            ],
            const SizedBox(height: 32),

            // ── Quick settings ───────────────────────────────────────────
            _DarkCard(
              child: Column(
                children: [
                  _SettingRow(
                    icon: isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    iconColor: isDark ? AppColors.lavender : AppColors.sun,
                    title: 'Mode sombre',
                    trailing: Switch(
                      value: isDark,
                      activeThumbColor: AppColors.brandStart,
                      activeTrackColor:
                          AppColors.brandStart.withValues(alpha: 0.4),
                      onChanged: (v) =>
                          ref.read(darkModeProvider.notifier).set(v),
                    ),
                  ),
                  _SettingDivider(),
                  _SettingRow(
                    icon: Icons.sticky_note_2_rounded,
                    iconColor: AppColors.lavender,
                    title: 'Mes notes',
                    onTap: () => context.push('/notes'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.lavender.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$notesCount',
                            style: const TextStyle(
                              color: AppColors.lavender,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: AppColors.inkSoft),
                      ],
                    ),
                  ),
                  _SettingDivider(),
                  _SettingRow(
                    icon: Icons.bar_chart_rounded,
                    iconColor: AppColors.mint,
                    title: 'Ma progression',
                    onTap: () => context.push('/progress'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.inkSoft),
                  ),
                  _SettingDivider(),
                  _SettingRow(
                    icon: Icons.notifications_rounded,
                    iconColor: AppColors.sky,
                    title: 'Rappels',
                    onTap: () => context.push('/reminders'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Voir profil complet ──────────────────────────────────────
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.line, width: 1),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Voir le profil complet',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 13, color: AppColors.inkSoft),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Version ──────────────────────────────────────────────────
            Text(
              'apprentik v1.0.0',
              style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkCard extends StatelessWidget {
  final Widget child;
  const _DarkCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: AppColors.softShadow,
      ),
      child: child,
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.iconColor,
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
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.ink,
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

class _SettingDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 66,
      color: AppColors.line,
    );
  }
}
