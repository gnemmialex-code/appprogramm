import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/content_models.dart';
import '../../state/app_providers.dart';
import '../../ui/theme/app_colors.dart';
import 'quiz_runner.dart';

/// Standalone final recap quiz across the whole program.
class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(programControllerProvider);
    final quiz = program?.quiz ?? const <QuizQuestion>[];

    if (quiz.isEmpty) {
      return const Scaffold(body: Center(child: Text('Aucun quiz disponible')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz récapitulatif'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: QuizRunner(
            questions: quiz,
            onFinished: (score, total) {
              ref
                  .read(progressControllerProvider.notifier)
                  .recordQuiz(score, total);
              _showResult(context, score, total);
            },
          ),
        ),
      ),
    );
  }

  void _showResult(BuildContext context, int score, int total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Quiz terminé 🎯'),
        content: Text(
          'Ton score : $score / $total\n\n'
          '${score == total
              ? 'Sans faute, impressionnant !'
              : score >= total / 2
              ? 'Beau travail, continue !'
              : 'Rejoue pour progresser.'}',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Retour au programme'),
          ),
        ],
      ),
    );
  }
}
