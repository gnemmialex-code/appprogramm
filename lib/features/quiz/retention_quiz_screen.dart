import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/adaptive/adaptive.dart';
import '../../core/models/content_models.dart';
import '../../state/app_providers.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';
import 'quiz_runner.dart';
import 'retention_quiz.dart';

/// A surprise retention check: a fresh random questionnaire pulled from the
/// whole program to verify what the user actually remembers.
class RetentionQuizScreen extends ConsumerStatefulWidget {
  const RetentionQuizScreen({super.key});

  @override
  ConsumerState<RetentionQuizScreen> createState() =>
      _RetentionQuizScreenState();
}

class _RetentionQuizScreenState extends ConsumerState<RetentionQuizScreen> {
  late final List<QuizQuestion> _questions;

  @override
  void initState() {
    super.initState();
    final program = ref.read(programControllerProvider);
    final progress = ref.read(progressControllerProvider);
    _questions = program == null
        ? const []
        : buildRetentionQuiz(
            program,
            count: 8,
            // Insist on the subjects the user struggled with.
            focusModuleIds: strugglingModuleIds(program, progress).toSet(),
          );
    // This due event is now being handled.
    ref.read(retentionControllerProvider.notifier).markAnnounced();
  }

  @override
  Widget build(BuildContext context) {
    final program = ref.watch(programControllerProvider);
    if (program == null || _questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Aucun quiz de rétention disponible')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz de rétention'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SoftCard(
                color: AppColors.sun.withValues(alpha: 0.20),
                child: Row(
                  children: [
                    const Icon(Icons.psychology_alt_rounded,
                        color: AppColors.ink),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Petit point mémoire sur « ${program.domain} ». '
                        'Des questions tirées au hasard dans tout ton programme.',
                        style: const TextStyle(fontSize: 13, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: QuizRunner(
                  questions: _questions,
                  finishLabel: 'Voir mon score',
                  onFinished: (score, total) {
                    ref
                        .read(retentionControllerProvider.notifier)
                        .record(score, total);
                    _showResult(context, score, total);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResult(BuildContext context, int score, int total) {
    final ratio = total == 0 ? 0.0 : score / total;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Point mémoire terminé 🧠'),
        content: Text(
          'Ton score : $score / $total\n\n'
          '${ratio >= 0.8 ? 'Excellente mémoire, c\'est bien ancré !' : ratio >= 0.5 ? 'Pas mal ! Revois les chapitres concernés.' : 'À retravailler : reprends les chapitres pour consolider.'}'
          '\n\nProchain point mémoire programmé automatiquement.',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }
}
