import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_providers.dart';
import '../domain_selection/domains_data.dart';
import 'knowledge_feed.dart';

/// A TikTok-style vertical feed of full-screen **text** learning cards.
///
/// Two modes:
///  • « Tout » — a bit of everything, all domains mixed.
///  • « Thématique » — only the themes the user wants to learn.
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  int _tab = 0; // 0 = Tout, 1 = Thématique
  late Set<String> _interests;
  int _page = 0;
  final Set<String> _liked = {};
  final Set<String> _saved = {};
  bool _initialised = false;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    // Seed the themed feed with the current program's domain, if any.
    final program = ref.read(programControllerProvider);
    String? match;
    if (program != null) {
      final target = program.domain.trim().toLowerCase();
      for (final d in kDomains) {
        if (d.label.toLowerCase() == target) {
          match = d.id;
          break;
        }
      }
    }
    _interests = {match ?? kDomains.first.id};
  }

  List<FeedCard> get _cards => _tab == 0 ? allFeed() : themedFeed(_interests);

  /// Jumps the (single, shared) controller back to the first card. Used when
  /// the feed content changes so the user starts at the top of the new list.
  void _resetToTop() {
    if (_pageController.hasClients) _pageController.jumpToPage(0);
  }

  void _switchTab(int t) {
    if (t == _tab) return;
    setState(() {
      _tab = t;
      _page = 0;
    });
    _resetToTop();
  }

  void _toggleInterest(String id) {
    setState(() {
      if (_interests.contains(id)) {
        if (_interests.length > 1) _interests.remove(id);
      } else {
        _interests.add(id);
      }
      _page = 0;
    });
    _resetToTop();
  }

  @override
  Widget build(BuildContext context) {
    final cards = _cards;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The vertical, snapping feed.
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (p) => setState(() => _page = p),
              itemCount: cards.length,
              itemBuilder: (context, i) {
                final c = cards[i];
                final key = '${c.domainId}|${c.title}';
                final view = _FeedCardView(
                  card: c,
                  index: i,
                  total: cards.length,
                  liked: _liked.contains(key),
                  saved: _saved.contains(key),
                  showHint: i == 0 && _page == 0,
                  onLike: () => setState(
                    () => _liked.contains(key)
                        ? _liked.remove(key)
                        : _liked.add(key),
                  ),
                  onSave: () => setState(
                    () => _saved.contains(key)
                        ? _saved.remove(key)
                        : _saved.add(key),
                  ),
                );
                // Depth effect: the off-screen card shrinks & fades, then
                // settles to full size as it snaps into place — synced to swipe.
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    var delta = 0.0;
                    if (_pageController.hasClients &&
                        _pageController.position.haveDimensions) {
                      delta = (_pageController.page ?? _page.toDouble()) - i;
                    }
                    final t = delta.abs().clamp(0.0, 1.0);
                    final scale = 1 - 0.06 * t;
                    final opacity = 1 - 0.45 * t;
                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(scale: scale, child: child),
                    );
                  },
                  child: view,
                );
              },
            ),
          ),

          // Top overlay: close + segmented tabs + optional interest chips.
          Positioned(
            top: topPad + 8,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    _Segmented(tab: _tab, onChanged: _switchTab),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
                if (_tab == 1)
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        for (final d in kDomains)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _InterestChip(
                              label: d.label,
                              selected: _interests.contains(d.id),
                              onTap: () => _toggleInterest(d.id),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onChanged;
  const _Segmented({required this.tab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, int i) {
      final active = tab == i;
      return GestureDetector(
        onTap: () => onChanged(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [seg('Tout', 0), seg('Thématique', 1)],
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _InterestChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _FeedCardView extends StatelessWidget {
  final FeedCard card;
  final int index;
  final int total;
  final bool liked;
  final bool saved;
  final bool showHint;
  final VoidCallback onLike;
  final VoidCallback onSave;

  const _FeedCardView({
    required this.card,
    required this.index,
    required this.total,
    required this.liked,
    required this.saved,
    required this.showHint,
    required this.onLike,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final deep = Color.lerp(card.color, Colors.black, 0.6)!;
    final pad = MediaQuery.of(context).padding;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [card.color, deep],
        ),
      ),
      child: Stack(
        children: [
          // Big faint background icon.
          Positioned(
            right: -30,
            top: pad.top + 80,
            child: Icon(
              card.icon,
              size: 220,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          // Card text content.
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              pad.top + 120,
              96,
              pad.bottom + 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(card.icon, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        card.domainLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  card.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  card.body,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 17,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                if (showHint)
                  Row(
                    children: [
                      const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Glisse vers le haut',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Right-side action column (TikTok-style).
          Positioned(
            right: 14,
            bottom: pad.bottom + 60,
            child: Column(
              children: [
                _Action(
                  icon: liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  active: liked,
                  onTap: onLike,
                ),
                const SizedBox(height: 18),
                _Action(
                  icon: saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  active: saved,
                  onTap: onSave,
                ),
                const SizedBox(height: 22),
                Text(
                  '${index + 1}/$total',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _Action({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: active ? 1.15 : 1,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
