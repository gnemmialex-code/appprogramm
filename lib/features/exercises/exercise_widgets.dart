import 'package:flutter/material.dart';

import '../../core/models/content_models.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';

IconData iconForStep(StepType type) => switch (type) {
  StepType.text => Icons.menu_book_rounded,
  StepType.reflection => Icons.edit_note_rounded,
  StepType.action => Icons.flash_on_rounded,
  StepType.fact => Icons.lightbulb_rounded,
  StepType.tip => Icons.tips_and_updates_rounded,
  StepType.challenge => Icons.emoji_events_rounded,
  StepType.framework => Icons.account_tree_rounded,
  StepType.research => Icons.biotech_rounded,
};

Color colorForStep(StepType type) => switch (type) {
  StepType.text => AppColors.mint,
  StepType.reflection => AppColors.lavender,
  StepType.action => AppColors.sun,
  StepType.fact => AppColors.sky,
  StepType.tip => AppColors.peach,
  StepType.challenge => AppColors.rose,
  StepType.framework => AppColors.deepPurple,
  StepType.research => AppColors.teal,
};

String labelForStep(StepType type) => switch (type) {
  StepType.text => 'Lecture',
  StepType.reflection => 'Réflexion',
  StepType.action => 'Action',
  StepType.fact => 'Le savais-tu ?',
  StepType.tip => 'Astuce',
  StepType.challenge => 'Défi',
  StepType.framework => 'Framework',
  StepType.research => 'Recherche',
};

/// Renders the interactive component matching the step type.
class StepInteractive extends StatelessWidget {
  final StepType type;
  const StepInteractive({super.key, required this.type});

  @override
  Widget build(BuildContext context) => switch (type) {
    StepType.reflection => const _ReflectionField(),
    StepType.action => const _ActionCheck(),
    StepType.fact => const _FactCallout(),
    StepType.tip => const _TipConfirm(),
    StepType.challenge => const _ChallengeAccept(),
    StepType.framework => const _FrameworkCapture(),
    StepType.research => const _ResearchNote(),
    StepType.text => const SizedBox.shrink(),
  };
}

// ---------------------------------------------------------------------------
// Reflection — free-text journal
// ---------------------------------------------------------------------------

class _ReflectionField extends StatelessWidget {
  const _ReflectionField();

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.lavender.withValues(alpha: 0.12),
      child: TextField(
        maxLines: 4,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Écris ta réflexion ici…',
          hintStyle: TextStyle(color: AppColors.inkSoft),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action — checkbox confirm
// ---------------------------------------------------------------------------

class _ActionCheck extends StatefulWidget {
  const _ActionCheck();

  @override
  State<_ActionCheck> createState() => _ActionCheckState();
}

class _ActionCheckState extends State<_ActionCheck> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: _done
          ? AppColors.success.withValues(alpha: 0.14)
          : AppColors.sun.withValues(alpha: 0.16),
      onTap: () => setState(() => _done = !_done),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _done ? AppColors.success : Colors.transparent,
              border: Border.all(
                color: _done ? AppColors.success : AppColors.inkSoft,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: _done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _done ? 'Action réalisée — bravo ! 🎉' : 'Je l\'ai fait',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fact — "Did you know?" callout
// ---------------------------------------------------------------------------

class _FactCallout extends StatefulWidget {
  const _FactCallout();

  @override
  State<_FactCallout> createState() => _FactCalloutState();
}

class _FactCalloutState extends State<_FactCallout> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _confirmed = true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _confirmed
              ? AppColors.sky.withValues(alpha: 0.28)
              : AppColors.sky.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              _confirmed ? '🧠' : '💡',
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _confirmed
                    ? 'Bien noté ! Ce fait change la donne.'
                    : 'Touche pour marquer comme assimilé',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _confirmed ? AppColors.ink : AppColors.inkSoft,
                ),
              ),
            ),
            if (_confirmed)
              const Icon(
                Icons.verified_rounded,
                color: AppColors.sky,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tip — confirm you noted it
// ---------------------------------------------------------------------------

class _TipConfirm extends StatefulWidget {
  const _TipConfirm();

  @override
  State<_TipConfirm> createState() => _TipConfirmState();
}

class _TipConfirmState extends State<_TipConfirm> {
  bool _noted = false;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: _noted
          ? AppColors.success.withValues(alpha: 0.12)
          : AppColors.peach.withValues(alpha: 0.14),
      onTap: () => setState(() => _noted = true),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _noted ? AppColors.success : Colors.transparent,
              border: Border.all(
                color: _noted ? AppColors.success : AppColors.inkSoft,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: _noted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _noted ? 'Astuce enregistrée ✨' : 'Noté, je l\'applique',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Challenge — accept/complete the challenge
// ---------------------------------------------------------------------------

class _ChallengeAccept extends StatefulWidget {
  const _ChallengeAccept();

  @override
  State<_ChallengeAccept> createState() => _ChallengeAcceptState();
}

class _ChallengeAcceptState extends State<_ChallengeAccept> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _accepted
            ? AppColors.rose.withValues(alpha: 0.22)
            : AppColors.rose.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _accepted
              ? AppColors.rose.withValues(alpha: 0.6)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: GestureDetector(
        onTap: () => setState(() => _accepted = !_accepted),
        child: Row(
          children: [
            Text(_accepted ? '🏆' : '🎯', style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _accepted ? 'Défi accepté !' : 'Je relève le défi',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _accepted ? AppColors.rose : AppColors.ink,
                      fontSize: 15,
                    ),
                  ),
                  if (_accepted) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Engagement pris · bonne chance !',
                      style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Framework — map / schema the framework visually in free text
// ---------------------------------------------------------------------------

class _FrameworkCapture extends StatefulWidget {
  const _FrameworkCapture();

  @override
  State<_FrameworkCapture> createState() => _FrameworkCaptureState();
}

class _FrameworkCaptureState extends State<_FrameworkCapture> {
  bool _mapped = false;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.deepPurple.withValues(alpha: 0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_tree_rounded,
                color: AppColors.deepPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Schématise ce framework',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Dessine-le mentalement, puis décris ses composants ici…',
              hintStyle: TextStyle(color: AppColors.inkSoft, fontSize: 13),
              border: InputBorder.none,
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.all(12),
            ),
            onChanged: (v) {
              if (v.length > 5 && !_mapped) setState(() => _mapped = true);
            },
          ),
          if (_mapped) ...[
            const SizedBox(height: 8),
            Text(
              'Framework schématisé ✓',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.deepPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Research — note the key finding
// ---------------------------------------------------------------------------

class _ResearchNote extends StatefulWidget {
  const _ResearchNote();

  @override
  State<_ResearchNote> createState() => _ResearchNoteState();
}

class _ResearchNoteState extends State<_ResearchNote> {
  bool _noted = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _noted = true),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _noted
              ? AppColors.teal.withValues(alpha: 0.18)
              : AppColors.teal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _noted
                ? AppColors.teal.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Text(_noted ? '🔬' : '📄', style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _noted
                    ? 'Résultat de recherche noté — continue !'
                    : 'Touche pour noter ce résultat de recherche',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _noted ? AppColors.teal : AppColors.inkSoft,
                ),
              ),
            ),
            if (_noted)
              const Icon(
                Icons.verified_rounded,
                color: AppColors.teal,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise tile (used on the exercises page)
// ---------------------------------------------------------------------------

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  const ExerciseTile({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TintedIcon(
                icon: iconForStep(exercise.type),
                color: colorForStep(exercise.type),
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labelForStep(exercise.type).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: colorForStep(exercise.type),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      exercise.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            exercise.instruction,
            style: TextStyle(color: AppColors.inkSoft, height: 1.4),
          ),
          const SizedBox(height: 14),
          StepInteractive(type: exercise.type),
        ],
      ),
    );
  }
}
