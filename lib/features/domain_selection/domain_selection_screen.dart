import 'dart:async';

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
import 'domains_data.dart';

// ---------------------------------------------------------------------------
// Swipe-up animation: phone silhouette + animated finger going bottom→top
// ---------------------------------------------------------------------------

class _SwipeUpHint extends StatefulWidget {
  const _SwipeUpHint();

  @override
  State<_SwipeUpHint> createState() => _SwipeUpHintState();
}

class _SwipeUpHintState extends State<_SwipeUpHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _y;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Finger moves from bottom (+14 px) to top (-14 px) of the phone body
    _y = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 14.0,
          end: -14.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 55,
      ),
      TweenSequenceItem(tween: ConstantTween(-14.0), weight: 45),
    ]).animate(_ctrl);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 43),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 25),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Phone outline
          Container(
            width: 26,
            height: 46,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.55),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                const SizedBox(height: 6),
                // Tiny "screen" line to suggest content
                Center(
                  child: Container(
                    width: 14,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ],
            ),
          ),
          // Bottom home bar
          Positioned(
            bottom: 3,
            child: Container(
              width: 10,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          // Animated finger icon
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) => Transform.translate(
              offset: Offset(0, _y.value),
              child: Opacity(
                opacity: _opacity.value,
                child: const Icon(
                  Icons.touch_app_rounded,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _DomainSelectionScreenState extends ConsumerState<DomainSelectionScreen> {
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
    final retentionDue =
        hasProgram && ref.watch(retentionControllerProvider).isDue;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
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
            top: false,
            child: CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
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
                                    Icon(
                                      Icons.psychology_alt_rounded,
                                      color: AppColors.ink,
                                      size: 30,
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Quiz de rétention dispo',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Vérifions ce que tu as retenu 🧠',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
                        const SizedBox(height: 16),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 160),
                          child: Row(
                            children: [
                              Expanded(child: _flashCard(context)),
                              const SizedBox(width: 12),
                              Expanded(child: _expertCard(context)),
                            ],
                          ),
                        ),
                        if (_idle)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Center(
                              child: Text(
                                'Touche un bouton pour commencer ✨',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.inkSoft,
                                ),
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
                        const Text(
                          'Choisis ton domaine',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
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
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final d = kDomains[i];
                      return RevealOnScroll(child: _DomainCard(domain: d));
                    }, childCount: kDomains.length),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _flashCard(BuildContext context) {
    return SoftCard(
      color: AppColors.sun.withValues(alpha: 0.18),
      padding: const EdgeInsets.all(16),
      onTap: () {
        _wake();
        // Navigate to first domain to pick a sub-theme for Flash
        context.push('/domain/${kDomains.first.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚡', style: TextStyle(fontSize: 26)),
          const SizedBox(height: 8),
          const Text(
            'Flash',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            '5 min · l\'essentiel',
            style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }

  Widget _expertCard(BuildContext context) {
    return SoftCard(
      color: AppColors.deepPurple.withValues(alpha: 0.14),
      padding: const EdgeInsets.all(16),
      onTap: () {
        _wake();
        context.push('/domain/${kDomains.first.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎓', style: TextStyle(fontSize: 26)),
          const SizedBox(height: 8),
          const Text(
            'Expert',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            '15 ch. · pro',
            style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final profile = ref.read(userProfileProvider);
    final initial = profile.pseudo.isNotEmpty
        ? profile.pseudo[0].toUpperCase()
        : null;

    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      title: ShaderMask(
        shaderCallback: (bounds) =>
            AppColors.brandGradient.createShader(bounds),
        child: const Text(
          'apprentik',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              _wake();
              context.push('/profile');
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: initial != null
                    ? Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _customCard(BuildContext context) {
    return Opacity(
      opacity: 0.55,
      child: Stack(
        children: [
          SoftCard(
            color: AppColors.mint.withValues(alpha: 0.20),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mon propre programme',
                        style:
                            TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Décris un thème, l\'IA construit tout',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: AppColors.inkSoft,
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.inkSoft.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.inkSoft.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Text(
                'Bientôt',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSoft,
                ),
              ),
            ),
          ),
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
                Text(
                  'Fil d\'apprentissage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Swipe ↑ • un peu de tout ou par thème',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const _SwipeUpHint(),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 16,
          ),
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
                  hasProgram ? 'Reprendre mon programme' : 'Crée ton programme',
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
    return SoftCard(
      color: domain.color.withValues(alpha: 0.16),
      padding: const EdgeInsets.all(18),
      onTap: () => context.push('/domain/${domain.id}'),
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
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            domain.tagline,
            style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
