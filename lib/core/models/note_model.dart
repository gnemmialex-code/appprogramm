library;

/// Where in the app a note was taken.
class NoteLocation {
  final String programDomain;
  final String moduleTitle;
  final int moduleIndex;
  final String? stepTitle; // null = module-level (intro or exercises)
  final String contextType; // 'intro' | 'step' | 'exercises' | 'expert'
  final bool isExpert;

  const NoteLocation({
    required this.programDomain,
    required this.moduleTitle,
    required this.moduleIndex,
    this.stepTitle,
    this.contextType = 'step',
    this.isExpert = false,
  });

  /// Human-readable path shown in the notes list.
  String get displayPath {
    final mode = isExpert ? '🎓 Expert · ' : '';
    final chap = 'Ch. ${moduleIndex + 1} · $moduleTitle';
    if (stepTitle != null && stepTitle!.isNotEmpty) {
      return '$mode$chap\n→ $stepTitle';
    }
    return '$mode$chap';
  }

  /// Short label for the note card header.
  String get shortLabel {
    if (stepTitle != null && stepTitle!.isNotEmpty) return stepTitle!;
    return contextType == 'intro' ? 'Introduction' : 'Exercices';
  }

  Map<String, dynamic> toMap() => {
    'domain': programDomain,
    'moduleTitle': moduleTitle,
    'moduleIndex': moduleIndex,
    'stepTitle': stepTitle,
    'contextType': contextType,
    'isExpert': isExpert,
  };

  factory NoteLocation.fromMap(Map<String, dynamic> m) => NoteLocation(
    programDomain: m['domain'] as String? ?? '',
    moduleTitle: m['moduleTitle'] as String? ?? '',
    moduleIndex: m['moduleIndex'] as int? ?? 0,
    stepTitle: m['stepTitle'] as String?,
    contextType: m['contextType'] as String? ?? 'step',
    isExpert: m['isExpert'] as bool? ?? false,
  );
}

class AppNote {
  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final NoteLocation location;

  const AppNote({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.location,
  });

  AppNote copyWith({String? content, DateTime? updatedAt}) => AppNote(
    id: id,
    content: content ?? this.content,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    location: location,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'content': content,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    'location': location.toMap(),
  };

  factory AppNote.fromMap(Map<String, dynamic> m) => AppNote(
    id: m['id'] as String,
    content: m['content'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      m['updatedAt'] as int? ?? m['createdAt'] as int,
    ),
    location: NoteLocation.fromMap(m['location'] as Map<String, dynamic>),
  );
}
