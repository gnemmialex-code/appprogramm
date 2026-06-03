import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/ai/flash_generator.dart';
import '../domain_selection/domains_data.dart';

class FlashScreen extends StatefulWidget {
  final String domainId;
  final String subTheme;
  const FlashScreen({
    super.key,
    required this.domainId,
    required this.subTheme,
  });

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {
  final _controller = PageController();
  int _page = 0;
  bool _finished = false;

  // Timer
  late final Stopwatch _stopwatch = Stopwatch()..start();
  late final Timer _ticker = Timer.periodic(
    const Duration(seconds: 1),
    (_) => setState(() {}),
  );

  late final DomainItem _domain;
  late final List<FlashCard> _cards;

  @override
  void initState() {
    super.initState();
    _domain = kDomains.firstWhere(
      (d) => d.id == widget.domainId,
      orElse: () => kDomains.first,
    );
    _cards = generateFlashCards(_domain.label, widget.subTheme);
  }

  @override
  void dispose() {
    _ticker.cancel();
    _controller.dispose();
    super.dispose();
  }

  String get _elapsed {
    final s = _stopwatch.elapsed.inSeconds;
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m}m ${sec.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;

    if (_finished) {
      return _FinishScreen(
        domain: _domain,
        subTheme: widget.subTheme,
        elapsed: _elapsed,
        cardCount: _cards.length,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Feed
          PageView.builder(
            controller: _controller,
            scrollDirection: Axis.vertical,
            onPageChanged: (p) {
              setState(() => _page = p);
              if (p == _cards.length) setState(() => _finished = true);
            },
            itemCount: _cards.length + 1, // +1 for finish trigger
            itemBuilder: (_, i) {
              if (i == _cards.length) {
                return const SizedBox.shrink();
              }
              return _FlashCardView(
                card: _cards[i],
                domain: _domain,
                index: i,
                total: _cards.length,
              );
            },
          ),

          // Top bar
          Positioned(
            top: pad.top + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (_page + 1) / _cards.length,
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.20),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _elapsed,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Page counter + swipe hint
          if (_page == 0)
            Positioned(
              bottom: pad.bottom + 14,
              left: 0,
              right: 0,
              child: _SwipeHint(),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Flash card view
// ---------------------------------------------------------------------------

class _FlashCardView extends StatelessWidget {
  final FlashCard card;
  final DomainItem domain;
  final int index;
  final int total;

  const _FlashCardView({
    required this.card,
    required this.domain,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final deep = Color.lerp(domain.color, Colors.black, 0.60)!;
    final pad = MediaQuery.of(context).padding;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [domain.color.withValues(alpha: 0.85), deep],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 70, 24, pad.bottom + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji
              Text(card.emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              // Tag
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  card.tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Headline
              Text(
                card.headline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              // Body
              Expanded(
                child: Text(
                  card.body,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 16,
                    height: 1.55,
                  ),
                ),
              ),
              // Action tip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        card.actionTip,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Counter
              Center(
                child: Text(
                  '${index + 1} / $total',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Swipe hint
// ---------------------------------------------------------------------------

class _SwipeHint extends StatefulWidget {
  @override
  State<_SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<_SwipeHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => Transform.translate(
            offset: Offset(0, -5 * _c.value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 20,
                ),
                Text(
                  'Swipe vers le haut',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Finish screen
// ---------------------------------------------------------------------------

class _FinishScreen extends StatelessWidget {
  final DomainItem domain;
  final String subTheme;
  final String elapsed;
  final int cardCount;

  const _FinishScreen({
    required this.domain,
    required this.subTheme,
    required this.elapsed,
    required this.cardCount,
  });

  @override
  Widget build(BuildContext context) {
    final deep = Color.lerp(domain.color, Colors.black, 0.65)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [domain.color.withValues(alpha: 0.80), deep],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏁', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 20),
                const Text(
                  'Flash terminé !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  elapsed,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(value: '$cardCount', label: 'insights\nassimilés'),
                      _Stat(
                        value: subTheme.length <= 12
                            ? subTheme
                            : '${subTheme.substring(0, 11)}…',
                        label: 'sous-thème',
                      ),
                      _Stat(value: domain.label, label: 'domaine'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _ActionButton(
                  emoji: '📚',
                  label: 'Programme Standard',
                  subtitle: '12 chapitres · aller plus loin',
                  onTap: () =>
                      context.go('/generate/${domain.id}', extra: subTheme),
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  emoji: '🎓',
                  label: 'Mode Expert',
                  subtitle: '15 chapitres · niveau professionnel',
                  onTap: () => context.go(
                    '/expert-generate/${domain.id}',
                    extra: subTheme,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Text(
                    'Retour à l\'accueil',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 14,
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
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionButton({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
