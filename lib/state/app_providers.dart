import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/ai/generator.dart';
import '../core/models/content_models.dart';
import '../core/notifications/notification_service.dart';
import '../core/storage/app_storage.dart';

/// Injected in `main()` once Hive is open.
final appStorageProvider = Provider<AppStorage>((ref) {
  throw UnimplementedError('appStorageProvider must be overridden');
});

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService.instance,
);

// ---------------------------------------------------------------------------
// Program (generated content)
// ---------------------------------------------------------------------------

class ProgramController extends Notifier<Program?> {
  @override
  Program? build() {
    final stored = ref.read(appStorageProvider).programJson;
    if (stored == null) return null;
    return Program.fromJson(jsonDecode(stored) as Map<String, dynamic>);
  }

  /// Generates a brand-new program for [domain] and persists it.
  /// [objectif] lets the custom-program flow pass a precise learning goal.
  /// Resets progress so the new journey starts clean.
  Future<void> generate(String domain, {int level = 1, String? objectif}) async {
    final json = generateContent(domain, level, objectif: objectif);
    await ref.read(appStorageProvider).saveProgram(json);
    ref.read(progressControllerProvider.notifier).reset();
    state = Program.fromJson(jsonDecode(json) as Map<String, dynamic>);
    // Fresh, unfinished program → start the automatic "continue" reminder.
    ref.read(progressControllerProvider.notifier).syncAutoReminder();
    // Begin the spaced-repetition retention checks for this theme.
    ref.read(retentionControllerProvider.notifier).scheduleFirst();
  }

  Future<void> clear() async {
    await ref.read(appStorageProvider).clearProgram();
    ref.read(notificationServiceProvider).cancelContinueReminder();
    ref.read(retentionControllerProvider.notifier).clear();
    state = null;
  }
}

final programControllerProvider =
    NotifierProvider<ProgramController, Program?>(ProgramController.new);

// ---------------------------------------------------------------------------
// Progress (completed modules, quiz score, badges)
// ---------------------------------------------------------------------------

class ProgressState {
  final Set<String> completedModules;
  final int quizScore; // final recap quiz
  final int quizTotal;
  final Map<String, int> moduleScores; // moduleId -> correct answers
  final Map<String, int> partScores; // partId -> correct answers
  final Map<String, int> moduleTimes; // moduleId -> seconds spent
  final Set<String> badges;

  const ProgressState({
    this.completedModules = const {},
    this.quizScore = 0,
    this.quizTotal = 0,
    this.moduleScores = const {},
    this.partScores = const {},
    this.moduleTimes = const {},
    this.badges = const {},
  });

  ProgressState copyWith({
    Set<String>? completedModules,
    int? quizScore,
    int? quizTotal,
    Map<String, int>? moduleScores,
    Map<String, int>? partScores,
    Map<String, int>? moduleTimes,
    Set<String>? badges,
  }) =>
      ProgressState(
        completedModules: completedModules ?? this.completedModules,
        quizScore: quizScore ?? this.quizScore,
        quizTotal: quizTotal ?? this.quizTotal,
        moduleScores: moduleScores ?? this.moduleScores,
        partScores: partScores ?? this.partScores,
        moduleTimes: moduleTimes ?? this.moduleTimes,
        badges: badges ?? this.badges,
      );

  Map<String, dynamic> toMap() => {
        'modules': completedModules.toList(),
        'quizScore': quizScore,
        'quizTotal': quizTotal,
        'moduleScores': moduleScores,
        'partScores': partScores,
        'moduleTimes': moduleTimes,
        'badges': badges.toList(),
      };

  factory ProgressState.fromMap(Map<String, dynamic> m) => ProgressState(
        completedModules:
            (m['modules'] as List<dynamic>? ?? []).map((e) => e as String).toSet(),
        quizScore: m['quizScore'] as int? ?? 0,
        quizTotal: m['quizTotal'] as int? ?? 0,
        moduleScores: (m['moduleScores'] as Map<dynamic, dynamic>? ?? {})
            .map((k, v) => MapEntry(k as String, v as int)),
        partScores: (m['partScores'] as Map<dynamic, dynamic>? ?? {})
            .map((k, v) => MapEntry(k as String, v as int)),
        moduleTimes: (m['moduleTimes'] as Map<dynamic, dynamic>? ?? {})
            .map((k, v) => MapEntry(k as String, v as int)),
        badges:
            (m['badges'] as List<dynamic>? ?? []).map((e) => e as String).toSet(),
      );
}

class ProgressController extends Notifier<ProgressState> {
  @override
  ProgressState build() =>
      ProgressState.fromMap(ref.read(appStorageProvider).progress);

  void _persist() => ref.read(appStorageProvider).saveProgress(state.toMap());

  void completeModule(String id) {
    if (state.completedModules.contains(id)) return;
    final modules = {...state.completedModules, id};
    final badges = {...state.badges};
    if (modules.length == 1) badges.add('Premier pas');
    state = state.copyWith(completedModules: modules, badges: badges);
    _persist();
    syncAutoReminder();
  }

  /// Records how long (seconds) the user spent on a module — used to adapt
  /// later chapters toward subjects the user lingered on. Keeps the maximum
  /// seen (a module can be revisited).
  void recordModuleTime(String moduleId, int seconds) {
    if (seconds <= 0) return;
    final prev = state.moduleTimes[moduleId] ?? 0;
    if (seconds <= prev) return;
    state = state.copyWith(
      moduleTimes: {...state.moduleTimes, moduleId: seconds},
    );
    _persist();
  }

  /// Records a chapter's mini-quiz result.
  void recordModuleQuiz(String moduleId, int score, int total) {
    final scores = {...state.moduleScores, moduleId: score};
    final badges = {...state.badges};
    if (total > 0 && score == total) badges.add('Chapitre maîtrisé');
    state = state.copyWith(moduleScores: scores, badges: badges);
    _persist();
  }

  /// Records a part's transversal quiz result.
  void recordPartQuiz(String partId, int score, int total) {
    final scores = {...state.partScores, partId: score};
    final badges = {...state.badges};
    if (total > 0 && score >= (total * 0.75).ceil()) {
      badges.add('Partie validée');
    }
    state = state.copyWith(partScores: scores, badges: badges);
    _persist();
  }

  void recordQuiz(int score, int total) {
    final badges = {...state.badges};
    if (total > 0 && score == total) badges.add('Quiz parfait');
    if (score >= (total / 2).ceil()) badges.add('Quiz réussi');
    state = state.copyWith(quizScore: score, quizTotal: total, badges: badges);
    _persist();
  }

  void awardCompletion() {
    final badges = {...state.badges, 'Programme terminé'};
    state = state.copyWith(badges: badges);
    _persist();
  }

  /// Adds an arbitrary badge (used by retention checks, etc.).
  void awardBadge(String badge) {
    if (state.badges.contains(badge)) return;
    state = state.copyWith(badges: {...state.badges, badge});
    _persist();
  }

  void reset() {
    state = const ProgressState();
    _persist();
  }

  /// Auto-reminder: as long as the program isn't finished, keep a daily
  /// "continue" notification scheduled; cancel it once everything is done.
  void syncAutoReminder() {
    final program = ref.read(programControllerProvider);
    final notifs = ref.read(notificationServiceProvider);
    if (program == null || program.modules.isEmpty) {
      notifs.cancelContinueReminder();
      return;
    }
    final done = state.completedModules.length;
    if (done >= program.modules.length) {
      notifs.cancelContinueReminder();
    } else {
      final r = ref.read(reminderControllerProvider);
      notifs.scheduleContinueReminder(hour: r.autoHour, minute: r.autoMinute);
    }
  }
}

final progressControllerProvider =
    NotifierProvider<ProgressController, ProgressState>(ProgressController.new);

// ---------------------------------------------------------------------------
// Reminder settings
// ---------------------------------------------------------------------------

class ReminderState {
  final bool enabled;
  final int hour;
  final int minute;
  // Time used for the automatic "continue" reminder (program unfinished).
  final int autoHour;
  final int autoMinute;

  const ReminderState({
    this.enabled = false,
    this.hour = 9,
    this.minute = 0,
    this.autoHour = 19,
    this.autoMinute = 0,
  });

  ReminderState copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    int? autoHour,
    int? autoMinute,
  }) =>
      ReminderState(
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        autoHour: autoHour ?? this.autoHour,
        autoMinute: autoMinute ?? this.autoMinute,
      );

  Map<String, dynamic> toMap() => {
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
        'autoHour': autoHour,
        'autoMinute': autoMinute,
      };

  factory ReminderState.fromMap(Map<String, dynamic> m) => ReminderState(
        enabled: m['enabled'] as bool? ?? false,
        hour: m['hour'] as int? ?? 9,
        minute: m['minute'] as int? ?? 0,
        autoHour: m['autoHour'] as int? ?? 19,
        autoMinute: m['autoMinute'] as int? ?? 0,
      );
}

class ReminderController extends Notifier<ReminderState> {
  @override
  ReminderState build() =>
      ReminderState.fromMap(ref.read(appStorageProvider).reminder);

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await _apply();
  }

  Future<void> setTime(int hour, int minute) async {
    state = state.copyWith(hour: hour, minute: minute);
    await _apply();
  }

  /// Updates the time of the automatic "continue" reminder and re-syncs it.
  Future<void> setAutoTime(int hour, int minute) async {
    state = state.copyWith(autoHour: hour, autoMinute: minute);
    await ref.read(appStorageProvider).saveReminder(state.toMap());
    ref.read(progressControllerProvider.notifier).syncAutoReminder();
  }

  Future<void> _apply() async {
    await ref.read(appStorageProvider).saveReminder(state.toMap());
    final notifs = ref.read(notificationServiceProvider);
    if (state.enabled) {
      await notifs.requestPermissions();
      await notifs.scheduleDaily(state.hour, state.minute);
    } else {
      await notifs.cancel();
    }
  }
}

final reminderControllerProvider =
    NotifierProvider<ReminderController, ReminderState>(ReminderController.new);

// ---------------------------------------------------------------------------
// Retention checks (spaced repetition)
// ---------------------------------------------------------------------------

class RetentionState {
  final int nextDueMillis; // when the next retention check becomes due
  final int lastCheckedMillis;
  final int lastScore;
  final int lastTotal;
  final int checks; // how many retention checks completed
  final int announcedDueMillis; // last due event we already auto-opened

  const RetentionState({
    this.nextDueMillis = 0,
    this.lastCheckedMillis = 0,
    this.lastScore = 0,
    this.lastTotal = 0,
    this.checks = 0,
    this.announcedDueMillis = 0,
  });

  bool get isDue =>
      nextDueMillis > 0 &&
      DateTime.now().millisecondsSinceEpoch >= nextDueMillis;

  /// Due and not yet auto-opened for this particular due event.
  bool get shouldAnnounce => isDue && announcedDueMillis != nextDueMillis;

  RetentionState copyWith({
    int? nextDueMillis,
    int? lastCheckedMillis,
    int? lastScore,
    int? lastTotal,
    int? checks,
    int? announcedDueMillis,
  }) =>
      RetentionState(
        nextDueMillis: nextDueMillis ?? this.nextDueMillis,
        lastCheckedMillis: lastCheckedMillis ?? this.lastCheckedMillis,
        lastScore: lastScore ?? this.lastScore,
        lastTotal: lastTotal ?? this.lastTotal,
        checks: checks ?? this.checks,
        announcedDueMillis: announcedDueMillis ?? this.announcedDueMillis,
      );

  Map<String, dynamic> toMap() => {
        'nextDueMillis': nextDueMillis,
        'lastCheckedMillis': lastCheckedMillis,
        'lastScore': lastScore,
        'lastTotal': lastTotal,
        'checks': checks,
        'announcedDueMillis': announcedDueMillis,
      };

  factory RetentionState.fromMap(Map<String, dynamic> m) => RetentionState(
        nextDueMillis: m['nextDueMillis'] as int? ?? 0,
        lastCheckedMillis: m['lastCheckedMillis'] as int? ?? 0,
        lastScore: m['lastScore'] as int? ?? 0,
        lastTotal: m['lastTotal'] as int? ?? 0,
        checks: m['checks'] as int? ?? 0,
        announcedDueMillis: m['announcedDueMillis'] as int? ?? 0,
      );
}

class RetentionController extends Notifier<RetentionState> {
  final _rng = Random();

  @override
  RetentionState build() =>
      RetentionState.fromMap(ref.read(appStorageProvider).retention);

  void _persist() => ref.read(appStorageProvider).saveRetention(state.toMap());

  /// First check after a program is created. Demo-friendly: becomes due within
  /// a short window so the priority behaviour is visible. In production you
  /// would use the same hour/day windows as [scheduleNext].
  void scheduleFirst() {
    final due = DateTime.now()
        .add(Duration(seconds: 15 + _rng.nextInt(20)))
        .millisecondsSinceEpoch;
    state = RetentionState(nextDueMillis: due);
    _persist();
    _scheduleNotification();
  }

  /// Picks the next due time at a RANDOM period — mostly daily (18–30 h), and
  /// roughly once in four a weekly (5–8 days) deeper check.
  void scheduleNext() {
    final weekly = _rng.nextInt(4) == 0;
    final gap = weekly
        ? Duration(days: 5 + _rng.nextInt(4), hours: _rng.nextInt(24))
        : Duration(hours: 18 + _rng.nextInt(13), minutes: _rng.nextInt(60));
    state = state.copyWith(
      nextDueMillis: DateTime.now().add(gap).millisecondsSinceEpoch,
    );
    _persist();
    _scheduleNotification();
  }

  void _scheduleNotification() {
    // Random hour so the nudge time varies day to day.
    ref
        .read(notificationServiceProvider)
        .scheduleRetention(hour: 9 + _rng.nextInt(12));
  }

  /// Marks the current due event as already auto-opened (avoids re-opening it
  /// every few seconds until it's completed).
  void markAnnounced() {
    state = state.copyWith(announcedDueMillis: state.nextDueMillis);
    _persist();
  }

  /// Records a completed retention check and schedules the next one.
  void record(int score, int total) {
    state = state.copyWith(
      lastCheckedMillis: DateTime.now().millisecondsSinceEpoch,
      lastScore: score,
      lastTotal: total,
      checks: state.checks + 1,
    );
    _persist();
    if (total > 0 && score >= (total * 0.8).ceil()) {
      ref.read(progressControllerProvider.notifier).awardBadge('Mémoire entretenue');
    }
    scheduleNext();
  }

  void clear() {
    state = const RetentionState();
    _persist();
    ref.read(notificationServiceProvider).cancelRetention();
  }
}

final retentionControllerProvider =
    NotifierProvider<RetentionController, RetentionState>(
        RetentionController.new);
