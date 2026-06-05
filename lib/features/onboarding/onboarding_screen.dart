import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_providers.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';
import '../domain_selection/domains_data.dart';

// ---------------------------------------------------------------------------
// Static option catalogues
// ---------------------------------------------------------------------------

/// Daily-time options — mirror the tiers used by the program generator.
const List<({int minutes, String emoji, String label, String detail})>
_kTimeOptions = [
  (
    minutes: 5,
    emoji: '⚡',
    label: 'Express',
    detail: '~5 min · juste l\'essentiel',
  ),
  (
    minutes: 10,
    emoji: '🎯',
    label: 'Rapide',
    detail: '~10 min · les points clés',
  ),
  (
    minutes: 20,
    emoji: '📚',
    label: 'Standard',
    detail: '~20 min · contenu équilibré',
  ),
  (
    minutes: 30,
    emoji: '🔥',
    label: 'Approfondi',
    detail: '~30 min · programme complet',
  ),
  (
    minutes: 45,
    emoji: '🚀',
    label: 'Intensif',
    detail: '~45 min · tout, à fond',
  ),
];

const List<({int value, String emoji, String label, String detail})>
_kSessionOptions = [
  (value: 1, emoji: '🌅', label: '1 fois', detail: 'Un rendez-vous par jour'),
  (value: 2, emoji: '🌗', label: '2 fois', detail: 'Matin et soir'),
  (value: 3, emoji: '☀️', label: '3 fois', detail: 'Petites touches régulières'),
  (
    value: 4,
    emoji: '✨',
    label: '4 fois ou +',
    detail: 'Dès que j\'ai un moment',
  ),
];

const List<({String id, String emoji, String label, String detail})>
_kGoalOptions = [
  (
    id: 'profond',
    emoji: '🧠',
    label: 'Comprendre en profondeur',
    detail: 'Maîtriser vraiment le sujet',
  ),
  (
    id: 'habitude',
    emoji: '🔁',
    label: 'Créer une habitude',
    detail: 'Un peu chaque jour, durablement',
  ),
  (
    id: 'objectif',
    emoji: '🎯',
    label: 'Préparer un objectif précis',
    detail: 'Examen, projet, échéance…',
  ),
  (
    id: 'curiosite',
    emoji: '🌱',
    label: 'Par curiosité',
    detail: 'Apprendre pour le plaisir',
  ),
];

const List<({String id, String emoji, String label, String detail})>
_kExperienceOptions = [
  (
    id: 'debutant',
    emoji: '🐣',
    label: 'Débutant',
    detail: 'Je pars de zéro',
  ),
  (
    id: 'intermediaire',
    emoji: '🚶',
    label: 'Intermédiaire',
    detail: 'J\'ai quelques bases',
  ),
  (
    id: 'avance',
    emoji: '🦅',
    label: 'Avancé',
    detail: 'Je veux aller plus loin',
  ),
];

// ---------------------------------------------------------------------------
// Onboarding screen — one question per step, with smooth slide transitions.
// ---------------------------------------------------------------------------

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  // Total steps: 0 = welcome, 1..8 = questions.
  static const int _stepCount = 9;

  int _step = 0;
  bool _forward = true; // controls slide direction of the transition

  // Collected answers ------------------------------------------------------
  final _firstNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String? _domainId;
  String? _subThemeId; // optional
  int? _dailyMinutes;
  int? _sessionsPerDay;
  String? _goalId;
  String? _experienceId;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  DomainItem? get _selectedDomain {
    if (_domainId == null) return null;
    for (final d in kDomains) {
      if (d.id == _domainId) return d;
    }
    return null;
  }

  bool get _isLastStep => _step == _stepCount - 1;

  /// Whether the current step is answered well enough to advance.
  bool get _canProceed {
    switch (_step) {
      case 0:
        return true; // welcome
      case 1:
        return _firstNameCtrl.text.trim().isNotEmpty;
      case 2:
        return _isValidEmail(_emailCtrl.text.trim());
      case 3:
        return _domainId != null;
      case 4:
        return true; // sub-theme is optional
      case 5:
        return _dailyMinutes != null;
      case 6:
        return _sessionsPerDay != null;
      case 7:
        return _goalId != null;
      case 8:
        return _experienceId != null;
      default:
        return false;
    }
  }

  bool _isValidEmail(String s) {
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(s);
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!_canProceed) return;
    if (_isLastStep) {
      _finish();
      return;
    }
    setState(() {
      _forward = true;
      _step++;
    });
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step == 0) return;
    setState(() {
      _forward = false;
      _step--;
    });
  }

  Future<void> _finish() async {
    final firstName = _firstNameCtrl.text.trim();

    // Persist everything the user told us.
    await ref
        .read(userProfileProvider.notifier)
        .update(
          pseudo: firstName, // drives the home avatar initial
          firstName: firstName,
          email: _emailCtrl.text.trim(),
          domainIds: _domainId != null ? [_domainId!] : [],
          subThemeIds: _subThemeId != null ? [_subThemeId!] : [],
          sessionsPerDay: _sessionsPerDay ?? 1,
          goal: _goalId ?? '',
          experience: _experienceId ?? '',
        );

    // The single daily-time answer applies to every day of the week.
    if (_dailyMinutes != null) {
      await ref.read(dailyAvailabilityProvider.notifier).setAll(_dailyMinutes!);
    }

    if (!mounted) return;
    context.go('/personality');
  }

  @override
  Widget build(BuildContext context) {
    // Progress over the 8 questions (the welcome step shows an empty bar).
    final progress = _step / (_stepCount - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              progress: progress,
              showBack: _step > 0,
              onBack: _back,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final entering = child.key == ValueKey(_step);
                  final beginX = entering
                      ? (_forward ? 0.18 : -0.18)
                      : (_forward ? -0.18 : 0.18);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween(
                            begin: Offset(beginX, 0),
                            end: Offset.zero,
                          ).animate(animation),
                      child: child,
                    ),
                  );
                },
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previous, ?current],
                ),
                child: SingleChildScrollView(
                  key: ValueKey(_step),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: _buildStep(),
                ),
              ),
            ),
            _BottomBar(
              label: _isLastStep ? 'Découvrir mon profil' : 'Continuer',
              enabled: _canProceed,
              onPressed: _next,
              showSkip: _step == 4, // sub-theme step is skippable
              onSkip: () {
                setState(() => _subThemeId = null);
                _next();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return const _WelcomeStep();
      case 1:
        return _QuestionShell(
          emoji: '👋',
          title: 'Comment t\'appelles-tu ?',
          subtitle: 'On utilisera ton prénom pour personnaliser ton espace.',
          child: _TextStep(
            controller: _firstNameCtrl,
            hint: 'Ton prénom',
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            onChanged: () => setState(() {}),
            onSubmitted: _next,
          ),
        );
      case 2:
        return _QuestionShell(
          emoji: '✉️',
          title: 'Quel est ton e-mail ?',
          subtitle:
              'Pour sauvegarder ta progression et te tenir au courant. '
              'Rien n\'est partagé sans ton accord.',
          child: _TextStep(
            controller: _emailCtrl,
            hint: 'prenom@email.com',
            keyboardType: TextInputType.emailAddress,
            onChanged: () => setState(() {}),
            onSubmitted: _next,
          ),
        );
      case 3:
        return _QuestionShell(
          emoji: '🧭',
          title: 'Quel domaine veux-tu explorer ?',
          subtitle: 'Tu pourras en découvrir d\'autres plus tard.',
          child: _DomainGrid(
            selectedId: _domainId,
            onSelected: (id) => setState(() {
              if (_domainId != id) _subThemeId = null; // reset sub-theme
              _domainId = id;
            }),
          ),
        );
      case 4:
        final domain = _selectedDomain;
        return _QuestionShell(
          emoji: '🎯',
          title: 'Un sous-thème en tête ?',
          subtitle: domain == null
              ? 'Optionnel — tu peux passer cette étape.'
              : 'Dans « ${domain.label} » — optionnel, tu peux passer.',
          child: _SubThemeList(
            domain: domain,
            selectedId: _subThemeId,
            onSelected: (id) => setState(() => _subThemeId = id),
          ),
        );
      case 5:
        return _QuestionShell(
          emoji: '⏳',
          title: 'Combien de temps par jour ?',
          subtitle: 'On adapte la densité de chaque session à ton rythme.',
          child: Column(
            children: [
              for (final o in _kTimeOptions)
                _SelectableTile(
                  emoji: o.emoji,
                  title: '${o.label} · ${o.minutes} min',
                  subtitle: o.detail,
                  selected: _dailyMinutes == o.minutes,
                  onTap: () => setState(() => _dailyMinutes = o.minutes),
                ),
            ],
          ),
        );
      case 6:
        return _QuestionShell(
          emoji: '🔔',
          title: 'Combien de fois par jour ?',
          subtitle: 'Le nombre de rendez-vous d\'apprentissage souhaités.',
          child: Column(
            children: [
              for (final o in _kSessionOptions)
                _SelectableTile(
                  emoji: o.emoji,
                  title: o.label,
                  subtitle: o.detail,
                  selected: _sessionsPerDay == o.value,
                  onTap: () => setState(() => _sessionsPerDay = o.value),
                ),
            ],
          ),
        );
      case 7:
        return _QuestionShell(
          emoji: '💡',
          title: 'Quel est ton objectif ?',
          subtitle: 'Ça nous aide à orienter le ton et le contenu.',
          child: Column(
            children: [
              for (final o in _kGoalOptions)
                _SelectableTile(
                  emoji: o.emoji,
                  title: o.label,
                  subtitle: o.detail,
                  selected: _goalId == o.id,
                  onTap: () => setState(() => _goalId = o.id),
                ),
            ],
          ),
        );
      case 8:
        return _QuestionShell(
          emoji: '📈',
          title: 'Où en es-tu sur ce sujet ?',
          subtitle: 'On calibre la difficulté en fonction de ton niveau.',
          child: Column(
            children: [
              for (final o in _kExperienceOptions)
                _SelectableTile(
                  emoji: o.emoji,
                  title: o.label,
                  subtitle: o.detail,
                  selected: _experienceId == o.id,
                  onTap: () => setState(() => _experienceId = o.id),
                ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ---------------------------------------------------------------------------
// Chrome: top progress bar + bottom action bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  final double progress;
  final bool showBack;
  final VoidCallback onBack;

  const _TopBar({
    required this.progress,
    required this.showBack,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 24, 4),
      child: Row(
        children: [
          AnimatedOpacity(
            opacity: showBack ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.ink),
              onPressed: showBack ? onBack : null,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.clamp(0, 1)),
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                builder: (_, value, _) => Stack(
                  children: [
                    Container(height: 8, color: AppColors.line),
                    FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          gradient: AppColors.brandGradient,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  final bool showSkip;
  final VoidCallback onSkip;

  const _BottomBar({
    required this.label,
    required this.enabled,
    required this.onPressed,
    required this.showSkip,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GradientButton(
            label: label,
            icon: Icons.arrow_forward_rounded,
            onPressed: enabled ? onPressed : null,
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: showSkip
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: TextButton(
                onPressed: onSkip,
                child: Text(
                  'Passer cette étape',
                  style: TextStyle(
                    color: AppColors.inkSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            secondChild: const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable step layout + inputs
// ---------------------------------------------------------------------------

/// Standard heading (emoji + title + subtitle) above a question's body.
class _QuestionShell extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget child;

  const _QuestionShell({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(emoji, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.inkSoft,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 28),
        child,
      ],
    );
  }
}

class _TextStep extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  const _TextStep({
    required this.controller,
    required this.hint,
    required this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: TextInputAction.next,
      onChanged: (_) => onChanged(),
      onSubmitted: (_) => onSubmitted(),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.brandStart, width: 2),
        ),
      ),
    );
  }
}

/// A tappable row card that highlights when selected.
class _SelectableTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.brandStart.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.brandStart : AppColors.line,
            width: selected ? 2 : 1.5,
          ),
          boxShadow: selected ? null : AppColors.softShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedScale(
                    scale: selected ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.brandStart,
                      size: 24,
                    ),
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

// ---------------------------------------------------------------------------
// Domain picker (grid) + sub-theme list
// ---------------------------------------------------------------------------

class _DomainGrid extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const _DomainGrid({required this.selectedId, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kDomains.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, i) {
        final d = kDomains[i];
        final selected = d.id == selectedId;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected
                ? d.color.withValues(alpha: 0.30)
                : d.color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.ink : Colors.transparent,
              width: 2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(d.id),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(d.icon, color: AppColors.ink, size: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            d.tagline,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.inkSoft,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SubThemeList extends StatelessWidget {
  final DomainItem? domain;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const _SubThemeList({
    required this.domain,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final d = domain;
    if (d == null) {
      return Text(
        'Choisis d\'abord un domaine à l\'étape précédente.',
        style: TextStyle(color: AppColors.inkSoft, fontSize: 14),
      );
    }
    return Column(
      children: [
        for (final s in d.subThemes)
          _SelectableTile(
            emoji: s.emoji,
            title: s.label,
            subtitle: s.description,
            selected: s.id == selectedId,
            onTap: () => onSelected(s.id),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Welcome (step 0)
// ---------------------------------------------------------------------------

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandStart.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 42,
          ),
        ),
        const SizedBox(height: 28),
        ShaderMask(
          shaderCallback: (b) => AppColors.brandGradient.createShader(b),
          child: const Text(
            'Bienvenue sur\napprentik',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Avant de commencer, réponds à quelques questions rapides. '
          'On construira un espace d\'apprentissage taillé pour toi — '
          'ton domaine, ton rythme et tes objectifs.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.inkSoft,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        const _WelcomePoint(
          emoji: '⏱️',
          text: 'Moins d\'une minute',
        ),
        const _WelcomePoint(
          emoji: '🎛️',
          text: 'Tout est modifiable plus tard',
        ),
        const _WelcomePoint(
          emoji: '🔒',
          text: 'Tes réponses restent sur ton appareil',
        ),
      ],
    );
  }
}

class _WelcomePoint extends StatelessWidget {
  final String emoji;
  final String text;

  const _WelcomePoint({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
