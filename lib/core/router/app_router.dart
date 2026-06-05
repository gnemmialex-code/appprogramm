import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/custom_program/custom_program_screen.dart';
import '../../features/domain_detail/domain_detail_screen.dart';
import '../../features/expert/expert_generate_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/expert/expert_program_screen.dart';
import '../../features/feed/feed_screen.dart';
import '../../features/final_report/final_report_screen.dart';
import '../../features/flash/flash_screen.dart';
import '../../features/generation/generation_screen.dart';
import '../../features/module/module_screen.dart';
import '../../features/notes/notes_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/personality_screen.dart';
import '../../features/onboarding/start_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/program/program_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/quiz/part_quiz_screen.dart';
import '../../features/quiz/quiz_screen.dart';
import '../../features/quiz/quiz_runner.dart';
import '../../features/quiz/domain_quiz_screen.dart';
import '../../features/quiz/retention_quiz_screen.dart';
import '../../features/reminders/reminders_screen.dart';
import '../../state/app_providers.dart';
import '../../ui/theme/app_colors.dart';

/// The app's router. Built as a provider so the redirect guard can read the
/// onboarding-completion state and force first-launch users through the
/// questionnaire before reaching any other screen.
final goRouterProvider = Provider<GoRouter>((ref) {
  final onboardingDone = ref.read(appStorageProvider).onboardingComplete;

  return GoRouter(
    initialLocation: onboardingDone ? '/' : '/onboarding',
    redirect: (context, state) {
      final done = ref.read(onboardingCompleteProvider);
      final loc = state.matchedLocation;
      final inOnboarding = loc == '/onboarding' || loc == '/personality';

      // First launch: keep the user inside the onboarding flow.
      if (!done && !inOnboarding) return '/onboarding';
      // Already onboarded: don't let them fall back into the questionnaire.
      if (done && loc == '/onboarding') return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/personality',
        pageBuilder: (context, state) =>
            _fade(state, const PersonalityScreen()),
      ),
      GoRoute(
        path: '/start',
        pageBuilder: (context, state) => _fade(state, const StartScreen()),
      ),
      GoRoute(path: '/', builder: (_, _) => const HomeShell()),
    GoRoute(
      path: '/feed',
      pageBuilder: (context, state) => _fade(state, const FeedScreen()),
    ),
    GoRoute(
      path: '/custom',
      pageBuilder: (context, state) =>
          _fade(state, const CustomProgramScreen()),
    ),
    GoRoute(
      path: '/domain/:domainId',
      pageBuilder: (context, state) => _fade(
        state,
        DomainDetailScreen(domainId: state.pathParameters['domainId']!),
      ),
    ),
    GoRoute(
      path: '/domain-quiz/:domainId',
      pageBuilder: (context, state) => _fade(
        state,
        DomainQuizScreen(domainId: state.pathParameters['domainId']!),
      ),
    ),

    // ── FLASH MODE ─────────────────────────────────────────────────────────
    GoRoute(
      path: '/flash/:domainId',
      pageBuilder: (context, state) => _fade(
        state,
        FlashScreen(
          domainId: state.pathParameters['domainId']!,
          subTheme: state.extra as String? ?? '',
        ),
      ),
    ),

    // ── EXPERT MODE ────────────────────────────────────────────────────────
    GoRoute(
      path: '/expert-generate/:domain',
      pageBuilder: (context, state) => _fade(
        state,
        ExpertGenerateScreen(
          domainId: state.pathParameters['domain']!,
          objectif: state.extra as String?,
        ),
      ),
    ),
    GoRoute(
      path: '/expert-program',
      pageBuilder: (context, state) =>
          _fade(state, const ExpertProgramScreen()),
    ),
    GoRoute(
      path: '/expert-module/:index',
      pageBuilder: (context, state) => _fade(
        state,
        _ExpertModuleWrapper(index: int.parse(state.pathParameters['index']!)),
      ),
    ),
    GoRoute(
      path: '/expert-quiz',
      pageBuilder: (context, state) => _fade(state, const _ExpertQuizWrapper()),
    ),

    // ── STANDARD PROGRAM ───────────────────────────────────────────────────
    GoRoute(
      path: '/generate/:domain',
      pageBuilder: (context, state) => _fade(
        state,
        GenerationScreen(
          domainId: state.pathParameters['domain']!,
          objectif: state.extra as String?,
        ),
      ),
    ),
    GoRoute(
      path: '/program',
      pageBuilder: (context, state) => _fade(state, const ProgramScreen()),
    ),
    GoRoute(
      path: '/module/:index',
      pageBuilder: (context, state) => _fade(
        state,
        ModuleScreen(index: int.parse(state.pathParameters['index']!)),
      ),
    ),
    GoRoute(
      path: '/quiz',
      pageBuilder: (context, state) => _fade(state, const QuizScreen()),
    ),
    GoRoute(
      path: '/partquiz/:index',
      pageBuilder: (context, state) => _fade(
        state,
        PartQuizScreen(index: int.parse(state.pathParameters['index']!)),
      ),
    ),
    GoRoute(
      path: '/retention',
      pageBuilder: (context, state) =>
          _fade(state, const RetentionQuizScreen()),
    ),
    GoRoute(
      path: '/reminders',
      pageBuilder: (context, state) => _fade(state, const RemindersScreen()),
    ),
    GoRoute(
      path: '/progress',
      pageBuilder: (context, state) => _fade(state, const ProgressScreen()),
    ),
    GoRoute(
      path: '/final',
      pageBuilder: (context, state) => _fade(state, const FinalReportScreen()),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => _fade(state, const ProfileScreen()),
    ),
    GoRoute(
      path: '/notes',
      pageBuilder: (context, state) => _fade(state, const NotesScreen()),
    ),
  ],
  );
});

// ---------------------------------------------------------------------------
// Expert route wrappers (need Riverpod ref to inject program)
// ---------------------------------------------------------------------------

class _ExpertModuleWrapper extends ConsumerWidget {
  final int index;
  const _ExpertModuleWrapper({required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(expertProgramControllerProvider);
    return ModuleScreen(index: index, programOverride: program, isExpert: true);
  }
}

class _ExpertQuizWrapper extends ConsumerStatefulWidget {
  const _ExpertQuizWrapper();

  @override
  ConsumerState<_ExpertQuizWrapper> createState() => _ExpertQuizWrapperState();
}

class _ExpertQuizWrapperState extends ConsumerState<_ExpertQuizWrapper> {
  @override
  Widget build(BuildContext context) {
    final program = ref.watch(expertProgramControllerProvider);
    if (program == null) {
      return const Scaffold(
        body: Center(child: Text('Aucun programme expert.')),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Quiz final Expert 🎓',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: QuizRunner(
            questions: program.quiz,
            finishLabel: 'Terminer le quiz expert',
            onFinished: (score, total) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: Text(
                    score >= total * 0.7
                        ? '🏆 Maîtrise validée !'
                        : '📚 Continue à pratiquer',
                  ),
                  content: Text(
                    'Score : $score / $total\n${score >= total * 0.7 ? 'Tu démontres une compréhension experte.' : 'Reviens sur les chapitres et réessaie.'}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.pop();
                      },
                      child: const Text('Fermer'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared fade+slide transition
// ---------------------------------------------------------------------------

CustomTransitionPage _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondary, child) {
      // Incoming page: fade + slide up + a subtle zoom-in for depth.
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      // Outgoing page: drift back and fade slightly so layers feel stacked.
      final secondaryCurved = CurvedAnimation(
        parent: secondary,
        curve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.0).animate(secondaryCurved),
        child: SlideTransition(
          position: Tween(
            begin: Offset.zero,
            end: const Offset(0, -0.02),
          ).animate(secondaryCurved),
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curved),
              child: ScaleTransition(
                scale: Tween(begin: 0.98, end: 1.0).animate(curved),
                child: child,
              ),
            ),
          ),
        ),
      );
    },
  );
}
