import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ai/generator.dart'
    show tierFromMinutes, tierLabel, tierMinutesPerChapter;
import '../../state/app_providers.dart';
import '../../ui/animations/fade_slide.dart';
import '../../ui/animations/idle_breath.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';
import '../domain_selection/domains_data.dart';

// Human-readable labels for the ids stored during onboarding.
const Map<String, ({String label, String emoji})> _kGoalLabels = {
  'profond': (label: 'Comprendre en profondeur', emoji: '🧠'),
  'habitude': (label: 'Créer une habitude', emoji: '🔁'),
  'objectif': (label: 'Préparer un objectif précis', emoji: '🎯'),
  'curiosite': (label: 'Apprendre par curiosité', emoji: '🌱'),
};

const Map<String, ({String label, String emoji})> _kExperienceLabels = {
  'debutant': (label: 'Débutant', emoji: '🐣'),
  'intermediaire': (label: 'Intermédiaire', emoji: '🚶'),
  'avance': (label: 'Avancé', emoji: '🦅'),
};

String _hhmm(int minutes) {
  final h = (minutes ~/ 60).toString().padLeft(2, '0');
  final m = (minutes % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

/// Shown right after the onboarding questionnaire — a warm, personalised recap
/// that greets the user by name, summarises their choices and previews what
/// apprentik can do, before sending them to the launch screen.
class PersonalityScreen extends ConsumerWidget {
  const PersonalityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final availability = ref.watch(dailyAvailabilityProvider);

    final firstName = profile.firstName.isNotEmpty ? profile.firstName : 'toi';
    final domains = kDomains
        .where((d) => profile.domainIds.contains(d.id))
        .toList();
    final primary = domains.isNotEmpty ? domains.first : null;
    final accent = primary?.color ?? AppColors.lavender;

    final minutes = availability.averageActiveMinutes;
    final tier = tierFromMinutes(minutes);

    // Representative times (use Monday / first day if available).
    final times = profile.schedule.isNotEmpty ? profile.schedule.first : <int>[];
    final timesLabel = times.isEmpty
        ? '—'
        : times.map(_hhmm).map((t) => '≈ $t').join(' · ');

    final goal = _kGoalLabels[profile.goal];
    final exp = _kExperienceLabels[profile.experience];

    Future<void> next() async {
      await ref.read(onboardingCompleteProvider.notifier).complete();
      if (context.mounted) context.go('/start');
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                children: [
                  // --- Greeting --------------------------------------------
                  FadeSlideIn(
                    child: _Greeting(firstName: firstName, accent: accent),
                  ),
                  const SizedBox(height: 24),

                  // --- Chosen domains hero ---------------------------------
                  if (domains.isNotEmpty || profile.wantsCustom)
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 100),
                      child: _DomainsHero(
                        domains: domains,
                        wantsCustom: profile.wantsCustom,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // --- Recap -----------------------------------------------
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 180),
                    child: _SectionTitle('Ton profil d\'apprentissage'),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 220),
                    child: _RecapCard(
                      rows: [
                        (
                          icon: Icons.explore_rounded,
                          color: AppColors.lavender,
                          label: 'Domaines',
                          value: domains.isEmpty
                              ? (profile.wantsCustom ? 'Le tien' : '—')
                              : '${domains.length} choisi${domains.length > 1 ? 's' : ''}',
                        ),
                        if (profile.subThemeIds.isNotEmpty)
                          (
                            icon: Icons.tag_rounded,
                            color: AppColors.sky,
                            label: 'Sous-thèmes',
                            value: '${profile.subThemeIds.length}',
                          ),
                        (
                          icon: Icons.schedule_rounded,
                          color: AppColors.mint,
                          label: 'Temps / jour',
                          value: '$minutes min',
                        ),
                        (
                          icon: Icons.repeat_rounded,
                          color: AppColors.peach,
                          label: 'Sessions / jour',
                          value: '${profile.sessionsPerDay}',
                        ),
                        (
                          icon: Icons.alarm_rounded,
                          color: AppColors.gold,
                          label: 'Horaires',
                          value: timesLabel,
                        ),
                        if (goal != null)
                          (
                            icon: Icons.flag_rounded,
                            color: AppColors.rose,
                            label: 'Objectif',
                            value: '${goal.emoji} ${goal.label}',
                          ),
                        if (exp != null)
                          (
                            icon: Icons.bar_chart_rounded,
                            color: AppColors.aqua,
                            label: 'Niveau',
                            value: '${exp.emoji} ${exp.label}',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 260),
                    child: _TierBanner(
                      tierName: tierLabel(tier),
                      minutesPerChapter: tierMinutesPerChapter(tier),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // --- Feature preview (expandable) ------------------------
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 320),
                    child: _SectionTitle('Ce qui t\'attend'),
                  ),
                  const SizedBox(height: 4),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 340),
                    child: Text(
                      'Touche une carte pour voir un exemple 👇',
                      style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._featureCards(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: GradientButton(
                label: 'Commencer mon aventure',
                icon: Icons.rocket_launch_rounded,
                onPressed: next,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _featureCards() {
    const features = [
      (
        emoji: '🧩',
        color: AppColors.lavender,
        title: 'Programme adaptatif',
        text: 'Des chapitres structurés qui s\'ajustent à ton rythme.',
        example:
            'Jour 1 · Chapitre « Les bases »\n'
            '→ 3 étapes courtes à lire\n'
            '→ 2 mini-questions pour valider\n'
            '→ le chapitre suivant se débloque ✅',
      ),
      (
        emoji: '⚡',
        color: AppColors.sun,
        title: 'Mode Flash',
        text: 'L\'essentiel d\'un thème en 5 minutes chrono.',
        example:
            '3 cartes-clés à parcourir :\n'
            '1️⃣ L\'idée principale\n'
            '2️⃣ Un exemple concret\n'
            '3️⃣ À retenir — et c\'est plié !',
      ),
      (
        emoji: '🎓',
        color: AppColors.deepPurple,
        title: 'Mode Expert',
        text: 'Une maîtrise professionnelle, en profondeur.',
        example:
            '15 chapitres avancés\n'
            '→ théorie + cas pratiques\n'
            '→ quiz final de maîtrise 🏆',
      ),
      (
        emoji: '📰',
        color: AppColors.sky,
        title: 'Fil d\'apprentissage',
        text: 'Un peu de savoir, chaque jour, en swipant.',
        example:
            'Comme un feed, mais utile :\n'
            'swipe ↑ pour enchaîner des capsules\n'
            'de savoir d\'un peu tous tes thèmes.',
      ),
      (
        emoji: '🧠',
        color: AppColors.mint,
        title: 'Quiz de rétention',
        text: 'La répétition espacée ancre ce que tu apprends.',
        example:
            '24 h après ta leçon :\n'
            '« Te souviens-tu de… ? »\n'
            'Une mini-révision au bon moment pour\n'
            'ne rien oublier. 🔁',
      ),
      (
        emoji: '🔔',
        color: AppColors.peach,
        title: 'Rappels intelligents',
        text: 'apprentik te relance au bon moment.',
        example:
            'À ton heure habituelle :\n'
            '« Prêt pour ta session du jour ? »\n'
            'L\'app apprend tes horaires tout seul.',
      ),
    ];

    return [
      for (var i = 0; i < features.length; i++)
        FadeSlideIn(
          delay: Duration(milliseconds: 360 + i * 70),
          child: _ExpandableFeatureCard(
            emoji: features[i].emoji,
            color: features[i].color,
            title: features[i].title,
            text: features[i].text,
            example: features[i].example,
          ),
        ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _Greeting extends StatelessWidget {
  final String firstName;
  final Color accent;

  const _Greeting({required this.firstName, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IdleBreath(
              active: true,
              grow: 0.06,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandStart.withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Enchanté 👋',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.inkSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Ton espace est prêt,\n$firstName.',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'On a tout réglé selon tes réponses. Voici à quoi ressemble '
          'ton parcours personnalisé 👇',
          style: TextStyle(fontSize: 15, color: AppColors.inkSoft, height: 1.45),
        ),
      ],
    );
  }
}

class _DomainsHero extends StatelessWidget {
  final List<DomainItem> domains;
  final bool wantsCustom;

  const _DomainsHero({required this.domains, required this.wantsCustom});

  @override
  Widget build(BuildContext context) {
    final base = domains.isNotEmpty ? domains.first.color : AppColors.brandStart;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            base.withValues(alpha: 0.55),
            base.withValues(alpha: 0.28),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.30),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu vas explorer',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final d in domains)
                _HeroChip(icon: d.icon, label: d.label),
              if (wantsCustom)
                _HeroChip(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Mon thème',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.ink),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
    );
  }
}

typedef _RecapRow = ({IconData icon, Color color, String label, String value});

class _RecapCard extends StatelessWidget {
  final List<_RecapRow> rows;
  const _RecapCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 60,
                endIndent: 16,
                color: AppColors.line,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: rows[i].color.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(rows[i].icon, size: 18, color: AppColors.ink),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    rows[i].label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rows[i].value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TierBanner extends StatelessWidget {
  final String tierName;
  final int minutesPerChapter;

  const _TierBanner({required this.tierName, required this.minutesPerChapter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brandStart.withValues(alpha: 0.22),
            AppColors.brandEnd.withValues(alpha: 0.14),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.brandStart.withValues(alpha: 0.40),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.brandStart.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.tune_rounded, color: AppColors.brandStart),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Format généré : $tierName',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '~$minutesPerChapter min / chapitre · ajustable à tout moment',
                  style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Feature card that expands on tap to reveal a concrete "how it works" example.
class _ExpandableFeatureCard extends StatefulWidget {
  final String emoji;
  final Color color;
  final String title;
  final String text;
  final String example;

  const _ExpandableFeatureCard({
    required this.emoji,
    required this.color,
    required this.title,
    required this.text,
    required this.example,
  });

  @override
  State<_ExpandableFeatureCard> createState() => _ExpandableFeatureCardState();
}

class _ExpandableFeatureCardState extends State<_ExpandableFeatureCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _open ? widget.color : AppColors.line,
            width: _open ? 2 : 1.5,
          ),
          boxShadow: AppColors.softShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.text,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.inkSoft,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _open ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.expand_more_rounded,
                          color: widget.color,
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: _open
                        ? Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: widget.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: widget.color.withValues(alpha: 0.30),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.play_circle_outline_rounded,
                                        size: 16,
                                        color: AppColors.ink,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Exemple',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.example,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      height: 1.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
