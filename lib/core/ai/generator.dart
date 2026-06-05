import 'dart:convert';

// ---------------------------------------------------------------------------
// Program tier — adapts depth to the user's daily available time
// ---------------------------------------------------------------------------

enum ProgramTier { express, rapide, standard, complet, intensif }

ProgramTier tierFromMinutes(int minutes) {
  if (minutes <= 7) return ProgramTier.express;
  if (minutes <= 12) return ProgramTier.rapide;
  if (minutes <= 22) return ProgramTier.standard;
  if (minutes <= 35) return ProgramTier.complet;
  return ProgramTier.intensif;
}

/// Human-readable label + emoji for a tier.
String tierLabel(ProgramTier t) => switch (t) {
  ProgramTier.express => '⚡ Express',
  ProgramTier.rapide => '🎯 Rapide',
  ProgramTier.standard => '📚 Standard',
  ProgramTier.complet => '🔥 Complet',
  ProgramTier.intensif => '🚀 Intensif',
};

/// Estimated minutes per chapter for a tier.
int tierMinutesPerChapter(ProgramTier t) => switch (t) {
  ProgramTier.express => 5,
  ProgramTier.rapide => 10,
  ProgramTier.standard => 18,
  ProgramTier.complet => 28,
  ProgramTier.intensif => 40,
};

// Step indices per tier (12 steps total: 0-11).
// 0=Essentiel, 1=Fait, 2=Ce que ça change, 3=Et toi, 4=Action(timer),
// 5=Astuce, 6=Défi, 7=Un cran+, 8=Ancrage, 9=Point clé, 10=Schéma, 11=+loin
const Map<ProgramTier, List<int>> _kStepIndices = {
  ProgramTier.express: [0, 4, 9],
  ProgramTier.rapide: [0, 1, 4, 5, 9],
  ProgramTier.standard: [0, 1, 2, 3, 4, 5, 6, 9],
  ProgramTier.complet: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
  ProgramTier.intensif: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
};

// Number of exercises included per tier (out of 6 available).
const Map<ProgramTier, int> _kExerciseCount = {
  ProgramTier.express: 2,
  ProgramTier.rapide: 3,
  ProgramTier.standard: 4,
  ProgramTier.complet: 5,
  ProgramTier.intensif: 6,
};

// ---------------------------------------------------------------------------
// Public chapter preview data (used by the domain detail screen)
// ---------------------------------------------------------------------------

typedef ChapterPreview = ({String title, String summary, int level});

/// All 12 chapters exposed for preview — no generation needed.
const List<ChapterPreview> kProgramChapters = [
  (
    title: 'Comprendre les fondations',
    summary: 'Pose les bases et clarifie ton intention.',
    level: 1,
  ),
  (
    title: 'Observer ton point de départ',
    summary: 'Fais le point, sans jugement, sur ta situation actuelle.',
    level: 1,
  ),
  (
    title: 'Construire ton premier rituel',
    summary: 'Transforme la théorie en habitude quotidienne mesurable.',
    level: 1,
  ),
  (
    title: 'Célébrer les petites victoires',
    summary: 'Reconnais tes progrès pour maintenir l\'élan.',
    level: 1,
  ),
  (
    title: 'Surmonter les obstacles',
    summary: 'Anticipe les blocages et apprends à rebondir vite.',
    level: 2,
  ),
  (
    title: 'Approfondir la pratique',
    summary: 'Élargis ta compréhension et varie les approches.',
    level: 2,
  ),
  (
    title: 'Développer ta régularité',
    summary: 'Transforme l\'effort en automatisme durable.',
    level: 2,
  ),
  (
    title: 'Mesurer tes progrès',
    summary: 'Utilise des indicateurs concrets pour rester motivé.',
    level: 2,
  ),
  (
    title: 'Élever le niveau d\'exigence',
    summary: 'Augmente progressivement la difficulté pour grandir.',
    level: 3,
  ),
  (
    title: 'Optimiser ta stratégie',
    summary: 'Affine ta méthode pour un impact maximal.',
    level: 3,
  ),
  (
    title: 'Ancrer durablement',
    summary: 'Rends tes progrès automatiques et prépare la suite.',
    level: 3,
  ),
  (
    title: 'Devenir expert et autonome',
    summary: 'Intègre ce domaine à ton identité et transmets ce que tu sais.',
    level: 3,
  ),
];

/// Mock "AI" content generator.
///
/// Builds a dense, domain-aware program: 12 chapters spread over 3 levels
/// (4 per level), each fully loaded with 8 steps, 6 exercises and a 3-question
/// mini-quiz — regardless of the chosen difficulty. The output shape matches
/// `Program.fromJson`.
///
/// [domaine] is the chosen domain label, [niveau] is the user level (1..3).
/// [objectif] is an optional custom goal woven into the content.
String generateContent(
  String domaine,
  int niveau, {
  String? objectif,
  int avgMinutes = 20,
}) {
  final d = domaine.trim();
  final startLevel = niveau.clamp(1, 3);
  var f = _flavors[d] ?? _defaultFlavor(d);
  if (objectif != null && objectif.trim().isNotEmpty) {
    f = _Flavor(objectif.trim(), f.practice, f.win);
  }

  final tier = tierFromMinutes(avgMinutes);

  // 12 chapters: 4 per level (levels 1→3).
  final modules = [
    for (var i = 0; i < _chapters.length; i++)
      _buildModule(i, (i ~/ 4) + 1, d, f, tier: tier),
  ];

  final program = {
    'domain': d,
    'level': startLevel,
    'title': 'Programme $d',
    'subtitle':
        '${tierLabel(tier)} · ~${tierMinutesPerChapter(tier)} min/chapitre · 12 chapitres',
    'modules': modules,
    'parts': _buildParts(d, f),
    'quiz': _finalQuiz(d, f),
    'detailQuiz': _detailQuiz(),
    'finalSummary':
        'Bravo ! Tu as parcouru les 12 chapitres de ton programme « $d » — '
        'du niveau facile jusqu\'à l\'expert. Ton objectif — ${f.goal} — '
        'n\'est plus un horizon lointain : tu l\'as intégré dans ta pratique '
        'quotidienne. Ce programme t\'a donné les outils, la régularité et '
        'la profondeur pour faire de $d une partie durable de ta vie. '
        'Continue une action simple par jour, célèbre chaque progrès, '
        'et reviens sur les chapitres au besoin.',
  };

  return jsonEncode(program);
}

// ---------------------------------------------------------------------------
// Level metadata  (3 levels × 4 chapters each = 12 total)
// ---------------------------------------------------------------------------

const List<(int, String, String, String)> _levelMeta = [
  (1, 'Niveau 1 · Facile', 'Les bases solides, en douceur', 'facile'),
  (2, 'Niveau 2 · Intermédiaire', 'On monte en intensité', 'intermédiaire'),
  (3, 'Niveau 3 · Expert', 'Maîtrise et autonomie complètes', 'expert'),
];

// ---------------------------------------------------------------------------
// Domain flavours
// ---------------------------------------------------------------------------

class _Flavor {
  final String goal;
  final String practice;
  final String win;
  const _Flavor(this.goal, this.practice, this.win);
}

_Flavor _defaultFlavor(String d) => _Flavor(
  'progresser en $d',
  'une petite pratique quotidienne liée à $d',
  'un pas en avant concret',
);

const Map<String, _Flavor> _flavors = {
  'Psychologie': _Flavor(
    'mieux te comprendre',
    'un temps d\'introspection guidée de 5 minutes',
    'une prise de conscience',
  ),
  'Anxiété': _Flavor(
    'apaiser ton mental',
    'une respiration 4-7-8 répétée trois fois',
    'un instant de calme retrouvé',
  ),
  'Productivité': _Flavor(
    'avancer sans t\'épuiser',
    'une session de focus de 25 minutes sans distraction',
    'une tâche clé bouclée',
  ),
  'Sport': _Flavor(
    'bouger avec plaisir',
    'une séance de mobilité de 10 minutes',
    'un corps plus énergique',
  ),
  'Nutrition': _Flavor(
    'manger en conscience',
    'un repas pris lentement, sans écran',
    'un choix alimentaire aligné',
  ),
  'Relations': _Flavor(
    'créer des liens plus sains',
    'une conversation sincère initiée par toi',
    'un échange authentique',
  ),
  'Sommeil': _Flavor(
    'retrouver des nuits réparatrices',
    'un rituel du soir sans écran 30 minutes avant le coucher',
    'un réveil reposé',
  ),
  'Confiance': _Flavor(
    'oser être toi',
    'une action qui te sort un peu de ta zone de confort',
    'une victoire sur le doute',
  ),
};

// ---------------------------------------------------------------------------
// 12 Chapter archetypes
// ---------------------------------------------------------------------------

class _Chapter {
  final String title;
  final String summary;
  final String Function(String d, _Flavor f) content;
  const _Chapter(this.title, this.summary, this.content);
}

const List<_Chapter> _chapters = [
  // --- Level 1 : Facile (Ch 1–4) -----------------------------------------
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
    'Construire ton premier rituel',
    'Transforme la théorie en habitude quotidienne mesurable.',
    _c2,
  ),
  _Chapter(
    'Célébrer les petites victoires',
    'Reconnais tes progrès pour maintenir l\'élan.',
    _c3,
  ),
  // --- Level 2 : Intermédiaire (Ch 5–8) ------------------------------------
  _Chapter(
    'Surmonter les obstacles',
    'Anticipe les blocages et apprends à rebondir vite.',
    _c4,
  ),
  _Chapter(
    'Approfondir la pratique',
    'Élargis ta compréhension et varie les approches.',
    _c5,
  ),
  _Chapter(
    'Développer ta régularité',
    'Transforme l\'effort en automatisme durable.',
    _c6,
  ),
  _Chapter(
    'Mesurer tes progrès',
    'Utilise des indicateurs concrets pour rester motivé.',
    _c7,
  ),
  // --- Level 3 : Expert (Ch 9–12) ------------------------------------------
  _Chapter(
    'Élever le niveau d\'exigence',
    'Augmente progressivement la difficulté pour grandir.',
    _c8,
  ),
  _Chapter(
    'Optimiser ta stratégie',
    'Affine ta méthode pour un impact maximal.',
    _c9,
  ),
  _Chapter(
    'Ancrer durablement',
    'Rends tes progrès automatiques et prépare la suite.',
    _c10,
  ),
  _Chapter(
    'Devenir expert et autonome',
    'Intègre ce domaine à ton identité et transmets ce que tu sais.',
    _c11,
  ),
];

// --- Content functions (rich, multi-sentence, domain-aware) ----------------

String _c0(String d, _Flavor f) =>
    'Bienvenue dans ton parcours « $d ». Avant d\'agir, il faut comprendre. '
    'Ce premier chapitre pose les fondations : ce que recouvre $d, pourquoi '
    'cela compte pour toi, et l\'état d\'esprit qui fait toute la différence. '
    'Ton objectif global est clair : ${f.goal}. Retiens un principe essentiel — '
    'la régularité prime toujours sur l\'intensité. Une pratique modeste mais '
    'constante surpasse n\'importe quel élan ponctuel. Dès maintenant, '
    'définis ce que $d signifie pour toi en une phrase courte et concrète.';

String _c1(String d, _Flavor f) =>
    'On ne peut améliorer que ce que l\'on observe. Dans ce chapitre, tu fais '
    'un état des lieux honnête de ta relation actuelle avec $d : tes forces, '
    'tes habitudes, tes déclencheurs et tes angles morts. Pas de jugement, '
    'seulement de la lucidité. Cette photographie de départ te servira de '
    'repère pour mesurer tout le chemin parcouru. Plus tu seras précis dans '
    'cet inventaire, plus tes actions ciblées seront efficaces. Prends le '
    'temps d\'être honnête — c\'est un cadeau que tu te fais à toi-même.';

String _c2(String d, _Flavor f) =>
    'Les changements durables naissent de petites actions répétées, pas de '
    'grands élans ponctuels. Tu vas mettre en place un rituel simple autour '
    'de $d : ${f.practice}. L\'idée n\'est pas d\'en faire beaucoup, mais '
    'd\'en faire un peu, chaque jour, à un moment fixe. Un rituel ancré '
    'demande de moins en moins de volonté : il devient automatique, comme '
    'se brosser les dents. Commence avec 5 minutes, c\'est suffisant pour '
    'installer la dynamique. Ce qui compte n\'est pas la durée mais la '
    'régularité.';

String _c3(String d, _Flavor f) =>
    'Le progrès n\'est pas visible chaque jour, mais il est réel. '
    'Apprendre à reconnaître et célébrer ${f.win} — même modeste — '
    'est une compétence en soi. Notre cerveau est câblé pour retenir '
    'les échecs et minimiser les succès : il faut activement contrebalancer '
    'ce biais. Un journal de victoires, une étoile sur un calendrier, '
    'ou simplement un moment de gratitude envers toi-même : choisis le '
    'rituel de célébration qui te ressemble. Célébrer renforce la confiance '
    'et te donne l\'énergie pour la prochaine étape.';

String _c4(String d, _Flavor f) =>
    'Tout parcours rencontre des frictions : fatigue, imprévus, baisse de '
    'motivation. Ce n\'est pas un signe d\'échec — c\'est la preuve que tu '
    'vises quelque chose qui compte. Ici tu apprends à reconnaître tes '
    'déclencheurs en $d et à réagir avec bienveillance plutôt qu\'avec '
    'culpabilité. Un écart n\'efface pas tes efforts accumulés — ce qui '
    'compte, c\'est de reprendre dès le lendemain, sans drame. Planifie '
    'd\'avance tes "plans B" : si tu rates le matin, tu pratiques le soir. '
    'La résilience se prépare avant que le problème survienne.';

String _c5(String d, _Flavor f) =>
    'Une fois la base installée, il est temps d\'élargir ta pratique de $d. '
    'Approfondir ne signifie pas faire plus — cela signifie faire mieux : '
    'varier les angles, questionner ce qui fonctionne vraiment, et explorer '
    'des approches que tu n\'as pas encore essayées. Dans ce chapitre, tu '
    'vas identifier deux ou trois leviers sous-exploités et les intégrer à '
    'ta routine existante. La diversité dans la pratique prévient la '
    'stagnation et maintient la curiosité — carburant indispensable à la '
    'progression sur le long terme.';

String _c6(String d, _Flavor f) =>
    'La régularité n\'est pas une question de discipline — c\'est une '
    'question de systèmes. Dans ce chapitre, tu vas mettre en place des '
    'déclencheurs environnementaux qui rendent ta pratique de $d presque '
    'inévitable. Un objet à portée de main, un rappel visuel, un horaire '
    'bloqué dans l\'agenda : ton environnement travaille pour toi ou contre '
    'toi. Tu apprendras aussi à gérer les "jours sans" sans tout abandonner, '
    'et à distinguer la régularité productive de l\'acharnement contre-productif.';

String _c7(String d, _Flavor f) =>
    'Ce qui ne se mesure pas ne s\'améliore pas — mais ce qui est mal '
    'mesuré décourage. Dans ce chapitre, tu vas choisir 2 ou 3 indicateurs '
    'simples pour suivre tes progrès en $d. Pas de tableaux complexes : '
    'une note sur 10, un nombre de jours consécutifs, ou la qualité '
    'subjective de ${f.win}. L\'objectif est de créer une boucle de '
    'rétroaction rapide qui t\'indique si tu avances dans la bonne '
    'direction. Un bon indicateur te motive ; un mauvais indicateur te '
    'paralyse. Choisis avec soin.';

String _c8(String d, _Flavor f) =>
    'Tu as posé des bases solides en $d. Il est temps d\'élever le niveau. '
    'Ce chapitre t\'invite à augmenter progressivement l\'exigence — plus '
    'de durée, plus d\'intensité, ou plus de complexité — sans brûler les '
    'étapes. Le principe de surcharge progressive s\'applique aussi bien '
    'au sport qu\'à l\'apprentissage intellectuel ou émotionnel. Tu vas '
    'identifier ton "seuil d\'inconfort productif" : la zone juste assez '
    'difficile pour progresser, sans être assez difficile pour te décourager. '
    'C\'est là que la croissance se produit.';

String _c9(String d, _Flavor f) =>
    'À ce stade, tu as de l\'expérience en $d. Il est temps d\'affiner ta '
    'méthode pour maximiser le retour sur chaque effort investi. Dans ce '
    'chapitre, tu vas analyser ce qui fonctionne vraiment pour toi — pas '
    'ce qui est supposé fonctionner pour tout le monde. Tu vas supprimer '
    'le superflu, renforcer l\'essentiel, et personnaliser ta pratique '
    'jusqu\'à ce qu\'elle soit aussi efficace qu\'agréable. Une stratégie '
    'optimisée fait que ${f.goal} devient moins un effort et davantage '
    'une expression naturelle de qui tu es.';

String _c10(String d, _Flavor f) =>
    'Dernier palier avant l\'autonomie : rendre tes progrès irréversibles. '
    'Tu vas relier ta pratique de $d à ton identité (« je suis quelqu\'un '
    'qui… ») et planifier les prochaines semaines avec précision. Le but '
    'de ce chapitre est que ${f.goal} ne soit plus un objectif, mais une '
    'évidence quotidienne — quelque chose que tu fais parce que c\'est '
    'qui tu es, pas juste parce que tu t\'y es engagé. Les habitudes '
    'identitaires sont les plus solides : elles résistent à la fatigue, '
    'aux imprévus et au passage du temps.';

String _c11(String d, _Flavor f) =>
    'Tu es arrivé au dernier chapitre. Ce n\'est pas une fin — c\'est '
    'le début de l\'autonomie complète. Dans ce chapitre, tu vas consolider '
    'l\'ensemble du parcours en $d, identifier ce que tu peux transmettre '
    'à d\'autres (enseigner est la meilleure façon d\'apprendre), et '
    'concevoir ta propre "version avancée" du programme pour les prochains '
    'mois. Un expert n\'a plus besoin de suivre un programme extérieur : '
    'il crée le sien. Ta pratique de $d est maintenant suffisamment ancrée '
    'pour que tu en sois toi-même le meilleur guide.';

// ---------------------------------------------------------------------------
// Module builder — 8 steps + 6 exercises for EVERY chapter
// ---------------------------------------------------------------------------

Map<String, dynamic> _step(
  String title,
  String body,
  String type, {
  String? qText,
  List<String>? qOptions,
  int qAnswer = -1,
}) {
  final m = <String, dynamic>{'title': title, 'body': body, 'type': type};
  if (qText != null && qOptions != null) {
    m['question'] = {
      'question': qText,
      'options': qOptions,
      'answerIndex': qAnswer,
    };
  }
  return m;
}

Map<String, dynamic> _exercise(String title, String instruction, String type) =>
    {'title': title, 'instruction': instruction, 'type': type};

Map<String, dynamic> _buildModule(
  int i,
  int level,
  String d,
  _Flavor f, {
  ProgramTier tier = ProgramTier.standard,
}) {
  final ch = _chapters[i];
  final intensity = _levelMeta[level - 1].$4;

  // 12 steps — 1 sentence each + inline quickQuestion.
  final steps = <Map<String, dynamic>>[
    // 0 — text · Accroche
    _step(
      'L\'essentiel',
      '« ${ch.title} » dans $d : une idée simple qui change tout.',
      'text',
      qText: 'Tu connais déjà ce sujet ?',
      qOptions: ['Un peu', 'Pas du tout'],
    ),
    // 1 — fact · Fait surprenant
    _step(
      'Le savais-tu ?',
      'Les pratiquants de « ${ch.title} » progressent 3× plus vite grâce à la plasticité cérébrale.',
      'fact',
      qText: 'Ce fait te surprend ?',
      qOptions: ['Oui, vraiment !', 'Je le savais déjà'],
    ),
    // 2 — text · Ce que ça change
    _step(
      'Ce que ça change',
      'Sans « ${ch.title} », on reste bloqué au même niveau indéfiniment dans $d.',
      'text',
      qText: 'Tu as déjà ressenti ce blocage ?',
      qOptions: ['Oui, plusieurs fois', 'Pas vraiment'],
    ),
    // 3 — reflection · Introspection
    _step(
      'Et toi ?',
      'Comment « ${ch.title} » se manifeste dans ta pratique de $d aujourd\'hui ?',
      'reflection',
      qText: 'As-tu réfléchi à ça récemment ?',
      qOptions: ['Oui, souvent', 'Rarement'],
    ),
    // 4 — action · Mini-action (TIMER AUTO)
    _step(
      'Mini-action maintenant',
      'Lance le timer et fais-le : ${f.practice}.',
      'action',
      qText: 'Tu es prêt ?',
      qOptions: ['À fond ! 🔥', 'J\'y vais doucement'],
    ),
    // 5 — tip · Astuce de pro
    _step(
      'Astuce de pro',
      'Associe ${f.practice} à quelque chose que tu fais déjà — les connexions s\'ancrent 3× plus vite.',
      'tip',
      qText: 'Tu as déjà une habitude à laquelle l\'associer ?',
      qOptions: ['Oui, j\'en ai une', 'Je vais en trouver une'],
    ),
    // 6 — challenge · Défi 24h
    _step(
      'Défi du chapitre',
      'Dans les 24h, applique « ${ch.title} » dans une vraie situation et vise ${f.win}.',
      'challenge',
      qText: 'Quand tu relèves ce défi ?',
      qOptions: ['Aujourd\'hui même', 'Dans les 48h'],
    ),
    // 7 — text · Niveau supérieur
    _step(
      'Un cran plus loin',
      'Ne copie pas la méthode — extrais le principe et adapte-le à TON vécu de $d.',
      'text',
      qText: 'Qu\'est-ce qui prime ?',
      qOptions: ['Comprendre le principe', 'L\'adapter à soi'],
      qAnswer: 1,
    ),
    // 8 — reflection · Ancrage identitaire
    _step(
      'Qui es-tu ?',
      'Dis à voix haute : « Je suis quelqu\'un qui pratique « ${ch.title} » dans $d. »',
      'reflection',
      qText: 'Comment ancrer durablement ?',
      qOptions: ['En le reliant à son identité', 'En comptant sur la volonté'],
      qAnswer: 0,
    ),
    // 9 — text · Point clé
    _step(
      'Le point clé',
      'Une seule chose : ${f.win} — tous les jours, peu importe les conditions.',
      'text',
      qText: 'Ce point clé te parle ?',
      qOptions: ['Oui, c\'est limpide', 'J\'y réfléchis encore'],
    ),
    // 10 — framework · Schéma mental
    _step(
      'Le schéma',
      'Visualise : input → ${f.practice} → ${f.win}. Répète. C\'est le cycle.',
      'framework',
      qText: 'Tu vois le schéma mentalement ?',
      qOptions: ['Oui, clairement', 'Pas encore'],
    ),
    // 11 — research · Pour aller plus loin
    _step(
      'Pour aller plus loin',
      'Qui autour de toi incarne « ${ch.title} » dans $d — et qu\'est-ce qui t\'inspire ?',
      'research',
      qText: 'Tu as un modèle en tête ?',
      qOptions: ['Oui, je vois qui', 'Je vais chercher'],
    ),
  ];

  // 6 exercises, varied types, no audio.
  final exercises = <Map<String, dynamic>>[
    _exercise(
      'Journal express',
      'Écris 4 phrases sur ce que « ${ch.title} » change concrètement '
          'dans ta pratique de $d. Sois précis : quoi, quand, comment ? '
          'Plus c\'est spécifique, plus c\'est utile.',
      'reflection',
    ),
    _exercise(
      'Défi du jour',
      'Applique une idée clé de ce chapitre dans ta vraie vie avant ce soir. '
          'Cible : ${f.win}. Après, note en un mot ce que tu as ressenti.',
      'action',
    ),
    _exercise(
      'Mémo flash',
      'Quel est le fait ou l\'insight de ce chapitre qui t\'a le plus surpris ? '
          'Reformule-le en une phrase simple que tu pourrais expliquer à un ami '
          'en 30 secondes. Teste-toi mentalement.',
      'fact',
    ),
    _exercise(
      'Mise en situation',
      'Reproduis « ${ch.title} » dans un contexte exigeant — sans aide, '
          'sans conditions idéales, sans filet. '
          'Note ce qui a fonctionné et ce qui a résisté. '
          'L\'inconfort est la preuve que tu grandis.',
      'action',
    ),
    _exercise(
      'Astuce perso',
      'Identifie une astuce ou un raccourci que TU as découvert en pratiquant '
          '« ${ch.title} » dans $d. Quelque chose que les débutants ne savent pas '
          'encore. Écris-la : tu viens de créer ta propre méthode.',
      'tip',
    ),
    _exercise(
      'Passage à l\'expert',
      'Imagine que tu dois guider quelqu\'un sur « ${ch.title} » dans $d '
          'en 5 minutes. Qu\'est-ce que tu lui dirais en premier ? '
          'Puis en deuxième ? Enseigner est la meilleure façon d\'apprendre.',
      'challenge',
    ),
  ];

  // The time tier sets the baseline depth; the chapter's level adds richness
  // on top, so advanced (level-3) chapters are denser than easy (level-1) ones
  // — more steps and exercises — making the climb tangibly harder.
  final levelBonus = level - 1; // 0, 1 or 2

  final stepSet = {..._kStepIndices[tier]!};
  var added = 0;
  for (var k = 0; k < steps.length && added < levelBonus; k++) {
    if (stepSet.add(k)) added++; // add the next deeper step not already in
  }
  final filteredSteps = [
    for (var k = 0; k < steps.length; k++)
      if (stepSet.contains(k)) steps[k],
  ];

  final exerciseCount = (_kExerciseCount[tier]! + levelBonus).clamp(
    0,
    exercises.length,
  );
  final filteredExercises = exercises.take(exerciseCount).toList();

  return {
    'id': 'm${i + 1}',
    'level': level,
    'title': 'Ch. ${i + 1} — ${ch.title}',
    'summary': ch.summary,
    'content': 'Niveau $intensity. ${ch.content(d, f)}',
    'steps': filteredSteps,
    'exercises': filteredExercises,
    'quiz': _moduleQuiz(i, d, f),
  };
}

// ---------------------------------------------------------------------------
// Per-chapter quiz (3 questions: MCQ + true/false + swipe)
// ---------------------------------------------------------------------------

List<Map<String, dynamic>> _moduleQuiz(int i, String d, _Flavor f) {
  final mcq = _chapterMcq[i];
  return [
    {
      'type': 'mcq',
      'question': mcq.$1,
      'options': mcq.$2,
      'answerIndex': mcq.$3,
      'chapter': i,
    },
    {
      'type': 'truefalse',
      'question': _chapterTrueFalse[i].$1,
      'answer': _chapterTrueFalse[i].$2,
      'chapter': i,
    },
    {
      'type': 'swipe',
      'question': 'Glisse à droite : « ${_chapterSwipe[i].$1} »',
      'answer': _chapterSwipe[i].$2,
      'chapter': i,
    },
  ];
}

// 12 MCQ questions
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
    'Pourquoi célébrer les petites victoires ?',
    [
      'Pour se vanter',
      'Pour renforcer la confiance et maintenir l\'élan',
      'Ce n\'est pas utile',
      'Pour éviter les échecs',
    ],
    1,
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
    'Comment approfondir une pratique efficacement ?',
    [
      'Faire toujours la même chose',
      'Varier les angles et explorer de nouvelles approches',
      'Réduire la fréquence',
      'Attendre d\'être parfait',
    ],
    1,
  ),
  (
    'Qu\'est-ce qui soutient une régularité durable ?',
    [
      'La volonté pure',
      'Un environnement conçu pour faciliter la pratique',
      'L\'inspiration du moment',
      'La pression des autres',
    ],
    1,
  ),
  (
    'Quel est le meilleur indicateur de progrès ?',
    [
      'Un chiffre complexe',
      'Un indicateur simple, personnel et motivant',
      'L\'avis des autres',
      'La durée totale de pratique',
    ],
    1,
  ),
  (
    'Comment passer au niveau supérieur sans se décourager ?',
    [
      'En forçant brutalement',
      'En n\'augmentant jamais l\'exigence',
      'En augmentant l\'exigence progressivement',
      'En réduisant la fréquence',
    ],
    2,
  ),
  (
    'Qu\'est-ce qu\'une stratégie personnelle efficace ?',
    [
      'Copier exactement la méthode d\'un expert',
      'Une méthode adaptée à soi, affinée par l\'expérience',
      'Faire le maximum en tout',
      'Suivre les tendances',
    ],
    1,
  ),
  (
    'Qu\'est-ce qui ancre durablement une habitude ?',
    [
      'La relier à son identité',
      'Compter uniquement sur la volonté',
      'La pratiquer une fois par mois',
      'La garder secrète',
    ],
    0,
  ),
  (
    'Qu\'est-ce que l\'autonomie dans l\'apprentissage ?',
    [
      'N\'avoir besoin de personne',
      'Être capable de créer et ajuster sa propre pratique',
      'Ne jamais demander d\'aide',
      'Tout maîtriser parfaitement',
    ],
    1,
  ),
];

// 12 true/false questions
const List<(String, bool)> _chapterTrueFalse = [
  ('Comprendre le « pourquoi » renforce durablement la motivation.', true),
  ('Faire un état des lieux honnête sert à se dévaloriser.', false),
  (
    'Un rituel ancré demande de moins en moins de volonté au fil du temps.',
    true,
  ),
  ('Reconnaître ses petits progrès aide le cerveau à rester engagé.', true),
  ('Un seul écart ruine tous les efforts accumulés.', false),
  ('Varier les angles d\'une pratique prévient la stagnation.', true),
  ('L\'environnement influence plus la régularité que la volonté.', true),
  (
    'Mesurer ses progrès avec des indicateurs complexes est toujours préférable.',
    false,
  ),
  ('Augmenter l\'exigence trop vite peut décourager durablement.', true),
  (
    'La meilleure stratégie est celle qui est adaptée à ta situation personnelle.',
    true,
  ),
  ('Les habitudes durables reposent surtout sur la volonté.', false),
  (
    'Enseigner ce qu\'on a appris est l\'une des meilleures façons de l\'ancrer.',
    true,
  ),
];

// 12 swipe questions
const List<(String, bool)> _chapterSwipe = [
  ('Je pose une intention claire avant d\'agir.', true),
  ('Mon point de départ ne mérite aucune attention.', false),
  ('Je pratique à heure fixe chaque jour.', true),
  ('Je note au moins une victoire chaque jour, aussi petite soit-elle.', true),
  ('Un écart signifie que j\'ai tout raté.', false),
  ('J\'explore régulièrement de nouvelles façons de pratiquer.', true),
  (
    'Mon environnement est organisé pour faciliter ma pratique quotidienne.',
    true,
  ),
  ('Je suis mes progrès avec un indicateur simple qui me motive.', true),
  ('Je m\'arrête dès que c\'est trop difficile.', false),
  ('J\'ajuste ma méthode selon ce qui fonctionne vraiment pour moi.', true),
  ('Je compte uniquement sur ma motivation du moment.', false),
  ('Je suis capable de guider quelqu\'un d\'autre dans cette pratique.', true),
];

// ---------------------------------------------------------------------------
// Parts: 3 groups of 4 chapters each + transversal quiz
// ---------------------------------------------------------------------------

List<Map<String, dynamic>> _buildParts(String d, _Flavor f) {
  const ids = ['p1', 'p2', 'p3'];
  const chapterGroups = <List<int>>[
    [0, 1, 2, 3],
    [4, 5, 6, 7],
    [8, 9, 10, 11],
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

/// Transversal quiz covering the 4 chapters of a part (8 questions).
List<Map<String, dynamic>> _partQuiz(List<int> chs, String d, _Flavor f) {
  final q = <Map<String, dynamic>>[];
  // One MCQ per chapter in the part
  for (final i in chs) {
    final mcq = _chapterMcq[i];
    q.add({
      'type': 'mcq',
      'question': mcq.$1,
      'options': mcq.$2,
      'answerIndex': mcq.$3,
      'chapter': i,
    });
  }
  // Two true/false (first and last chapter of the part)
  q.add({
    'type': 'truefalse',
    'question': _chapterTrueFalse[chs.first].$1,
    'answer': _chapterTrueFalse[chs.first].$2,
    'chapter': chs.first,
  });
  q.add({
    'type': 'truefalse',
    'question': _chapterTrueFalse[chs.last].$1,
    'answer': _chapterTrueFalse[chs.last].$2,
    'chapter': chs.last,
  });
  // Two swipe cards (middle chapters)
  q.add({
    'type': 'swipe',
    'question': 'Glisse à droite : « ${_chapterSwipe[chs[1]].$1} »',
    'answer': _chapterSwipe[chs[1]].$2,
    'chapter': chs[1],
  });
  q.add({
    'type': 'swipe',
    'question': 'Glisse à droite : « ${_chapterSwipe[chs[2]].$1} »',
    'answer': _chapterSwipe[chs[2]].$2,
    'chapter': chs[2],
  });
  return q;
}

// ---------------------------------------------------------------------------
// Final quiz — covers all 12 chapters (~25 questions)
// ---------------------------------------------------------------------------

List<Map<String, dynamic>> _finalQuiz(String d, _Flavor f) {
  final q = <Map<String, dynamic>>[];

  // All 12 MCQs
  for (var i = 0; i < _chapterMcq.length; i++) {
    final mcq = _chapterMcq[i];
    q.add({
      'type': 'mcq',
      'question': mcq.$1,
      'options': mcq.$2,
      'answerIndex': mcq.$3,
      'chapter': i,
    });
  }

  // 6 true/false (even indices: 0, 2, 4, 6, 8, 10)
  for (final i in const [0, 2, 4, 6, 8, 10]) {
    q.add({
      'type': 'truefalse',
      'question': _chapterTrueFalse[i].$1,
      'answer': _chapterTrueFalse[i].$2,
      'chapter': i,
    });
  }

  // 6 swipe (odd indices: 1, 3, 5, 7, 9, 11)
  for (final i in const [1, 3, 5, 7, 9, 11]) {
    q.add({
      'type': 'swipe',
      'question': 'Glisse à droite : « ${_chapterSwipe[i].$1} »',
      'answer': _chapterSwipe[i].$2,
      'chapter': i,
    });
  }

  // Synthesis question tied to the domain/goal
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
    'difficulty': 2,
  });

  return q;
}

// ---------------------------------------------------------------------------
// Detail bank — harder, precise questions (difficulty 2 & 3), one pair per
// chapter. Pooled by the retention quiz, which surfaces them more and more as
// the learner advances (and favours the earliest chapters — "the beginning").
// ---------------------------------------------------------------------------

List<Map<String, dynamic>> _detailQuiz() {
  final q = <Map<String, dynamic>>[];
  for (var i = 0; i < _chapters.length; i++) {
    final m = _chapterDetailMcq[i];
    q.add({
      'type': 'mcq',
      'question': 'Détail · ${_chapters[i].title} — ${m.$1}',
      'options': m.$2,
      'answerIndex': m.$3,
      'difficulty': 2,
      'chapter': i,
    });
    // Tricky true/false: the statement is subtly INEXACT → the answer is "faux".
    q.add({
      'type': 'truefalse',
      'question': 'Vrai ou faux ? ${_chapterDetailFalse[i]}',
      'answer': false,
      'difficulty': 3,
      'chapter': i,
    });
  }
  return q;
}

// Precise "detail" MCQ per chapter (difficulty 2).
const List<(String, List<String>, int)> _chapterDetailMcq = [
  (
    'qu\'est-ce qui prime avant tout ?',
    [
      'La régularité sur l\'intensité',
      'L\'intensité ponctuelle',
      'La perfection',
      'La vitesse',
    ],
    0,
  ),
  (
    'l\'état des lieux initial doit être :',
    [
      'Honnête et sans jugement',
      'Sévère envers soi',
      'Évité',
      'Copié sur les autres',
    ],
    0,
  ),
  (
    'pour ancrer un rituel, mieux vaut le faire :',
    [
      'À un moment fixe chaque jour',
      'À une heure différente chaque jour',
      'Une fois par semaine',
      'Quand l\'envie vient',
    ],
    0,
  ),
  (
    'célébrer une petite victoire sert surtout à :',
    [
      'Renforcer la confiance et l\'élan',
      'Se vanter',
      'Perdre du temps',
      'Éviter l\'effort',
    ],
    0,
  ),
  (
    'face à un écart, le bon réflexe est de :',
    [
      'Reprendre dès le lendemain sans dramatiser',
      'Tout abandonner',
      'Culpabiliser longtemps',
      'Recommencer de zéro',
    ],
    0,
  ),
  (
    'approfondir une pratique passe par :',
    [
      'Varier les angles et explorer',
      'Toujours répéter à l\'identique',
      'Réduire la fréquence',
      'Attendre d\'être parfait',
    ],
    0,
  ),
  (
    'ce qui soutient le plus la régularité, c\'est :',
    [
      'Un environnement qui facilite la pratique',
      'La seule volonté',
      'L\'inspiration du moment',
      'La pression des autres',
    ],
    0,
  ),
  (
    'le bon indicateur de progrès est :',
    [
      'Simple, personnel et motivant',
      'Complexe et détaillé',
      'Donné par les autres',
      'La durée totale',
    ],
    0,
  ),
  (
    'on élève le niveau d\'exigence :',
    [
      'Progressivement, par paliers',
      'Brutalement',
      'Jamais',
      'En réduisant la fréquence',
    ],
    0,
  ),
  (
    'la meilleure stratégie est :',
    [
      'Celle adaptée à ta situation',
      'Celle d\'un expert, copiée à l\'identique',
      'La plus à la mode',
      'La plus complexe',
    ],
    0,
  ),
  (
    'ce qui ancre le plus durablement :',
    [
      'Relier la pratique à ton identité',
      'La volonté seule',
      'Le secret',
      'La pratique mensuelle',
    ],
    0,
  ),
  (
    'devenir autonome, c\'est :',
    [
      'Savoir créer et ajuster sa propre pratique',
      'Ne besoin de personne',
      'Ne jamais demander d\'aide',
      'Tout maîtriser parfaitement',
    ],
    0,
  ),
];

// Subtly INEXACT statement per chapter (difficulty 3 → answer is "faux").
const List<String> _chapterDetailFalse = [
  'Les fondations reposent surtout sur des élans intenses ponctuels.',
  'Faire son état des lieux revient à se juger sévèrement.',
  'Un rituel efficace change de créneau horaire chaque jour.',
  'Reconnaître ses petits progrès est une perte de temps.',
  'Un seul écart annule tous les progrès accumulés.',
  'Répéter exactement la même chose suffit à progresser longtemps.',
  'La volonté compte plus que l\'environnement pour rester régulier.',
  'Un indicateur de progrès complexe est toujours préférable à un simple.',
  'Augmenter brutalement l\'exigence est la voie la plus sûre.',
  'La meilleure méthode est universelle et identique pour tous.',
  'Une habitude durable tient surtout grâce à la volonté.',
  'Être autonome, c\'est ne jamais demander d\'aide à personne.',
];
