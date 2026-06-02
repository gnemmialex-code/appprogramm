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
    if (raw == null) return {'modules': <String>[], 'quizScore': 0, 'badges': <String>[]};
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

  Future<void> wipe() => _box.clear();
}
