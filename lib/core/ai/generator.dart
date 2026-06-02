import 'dart:convert';

/// Mock "AI" content generator.
///
/// In a production app this would call a remote LLM. Here it deterministically
/// builds a rich, domain-aware program (several well-stocked chapters, each
/// with steps, exercises and its own mini-quiz, plus a final recap quiz) so the
/// whole app is fully functional offline. The output shape matches
/// `Program.fromJson`.
///
/// [domaine] is the chosen domain label, [niveau] is the user level (1..3).
/// [objectif] is an optional custom goal (used by the "Mon propre programme"
/// flow) that is woven into the generated content for extra precision.
String generateContent(String domaine, int niveau, {String? objectif}) {
  final d = domaine.trim();
  // [niveau] is kept for backward compatibility (and as the suggested starting
  // level) but every program now ships ALL 3 learning levels.
  final startLevel = niveau.clamp(1, 3);
  var f = _flavors[d] ?? _defaultFlavor(d);
  if (objectif != null && objectif.trim().isNotEmpty) {
    f = _Flavor(objectif.trim(), f.practice, f.win);
  }

  // 6 chapters spread over 3 levels (2 per level), intensity rising 1 → 3.
  final modules = [
    for (var i = 0; i < _chapters.length; i++)
      _buildModule(i, (i ~/ 2) + 1, d, f),
  ];

  final program = {
    'domain': d,
    'level': startLevel,
    'title': 'Programme $d',
    'subtitle': '3 niveaux d\'intensité • du facile à l\'avancé',
    'modules': modules,
    'parts': _buildParts(d, f),
    // Final recap quiz across the whole program.
    'quiz': _finalQuiz(d, f),
    'finalSummary':
        'Bravo ! Tu as gravi les 3 niveaux de ton programme « $d » : du facile '
            'à l\'avancé. Ton objectif — ${f.goal} — est désormais à portée de '
            'main. Ton point fort : la constance. Ta prochaine étape : '
            'transformer ces acquis en rituel quotidien et entretenir le '
            'niveau avancé. Garde une action simple par jour, célèbre chaque '
            'progrès, et reviens sur les niveaux au besoin.',
  };

  return jsonEncode(program);
}

/// Metadata for the 3 in-program learning levels (intensity rises 1 → 3).
/// (level number, title, subtitle, intensity adjective)
const List<(int, String, String, String)> _levelMeta = [
  (1, 'Niveau 1 · Facile', 'Facile à comprendre, en douceur', 'facile'),
  (2, 'Niveau 2 · Intermédiaire', 'On monte en intensité', 'intermédiaire'),
  (3, 'Niveau 3 · Avancé', 'Intensité maximale, vers la maîtrise', 'avancé'),
];

// ---------------------------------------------------------------------------
// Domain-specific flavour
// ---------------------------------------------------------------------------

class _Flavor {
  final String goal; // what the user is aiming for
  final String practice; // a concrete daily practice
  final String win; // what a small victory looks like
  const _Flavor(this.goal, this.practice, this.win);
}

_Flavor _defaultFlavor(String d) =>
    _Flavor('progresser en $d', 'une petite pratique quotidienne liée à $d',
        'un pas en avant concret');

const Map<String, _Flavor> _flavors = {
  'Psychologie': _Flavor('mieux te comprendre',
      'un temps d\'introspection guidée de 5 minutes', 'une prise de conscience'),
  'Anxiété': _Flavor('apaiser ton mental',
      'une respiration 4-7-8 répétée trois fois', 'un instant de calme retrouvé'),
  'Productivité': _Flavor('avancer sans t\'épuiser',
      'une session de focus de 25 minutes sans distraction', 'une tâche clé bouclée'),
  'Sport': _Flavor('bouger avec plaisir',
      'une séance de mobilité de 10 minutes', 'un corps plus énergique'),
  'Nutrition': _Flavor('manger en conscience',
      'un repas pris lentement, sans écran', 'un choix alimentaire aligné'),
  'Relations': _Flavor('créer des liens plus sains',
      'une conversation sincère initiée par toi', 'un échange authentique'),
  'Sommeil': _Flavor('retrouver des nuits réparatrices',
      'un rituel du soir sans écran 30 minutes avant le coucher', 'un réveil reposé'),
  'Confiance': _Flavor('oser être toi',
      'une action qui te sort un peu de ta zone de confort', 'une victoire sur le doute'),
};

// ---------------------------------------------------------------------------
// Chapters (6 well-stocked archetypes, woven with the chosen domain)
// ---------------------------------------------------------------------------

class _Chapter {
  final String title;
  final String summary;
  final String Function(String d, _Flavor f) content;
  const _Chapter(this.title, this.summary, this.content);
}

const List<_Chapter> _chapters = [
  _Chapter(
    'Comprendre les fondations',
    'Pose les bases et clarifie ton intention.',
    _c0,
  ),
  _Chapter(
    'Observer ton point de départ',
    'Fais le point, sans jugement, sur ta situation actuelle.',
    _c1,
  ),
  _Chapter(
    'Construire ton rituel',
    'Transforme la théorie en habitude quotidienne mesurable.',
    _c2,
  ),
  _Chapter(
    'Surmonter les obstacles',
    'Anticipe les blocages et apprends à rebondir vite.',
    _c3,
  ),
  _Chapter(
    'Approfondir et renforcer',
    'Consolide tes acquis et passe au niveau supérieur.',
    _c4,
  ),
  _Chapter(
    'Ancrer durablement',
    'Rends tes progrès automatiques et prépare la suite.',
    _c5,
  ),
];

String _c0(String d, _Flavor f) =>
    'Bienvenue dans ton parcours « $d ». Avant d\'agir, il faut comprendre. '
    'Ce chapitre pose les fondations : ce que recouvre $d, pourquoi cela '
    'compte pour toi, et l\'état d\'esprit qui fait la différence. '
    'Ton objectif global est clair : ${f.goal}. Retiens un principe — la '
    'régularité prime toujours sur l\'intensité.';

String _c1(String d, _Flavor f) =>
    'On ne peut améliorer que ce que l\'on observe. Dans ce chapitre, tu fais '
    'un état des lieux honnête de ta relation actuelle avec $d : tes forces, '
    'tes habitudes, tes déclencheurs. Pas de jugement, seulement de la '
    'lucidité. Cette photographie de départ te servira de repère pour mesurer '
    'tout le chemin parcouru.';

String _c2(String d, _Flavor f) =>
    'Les changements durables naissent de petites actions répétées. Tu vas '
    'mettre en place un rituel simple autour de $d : ${f.practice}. '
    'L\'idée n\'est pas d\'en faire beaucoup, mais d\'en faire un peu, '
    'chaque jour, à un moment fixe. Un rituel ancré demande peu de volonté : '
    'il devient automatique.';

String _c3(String d, _Flavor f) =>
    'Tout parcours rencontre des frictions : fatigue, imprévus, baisse de '
    'motivation. Ici tu apprends à reconnaître tes déclencheurs en $d et à '
    'réagir avec bienveillance plutôt qu\'avec culpabilité. Un écart n\'efface '
    'pas tes efforts — ce qui compte, c\'est de reprendre dès le lendemain.';

String _c4(String d, _Flavor f) =>
    'Tu as posé des bases solides en $d. Ce chapitre élargit ta pratique : tu '
    'augmentes progressivement l\'exigence, tu varies les approches et tu '
    'transformes ${f.win} ponctuel en résultat régulier. C\'est l\'étape où la '
    'compétence remplace l\'effort.';

String _c5(String d, _Flavor f) =>
    'Dernier chapitre : rendre tes progrès durables. Tu vas relier ta pratique '
    'de $d à ton identité (« je suis quelqu\'un qui… »), planifier les '
    'prochaines semaines et préparer ton plan personnalisé. Le but : que ${f.goal} '
    'ne soit plus un objectif, mais une évidence quotidienne.';

// ---------------------------------------------------------------------------
// Builders
// ---------------------------------------------------------------------------

Map<String, dynamic> _step(String title, String body, String type) =>
    {'title': title, 'body': body, 'type': type};

Map<String, dynamic> _exercise(String title, String instruction, String type) =>
    {'title': title, 'instruction': instruction, 'type': type};

Map<String, dynamic> _buildModule(int i, int level, String d, _Flavor f) {
  final ch = _chapters[i];
  final intensity = _levelMeta[level - 1].$4; // facile / intermédiaire / avancé

  // Steps grow with the level (intensity rises).
  final steps = <Map<String, dynamic>>[
    _step('Comprendre',
        'Lis attentivement « ${ch.title} » et garde un esprit ouvert.', 'text'),
    _step('Écoute guidée',
        'Une session audio de 3 minutes pour ancrer « ${ch.title} ».', 'audio'),
    _step('Réflexion',
        'Que t\'inspire « ${ch.title} » appliqué à $d ? Note ta première '
            'réaction, sans filtre.',
        'reflection'),
    _step('Mini-action',
        'Réalise maintenant ${f.practice}. Deux minutes suffisent pour lancer '
            'la dynamique.',
        'action'),
    if (level >= 2)
      _step('Récapitulatif',
          'Résume en une phrase ce que tu retiens. La répétition consolide la '
              'mémoire.',
          'text'),
    if (level >= 3)
      _step('Défi avancé',
          'Pousse l\'exercice plus loin et plus longtemps : sors de ta zone de '
              'confort sur « ${ch.title} ».',
          'action'),
  ];

  // Exercises also scale: 2 (facile) → 3 (intermédiaire) → 4 (avancé).
  final exercises = <Map<String, dynamic>>[
    _exercise('Journal express',
        'Écris 3 phrases sur ce que « ${ch.title} » change dans ta journée.',
        'reflection'),
    _exercise('Défi du jour',
        'Applique une idée de ce chapitre dans la vraie vie avant ce soir : '
            'vise ${f.win}.',
        'action'),
    if (level >= 2)
      _exercise('Ancrage audio',
          'Réécoute la session guidée et reste 1 minute en silence ensuite.',
          'audio'),
    if (level >= 3)
      _exercise('Mise en situation',
          'Reproduis « ${ch.title} » dans un contexte réel et exigeant, sans '
              'aide.',
          'action'),
  ];

  return {
    'id': 'm${i + 1}',
    'level': level,
    'title': 'Ch. ${i + 1} — ${ch.title}',
    'summary': ch.summary,
    'content': 'Niveau $intensity. ${ch.content(d, f)}',
    'steps': steps,
    'exercises': exercises,
    'quiz': _moduleQuiz(i, d, f),
  };
}

// Each chapter ships a 3-question mini-quiz (MCQ + true/false + swipe).
List<Map<String, dynamic>> _moduleQuiz(int i, String d, _Flavor f) {
  final mcq = _chapterMcq[i];
  return [
    {
      'type': 'mcq',
      'question': mcq.$1,
      'options': mcq.$2,
      'answerIndex': mcq.$3,
    },
    {
      'type': 'truefalse',
      'question': _chapterTrueFalse[i].$1,
      'answer': _chapterTrueFalse[i].$2,
    },
    {
      'type': 'swipe',
      'question': 'Glisse à droite : « ${_chapterSwipe[i].$1} »',
      'answer': _chapterSwipe[i].$2,
    },
  ];
}

const List<(String, List<String>, int)> _chapterMcq = [
  (
    'Quel principe guide tout progrès durable ?',
    [
      'La régularité plutôt que l\'intensité',
      'Tout réussir en une journée',
      'Attendre la motivation parfaite',
      'Se comparer aux autres',
    ],
    0,
  ),
  (
    'Pourquoi observer son point de départ ?',
    [
      'Pour se juger sévèrement',
      'Pour avoir un repère et mesurer ses progrès',
      'Ce n\'est pas utile',
      'Pour copier les autres',
    ],
    1,
  ),
  (
    'Qu\'est-ce qui rend un rituel efficace ?',
    [
      'Le faire à un moment fixe, chaque jour',
      'Le faire rarement mais très longtemps',
      'Changer de méthode chaque jour',
      'Attendre d\'en avoir envie',
    ],
    0,
  ),
  (
    'Face à un écart, la bonne réaction est de :',
    [
      'Tout abandonner',
      'Culpabiliser longuement',
      'Reprendre dès le lendemain sans drame',
      'Recommencer tout à zéro',
    ],
    2,
  ),
  (
    'Comment passer au niveau supérieur ?',
    [
      'En augmentant l\'exigence progressivement',
      'En forçant brutalement',
      'En ne changeant jamais rien',
      'En réduisant la fréquence',
    ],
    0,
  ),
  (
    'Qu\'est-ce qui ancre durablement une habitude ?',
    [
      'La relier à son identité',
      'La garder secrète',
      'La pratiquer une fois par mois',
      'Compter uniquement sur la volonté',
    ],
    0,
  ),
];

const List<(String, bool)> _chapterTrueFalse = [
  ('Comprendre le « pourquoi » renforce la motivation.', true),
  ('Faire un état des lieux honnête sert à se dévaloriser.', false),
  ('Un rituel ancré demande de moins en moins de volonté.', true),
  ('Un seul écart ruine tous les efforts accumulés.', false),
  ('Augmenter l\'exigence trop vite peut décourager.', true),
  ('Les habitudes durables reposent surtout sur la volonté.', false),
];

const List<(String, bool)> _chapterSwipe = [
  ('Je pose une intention claire avant d\'agir.', true),
  ('Mon point de départ ne mérite aucune attention.', false),
  ('Je pratique à heure fixe chaque jour.', true),
  ('Un écart signifie que j\'ai tout raté.', false),
  ('Je célèbre mes petites victoires.', true),
  ('Je compte uniquement sur ma motivation du moment.', false),
];

// ---------------------------------------------------------------------------
// Parts (groups of chapters) + their transversal quiz
// ---------------------------------------------------------------------------

/// Builds the 3 learning levels (each groups 2 chapters + a transversal quiz).
List<Map<String, dynamic>> _buildParts(String d, _Flavor f) {
  const ids = ['p1', 'p2', 'p3'];
  const chapterGroups = <List<int>>[
    [0, 1],
    [2, 3],
    [4, 5],
  ];
  return [
    for (var li = 0; li < chapterGroups.length; li++)
      <String, dynamic>{
        'id': ids[li],
        'level': _levelMeta[li].$1,
        'title': _levelMeta[li].$2,
        'subtitle': _levelMeta[li].$3,
        'intensity': _levelMeta[li].$4,
        'moduleIds': [for (final i in chapterGroups[li]) 'm${i + 1}'],
        'quiz': _partQuiz(chapterGroups[li], d, f),
      },
  ];
}

/// Transversal quiz reviewing the two chapters of a part.
List<Map<String, dynamic>> _partQuiz(List<int> chs, String d, _Flavor f) {
  final a = chs[0];
  final b = chs[1];
  final mcqA = _chapterMcq[a];
  final mcqB = _chapterMcq[b];
  return [
    {
      'type': 'mcq',
      'question': mcqA.$1,
      'options': mcqA.$2,
      'answerIndex': mcqA.$3,
    },
    {
      'type': 'mcq',
      'question': mcqB.$1,
      'options': mcqB.$2,
      'answerIndex': mcqB.$3,
    },
    {
      'type': 'truefalse',
      'question': _chapterTrueFalse[b].$1,
      'answer': _chapterTrueFalse[b].$2,
    },
    {
      'type': 'swipe',
      'question': 'Glisse à droite : « ${_chapterSwipe[a].$1} »',
      'answer': _chapterSwipe[a].$2,
    },
  ];
}

// ---------------------------------------------------------------------------
// Final questionnaire (comprehensive: covers every chapter & level)
// ---------------------------------------------------------------------------

/// A complete final questionnaire that reviews the WHOLE program: one MCQ per
/// chapter, several true/false and swipe cards drawn across the chapters, plus
/// a synthesis question tied to the user's goal. ~13 questions.
List<Map<String, dynamic>> _finalQuiz(String d, _Flavor f) {
  final q = <Map<String, dynamic>>[];

  // One MCQ per chapter → covers the entire program.
  for (final mcq in _chapterMcq) {
    q.add({
      'type': 'mcq',
      'question': mcq.$1,
      'options': mcq.$2,
      'answerIndex': mcq.$3,
    });
  }

  // A spread of true/false statements.
  for (final i in const [0, 2, 4]) {
    q.add({
      'type': 'truefalse',
      'question': _chapterTrueFalse[i].$1,
      'answer': _chapterTrueFalse[i].$2,
    });
  }

  // A spread of swipe cards.
  for (final i in const [1, 3, 5]) {
    q.add({
      'type': 'swipe',
      'question': 'Glisse à droite : « ${_chapterSwipe[i].$1} »',
      'answer': _chapterSwipe[i].$2,
    });
  }

  // Synthesis question tied to the domain / personal goal.
  q.add({
    'type': 'mcq',
    'question': 'Pour ancrer durablement « ${f.goal} », mieux vaut :',
    'options': [
      'La relier à ton identité et à un moment fixe',
      'Compter uniquement sur la motivation',
      'Tout faire d\'un seul coup',
      'Attendre le moment parfait',
    ],
    'answerIndex': 0,
  });

  return q;
}
