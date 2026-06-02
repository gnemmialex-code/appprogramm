import 'package:flutter/material.dart';

import '../../core/models/content_models.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';

IconData iconForStep(StepType type) {
  switch (type) {
    case StepType.audio:
      return Icons.headphones_rounded;
    case StepType.reflection:
      return Icons.edit_note_rounded;
    case StepType.action:
      return Icons.flash_on_rounded;
    case StepType.text:
      return Icons.menu_book_rounded;
  }
}

Color colorForStep(StepType type) {
  switch (type) {
    case StepType.audio:
      return AppColors.sky;
    case StepType.reflection:
      return AppColors.lavender;
    case StepType.action:
      return AppColors.sun;
    case StepType.text:
      return AppColors.mint;
  }
}

/// Renders the right interactive control for a given step type.
class StepInteractive extends StatelessWidget {
  final StepType type;
  const StepInteractive({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case StepType.audio:
        return const _MockAudioPlayer();
      case StepType.reflection:
        return const _ReflectionField();
      case StepType.action:
        return const _ActionCheck();
      case StepType.text:
        return const SizedBox.shrink();
    }
  }
}

/// A simulated audio player with an animated progress bar.
class _MockAudioPlayer extends StatefulWidget {
  const _MockAudioPlayer();

  @override
  State<_MockAudioPlayer> createState() => _MockAudioPlayerState();
}

class _MockAudioPlayerState extends State<_MockAudioPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      if (_c.isAnimating) {
        _c.stop();
      } else {
        if (_c.value >= 1) _c.reset();
        _c.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.sky.withValues(alpha: 0.14),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, _) => Icon(
                  _c.isAnimating
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Session guidée',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  GradientProgressBar(value: _c.value, height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionField extends StatelessWidget {
  const _ReflectionField();

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: TextField(
        maxLines: 4,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Écris ta réflexion ici…',
        ),
      ),
    );
  }
}

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
                  width: 2),
              borderRadius: BorderRadius.circular(9),
            ),
            child: _done
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 20)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _done ? 'Action réalisée, bravo !' : 'Je l\'ai fait',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// A collapsible exercise card used on the exercises page.
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
                child: Text(exercise.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(exercise.instruction,
              style: TextStyle(color: AppColors.inkSoft, height: 1.4)),
          const SizedBox(height: 14),
          StepInteractive(type: exercise.type),
        ],
      ),
    );
  }
}
