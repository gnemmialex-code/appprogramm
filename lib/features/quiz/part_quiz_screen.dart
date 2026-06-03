import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_providers.dart';
import '../../ui/theme/app_colors.dart';
import 'quiz_runner.dart';

/// Transversal quiz that reviews all the chapters of a single part.
class PartQuizScreen extends ConsumerWidget {
  final int index;
  const PartQuizScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(programControllerProvider);
    if (program == null || index >= program.parts.length) {
      return const Scaffold(body: Center(child: Text('Partie introuvable')));
    }
    final part = program.parts[index];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz du niveau'),
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
              Text(
                part.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Quiz transversal du niveau • ${part.subtitle}',
                style: TextStyle(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: QuizRunner(
                  questions: part.quiz,
                  finishLabel: 'Voir mon score',
                  onFinished: (score, total) {
                    ref
                        .read(progressControllerProvider.notifier)
                        .recordPartQuiz(part.id, score, total);
                    _showResult(context, part.title, score, total);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResult(BuildContext context, String title, int score, int total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Quiz de partie terminé 🎯'),
        content: Text(
          '$title\n\nTon score : $score / $total\n\n'
          '${score >= (total * 0.75).ceil() ? 'Partie validée, bravo !' : 'Revois les chapitres et retente.'}',
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
