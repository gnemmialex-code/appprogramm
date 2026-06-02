import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/custom_program/custom_program_screen.dart';
import '../../features/domain_selection/domain_selection_screen.dart';
import '../../features/feed/feed_screen.dart';
import '../../features/final_report/final_report_screen.dart';
import '../../features/generation/generation_screen.dart';
import '../../features/module/module_screen.dart';
import '../../features/program/program_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/quiz/part_quiz_screen.dart';
import '../../features/quiz/quiz_screen.dart';
import '../../features/quiz/retention_quiz_screen.dart';
import '../../features/reminders/reminders_screen.dart';

/// Central GoRouter configuration. A shared fade+slide transition is applied
/// to every push for a consistent, premium feel.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, _) => const DomainSelectionScreen()),
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
      path: '/generate/:domain',
      pageBuilder: (context, state) => _fade(
        state,
        GenerationScreen(domainId: state.pathParameters['domain']!),
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
  ],
);

CustomTransitionPage _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    transitionsBuilder: (context, animation, secondary, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
