import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Thin wrapper around a single Hive box used for all local persistence.
///
/// We intentionally store plain JSON-encodable maps instead of generating
/// typed adapters — this keeps the project free of build_runner codegen while
/// remaining fully functional.
class AppStorage {
  AppStorage._(this._box);

  static const _boxName = 'lumina_box';
  final Box _box;

  static Future<AppStorage> open() async {
    await Hive.initFlutter();
    final box = await Hive.openBox(_boxName);
    return AppStorage._(box);
  }

  // --- Current program -------------------------------------------------------
  String? get programJson => _box.get('program') as String?;
  Future<void> saveProgram(String json) => _box.put('program', json);
  Future<void> clearProgram() => _box.delete('program');

  // --- Progress (completed module ids, quiz score, badges) -------------------
  Map<String, dynamic> get progress {
    final raw = _box.get('progress') as String?;
    if (raw == null) {
      return {'modules': <String>[], 'quizScore': 0, 'badges': <String>[]};
    }
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveProgress(Map<String, dynamic> data) =>
      _box.put('progress', jsonEncode(data));

  // --- Reminder settings -----------------------------------------------------
  Map<String, dynamic> get reminder {
    final raw = _box.get('reminder') as String?;
    if (raw == null) return {'enabled': false, 'hour': 9, 'minute': 0};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveReminder(Map<String, dynamic> data) =>
      _box.put('reminder', jsonEncode(data));

  // --- Retention checks (spaced repetition) ----------------------------------
  Map<String, dynamic> get retention {
    final raw = _box.get('retention') as String?;
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveRetention(Map<String, dynamic> data) =>
      _box.put('retention', jsonEncode(data));

  // --- Notes -----------------------------------------------------------------
  /// All notes stored as a JSON list of note maps.
  List<Map<String, dynamic>> get notes {
    final raw = _box.get('notes') as String?;
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<void> saveNotes(List<Map<String, dynamic>> data) =>
      _box.put('notes', jsonEncode(data));

  // --- Expert program --------------------------------------------------------
  String? get expertProgramJson => _box.get('expertProgram') as String?;
  Future<void> saveExpertProgram(String json) =>
      _box.put('expertProgram', json);
  Future<void> clearExpertProgram() => _box.delete('expertProgram');

  // --- Usage analytics (session open timestamps) ----------------------------
  List<int> get sessionTimestamps {
    final raw = _box.get('sessions') as String?;
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).map((e) => e as int).toList();
  }

  /// Appends [ts] and keeps the last 90 entries (~30 days × 3 opens/day).
  Future<void> addSessionTimestamp(int ts) async {
    var list = sessionTimestamps..add(ts);
    if (list.length > 90) list = list.sublist(list.length - 90);
    await _box.put('sessions', jsonEncode(list));
  }

  bool get smartReminderEnabled =>
      _box.get('smartReminderEnabled') as bool? ?? false;
  Future<void> setSmartReminderEnabled(bool v) =>
      _box.put('smartReminderEnabled', v);

  // Whether we've ever auto-enabled the smart reminder (to avoid re-enabling
  // after the user explicitly turns it off).
  bool get smartReminderAutoEnabled =>
      _box.get('smartReminderAutoEnabled') as bool? ?? false;
  Future<void> markSmartReminderAutoEnabled() =>
      _box.put('smartReminderAutoEnabled', true);

  // --- Daily availability (minutes per day, index 0 = Monday) --------------
  List<int> get availabilityPerDay {
    final raw = _box.get('availability') as String?;
    if (raw == null) return [15, 15, 15, 15, 15, 25, 25];
    return (jsonDecode(raw) as List<dynamic>).map((e) => e as int).toList();
  }

  Future<void> saveAvailabilityPerDay(List<int> data) =>
      _box.put('availability', jsonEncode(data));

  // --- User profile ----------------------------------------------------------
  Map<String, dynamic> get userProfile {
    final raw = _box.get('userProfile') as String?;
    if (raw == null) return {'pseudo': '', 'email': ''};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveUserProfile(Map<String, dynamic> data) =>
      _box.put('userProfile', jsonEncode(data));

  // --- Appearance (dark mode) ------------------------------------------------
  bool get darkMode => _box.get('darkMode') as bool? ?? false;
  Future<void> setDarkMode(bool v) => _box.put('darkMode', v);

  // --- Onboarding ------------------------------------------------------------
  /// Whether the first-launch questionnaire + personality recap has been done.
  bool get onboardingComplete =>
      _box.get('onboardingComplete') as bool? ?? false;
  Future<void> setOnboardingComplete(bool v) =>
      _box.put('onboardingComplete', v);

  // --- Preferences (timer + newsletter rhythm) -------------------------------
  /// Whether a countdown timer is shown on every chapter for a sense of pace.
  bool get chapterTimerEnabled =>
      _box.get('chapterTimer') as bool? ?? false;
  Future<void> setChapterTimerEnabled(bool v) =>
      _box.put('chapterTimer', v);

  /// Personalised newsletter rhythm: 'daily', 'weekly' (default) or 'off'.
  String get newsletterFrequency =>
      _box.get('newsletterFreq') as String? ?? 'weekly';
  Future<void> setNewsletterFrequency(String v) =>
      _box.put('newsletterFreq', v);

  Future<void> wipe() => _box.clear();
}
