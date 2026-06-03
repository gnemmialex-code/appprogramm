import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ai/generator.dart';
import '../../state/app_providers.dart';
import '../../ui/animations/domain_hero.dart';
import '../../ui/animations/reveal_on_scroll.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';
import '../domain_selection/domains_data.dart';
import 'domain_decor.dart';

class DomainDetailScreen extends StatelessWidget {
  final String domainId;
  const DomainDetailScreen({super.key, required this.domainId});

  @override
  Widget build(BuildContext context) {
    final domain = kDomains.firstWhere(
      (d) => d.id == domainId,
      orElse: () => kDomains.first,
    );
    return _DetailView(domain: domain);
  }
}

// ---------------------------------------------------------------------------
// Stateful view — holds selected sub-theme
// ---------------------------------------------------------------------------

class _DetailView extends ConsumerStatefulWidget {
  final DomainItem domain;
  const _DetailView({required this.domain});

  @override
  ConsumerState<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends ConsumerState<_DetailView> {
  // Pre-select the first sub-theme
  late String _selectedId = widget.domain.subThemes.first.id;

  SubTheme get _selected =>
      widget.domain.subThemes.firstWhere((s) => s.id == _selectedId);

  @override
  Widget build(BuildContext context) {
    final domain = widget.domain;
    final pad = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _HeroSliver(domain: domain, subThemeId: _selectedId),
              SliverToBoxAdapter(
                child: _Body(
                  domain: domain,
                  selectedId: _selectedId,
                  onSelect: (id) => setState(() => _selectedId = id),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _StickyStart(
              domain: domain,
              selected: _selected,
              bottomPad: pad.bottom,
              avgMinutes: ref
                  .watch(dailyAvailabilityProvider)
                  .averageActiveMinutes,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero collapsible header
// ---------------------------------------------------------------------------

class _HeroSliver extends StatelessWidget {
  final DomainItem domain;
  final String subThemeId;
  const _HeroSliver({required this.domain, required this.subThemeId});

  @override
  Widget build(BuildContext context) {
    final deeper = Color.lerp(domain.color, Colors.black, 0.45)!;
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: deeper,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
      title: Text(
        domain.label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _HeroBackground(domain: domain, subThemeId: subThemeId),
      ),
    );
  }
}

class _HeroBackground extends StatelessWidget {
  final DomainItem domain;
  final String subThemeId;
  const _HeroBackground({required this.domain, required this.subThemeId});

  @override
  Widget build(BuildContext context) {
    final deeper = Color.lerp(domain.color, Colors.black, 0.45)!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [domain.color, deeper],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Per-sub-theme animated decor — a distinct motif each time.
          Positioned.fill(
            child: DomainDecor(
              motif: resolveDecorMotif(domain.id, subThemeId),
              color: domain.color,
              seed: subThemeId.hashCode,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Hero(
                  tag: 'domain-${domain.id}',
                  flightShuttleBuilder: domainHeroShuttle(
                    domain.icon,
                    domain.color,
                  ),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(domain.icon, color: Colors.white, size: 50),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  domain.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  domain.tagline,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatChip(
                      icon: Icons.menu_book_rounded,
                      label: '12 chapitres',
                    ),
                    const SizedBox(width: 8),
                    _StatChip(icon: Icons.stairs_rounded, label: '3 niveaux'),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.explore_rounded,
                      label: '${domain.subThemes.length} sous-thèmes',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _Body extends StatelessWidget {
  final DomainItem domain;
  final String selectedId;
  final ValueChanged<String> onSelect;

  const _Body({
    required this.domain,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1 — Sub-theme picker (most prominent)
          _SubThemePicker(
            domain: domain,
            selectedId: selectedId,
            onSelect: onSelect,
          ),
          const SizedBox(height: 28),

          // 2 — Description
          _SectionTitle('À propos de ce programme'),
          const SizedBox(height: 10),
          Text(
            domain.description,
            style: TextStyle(fontSize: 15, height: 1.55, color: AppColors.ink),
          ),
          const SizedBox(height: 28),

          // 3 — Avant / Après
          _SectionTitle('Avant → Après'),
          const SizedBox(height: 12),
          RevealOnScroll(
            child: Row(
              children: [
                Expanded(child: _BeforeCard(text: domain.before)),
                const SizedBox(width: 12),
                Expanded(
                  child: _AfterCard(text: domain.after, color: domain.color),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 4 — Chapters
          _SectionTitle('Les 12 chapitres du programme'),
          const SizedBox(height: 12),
          RevealOnScroll(child: _ChapterList(domain: domain)),
          const SizedBox(height: 28),

          // 5 — Highlights
          _SectionTitle('Ce que tu vas développer'),
          const SizedBox(height: 12),
          ...domain.highlights.map(
            (h) => RevealOnScroll(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _HighlightRow(text: h, color: domain.color),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // 6 — Stats
          _SectionTitle('Le programme en chiffres'),
          const SizedBox(height: 12),
          RevealOnScroll(child: _StatsGrid(color: domain.color)),
          const SizedBox(height: 28),

          // 7 — Pour qui
          _SectionTitle('Pour qui ?'),
          const SizedBox(height: 10),
          RevealOnScroll(
            child: SoftCard(
              color: domain.color.withValues(alpha: 0.12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.person_search_rounded,
                    color: domain.color,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      domain.whoIsItFor,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-theme picker (the new main section)
// ---------------------------------------------------------------------------

class _SubThemePicker extends StatelessWidget {
  final DomainItem domain;
  final String selectedId;
  final ValueChanged<String> onSelect;

  const _SubThemePicker({
    required this.domain,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final selected = domain.subThemes.firstWhere((s) => s.id == selectedId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SectionTitle('Choisis ton focus'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: domain.color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${domain.subThemes.length} sous-thèmes',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color.lerp(domain.color, Colors.black, 0.3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Chaque sous-thème génère un programme de 12 chapitres entièrement dédié.',
          style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
        ),
        const SizedBox(height: 14),

        // Selected sub-theme preview card
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _SelectedPreview(
            key: ValueKey(selected.id),
            subTheme: selected,
            color: domain.color,
          ),
        ),
        const SizedBox(height: 14),

        // Chip grid
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final st in domain.subThemes)
              _SubThemeChip(
                subTheme: st,
                selected: st.id == selectedId,
                color: domain.color,
                onTap: () => onSelect(st.id),
              ),
          ],
        ),
      ],
    );
  }
}

class _SelectedPreview extends StatelessWidget {
  final SubTheme subTheme;
  final Color color;
  const _SelectedPreview({
    super.key,
    required this.subTheme,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Row(
        children: [
          Text(subTheme.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subTheme.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color.lerp(color, Colors.black, 0.25),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subTheme.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.inkSoft,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: color, size: 22),
        ],
      ),
    );
  }
}

class _SubThemeChip extends StatelessWidget {
  final SubTheme subTheme;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _SubThemeChip({
    required this.subTheme,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.5) : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected ? [] : AppColors.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(subTheme.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              subTheme.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? Color.lerp(color, Colors.black, 0.25)
                    : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Before / After
// ---------------------------------------------------------------------------

class _BeforeCard extends StatelessWidget {
  final String text;
  const _BeforeCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('😓', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Text(
                'Avant',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _AfterCard extends StatelessWidget {
  final String text;
  final Color color;
  const _AfterCard({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Text(
                'Après',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(fontSize: 13, height: 1.45, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chapter list
// ---------------------------------------------------------------------------

class _ChapterList extends StatefulWidget {
  final DomainItem domain;
  const _ChapterList({required this.domain});

  @override
  State<_ChapterList> createState() => _ChapterListState();
}

class _ChapterListState extends State<_ChapterList> {
  final Set<int> _open = {1, 2, 3};

  @override
  Widget build(BuildContext context) {
    const levelLabels = [
      'Niveau 1 · Facile',
      'Niveau 2 · Intermédiaire',
      'Niveau 3 · Expert',
    ];
    const levelColors = [AppColors.mint, AppColors.sun, AppColors.rose];

    return Column(
      children: [
        for (int lvl = 1; lvl <= 3; lvl++) ...[
          GestureDetector(
            onTap: () => setState(() {
              _open.contains(lvl) ? _open.remove(lvl) : _open.add(lvl);
            }),
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: levelColors[lvl - 1].withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: levelColors[lvl - 1],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      levelLabels[lvl - 1],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color.lerp(
                          levelColors[lvl - 1],
                          Colors.black,
                          0.3,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    _open.contains(lvl)
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Color.lerp(levelColors[lvl - 1], Colors.black, 0.3),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                children: [
                  for (final c
                      in kProgramChapters
                          .where((c) => c.level == lvl)
                          .toList()
                          .asMap()
                          .entries) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: levelColors[lvl - 1].withValues(
                                alpha: 0.18,
                              ),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(
                              child: Text(
                                '${kProgramChapters.indexOf(c.value) + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color.lerp(
                                    levelColors[lvl - 1],
                                    Colors.black,
                                    0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.value.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  c.value.summary,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.inkSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (c.key <
                        kProgramChapters.where((cc) => cc.level == lvl).length -
                            1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 50,
                        color: AppColors.line,
                      ),
                  ],
                ],
              ),
            ),
            crossFadeState: _open.contains(lvl)
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Highlights
// ---------------------------------------------------------------------------

class _HighlightRow extends StatelessWidget {
  final String text;
  final Color color;
  const _HighlightRow({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 3),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, size: 14, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.ink),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Stats grid
// ---------------------------------------------------------------------------

class _StatsGrid extends StatelessWidget {
  final Color color;
  const _StatsGrid({required this.color});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (Icons.menu_book_rounded, '12', 'chapitres'),
      (Icons.stairs_rounded, '3', 'niveaux'),
      (Icons.swipe_up_rounded, '8', 'étapes / ch.'),
      (Icons.fitness_center_rounded, '6', 'exercices / ch.'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: [
        for (final (icon, value, label) in stats)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color.lerp(color, Colors.black, 0.2),
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(fontSize: 11, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section title helper
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.inkSoft,
        letterSpacing: 1.0,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sticky CTA — shows selected sub-theme name
// ---------------------------------------------------------------------------

class _StickyStart extends StatelessWidget {
  final DomainItem domain;
  final SubTheme selected;
  final double bottomPad;
  final int avgMinutes;

  const _StickyStart({
    required this.domain,
    required this.selected,
    required this.bottomPad,
    required this.avgMinutes,
  });

  void _showTierInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Niveau du programme',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Le programme s\'adapte à ton temps disponible par jour.\nModifie-le dans Profil → Mon temps disponible.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.inkSoft,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            for (final t in ProgramTier.values) ...[
              _TierRow(tier: t, current: tierFromMinutes(avgMinutes) == t),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini preview of selection + tier badge
          Row(
            children: [
              Text(selected.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${tierLabel(tierFromMinutes(avgMinutes))} · ~${tierMinutesPerChapter(tierFromMinutes(avgMinutes))} min/chapitre',
                      style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showTierInfo(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lavender.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 14,
                        color: AppColors.inkSoft,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Adapter',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GradientButton(
            label: 'Commencer ce programme',
            icon: Icons.play_arrow_rounded,
            onPressed: () =>
                context.push('/generate/${domain.id}', extra: selected.label),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  emoji: '⚡',
                  label: 'Flash · 5 min',
                  color: AppColors.sun,
                  onTap: () => context.push(
                    '/flash/${domain.id}',
                    extra: selected.label,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeButton(
                  emoji: '🎓',
                  label: 'Mode Expert',
                  color: AppColors.deepPurple,
                  onTap: () => context.push(
                    '/expert-generate/${domain.id}',
                    extra: selected.label,
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

// ---------------------------------------------------------------------------
// Flash / Expert mode mini-buttons
// ---------------------------------------------------------------------------

class _ModeButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModeButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color.lerp(color, Colors.black, 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tier info row (used in the bottom sheet)
// ---------------------------------------------------------------------------

class _TierRow extends StatelessWidget {
  final ProgramTier tier;
  final bool current;
  const _TierRow({required this.tier, required this.current});

  @override
  Widget build(BuildContext context) {
    const descriptions = {
      ProgramTier.express: '3 étapes · l\'essentiel · ~5 min',
      ProgramTier.rapide: '5 étapes · les points clés · ~10 min',
      ProgramTier.standard: '7 étapes · contenu équilibré · ~18 min',
      ProgramTier.complet: '8 étapes + 5 exercices · ~28 min',
      ProgramTier.intensif: '8 étapes + 6 exercices · ~40 min',
    };
    const rangeLabels = {
      ProgramTier.express: '≤ 7 min/jour',
      ProgramTier.rapide: '8–12 min/jour',
      ProgramTier.standard: '13–22 min/jour',
      ProgramTier.complet: '23–35 min/jour',
      ProgramTier.intensif: '36+ min/jour',
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: current
            ? AppColors.brandStart.withValues(alpha: 0.08)
            : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: current
              ? AppColors.brandStart.withValues(alpha: 0.4)
              : AppColors.line,
          width: current ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tierLabel(tier),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: current ? AppColors.brandStart : AppColors.ink,
                      ),
                    ),
                    if (current) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandStart.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'actuel',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandStart,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  descriptions[tier]!,
                  style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
          Text(
            rangeLabels[tier]!,
            style: TextStyle(fontSize: 11, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
