import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/app_providers.dart';
import '../../ui/animations/fade_slide.dart';
import '../../ui/components/app_components.dart';
import '../../ui/theme/app_colors.dart';

/// Final questionnaire followed by an AI-style summary and personalised plan.
class FinalReportScreen extends ConsumerStatefulWidget {
  const FinalReportScreen({super.key});

  @override
  ConsumerState<FinalReportScreen> createState() => _FinalReportScreenState();
}

class _FinalReportScreenState extends ConsumerState<FinalReportScreen> {
  final _questions = const [
    'Comment te sens-tu après ce parcours ?',
    'À quel point te sens-tu prêt(e) à continuer seul(e) ?',
    'Quelle est ta motivation actuelle ?',
  ];
  final _answers = <int>[2, 2, 2]; // 0..4 scale
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final program = ref.watch(programControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilan final'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _submitted
              ? _buildReport(program?.finalSummary ?? '', program?.domain ?? '')
              : _buildQuestionnaire(),
        ),
      ),
    );
  }

  Widget _buildQuestionnaire() {
    return ListView(
      key: const ValueKey('q'),
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Questionnaire final',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Réponds honnêtement pour personnaliser ton plan.',
            style: TextStyle(color: AppColors.inkSoft)),
        const SizedBox(height: 20),
        ...List.generate(_questions.length, (i) {
          return FadeSlideIn(
            delay: Duration(milliseconds: i * 90),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_questions[i],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (v) {
                        final selected = _answers[i] == v;
                        return GestureDetector(
                          onTap: () => setState(() => _answers[i] = v),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: selected
                                  ? AppColors.brandGradient
                                  : null,
                              color: selected ? null : AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              ['😞', '😐', '🙂', '😊', '🤩'][v],
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        GradientButton(
          label: 'Générer mon plan',
          icon: Icons.auto_awesome_rounded,
          onPressed: () {
            ref.read(progressControllerProvider.notifier).awardCompletion();
            setState(() => _submitted = true);
          },
        ),
      ],
    );
  }

  Widget _buildReport(String summary, String domain) {
    final motivation = _answers.reduce((a, b) => a + b) / (_answers.length * 4);
    final plan = _buildPlan(domain, motivation);

    return ListView(
      key: const ValueKey('r'),
      padding: const EdgeInsets.all(20),
      children: [
        FadeSlideIn(
          child: SoftCard(
            gradient: AppColors.brandGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Résumé généré par IA',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(summary,
                    style: const TextStyle(
                        color: Colors.white, height: 1.5, fontSize: 15)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Ton plan personnalisé',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ...List.generate(plan.length, (i) {
          return FadeSlideIn(
            delay: Duration(milliseconds: i * 90),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SoftCard(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.lavender.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text('${i + 1}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Text(plan[i],
                            style: const TextStyle(height: 1.4))),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        GradientButton(
          label: 'Terminer',
          icon: Icons.check_rounded,
          onPressed: () => context.go('/'),
        ),
      ],
    );
  }

  List<String> _buildPlan(String domain, double motivation) {
    final cadence = motivation > 0.6
        ? 'chaque jour'
        : motivation > 0.3
            ? '5 jours par semaine'
            : '3 jours par semaine';
    return [
      'Pratique $domain $cadence pendant 10 minutes.',
      'Relis un module clé en début de semaine pour ancrer les acquis.',
      'Note une victoire chaque soir, même minime.',
      'Refais le quiz dans 7 jours pour mesurer tes progrès.',
      'Augmente progressivement le niveau dès que tu te sens à l\'aise.',
    ];
  }
}
