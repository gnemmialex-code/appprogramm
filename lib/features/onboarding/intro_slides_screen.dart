import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Root
// ─────────────────────────────────────────────────────────────────────────────

class IntroSlidesScreen extends StatefulWidget {
  const IntroSlidesScreen({super.key});
  @override
  State<IntroSlidesScreen> createState() => _IntroSlidesScreenState();
}

class _IntroSlidesScreenState extends State<IntroSlidesScreen> {
  final _ctrl = PageController();
  int _page = 0;
  static const _n = 5;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _n - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go('/profile-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _ctrl,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (p) => setState(() => _page = p),
            children: [
              _Slide1(isActive: _page == 0),
              _Slide2(isActive: _page == 1),
              _Slide3(isActive: _page == 2),
              _Slide4(isActive: _page == 3),
              _Slide5(isActive: _page == 4),
            ],
          ),
          if (_page < _n - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 20,
              child: TextButton(
                onPressed: () => context.go('/profile-setup'),
                child: Text(
                  'Passer',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomNav(
              page: _page,
              n: _n,
              isLast: _page == _n - 1,
              onNext: _next,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom nav
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int page, n;
  final bool isLast;
  final VoidCallback onNext;
  const _BottomNav(
      {required this.page,
      required this.n,
      required this.isLast,
      required this.onNext});

  @override
  Widget build(BuildContext context) {
    final bot = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(28, 12, 28, bot + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(n, (i) {
              final active = i == page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 26 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: active
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.28),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: Material(
              borderRadius: BorderRadius.circular(20),
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient:
                      isLast ? AppColors.brandGradient : null,
                  color: isLast ? null : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isLast
                          ? AppColors.brandStart.withValues(alpha: 0.45)
                          : Colors.black.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: onNext,
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast ? 'Créer mon profil' : 'Continuer',
                        style: TextStyle(
                          color: isLast
                              ? Colors.white
                              : const Color(0xFF1C1C28),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color:
                            isLast ? Colors.white : const Color(0xFF1C1C28),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Staggered fade + slide-up for entrance.
class _Enter extends StatelessWidget {
  final Animation<double> parent;
  final double start, end;
  final Widget child;

  const _Enter({
    required this.parent,
    required this.start,
    required this.end,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: parent,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(curve),
        child: child,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide 1 — 15+ domaines
// ─────────────────────────────────────────────────────────────────────────────

class _Slide1 extends StatefulWidget {
  final bool isActive;
  const _Slide1({required this.isActive});
  @override
  State<_Slide1> createState() => _Slide1State();
}

class _Slide1State extends State<_Slide1> with TickerProviderStateMixin {
  late AnimationController _enter;
  late AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300));
    _drift = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);
    if (widget.isActive) _enter.forward();
  }

  @override
  void didUpdateWidget(_Slide1 old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _enter.reset();
      _enter.forward();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    _drift.dispose();
    super.dispose();
  }

  static const _row1 = [
    ('🧠', 'Psychologie'),
    ('💻', 'Technologie'),
    ('💰', 'Finance'),
    ('🎨', 'Créativité'),
    ('🔬', 'Sciences'),
  ];
  static const _row2 = [
    ('🌿', 'Bien-être'),
    ('📚', 'Histoire'),
    ('🗣️', 'Langues'),
    ('🎸', 'Musique'),
    ('🏋️', 'Sport'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_enter, _drift]),
      builder: (ctx, _) {
        final d = _drift.value; // 0..1
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B0820), Color(0xFF1A1040), Color(0xFF080618)],
            ),
          ),
          child: Stack(
            children: [
              // Ambient orbs
              Positioned(
                right: -60,
                top: 80,
                child: _orb(200, AppColors.brandStart.withValues(alpha: 0.13)),
              ),
              Positioned(
                left: -80,
                bottom: 180,
                child: _orb(180, const Color(0xFF9B5FFF).withValues(alpha: 0.1)),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Enter(
                        parent: _enter,
                        start: 0.0,
                        end: 0.35,
                        child: const _Badge(
                          label: '15+ domaines disponibles',
                          color: Color(0xFF7C6CFF),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Enter(
                        parent: _enter,
                        start: 0.1,
                        end: 0.5,
                        child: ShaderMask(
                          shaderCallback: (b) =>
                              AppColors.brandGradient.createShader(b),
                          child: const Text(
                            '15+',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 88,
                              fontWeight: FontWeight.w900,
                              height: 0.85,
                              letterSpacing: -4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _Enter(
                        parent: _enter,
                        start: 0.2,
                        end: 0.55,
                        child: const Text(
                          'Domaines à explorer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _Enter(
                        parent: _enter,
                        start: 0.3,
                        end: 0.65,
                        child: Text(
                          'De la psychologie au code, de la finance\nà la créativité — ton terrain de jeu.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.58),
                            fontSize: 16,
                            height: 1.55,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Domain pill rows
                      _Enter(
                        parent: _enter,
                        start: 0.55,
                        end: 0.9,
                        child: Column(
                          children: [
                            _PillRow(
                              items: _row1,
                              offsetY: d * -10 + 5,
                            ),
                            const SizedBox(height: 10),
                            _PillRow(
                              items: _row2,
                              offsetY: d * 10 - 5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _orb(double size, Color color) => Container(
        width: size,
        height: size,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _PillRow extends StatelessWidget {
  final List<(String, String)> items;
  final double offsetY;
  const _PillRow({required this.items, required this.offsetY});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offsetY),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: items
              .map(
                (e) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.13),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.$1,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 7),
                      Text(
                        e.$2,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide 2 — Programme IA
// ─────────────────────────────────────────────────────────────────────────────

class _Slide2 extends StatefulWidget {
  final bool isActive;
  const _Slide2({required this.isActive});
  @override
  State<_Slide2> createState() => _Slide2State();
}

class _Slide2State extends State<_Slide2> with TickerProviderStateMixin {
  late AnimationController _enter;
  late AnimationController _build; // chapters building up
  late AnimationController _pulse; // AI badge pulse
  late AnimationController _cursor; // cursor blink

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _build = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _cursor = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);

    _enter.addStatusListener((s) {
      if (s == AnimationStatus.completed) _build.forward();
    });

    if (widget.isActive) _enter.forward();
  }

  @override
  void didUpdateWidget(_Slide2 old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _build.reset();
      _enter.reset();
      _enter.forward();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    _build.dispose();
    _pulse.dispose();
    _cursor.dispose();
    super.dispose();
  }

  static const _chapters = [
    ('01', 'Introduction & fondamentaux', '8 min'),
    ('02', 'Concepts clés approfondis', '12 min'),
    ('03', 'Application pratique', '10 min'),
    ('04', 'Quiz & révision finale', '6 min'),
  ];

  Animation<double> _chap(int i) => Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _build,
          curve: Interval(i * 0.2, (i * 0.2 + 0.45).clamp(0, 1),
              curve: Curves.easeOutBack),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_enter, _build, _pulse, _cursor]),
      builder: (ctx, _) {
        final pScale = Tween(begin: 1.0, end: 1.06)
            .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOutSine))
            .value;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF060C1A), Color(0xFF0E1C38), Color(0xFF060C1A)],
            ),
          ),
          child: Stack(
            children: [
              // Grid lines
              CustomPaint(
                painter: _GridPainter(
                    color: Colors.white.withValues(alpha: 0.03)),
                child: const SizedBox.expand(),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI badge
                      _Enter(
                        parent: _enter,
                        start: 0.0,
                        end: 0.3,
                        child: Transform.scale(
                          scale: pScale,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: AppColors.brandGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brandStart
                                      .withValues(alpha: 0.5),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome_rounded,
                                    color: Colors.white, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Généré par IA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Enter(
                        parent: _enter,
                        start: 0.1,
                        end: 0.45,
                        child: const Text(
                          'Ton programme\nen 30 secondes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _Enter(
                        parent: _enter,
                        start: 0.22,
                        end: 0.55,
                        child: Text(
                          'L\'IA construit un parcours complet,\nadapté à ton niveau et tes objectifs.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.58),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Program card
                      _Enter(
                        parent: _enter,
                        start: 0.35,
                        end: 0.7,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF111D33),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF60A5FA).withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6)
                                    .withValues(alpha: 0.15),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF60A5FA)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.school_rounded,
                                        color: Color(0xFF60A5FA), size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Programme Psychologie',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          '4 chapitres · niveau débutant',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.45),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              for (int i = 0; i < _chapters.length; i++) ...[
                                AnimatedBuilder(
                                  animation: _chap(i),
                                  builder: (ctx2, child2) => Opacity(
                                    opacity:
                                        _chap(i).value.clamp(0.0, 1.0),
                                    child: Transform.translate(
                                      offset: Offset(
                                          20 * (1 - _chap(i).value), 0),
                                      child: _ChapterRow(
                                        num: _chapters[i].$1,
                                        title: _chapters[i].$2,
                                        dur: _chapters[i].$3,
                                        cursor: i == _chapters.length - 1 &&
                                            _build.value < 0.95
                                            ? _cursor.value
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                                if (i < _chapters.length - 1)
                                  const SizedBox(height: 8),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChapterRow extends StatelessWidget {
  final String num, title, dur;
  final double? cursor; // 0..1 blink, null = no cursor

  const _ChapterRow(
      {required this.num,
      required this.title,
      required this.dur,
      this.cursor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Row(
        children: [
          Text(
            num,
            style: TextStyle(
              color: const Color(0xFF60A5FA).withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (cursor != null)
                  AnimatedOpacity(
                    opacity: cursor!,
                    duration: Duration.zero,
                    child: const Text(
                      '|',
                      style: TextStyle(
                          color: Color(0xFF60A5FA),
                          fontSize: 13,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            dur,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide 3 — Flash mode (card flip)
// ─────────────────────────────────────────────────────────────────────────────

class _Slide3 extends StatefulWidget {
  final bool isActive;
  const _Slide3({required this.isActive});
  @override
  State<_Slide3> createState() => _Slide3State();
}

class _Slide3State extends State<_Slide3> with TickerProviderStateMixin {
  late AnimationController _enter;
  late AnimationController _flip; // 0→1 = 180° rotation
  late AnimationController _idle; // subtle float

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _flip = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _idle = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);

    _enter.addStatusListener((s) async {
      if (s == AnimationStatus.completed) {
        await Future.delayed(const Duration(milliseconds: 1400));
        if (mounted) _scheduleFlip();
      }
    });

    if (widget.isActive) _enter.forward();
  }

  void _scheduleFlip() async {
    if (!mounted) return;
    await _flip.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    await _flip.reverse();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (mounted) _scheduleFlip();
  }

  @override
  void didUpdateWidget(_Slide3 old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _flip.reset();
      _enter.reset();
      _enter.forward();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    _flip.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_enter, _flip, _idle]),
      builder: (ctx, _) {
        final floatY = Tween(begin: -8.0, end: 8.0)
            .animate(CurvedAnimation(
                parent: _idle, curve: Curves.easeInOutSine))
            .value;
        final angle = _flip.value * math.pi;
        final isBack = angle > math.pi / 2;
        final displayAngle = isBack ? angle - math.pi : angle;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF050E0E),
                Color(0xFF0A1E1E),
                Color(0xFF050E0E)
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Enter(
                    parent: _enter,
                    start: 0.0,
                    end: 0.35,
                    child: const _Badge(
                      label: '⚡  Mode Flash',
                      color: Color(0xFF34D399),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _Enter(
                    parent: _enter,
                    start: 0.1,
                    end: 0.45,
                    child: const Text(
                      'L\'essentiel\nen 5 minutes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Enter(
                    parent: _enter,
                    start: 0.2,
                    end: 0.55,
                    child: Text(
                      'Des modules courts pour apprendre\nmême quand tu n\'as pas le temps.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Flipping card
                  _Enter(
                    parent: _enter,
                    start: 0.4,
                    end: 0.75,
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(0, floatY),
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0015)
                            ..rotateY(displayAngle),
                          alignment: Alignment.center,
                          child: isBack
                              ? _FlashBack()
                              : _FlashFront(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Enter(
                    parent: _enter,
                    start: 0.6,
                    end: 0.9,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _dot(isBack ? 0 : 1),
                          const SizedBox(width: 6),
                          _dot(isBack ? 1 : 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dot(double opacity) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF34D399).withValues(alpha: 0.35 + opacity * 0.65),
        ),
      );
}

class _FlashFront extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2020),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF34D399).withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF34D399).withValues(alpha: 0.15),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF34D399).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Question',
              style: TextStyle(
                color: Color(0xFF34D399),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Qu\'est-ce que\nla neuroplasticité ?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Appuie pour révéler la réponse →',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlashBack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()..rotateY(math.pi),
      alignment: Alignment.center,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0A2418),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF34D399).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF34D399).withValues(alpha: 0.25),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF34D399).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '✓  Réponse',
                style: TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'La capacité du cerveau à\nse remodeler et créer de\nnouveaux circuits neuronaux.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide 4 — Quiz adaptatif
// ─────────────────────────────────────────────────────────────────────────────

class _Slide4 extends StatefulWidget {
  final bool isActive;
  const _Slide4({required this.isActive});
  @override
  State<_Slide4> createState() => _Slide4State();
}

class _Slide4State extends State<_Slide4> with TickerProviderStateMixin {
  late AnimationController _enter;
  late AnimationController _options;
  late AnimationController _correct; // highlight correct answer
  late AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _options = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _correct = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _glow = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    _enter.addStatusListener((s) async {
      if (s == AnimationStatus.completed) {
        await _options.forward();
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) await _correct.forward();
      }
    });

    if (widget.isActive) _enter.forward();
  }

  @override
  void didUpdateWidget(_Slide4 old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _correct.reset();
      _options.reset();
      _enter.reset();
      _enter.forward();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    _options.dispose();
    _correct.dispose();
    _glow.dispose();
    super.dispose();
  }

  Animation<double> _opt(int i) => Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _options,
          curve: Interval(i * 0.18, (i * 0.18 + 0.5).clamp(0, 1),
              curve: Curves.easeOutBack),
        ),
      );

  static const _opts = [
    'La capacité du cerveau à se remodeler',
    'Un type de mémoire à court terme',
    'La vitesse de traitement cérébral',
    'Un réseau de neurones artificiels',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_enter, _options, _correct, _glow]),
      builder: (ctx, _) {
        final glowVal = Tween(begin: 0.15, end: 0.35)
            .animate(CurvedAnimation(parent: _glow, curve: Curves.easeInOutSine))
            .value;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F0A04),
                Color(0xFF1A1208),
                Color(0xFF0F0A04)
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Enter(
                    parent: _enter,
                    start: 0.0,
                    end: 0.35,
                    child: const _Badge(
                      label: '🎯  Quiz adaptatif',
                      color: Color(0xFFFB923C),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _Enter(
                    parent: _enter,
                    start: 0.1,
                    end: 0.45,
                    child: const Text(
                      'Teste tes\nconnaissances',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Enter(
                    parent: _enter,
                    start: 0.2,
                    end: 0.55,
                    child: Text(
                      'Des questions ciblées pour ancrer\nchaque notion durablement.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Enter(
                    parent: _enter,
                    start: 0.3,
                    end: 0.65,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1208),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFB923C).withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFB923C)
                                .withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFB923C)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Question 3 / 5',
                                  style: TextStyle(
                                    color: Color(0xFFFB923C),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Qu\'est-ce que la neuroplasticité ?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Options
                          for (int i = 0; i < _opts.length; i++) ...[
                            AnimatedBuilder(
                              animation: Listenable.merge(
                                  [_opt(i), _correct]),
                              builder: (ctx2, child2) {
                                final anim = _opt(i).value;
                                final isCorrect = i == 0;
                                final highlighted =
                                    isCorrect && _correct.value > 0.5;
                                return Opacity(
                                  opacity: anim.clamp(0.0, 1.0),
                                  child: Transform.translate(
                                    offset: Offset(20 * (1 - anim), 0),
                                    child: _QuizOpt(
                                      label: _opts[i],
                                      isCorrect: isCorrect,
                                      highlighted: highlighted,
                                      glowAlpha: glowVal,
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (i < _opts.length - 1)
                              const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuizOpt extends StatelessWidget {
  final String label;
  final bool isCorrect, highlighted;
  final double glowAlpha;

  const _QuizOpt({
    required this.label,
    required this.isCorrect,
    required this.highlighted,
    required this.glowAlpha,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted
            ? const Color(0xFF34C759).withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? const Color(0xFF34C759).withValues(alpha: glowAlpha + 0.2)
              : Colors.white.withValues(alpha: 0.08),
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: highlighted
                    ? const Color(0xFF34C759)
                    : Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
                fontWeight:
                    highlighted ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          if (highlighted)
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF34C759), size: 18),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide 5 — Progression & stats
// ─────────────────────────────────────────────────────────────────────────────

class _Slide5 extends StatefulWidget {
  final bool isActive;
  const _Slide5({required this.isActive});
  @override
  State<_Slide5> createState() => _Slide5State();
}

class _Slide5State extends State<_Slide5> with TickerProviderStateMixin {
  late AnimationController _enter;
  late AnimationController _ring; // arc draw 0→0.76
  late AnimationController _stats;
  late AnimationController _sparkle;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _ring = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _stats = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _sparkle = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat();

    _enter.addStatusListener((s) async {
      if (s == AnimationStatus.completed) {
        _ring.forward();
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) _stats.forward();
      }
    });

    if (widget.isActive) _enter.forward();
  }

  @override
  void didUpdateWidget(_Slide5 old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _stats.reset();
      _ring.reset();
      _enter.reset();
      _enter.forward();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    _ring.dispose();
    _stats.dispose();
    _sparkle.dispose();
    super.dispose();
  }

  Animation<double> _stat(int i) => Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _stats,
          curve: Interval(i * 0.22, (i * 0.22 + 0.6).clamp(0, 1),
              curve: Curves.easeOutBack),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_enter, _ring, _stats, _sparkle]),
      builder: (ctx, _) {
        final ringVal = CurvedAnimation(
                parent: _ring, curve: Curves.easeInOutCubic)
            .value;
        final pct = (ringVal * 78).round();

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D0520),
                Color(0xFF180930),
                Color(0xFF0D0520)
              ],
            ),
          ),
          child: Stack(
            children: [
              // Sparkle particles
              ..._sparkleWidgets(context),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Enter(
                        parent: _enter,
                        start: 0.0,
                        end: 0.35,
                        child: const _Badge(
                          label: '📊  Progression',
                          color: Color(0xFF7C6CFF),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Enter(
                        parent: _enter,
                        start: 0.1,
                        end: 0.45,
                        child: const Text(
                          'Mesure\ntes avancées',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _Enter(
                        parent: _enter,
                        start: 0.2,
                        end: 0.55,
                        child: Text(
                          'Suis tes stats, débloque des badges\net reste motivé chaque jour.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.58),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Progress ring
                      _Enter(
                        parent: _enter,
                        start: 0.35,
                        end: 0.7,
                        child: Center(
                          child: SizedBox(
                            width: 160,
                            height: 160,
                            child: CustomPaint(
                              painter: _RingPainter(
                                progress: ringVal * 0.78,
                                color: AppColors.brandStart,
                                trackColor:
                                    Colors.white.withValues(alpha: 0.1),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (b) =>
                                          AppColors.brandGradient
                                              .createShader(b),
                                      child: Text(
                                        '$pct%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 38,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -1.5,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'complété',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.45),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Stat cards
                      Row(
                        children: [
                          for (int i = 0;
                              i < _statData.length;
                              i++) ...[
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _stat(i),
                                builder: (ctx2, child2) => Opacity(
                                  opacity: _stat(i).value.clamp(0.0, 1.0),
                                  child: Transform.translate(
                                    offset: Offset(
                                        0, 20 * (1 - _stat(i).value)),
                                    child: _StatCard(
                                      value: _statData[i].$1,
                                      label: _statData[i].$2,
                                      icon: _statData[i].$3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (i < _statData.length - 1)
                              const SizedBox(width: 10),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static const _statData = [
    ('12', 'Chapitres', '📖'),
    ('4', 'Badges', '🏆'),
    ('5j', 'Streak', '🔥'),
  ];

  List<Widget> _sparkleWidgets(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final rng = math.Random(7);
    final t = _sparkle.value;
    return List.generate(6, (i) {
      final angle = (i / 6) * 2 * math.pi + t * 2 * math.pi;
      final r = 100.0 + rng.nextDouble() * 80;
      final cx = size.width / 2 + math.cos(angle) * r;
      final cy = size.height * 0.55 + math.sin(angle) * r;
      final s = 3.0 + rng.nextDouble() * 5;
      return Positioned(
        left: cx - s / 2,
        top: cy - s / 2,
        child: Opacity(
          opacity: 0.1 + 0.25 * ((math.sin(angle * 2) + 1) / 2),
          child: Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              color: AppColors.brandStart,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String value, label, icon;
  const _StatCard(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painters
// ─────────────────────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color, trackColor;
  const _RingPainter(
      {required this.progress,
      required this.color,
      required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - 12;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    canvas.drawCircle(c, r, trackPaint);

    final arcPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.brandStart, AppColors.brandEnd],
      ).createShader(Rect.fromCircle(center: c, radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
