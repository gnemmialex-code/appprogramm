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

String tierLabel(ProgramTier t) => switch (t) {
  ProgramTier.express => '⚡ Express',
  ProgramTier.rapide => '🎯 Rapide',
  ProgramTier.standard => '📚 Standard',
  ProgramTier.complet => '🔥 Complet',
  ProgramTier.intensif => '🚀 Intensif',
};

int tierMinutesPerChapter(ProgramTier t) => switch (t) {
  ProgramTier.express => 5,
  ProgramTier.rapide => 10,
  ProgramTier.standard => 18,
  ProgramTier.complet => 28,
  ProgramTier.intensif => 40,
};

// Step indices per tier (12 steps total: 0-11).
const Map<ProgramTier, List<int>> _kStepIndices = {
  ProgramTier.express: [0, 4, 9],
  ProgramTier.rapide: [0, 1, 4, 5, 9],
  ProgramTier.standard: [0, 1, 2, 3, 4, 5, 6, 9],
  ProgramTier.complet: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
  ProgramTier.intensif: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
};

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

const List<ChapterPreview> kProgramChapters = [
  (title: 'Comprendre les fondations', summary: 'Pose les bases et clarifie ton intention.', level: 1),
  (title: 'Observer ton point de départ', summary: 'Fais le point, sans jugement, sur ta situation actuelle.', level: 1),
  (title: 'Construire ton premier rituel', summary: 'Transforme la théorie en habitude quotidienne mesurable.', level: 1),
  (title: 'Célébrer les petites victoires', summary: 'Reconnais tes progrès pour maintenir l\'élan.', level: 1),
  (title: 'Surmonter les obstacles', summary: 'Anticipe les blocages et apprends à rebondir vite.', level: 2),
  (title: 'Approfondir la pratique', summary: 'Élargis ta compréhension et varie les approches.', level: 2),
  (title: 'Développer ta régularité', summary: 'Transforme l\'effort en automatisme durable.', level: 2),
  (title: 'Mesurer tes progrès', summary: 'Utilise des indicateurs concrets pour rester motivé.', level: 2),
  (title: 'Élever le niveau d\'exigence', summary: 'Augmente progressivement la difficulté pour grandir.', level: 3),
  (title: 'Optimiser ta stratégie', summary: 'Affine ta méthode pour un impact maximal.', level: 3),
  (title: 'Ancrer durablement', summary: 'Rends tes progrès automatiques et prépare la suite.', level: 3),
  (title: 'Devenir expert et autonome', summary: 'Intègre ce domaine à ton identité et transmets ce que tu sais.', level: 3),
];

// ---------------------------------------------------------------------------
// Main generator
// ---------------------------------------------------------------------------

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
// Level metadata
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
  'Psychologie': _Flavor('mieux te comprendre', 'un temps d\'introspection guidée de 5 minutes', 'une prise de conscience'),
  'Anxiété': _Flavor('apaiser ton mental', 'une respiration 4-7-8 répétée trois fois', 'un instant de calme retrouvé'),
  'Productivité': _Flavor('avancer sans t\'épuiser', 'une session de focus de 25 minutes sans distraction', 'une tâche clé bouclée'),
  'Sport': _Flavor('bouger avec plaisir', 'une séance de mobilité de 10 minutes', 'un corps plus énergique'),
  'Nutrition': _Flavor('manger en conscience', 'un repas pris lentement, sans écran', 'un choix alimentaire aligné'),
  'Relations': _Flavor('créer des liens plus sains', 'une conversation sincère initiée par toi', 'un échange authentique'),
  'Sommeil': _Flavor('retrouver des nuits réparatrices', 'un rituel du soir sans écran 30 minutes avant le coucher', 'un réveil reposé'),
  'Confiance': _Flavor('oser être toi', 'une action qui te sort un peu de ta zone de confort', 'une victoire sur le doute'),
  'Finance': _Flavor('gérer ton argent avec clarté', 'une revue de 5 minutes de tes dépenses de la semaine', 'une décision financière consciente'),
  'Apprentissage': _Flavor('apprendre plus vite et mieux', 'une session de révision en rappel actif de 15 minutes', 'un concept ancré durablement'),
  'Bien-être': _Flavor('vivre plus aligné avec tes valeurs', 'un moment de pleine conscience de 5 minutes', 'un instant de paix intérieure'),
  'Leadership': _Flavor('inspirer et guider avec authenticité', 'une conversation de feedback sincère avec quelqu\'un', 'une relation de confiance renforcée'),
  'Communication': _Flavor('t\'exprimer avec clarté et impact', 'un exercice de reformulation ou d\'écoute active', 'un message reçu exactement comme tu le voulais'),
  'Créativité': _Flavor('libérer ta créativité au quotidien', 'une session d\'exploration libre de 10 minutes sans jugement', 'une idée originale concrétisée'),
};

// ---------------------------------------------------------------------------
// Chapter titles (12 total, used for module IDs and content strings)
// ---------------------------------------------------------------------------

class _Chapter {
  final String title;
  final String summary;
  final String Function(String d, _Flavor f) content;
  const _Chapter(this.title, this.summary, this.content);
}

const List<_Chapter> _chapters = [
  _Chapter('Comprendre les fondations', 'Pose les bases et clarifie ton intention.', _c0),
  _Chapter('Observer ton point de départ', 'Fais le point, sans jugement, sur ta situation actuelle.', _c1),
  _Chapter('Construire ton premier rituel', 'Transforme la théorie en habitude quotidienne mesurable.', _c2),
  _Chapter('Célébrer les petites victoires', 'Reconnais tes progrès pour maintenir l\'élan.', _c3),
  _Chapter('Surmonter les obstacles', 'Anticipe les blocages et apprends à rebondir vite.', _c4),
  _Chapter('Approfondir la pratique', 'Élargis ta compréhension et varie les approches.', _c5),
  _Chapter('Développer ta régularité', 'Transforme l\'effort en automatisme durable.', _c6),
  _Chapter('Mesurer tes progrès', 'Utilise des indicateurs concrets pour rester motivé.', _c7),
  _Chapter('Élever le niveau d\'exigence', 'Augmente progressivement la difficulté pour grandir.', _c8),
  _Chapter('Optimiser ta stratégie', 'Affine ta méthode pour un impact maximal.', _c9),
  _Chapter('Ancrer durablement', 'Rends tes progrès automatiques et prépare la suite.', _c10),
  _Chapter('Devenir expert et autonome', 'Intègre ce domaine à ton identité et transmets ce que tu sais.', _c11),
];

// Chapter content paragraphs (module.content field — domain-aware introductions).
String _c0(String d, _Flavor f) =>
    'Bienvenue dans ton parcours « $d ». Avant d\'agir, il faut comprendre. '
    'Ce premier chapitre pose les fondations : ce que recouvre $d, pourquoi '
    'cela compte pour toi, et l\'état d\'esprit qui fait toute la différence. '
    'Ton objectif global est clair : ${f.goal}. Retiens un principe essentiel — '
    'la régularité prime toujours sur l\'intensité.';

String _c1(String d, _Flavor f) =>
    'On ne peut améliorer que ce que l\'on observe. Dans ce chapitre, tu fais '
    'un état des lieux honnête de ta relation actuelle avec $d : tes forces, '
    'tes habitudes, tes déclencheurs et tes angles morts. Pas de jugement, '
    'seulement de la lucidité. Cette photographie de départ te servira de '
    'repère pour mesurer tout le chemin parcouru.';

String _c2(String d, _Flavor f) =>
    'Les changements durables naissent de petites actions répétées. Tu vas '
    'mettre en place un rituel simple autour de $d : ${f.practice}. '
    'Un rituel ancré demande de moins en moins de volonté : il devient '
    'automatique. Commence avec 5 minutes — c\'est suffisant pour installer '
    'la dynamique.';

String _c3(String d, _Flavor f) =>
    'Le progrès n\'est pas visible chaque jour, mais il est réel. '
    'Apprendre à reconnaître et célébrer ${f.win} — même modeste — '
    'est une compétence en soi. Notre cerveau est câblé pour retenir '
    'les échecs et minimiser les succès : il faut activement contrebalancer '
    'ce biais.';

String _c4(String d, _Flavor f) =>
    'Tout parcours rencontre des frictions : fatigue, imprévus, baisse de '
    'motivation. Ce n\'est pas un signe d\'échec — c\'est la preuve que tu '
    'vises quelque chose qui compte. Tu apprends à reconnaître tes '
    'déclencheurs en $d et à réagir avec bienveillance plutôt qu\'avec '
    'culpabilité.';

String _c5(String d, _Flavor f) =>
    'Une fois la base installée, il est temps d\'élargir ta pratique de $d. '
    'Approfondir ne signifie pas faire plus — cela signifie faire mieux : '
    'varier les angles, questionner ce qui fonctionne vraiment, et explorer '
    'des approches que tu n\'as pas encore essayées.';

String _c6(String d, _Flavor f) =>
    'La régularité n\'est pas une question de discipline — c\'est une '
    'question de systèmes. Tu vas mettre en place des déclencheurs '
    'environnementaux qui rendent ta pratique de $d presque inévitable. '
    'Ton environnement travaille pour toi ou contre toi — à toi de choisir.';

String _c7(String d, _Flavor f) =>
    'Ce qui ne se mesure pas ne s\'améliore pas — mais ce qui est mal '
    'mesuré décourage. Tu vas choisir 2 ou 3 indicateurs simples pour '
    'suivre tes progrès en $d. L\'objectif est de créer une boucle de '
    'rétroaction rapide qui t\'indique si tu avances dans la bonne direction.';

String _c8(String d, _Flavor f) =>
    'Tu as posé des bases solides en $d. Il est temps d\'élever le niveau. '
    'Ce chapitre t\'invite à augmenter progressivement l\'exigence. '
    'Tu vas identifier ton « seuil d\'inconfort productif » : la zone '
    'juste assez difficile pour progresser, sans être assez difficile '
    'pour te décourager.';

String _c9(String d, _Flavor f) =>
    'À ce stade, tu as de l\'expérience en $d. Il est temps d\'affiner ta '
    'méthode pour maximiser le retour sur chaque effort investi. Tu vas '
    'supprimer le superflu, renforcer l\'essentiel, et personnaliser ta '
    'pratique jusqu\'à ce qu\'elle soit aussi efficace qu\'agréable.';

String _c10(String d, _Flavor f) =>
    'Dernier palier avant l\'autonomie : rendre tes progrès irréversibles. '
    'Tu vas relier ta pratique de $d à ton identité et planifier les '
    'prochaines semaines avec précision. ${f.goal} ne sera plus un objectif, '
    'mais une évidence quotidienne.';

String _c11(String d, _Flavor f) =>
    'Tu es arrivé au dernier chapitre. Ce n\'est pas une fin — c\'est '
    'le début de l\'autonomie complète. Tu vas consolider l\'ensemble du '
    'parcours en $d, identifier ce que tu peux transmettre à d\'autres, '
    'et concevoir ta propre version avancée du programme pour les prochains mois.';

// ---------------------------------------------------------------------------
// Chapter DNA — unique content per chapter
// ---------------------------------------------------------------------------

class _ChapterDNA {
  // Step bodies (unique per chapter)
  final String essential;   // step 0
  final String fact;        // step 1
  final String change;      // step 2
  final String reflect;     // step 3
  // step 4 = mini-action uses f.practice (domain-specific)
  final String tip;         // step 5
  final String challenge;   // step 6
  final String deeper;      // step 7
  final String identity;    // step 8
  final String keyPoint;    // step 9
  final String schema;      // step 10
  final String goFurther;   // step 11

  // Quiz (unique per chapter)
  final (String, List<String>, int) mcq;
  final (String, bool) trueFalse;
  final (String, bool) swipe;

  // Exercises (6 per chapter, unique)
  final List<(String, String, String)> exercises; // (title, instruction, type)

  const _ChapterDNA({
    required this.essential,
    required this.fact,
    required this.change,
    required this.reflect,
    required this.tip,
    required this.challenge,
    required this.deeper,
    required this.identity,
    required this.keyPoint,
    required this.schema,
    required this.goFurther,
    required this.mcq,
    required this.trueFalse,
    required this.swipe,
    required this.exercises,
  });
}

const List<_ChapterDNA> _dna = [
  // ─── Ch 0 : Comprendre les fondations ────────────────────────────────────
  _ChapterDNA(
    essential: 'Avant d\'agir, comprendre. La fondation d\'une pratique solide repose sur trois piliers : clarté du but, connaissance des mécanismes de base, et alignement avec tes valeurs profondes. Sans cette base, chaque difficulté devient une raison d\'arrêter.',
    fact: 'La neuroscience le confirme : définir une intention explicite avant d\'apprendre augmente la rétention à long terme de 43 %. Le cerveau encode prioritairement les informations qui correspondent à un objectif déclaré — les autres sont filtrées.',
    change: 'Sans intention claire, chaque obstacle devient une raison d\'arrêter. Les études sur l\'abandon montrent que 78 % des personnes qui renoncent à une pratique n\'avaient pas formulé de « pourquoi » précis au départ.',
    reflect: 'Pourquoi ce domaine maintenant ? Quelle frustration ou aspiration t\'a amené ici — et à quoi ressemblera ta vie dans 3 mois si tu t\'y engages vraiment ?',
    tip: 'Écris ton objectif en une seule phrase avec un verbe d\'action et une échéance. « Je veux progresser » ne s\'ancre pas ; « Je pratique 10 minutes chaque matin d\'ici 30 jours » crée une image mentale précise que le cerveau peut saisir.',
    challenge: 'D\'ici ce soir, formule ton intention en une phrase et dis-la à voix haute trois fois. La vocalisation active les mêmes circuits cérébraux que l\'action elle-même.',
    deeper: 'Les fondations ne sont pas rigides — elles s\'approfondissent au fil du parcours. Reviens sur ce chapitre dans 4 semaines : tu liras les mêmes mots mais tu y verras quelque chose de différent.',
    identity: 'Dis à voix haute : « Je suis quelqu\'un qui comprend pourquoi ce domaine compte pour moi, et qui avance avec intention. »',
    keyPoint: 'Une intention claire précède toujours une action efficace. Le « pourquoi » suffisamment fort rend le « comment » évident — et résiste aux jours difficiles.',
    schema: 'Intention précise → Engagement conscient → Action répétée → Résultat mesurable. Saute la première étape et tout le reste devient aléatoire.',
    goFurther: 'Pense à quelqu\'un qui excelle dans ce domaine. Quelle est, selon toi, la fondation invisible derrière sa réussite — la croyance profonde qui rend tout le reste possible ?',
    mcq: (
      'Qu\'est-ce qui distingue une intention efficace d\'un vœu pieux ?',
      ['Un verbe d\'action concret, une date et un critère mesurable', 'Une motivation forte mais vague', 'Une longue liste d\'objectifs ambitieux', 'L\'approbation et le soutien des autres'],
      0,
    ),
    trueFalse: ('Définir une intention explicite avant d\'apprendre augmente significativement la rétention à long terme.', true),
    swipe: ('Je peux expliquer en une phrase précise pourquoi je veux progresser dans ce domaine.', true),
    exercises: [
      ('L\'intention en une phrase', 'Formule ton objectif : « D\'ici [date], je veux [résultat concret] parce que [raison personnelle]. » Lis-le à voix haute. Enregistre-le dans tes notes — tu le reliras dans 30 jours.', 'reflection'),
      ('Cartographie initiale du domaine', 'En 5 minutes chrono, note tout ce que tu sais déjà sur ce domaine (sans chercher). Puis note 5 choses que tu ne sais pas encore mais que tu veux apprendre. Ce double inventaire te donne ta boussole.', 'fact'),
      ('Les 5 pourquoi', 'Pose-toi 5 fois la question « pourquoi ? » à la suite sur ton objectif. Chaque réponse amène un niveau plus profond. La 5e réponse est souvent ta vraie motivation — celle qui tiendra dans la durée.', 'reflection'),
      ('Engagement public minimal', 'Dis à une personne de confiance ce que tu vas apprendre et pourquoi. L\'engagement social augmente le taux de complétion d\'une pratique de 65 % selon les études comportementales.', 'action'),
      ('Visualisation de la réussite', 'Ferme les yeux 3 minutes. Imagine que tu as atteint ton objectif. Qu\'est-ce qui est différent dans ton quotidien ? Comment tu te sens ? Qu\'est-ce que tu fais que tu ne faisais pas avant ?', 'reflection'),
      ('Définition personnelle', 'En tes propres mots, sans chercher en ligne, définis ce domaine. Enregistre ta définition. Tu la reliras dans 4 semaines — l\'évolution te montrera exactement ce que tu as appris.', 'challenge'),
    ],
  ),

  // ─── Ch 1 : Observer ton point de départ ─────────────────────────────────
  _ChapterDNA(
    essential: 'Un diagnostic honnête vaut mille plans d\'action. Savoir exactement où tu en es — forces, angles morts, habitudes actuelles — te permet de cibler les bons efforts dès le début, plutôt que de travailler sur les mauvaises priorités.',
    fact: 'Des chercheurs de l\'Université du Michigan ont montré en 2021 que les apprenants qui réalisent un auto-diagnostic structuré avant de commencer progressent 2,6× plus vite que ceux qui sautent cette étape. Observer, c\'est déjà apprendre.',
    change: 'Sans état des lieux initial, tu travailles sur les mauvaises priorités, répètes des erreurs évitables et n\'as aucune référence pour mesurer le chemin parcouru. Dans 90 jours, tu ne sauras pas si tu as vraiment progressé.',
    reflect: 'Si tu devais te noter sur 10 dans ce domaine aujourd\'hui, ce serait combien ? Et qu\'est-ce qui t\'empêche précisément d\'être à 10 ?',
    tip: 'Note tes déclencheurs positifs ET négatifs : quand tu progresses bien et quand tu recules. Les patterns deviennent visibles en seulement 7 jours d\'observation simple — sans rien changer d\'autre.',
    challenge: 'Fais un audit honnête de 10 minutes : liste 3 forces actuelles, 3 angles morts et 3 comportements existants liés à ce domaine. Sois précis — personne ne lit tes notes.',
    deeper: 'Tes forces sous-exploitées sont souvent tes leviers les plus puissants. Les angles morts que tu identifies aujourd\'hui deviendront tes plus grandes zones de progression dans 6 semaines.',
    identity: 'Dis à voix haute : « Je suis quelqu\'un qui s\'observe avec lucidité et sans jugement pour progresser de façon ciblée. »',
    keyPoint: 'On ne peut améliorer que ce qu\'on a d\'abord honnêtement observé. La lucidité sans jugement est la compétence de base de tout progrès durable — et elle s\'entraîne.',
    schema: 'Situation actuelle observée → Forces à amplifier + Angles morts identifiés → Actions ciblées → Progrès mesurable. Sans la première étape, tout le reste est au hasard.',
    goFurther: 'Imagine que tu regardes ta situation actuelle comme un scientifique — sans émotion, avec pure curiosité. Qu\'est-ce qui t\'intriguerait le plus dans tes propres patterns de comportement ?',
    mcq: (
      'À quoi sert principalement l\'état des lieux initial dans un apprentissage ?',
      ['À se juger sévèrement pour se motiver', 'À créer une référence pour cibler ses efforts et mesurer ses progrès réels', 'À copier la méthode des experts', 'À lister ses échecs passés pour ne pas les répéter'],
      1,
    ),
    trueFalse: ('Observer sa situation actuelle sans jugement permet d\'identifier les leviers réels de progrès plutôt que de travailler sur les mauvaises priorités.', true),
    swipe: ('J\'ai identifié au moins une force réelle et un angle mort concret dans ma pratique actuelle dans ce domaine.', true),
    exercises: [
      ('Audit des habitudes actuelles', 'Liste tout ce que tu fais déjà (même peu) dans ce domaine. Classe chaque habitude en trois colonnes : ✅ efficace, ⚠️ à améliorer, ❌ contre-productive. Observe seulement — ne cherche pas encore à changer.', 'reflection'),
      ('La note sur 10 argumentée', 'Donne-toi une note sur 10 dans ce domaine. Explique en 3 phrases précises pourquoi pas moins — et en 3 phrases précises pourquoi pas plus. Cette tension est exactement ton terrain de jeu.', 'reflection'),
      ('L\'interview du futur toi', 'Imagine que le toi d\'ici 6 mois te regarde travailler aujourd\'hui. Qu\'est-ce qu\'il voit ? Qu\'est-ce qu\'il ferait différemment dès maintenant ? Écris sa réponse à la 2e personne du singulier.', 'challenge'),
      ('Journal d\'observation 3 jours', 'Pendant 3 jours consécutifs, note chaque soir : une situation où tu as bien appliqué les principes du domaine, et une où tu aurais pu mieux faire. Sans jugement — juste des données brutes.', 'action'),
      ('La question miroir externe', 'Demande à quelqu\'un qui te connaît bien : « Dans ce domaine, quelle est ma plus grande force que je sous-estime ? Et quel est mon principal angle mort ? » Écoute sans te défendre.', 'research'),
      ('Inventaire de ressources', 'Liste ce que tu as déjà : connaissances, expériences connexes, contacts utiles, outils disponibles, temps libre. On commence toujours avec plus qu\'on ne le croit — le voir te donne confiance.', 'fact'),
    ],
  ),

  // ─── Ch 2 : Construire ton premier rituel ─────────────────────────────────
  _ChapterDNA(
    essential: 'Un rituel n\'est pas une contrainte — c\'est un accord passé avec ton futur toi. En attachant une nouvelle pratique à un moment fixe et un déclencheur existant, tu réduis le coût de la décision à zéro et tu libères ta volonté pour ce qui compte.',
    fact: 'La recherche en psychologie comportementale le prouve : associer une nouvelle habitude à un déclencheur existant (habit stacking) multiplie par 3 le taux d\'adoption à 90 jours. Le cerveau aime le prévisible — et il automatise ce qu\'il voit répété.',
    change: 'Sans rituel ancré, la pratique dépend de la motivation du moment — une ressource qui varie de 40 à 60 % selon les journées et l\'état émotionnel. Le rituel court-circuite la question « ai-je envie ou pas ? » et remplace la décision par l\'automatisme.',
    reflect: 'Quel est le moment de la journée où tu as le plus d\'énergie disponible ? Et quelle habitude existante (café du matin, retour du travail, brossage des dents) pourrait servir de déclencheur naturel ?',
    tip: 'Commence plus petit que tu ne le penses nécessaire. Une pratique de 2 minutes tenue chaque jour vaut infiniment plus qu\'une pratique de 30 minutes abandonnée après 10 jours. La régularité construit la confiance.',
    challenge: 'Choisis un déclencheur précis (après [action existante]) et pratique exactement 2 minutes aujourd\'hui et les 6 prochains jours. Pas plus — l\'objectif est la chaîne de 7, pas la durée.',
    deeper: 'La consistance construit la confiance. Après 21 jours de rituel quotidien, le cerveau encode l\'activité comme « normale » — elle demande alors 60 % moins d\'effort mental. L\'effort que tu ressens maintenant est temporaire.',
    identity: 'Dis à voix haute : « Je suis quelqu\'un qui pratique chaque jour, peu importe les conditions — parce que mon rituel ne dépend pas de mon humeur. »',
    keyPoint: 'Un rituel ancré à une habitude existante devient automatique en moyenne en 66 jours. Commence minuscule, reste régulier — la durée s\'ajuste d\'elle-même quand le rituel est installé.',
    schema: 'Déclencheur existant → Nouvelle pratique (mini) → Récompense immédiate. C\'est la boucle habitude. Plus elle est répétée, plus elle se solidifie — et moins elle demande d\'énergie.',
    goFurther: 'Quand ton rituel sera automatique dans 3-4 semaines, qu\'est-ce que tu y ajouteras ? Imagine la version 3.0 de ton rituel dans 3 mois — ce à quoi il ressemble quand il fait pleinement partie de toi.',
    mcq: (
      'Qu\'est-ce qui rend un rituel durable selon la recherche comportementale ?',
      ['Son association à un déclencheur existant et une récompense immédiate', 'Sa longue durée quotidienne', 'Le fait de le faire uniquement quand on en a envie', 'L\'absence de toute variation'],
      0,
    ),
    trueFalse: ('Commencer avec une pratique très courte (2 minutes) augmente significativement les chances de maintenir l\'habitude sur le long terme.', true),
    swipe: ('Mon rituel est associé à un déclencheur précis et existant dans ma journée — pas à la motivation du moment.', true),
    exercises: [
      ('Design complet du rituel', 'Complète la phrase : « Chaque jour, après [habitude existante], je vais [nouvelle pratique de 2-5 min] et ensuite je [petite récompense]. » Écris-la, affiche-la, puis fais-la aujourd\'hui même.', 'action'),
      ('Calendrier des coches', 'Prends un calendrier physique ou numérique. Dessine une croix chaque jour où tu fais ton rituel. L\'objectif unique : ne jamais manquer 2 jours consécutifs. La chaîne visuelle est une récompense en elle-même.', 'challenge'),
      ('Réduction maximale des frictions', 'Identifie les 3 frictions principales qui pourraient t\'empêcher de faire ton rituel demain. Résous chacune ce soir. (Ex : tenue posée, matériel visible, app ouverte sur la page suivante.)', 'tip'),
      ('Audit du temps disponible', 'Pendant une journée, note ce que tu fais en blocs de 30 minutes. Identifie les 2 créneaux où la nouvelle pratique s\'insérerait le plus naturellement — ceux où tu « végètes » légèrement.', 'reflection'),
      ('Test du micro-rituel minimal', 'Fais ton rituel sous sa forme la plus réduite (30 secondes maximum). L\'objectif : prouver à ton cerveau que tu peux toujours commencer, même les jours difficiles. Commencer est 80 % de la bataille.', 'action'),
      ('Simulation des obstacles probables', 'Imagine les 3 scénarios les plus probables où tu rateras ton rituel. Pour chacun, prépare un plan B précis par écrit. La résilience se prépare toujours avant que le problème survienne.', 'challenge'),
    ],
  ),

  // ─── Ch 3 : Célébrer les petites victoires ────────────────────────────────
  _ChapterDNA(
    essential: 'Le cerveau ne fait pas de différence entre une petite victoire et une grande : la dopamine libérée est réelle dans les deux cas. Célébrer consciemment n\'est pas de la vanité — c\'est de l\'ingénierie comportementale qui renforce les bons circuits.',
    fact: 'Des études en neurosciences du comportement montrent que reconnaître explicitement une réussite — même mineure — augmente la probabilité de répéter le comportement de 58 %. Sans reconnaissance consciente, le biais de négativité minimise systématiquement les progrès réels.',
    change: 'Sans célébration consciente, le cerveau amplifie les échecs et minimise les progrès (biais de négativité documenté : ratio 3:1 en faveur du négatif). On finit par croire qu\'on n\'avance pas — alors qu\'on avance, mais on ne le compte pas.',
    reflect: 'Quel est le dernier vrai progrès que tu as fait dans ce domaine — même minuscule — et que tu n\'as pas reconnu à sa juste valeur ? Qu\'est-ce qui t\'en a empêché ?',
    tip: 'La célébration doit être immédiate (dans les 2 minutes suivant la réussite) pour créer une association neuronale forte. Un simple sourire ou un « oui ! » dit à voix haute suffit — le cerveau répond au signal, quelle que soit sa taille.',
    challenge: 'Ce soir, liste 3 réussites de cette semaine dans ce domaine — aussi petites soient-elles. Dis chaque réussite à voix haute en ajoutant « et c\'est réel. » La vocalisation ancre mieux que la pensée seule.',
    deeper: 'Progressivement, introduis un « journal de victoires » : 1 ligne par jour sur ce qui a marché. En 30 jours, tu auras une preuve irréfutable de tes progrès — et un outil contre les jours de doute.',
    identity: 'Dis à voix haute : « Je suis quelqu\'un qui reconnaît ses progrès chaque jour — parce que ce que je célèbre, je le reproduis. »',
    keyPoint: 'Fête ce que tu veux voir plus souvent. Célébrer une victoire, c\'est programmer le cerveau à vouloir la répéter. Sans célébration, la boucle de renforcement positif est incomplète.',
    schema: 'Action → Résultat (même modeste) → Reconnaissance consciente → Dopamine → Envie de recommencer. Supprimer l\'étape 3, c\'est couper le circuit de la motivation intrinsèque.',
    goFurther: 'Qu\'est-ce qui t\'empêche de te féliciter sans te sentir prétentieux ? Identifier cette croyance limitante sur la célébration — souvent culturelle — c\'est déjà à moitié la dissoudre.',
    mcq: (
      'Pourquoi célébrer immédiatement après une petite réussite est-il efficace ?',
      ['Pour se vanter auprès des autres', 'Parce que la dopamine libérée crée une association qui augmente la répétition du comportement', 'Pour compenser les efforts importants', 'Pour éviter la fatigue décisionnelle'],
      1,
    ),
    trueFalse: ('Le cerveau libère de la dopamine uniquement pour les grandes réussites significatives — pas pour les petites victoires quotidiennes.', false),
    swipe: ('J\'ai identifié et reconnu au moins une réussite concrète cette semaine que je mérite de célébrer.', true),
    exercises: [
      ('Journal des victoires — 7 jours', 'Chaque soir pendant 7 jours, note 1 réussite dans ce domaine, aussi petite soit-elle. Lis-la à voix haute. Le rituel de reconnaissance crée l\'habitude de voir ses progrès.', 'reflection'),
      ('Design de ta récompense personnalisée', 'Crée ta récompense post-rituel : quelque chose de petit, immédiat et plaisant qui n\'annule pas l\'effort. (2 minutes de musique préférée, un thé, un moment de silence.) Associe-la systématiquement au rituel accompli.', 'tip'),
      ('Lettre au futur toi', 'Écris une lettre à toi-même dans 3 mois, en listant les victoires que tu t\'attends à avoir accumulées. Relis-la dans 90 jours — l\'écart entre ce que tu écris et ce que tu vis réellement est souvent surprenant.', 'challenge'),
      ('Audit des victoires jamais célébrées', 'Liste 5 progrès que tu as faits dans ta vie et que tu n\'as jamais vraiment honorés. Pour chacun, dis à voix haute : « Je suis fier de ça. » Cette reconnaissance tardive est valide et utile.', 'reflection'),
      ('Partage d\'une victoire', 'Partage une petite réussite avec quelqu\'un de confiance — en personne ou par message. La reconnaissance sociale amplifie l\'effet neurologique de la célébration et renforce l\'engagement.', 'action'),
      ('Tracker visuel de progression', 'Crée un suivi visuel (tableau, app, post-it) où tu coches chaque jour réussi. Voir la chaîne se construire jour après jour est en soi une forme de célébration qui nourrit la motivation.', 'challenge'),
    ],
  ),

  // ─── Ch 4 : Surmonter les obstacles ──────────────────────────────────────
  _ChapterDNA(
    essential: 'Les obstacles ne sont pas des signaux d\'arrêt — ce sont des données. Chaque friction rencontrée dans ta pratique te dit précisément où concentrer ton prochain effort. L\'obstacle prévu perd la moitié de son pouvoir.',
    fact: 'La recherche sur la résilience comportementale est claire : les personnes qui anticipent et planifient leurs obstacles réussissent 2,5× plus souvent que celles qui espèrent simplement « ne pas en avoir ». L\'imprévu préparé devient un inconvénient gérable.',
    change: 'Sans stratégie d\'obstacle, le premier imprévu sérieux devient un abandon. L\'absence de plan B transforme chaque écart en échec perçu — et l\'échec perçu précède l\'abandon réel dans 73 % des cas selon les études sur les habitudes.',
    reflect: 'Quel est l\'obstacle qui t\'a déjà fait abandonner une bonne habitude dans le passé ? Avec ce que tu sais aujourd\'hui, qu\'aurais-tu fait différemment à ce moment précis ?',
    tip: 'La règle des deux jours : après un écart, reviens à ta pratique dans les 48 heures. Deux jours manqués consécutifs est la ligne à ne pas franchir — passé ce seuil, l\'habitude se désintègre rapidement.',
    challenge: 'Identifie tes 3 obstacles les plus probables dans ce domaine dans les 30 prochains jours. Pour chacun, formule un « Si [obstacle], alors [action de récupération précise] ». Écris-les dès maintenant.',
    deeper: 'L\'écart n\'efface pas tes progrès accumulés — il n\'affecte que le jour en cours. Un mois de pratique régulière avec 3 jours manqués vaut infiniment plus qu\'une semaine parfaite suivie d\'un abandon total.',
    identity: 'Dis à voix haute : « Je suis quelqu\'un qui rebondit vite — parce que je sais que l\'écart est prévisible et que la récupération est toujours possible. »',
    keyPoint: 'La résilience n\'est pas de ne jamais tomber — c\'est de réduire le temps entre la chute et le lever. Prépare ta récupération avant d\'en avoir besoin, quand tu es encore dans un bon état d\'esprit.',
    schema: 'Obstacle prévu → Plan B activé → Reprise rapide (même mini) → Momentum restauré. Sans l\'étape 2 (Plan B pré-conçu), l\'obstacle devient une décision à prendre sous stress.',
    goFurther: 'Quel serait ton discours bienveillant à un ami proche qui vient de rater 3 jours de pratique et culpabilise ? Applique-toi exactement ce même discours — l\'auto-compassion accélère la récupération.',
    mcq: (
      'Comment la planification préalable des obstacles améliore-t-elle les résultats ?',
      ['Elle garantit qu\'aucun obstacle ne survient', 'Elle réduit l\'impact des obstacles en activant un plan B déjà réfléchi sous pression', 'Elle élimine le besoin de motivation', 'Elle remplace le travail régulier'],
      1,
    ),
    trueFalse: ('Un seul écart dans une pratique régulière annule tous les progrès accumulés jusqu\'alors.', false),
    swipe: ('J\'ai un plan B écrit et concret pour au moins un des obstacles probables de ma pratique.', true),
    exercises: [
      ('Cartographie des obstacles (30 jours)', 'Liste 5 obstacles qui pourraient interrompre ta pratique dans les 30 prochains jours. Pour chacun, note sa probabilité (1-5), son impact potentiel (1-5), et ta stratégie de récupération précise.', 'challenge'),
      ('Le protocole de récupération', 'Rédige ton protocole post-écart en 3 étapes concrètes : ce que tu te dis, ce que tu fais dans l\'heure suivante, et comment tu reprends le lendemain. Garde-le dans un endroit visible.', 'tip'),
      ('Simulation d\'obstacle', 'Fais ton rituel délibérément dans des conditions difficiles (fatigué, peu de temps, distrait). Prouve à ton cerveau que tu peux maintenir une version réduite même dans les mauvais jours.', 'action'),
      ('Analyse d\'un abandon passé', 'Pense à une habitude que tu as abandonnée dans le passé. Identifie l\'obstacle déclencheur précis et le moment exact de la décision d\'arrêter. Qu\'aurais-tu dû avoir en place pour rebondir ?', 'reflection'),
      ('Lettre à l\'obstacle', 'Écris une lettre au principal obstacle que tu anticipes, comme s\'il était une personne. Explique-lui pourquoi il n\'aura pas le dessus cette fois. Cet exercice clarifie ton engagement et renforce ta résolution.', 'challenge'),
      ('Allié de relance', 'Identifie 1 personne qui peut te relancer quand tu décroches. Envoie-lui un message aujourd\'hui pour lui expliquer ton objectif et lui demander de te contacter si tu disparais 5 jours.', 'action'),
    ],
  ),

  // ─── Ch 5 : Approfondir la pratique ──────────────────────────────────────
  _ChapterDNA(
    essential: 'La maîtrise ne vient pas de répéter indéfiniment la même chose — elle vient de varier les angles, de tester des approches différentes et de solliciter le même concept dans des contextes nouveaux. La diversité dans la pratique est le carburant de la progression.',
    fact: 'Anders Ericsson, spécialiste mondial de l\'expertise, a démontré que ce sont les heures de pratique DÉLIBÉRÉE — variée, ciblée sur les zones de faiblesse, légèrement hors zone de confort — qui créent l\'excellence. Pas la répétition mécanique du même geste.',
    change: 'Une pratique qui ne varie jamais crée un plateau durable. Le cerveau cesse de former de nouvelles connexions neuronales quand le défi disparaît. La stagnation prolongée est le signal que tu dois impérativement changer d\'angle.',
    reflect: 'Quel aspect de ce domaine n\'as-tu encore jamais vraiment exploré — par peur de l\'inconfort, par manque de curiosité, ou simplement parce que tu ne savais pas qu\'il existait ?',
    tip: 'Cherche ton « défi optimal » : légèrement au-dessus de ton niveau actuel, pas au point de te paralyser. La zone d\'apprentissage maximale est exactement à la frontière entre le confort et l\'inconfort.',
    challenge: 'Cette semaine, essaie une approche que tu n\'as jamais testée dans ce domaine. Pas la meilleure — une simplement différente. Ce que tu apprends sur toi en l\'essayant a plus de valeur que le résultat.',
    deeper: 'L\'apprentissage entrelacé (mixer plusieurs sous-domaines dans la même session) est moins confortable que la répétition bloquée, mais crée une rétention à long terme 40 % supérieure selon la recherche cognitive.',
    identity: 'Dis à voix haute : « Je suis quelqu\'un qui explore activement de nouveaux angles dans ce domaine — parce que la curiosité est mon meilleur outil de progression. »',
    keyPoint: 'Varier les approches dans ta pratique n\'est pas de la dispersion — c\'est de l\'optimisation. Chaque angle nouveau renforce la compréhension globale du domaine de façon que la répétition seule ne peut pas atteindre.',
    schema: 'Compétence actuelle → Nouvel angle introduit → Inconfort productif temporaire → Nouvelles connexions neuronales → Niveau supérieur consolidé. Répéter sans varier, c\'est rester au même étage.',
    goFurther: 'Quel maître dans ce domaine t\'inspire le plus — et quelle est l\'approche spécifique de sa pratique qui te semble la plus différente de la tienne ? Qu\'est-ce qui t\'en a éloigné jusqu\'ici ?',
    mcq: (
      'Qu\'est-ce que la pratique délibérée selon les recherches d\'Ericsson ?',
      ['Répéter mécaniquement pendant de longues heures', 'Une pratique variée, ciblée sur les zones de faiblesse et légèrement hors zone de confort', 'Pratiquer uniquement ce qu\'on maîtrise déjà', 'S\'entraîner sans feedback ni ajustement'],
      1,
    ),
    trueFalse: ('Répéter exactement la même chose pendant des milliers d\'heures suffit à atteindre la maîtrise dans n\'importe quel domaine.', false),
    swipe: ('J\'ai exploré au moins une approche différente de ce domaine cette semaine que je n\'avais jamais testée auparavant.', true),
    exercises: [
      ('Exploration d\'une méthode inconnue', 'Identifie une sous-pratique ou méthode de ce domaine que tu n\'as jamais essayée. Pratique-la pendant 15 minutes aujourd\'hui sans chercher à performer. Note : qu\'est-ce que ça révèle ?', 'challenge'),
      ('Interview d\'un praticien avancé', 'Trouve quelqu\'un plus avancé dans ce domaine (personne, vidéo, livre). Identifie une approche qu\'il utilise que tu n\'as pas encore intégrée — et comprends pourquoi il l\'a choisie.', 'research'),
      ('Pratique en contexte difficile', 'Applique ta pratique dans un contexte inhabituellement exigeant. Les conditions difficiles révèlent les vraies compétences et accélèrent le développement des compétences robustes.', 'action'),
      ('Décomposition en sous-compétences', 'Liste 6 à 8 sous-compétences qui composent ce domaine. Classe-les de ta plus forte à ta plus faible. Ta prochaine session cible spécifiquement ta plus faible.', 'reflection'),
      ('Feedback d\'un œil extérieur', 'Montre ta pratique à quelqu\'un d\'autre, même un novice. Les questions d\'un débutant révèlent des angles morts que les praticiens expérimentés ne perçoivent plus.', 'tip'),
      ('Session d\'exploration libre', 'Réserve 30 minutes pour explorer ce domaine librement, sans objectif de performance — juste de la curiosité pure. Note 3 découvertes que tu n\'avais pas anticipées.', 'action'),
    ],
  ),

  // ─── Ch 6 : Développer ta régularité ─────────────────────────────────────
  _ChapterDNA(
    essential: 'La régularité n\'est pas une question de volonté — c\'est une question d\'architecture. Concevoir son environnement pour que la bonne pratique soit la chose la plus facile à faire est plus puissant que n\'importe quelle résolution.',
    fact: 'Une étude du University College London montre que les personnes qui modifient leur environnement physique pour faciliter une nouvelle pratique réussissent à la maintenir 3× plus souvent que celles qui comptent uniquement sur leur discipline et leur motivation.',
    change: 'Sans design environnemental conscient, l\'environnement par défaut sabote la pratique : notifications incessantes, objets mal rangés, lieux non associés à la concentration. L\'environnement par défaut est rarement un allié de la régularité.',
    reflect: 'Qu\'est-ce que dans ton environnement actuel rend ta pratique plus difficile qu\'elle ne devrait l\'être ? Et qu\'est-ce qu\'un changement simple pourrait faire pour la rendre presque inévitable ?',
    tip: 'Augmente le coût de l\'abandon et réduis le coût de la pratique. Exemple : laisser le livre ouvert sur la table (plutôt que rangé dans l\'armoire) réduit la friction d\'entrée de façon spectaculaire.',
    challenge: 'Réorganise un aspect de ton espace physique ou numérique pour que ta pratique soit visible, accessible et quasi-inévitable. Fais ce changement dans les 20 prochaines minutes — pas plus tard.',
    deeper: 'La règle du « jamais deux fois de suite » est plus puissante que la règle du « jamais rater ». Un système qui tolère les jours difficiles avec une version réduite est plus solide qu\'un système parfait mais fragile.',
    identity: 'Dis à voix haute : « Je suis quelqu\'un dont l\'environnement travaille pour ma pratique — parce que j\'ai conçu mon espace pour faciliter ce qui compte. »',
    keyPoint: 'Ton environnement vote pour ou contre tes habitudes à chaque instant de la journée. Concevoir un environnement qui vote pour toi est l\'investissement avec le meilleur rapport effort/résultat en termes de régularité.',
    schema: 'Environnement optimisé → Friction réduite → Décision facilitée → Action automatique → Régularité → Progression exponentielle dans le temps.',
    goFurther: 'Comment combiner environnement physique, social et numérique pour créer une pression positive vers ta pratique ? Lequel de ces trois environnements est ton levier le plus sous-exploité ?',
    mcq: (
      'Selon la recherche comportementale, qu\'est-ce qui soutient le mieux la régularité à long terme ?',
      ['La volonté et la discipline pure', 'La modification de l\'environnement pour réduire la friction', 'La pression sociale négative et la peur d\'échouer', 'La récompense financière externe'],
      1,
    ),
    trueFalse: ('Modifier son environnement physique pour faciliter une pratique est plus efficace sur le long terme que de compter sur sa seule motivation quotidienne.', true),
    swipe: ('Mon environnement actuel est organisé de façon à faciliter ma pratique — pas à la rendre plus difficile.', true),
    exercises: [
      ('Audit de l\'environnement', 'Fais le tour de ton espace principal. Identifie 3 éléments qui créent de la friction pour ta pratique et 3 qui la facilitent. Supprime une friction ce soir. Juste une.', 'action'),
      ('Design du déclencheur visuel', 'Place un déclencheur visuel (objet, note, rappel) dans un endroit que tu vois obligatoirement chaque jour, au moment où ta pratique devrait avoir lieu. Sois créatif et personnel.', 'tip'),
      ('Œil extérieur sur l\'environnement', 'Demande à quelqu\'un d\'observer ton espace de vie ou de travail. Selon lui, qu\'est-ce qui te pousse naturellement vers ou contre ta pratique ? L\'œil externe voit ce que l\'habitude a rendu invisible.', 'research'),
      ('Temptation bundling', 'Associe ta pratique à quelque chose que tu aimes déjà : podcast préféré, café, musique. Tu n\'accèdes à ce plaisir QUE pendant la pratique. L\'association crée une motivation intrinsèque puissante.', 'challenge'),
      ('Définition de la version minimale', 'Définis ta pratique réduite pour les jours difficiles : 2 minutes, 1 répétition, le geste le plus simple possible. C\'est ce qui maintient la chaîne vivante quand les conditions ne sont pas idéales.', 'reflection'),
      ('Engagement contraignant', 'Crée un engagement externe concret : pari symbolique avec un ami, inscription à quelque chose, conséquence prévue si tu rates. Un engagement externe libère l\'énergie mentale qui irait à la décision quotidienne.', 'action'),
    ],
  ),

  // ─── Ch 7 : Mesurer tes progrès ───────────────────────────────────────────
  _ChapterDNA(
    essential: 'Ce qui ne se mesure pas ne s\'améliore pas — mais ce qui est mal mesuré décourage. Un bon indicateur est simple, personnel, visible et lié directement à ce qui compte réellement pour toi, pas à ce que les autres mesurent.',
    fact: 'Une méta-analyse de 138 études publiée dans le Psychological Bulletin montre que le suivi visible de ses progrès augmente de 42 % les chances d\'atteindre ses objectifs. La mesure transforme le flou en information — et l\'information en décision.',
    change: 'Sans mesure, on navigue à l\'intuition. On surévalue les bonnes périodes, sous-estime les progrès réels et on ne sait pas quand ajuster le cap. Dans 60 jours, sans repère, tu ne sauras pas si tu as vraiment progressé ou non.',
    reflect: 'Comment sauras-tu, dans 30 jours précisément, que tu as progressé dans ce domaine ? Quel signe concret et observable te le montrera — sans que quelqu\'un d\'autre ait besoin de te le dire ?',
    tip: 'Choisis maximum 2 indicateurs : un pour les INPUT (la pratique — « J\'ai fait X ») et un pour l\'OUTPUT (le résultat — « J\'observe Y »). Les deux ensemble donnent une image complète sans créer de surcharge.',
    challenge: 'Définis tes 2 indicateurs de progrès maintenant et crée un système de suivi que tu pourras consulter une fois par semaine. Simple, visible, régulier.',
    deeper: 'Les indicateurs de process (faire l\'action) sont plus motivants à court terme que les indicateurs de résultat (obtenir le résultat). Commence par mesurer ce que tu contrôles directement — les résultats suivront.',
    identity: 'Dis à voix haute : « Je suis quelqu\'un qui sait où il en est parce qu\'il mesure ce qui compte — et qui ajuste sa trajectoire en fonction des données, pas des humeurs. »',
    keyPoint: 'Un bon indicateur te dit si tu avances et dans quelle direction — sans te juger. Il transforme l\'incertitude en information et l\'information en décision éclairée.',
    schema: 'Mesure → Analyse (une fois par semaine) → Ajustement → Action améliorée → Nouvelle mesure. Sans ce cycle, on répète les mêmes efforts et on appelle ça « manque de talent ».',
    goFurther: 'Y a-t-il quelque chose dans ta pratique actuelle que tu pourrais commencer à mesurer — et qui changerait radicalement ta façon d\'aborder ce domaine si tu le voyais en données concrètes ?',
    mcq: (
      'Quel type d\'indicateur est le plus motivant pour maintenir une pratique à court terme ?',
      ['Un indicateur de résultat final complexe', 'Un indicateur de process simple (la pratique elle-même, ce qu\'on contrôle)', 'La comparaison avec les autres pratiquants', 'Un indicateur précis mais difficile à calculer'],
      1,
    ),
    trueFalse: ('Utiliser de nombreux indicateurs différents pour suivre ses progrès améliore la clarté et augmente la motivation.', false),
    swipe: ('J\'ai défini au moins un indicateur concret et mesurable pour suivre ma progression dans ce domaine.', true),
    exercises: [
      ('Design du tableau de bord minimal', 'Crée un suivi simple avec 2 colonnes : date + indicateur(s). Complète-le pendant 14 jours consécutifs. La régularité du suivi est en elle-même révélatrice de ton engagement.', 'action'),
      ('Rétrospective hebdomadaire', 'Chaque dimanche soir, réponds à 3 questions en 5 minutes : Qu\'est-ce qui a bien fonctionné ? Qu\'est-ce qui a résisté ? Qu\'est-ce que j\'ajuste la semaine prochaine ?', 'reflection'),
      ('Baseline établie aujourd\'hui', 'Mesure ton niveau actuel avec ton indicateur principal dès aujourd\'hui. Ce chiffre est ton point de référence absolu. Dans 30 jours, tu le remesureras — la différence sera ton progrès visible et réel.', 'fact'),
      ('Analyse des patterns de performance', 'Regarde tes données des 2 dernières semaines. À quel moment de la journée ou de la semaine tu pratiques le mieux ? Le moins bien ? L\'analyse de patterns précède toujours l\'optimisation efficace.', 'research'),
      ('Ajustement basé sur les données', 'Si une de tes métriques stagne depuis 10 jours, c\'est le signal d\'ajuster — pas d\'abandonner. Identifie une variable à changer (heure, durée, approche) et teste-la exactement 7 jours.', 'challenge'),
      ('Mesure de l\'énergie subjective', 'Ajoute à ton suivi une note sur 5 de ton énergie au moment de la pratique. En 2 semaines, tu verras les patterns qui te font pratiquer au meilleur et au pire de toi — et tu pourras les exploiter.', 'tip'),
    ],
  ),

  // ─── Ch 8 : Élever le niveau d'exigence ───────────────────────────────────
  _ChapterDNA(
    essential: 'Le plateau est le signal que ton niveau actuel de pratique ne génère plus de défi suffisant. Pour progresser à nouveau, tu dois augmenter l\'exigence — en durée, en complexité ou en intensité — de façon délibérée et progressive.',
    fact: 'Le concept de « zone proximale de développement » de Vygotski : la progression maximale se produit là où la difficulté dépasse légèrement la compétence actuelle. Trop facile → ennui et stagnation. Trop difficile → abandon. La frontière exacte entre les deux : c\'est là que la croissance réelle se produit.',
    change: 'Rester au même niveau de difficulté, c\'est choisir activement la stagnation. Le cerveau est câblé pour l\'efficacité : il arrête de créer de nouvelles connexions dès que la tâche devient automatique et ne représente plus de défi.',
    reflect: 'À quel niveau de difficulté es-tu actuellement dans ce domaine — trop facile, juste bien, ou trop difficile ? Et comment le rendrais-tu concrètement 10 % plus exigeant dès cette semaine ?',
    tip: 'La règle des 10 % : augmente l\'exigence de 10 % à la fois (durée, complexité, fréquence), pas de 100 %. L\'escalade progressive prévient le découragement mental autant que la blessure physique.',
    challenge: 'Cette semaine, augmente l\'exigence d\'un aspect précis de ta pratique de 10 à 15 %. Pas plus, pas moins. Note la sensation d\'inconfort productif au moment de l\'effort — c\'est le signe que tu es dans la bonne zone.',
    deeper: 'L\'inconfort productif est fondamentalement différent de la souffrance ou de l\'épuisement. C\'est la sensation d\'effort concentré dans la zone de challenge — pas de douleur. Apprendre à distinguer les deux est une compétence méta-essentielle.',
    identity: 'Dis à voix haute : « Je suis quelqu\'un qui cherche activement le niveau d\'exigence qui me fait grandir — parce que l\'inconfort productif est la preuve de ma progression. »',
    keyPoint: 'Sans surcharge progressive, il n\'y a pas de progression réelle. Chaque plateau est une invitation à réévaluer le niveau de challenge — pas un signal de changer de domaine ou de baisser les bras.',
    schema: 'Niveau actuel → Identification du plafond → Augmentation ciblée de 10 % → Inconfort productif → Adaptation du cerveau et du corps → Nouveau niveau stabilisé → Répéter le cycle.',
    goFurther: 'Quels sont les 2-3 aspects de ta pratique où tu te retiens consciemment ou inconsciemment de monter le niveau ? Qu\'est-ce qui t\'en empêche réellement — peur de l\'échec, confort, manque de méthode ?',
    mcq: (
      'Dans quelle zone la progression maximale se produit-elle selon la recherche en sciences de l\'apprentissage ?',
      ['Dans la zone de confort total, sans aucun stress', 'Dans la zone légèrement au-delà de la compétence actuelle, avec un défi gérable', 'Dans la zone de grande difficulté et de stress élevé', 'En dehors de toute routine et structure'],
      1,
    ),
    trueFalse: ('Augmenter l\'exigence de plus de 50 % d\'un coup est la stratégie la plus efficace pour progresser rapidement dans un domaine.', false),
    swipe: ('J\'ai identifié un aspect précis de ma pratique où je peux augmenter l\'exigence de 10 % cette semaine sans me décourager.', true),
    exercises: [
      ('Diagnostic de plateau', 'Identifie les 2-3 aspects de ta pratique qui semblent devenus faciles ou automatiques. Ce sont tes zones de plateau — et donc tes prochaines zones de progression à cibler.', 'reflection'),
      ('Plan de surcharge progressive sur 4 semaines', 'Conçois un plan sur 4 semaines où tu augmentes l\'exigence sur un aspect précis chaque semaine. Écris les objectifs mesurables pour chaque semaine — la spécificité rend le plan actionnable.', 'challenge'),
      ('Simulation de la zone de challenge', 'Pratique pendant 20 minutes dans une condition 15-20 % plus difficile que d\'habitude. Note ton niveau d\'inconfort (1-10) et ce que ça révèle sur tes vraies limites actuelles.', 'action'),
      ('Mesure de performance avant/après', 'Mesure ta performance actuelle sur un aspect précis (temps, qualité, fréquence). Dans 2 semaines, remesure après avoir augmenté l\'exigence. La différence est ta preuve tangible de progression.', 'fact'),
      ('Référence avancée à observer', 'Identifie quelqu\'un dont le niveau d\'exigence dans ce domaine dépasse clairement le tien. Observe une de ses sessions. Qu\'est-ce qui est fondamentalement différent dans son niveau d\'exigence et son approche ?', 'research'),
      ('Test des limites réelles', 'Essaie quelque chose dans ce domaine que tu pensais trop difficile pour toi. Pas pour réussir — pour voir où est vraiment ton plafond. Il est souvent bien plus haut qu\'on ne le croit.', 'action'),
    ],
  ),

  // ─── Ch 9 : Optimiser ta stratégie ───────────────────────────────────────
  _ChapterDNA(
    essential: 'La stratégie optimale n\'existe pas dans les livres — elle se construit à partir de données réelles sur TOI. Ce qui fonctionne pour un expert est un point de départ, pas une vérité absolue. Ton expérience personnelle est ta meilleure source d\'optimisation.',
    fact: 'Le principe de Pareto appliqué à l\'apprentissage : 20 % des pratiques génèrent 80 % des résultats. Identifier et amplifier ces 20 % — puis réduire ou éliminer le reste — est systématiquement la stratégie la plus puissante à ce niveau de progression.',
    change: 'Sans optimisation, on accumule des efforts sans discernement : on fait « plus » au lieu de faire « mieux ». L\'efficacité sans efficience est du travail gâché — beaucoup d\'énergie investie pour un retour décevant.',
    reflect: 'Si tu devais supprimer 50 % de ce que tu fais dans ta pratique actuelle et ne garder que l\'essentiel, qu\'est-ce que tu garderais absolument — et pourquoi ?',
    tip: 'Analyse d\'abord tes résultats RÉCENTS (7 à 14 derniers jours), pas tes résultats globaux. Les données récentes sont plus indicatives de ta dynamique actuelle que les résultats anciens qui ne reflètent plus ton niveau.',
    challenge: 'Cette semaine, identifie les 2 pratiques qui t\'ont donné le meilleur retour ces 30 derniers jours. Double le temps et l\'attention que tu leur accordes. Observe ce qui se passe.',
    deeper: 'L\'optimisation n\'est pas une destination — c\'est un cycle permanent. Ce qui est optimal aujourd\'hui ne le sera plus dans 3 mois, quand ton niveau aura changé. Révise ta stratégie régulièrement et sans attachement.',
    identity: 'Dis à voix haute : « Je suis quelqu\'un qui optimise continuellement sa méthode à partir de ses propres données — parce que ma stratégie personnelle est plus efficace que la stratégie générique. »',
    keyPoint: 'Travailler plus ne compense pas travailler sur les mauvaises choses. Identifier tes 20 % les plus efficaces et leur consacrer la majorité de ton énergie est systématiquement la stratégie la plus rentable.',
    schema: 'Analyse 80/20 → Identification des leviers réels → Concentration de l\'énergie → Résultats amplifiés → Suppression du superflu → Réévaluation régulière.',
    goFurther: 'Quelles sont les croyances ou habitudes « sacrées » de ta pratique actuelle que tu n\'as jamais remises en question ? Méritent-elles vraiment leur place dans ta stratégie à ce stade ?',
    mcq: (
      'Comment appliquer le principe de Pareto pour optimiser une pratique ?',
      ['Faire absolument tout à 100 % sans distinction', 'Identifier les 20 % d\'actions qui génèrent 80 % des résultats et les amplifier', 'Supprimer tout ce qui est difficile ou inconfortable', 'Copier exactement la méthode d\'un expert reconnu'],
      1,
    ),
    trueFalse: ('Faire plus d\'efforts dans n\'importe quelle direction compense toujours une stratégie sous-optimale.', false),
    swipe: ('J\'ai identifié les 2-3 pratiques qui me donnent les meilleurs résultats et je leur consacre désormais plus d\'attention et d\'énergie.', true),
    exercises: [
      ('Analyse 80/20 personnelle', 'Liste toutes tes activités dans ce domaine. Pour chacune, note le retour sur investissement perçu (1-5). Identifie les 2 qui obtiennent 5/5. Comment leur donner concrètement plus de place cette semaine ?', 'reflection'),
      ('Expérimentation contrôlée sur 2 semaines', 'Choisis 1 variable précise à tester (heure différente, durée différente, approche différente). Mesure l\'impact sur 2 semaines. Décision finale : garder ou abandonner — basée sur des données, pas des impressions.', 'action'),
      ('Revue mensuelle de stratégie', 'Pose-toi ces 4 questions chaque mois : Qu\'est-ce qui fonctionne vraiment ? Qu\'est-ce qui ne fonctionne pas ? Qu\'est-ce que j\'arrête immédiatement ? Qu\'est-ce que j\'essaie le mois prochain ?', 'challenge'),
      ('Benchmark avec ta meilleure session', 'Compare ta pratique actuelle à ta meilleure session des 3 derniers mois. Qu\'est-ce qui était différent — environnement, état, méthode ? Reproduire les conditions optimales est une stratégie en soi.', 'fact'),
      ('Suppression du superflu', 'Identifie 3 choses dans ta pratique qui prennent du temps sans générer de résultats mesurables. Supprime-les ou réduis-les drastiquement. Libérer de l\'espace et de l\'énergie est aussi une forme de croissance.', 'tip'),
      ('Stratégie documentée en une page', 'Rédige en une page ta stratégie actuelle : ce que tu fais, pourquoi, à quelle fréquence, comment tu mesures. Un document qu\'on peut réviser est infiniment plus utile qu\'un plan flou dans la tête.', 'challenge'),
    ],
  ),

  // ─── Ch 10 : Ancrer durablement ───────────────────────────────────────────
  _ChapterDNA(
    essential: 'La durabilité d\'une pratique ne dépend pas de la volonté — elle dépend de l\'identité. Quand tu te définis comme quelqu\'un qui pratique (et non quelqu\'un qui essaie), le comportement devient une expression de qui tu es — pas une lutte contre qui tu es.',
    fact: 'James Clear, s\'appuyant sur des décennies de recherche en psychologie comportementale, a montré que les personnes qui s\'identifient à leur pratique (« je suis quelqu\'un qui... ») maintiennent leurs habitudes 70 % plus longtemps que celles définies par un objectif (« j\'essaie de... »).',
    change: 'Sans ancrage identitaire, chaque jour recommence à zéro : la question « est-ce que je le fais aujourd\'hui ? » se pose indéfiniment. Avec une identité ancrée, la question disparaît — c\'est simplement qui tu es, et tu ne te questionnes plus.',
    reflect: 'Qui serais-tu si ce domaine faisait pleinement partie de ton identité ? Qu\'est-ce qui changerait concrètement dans tes décisions quotidiennes, tes priorités, la façon dont tu te présentes aux autres ?',
    tip: 'Commence par voter pour l\'identité avec de petites actions répétées. Chaque fois que tu pratiques, tu votes pour « je suis ce genre de personne ». Après 100 votes accumulés, l\'identité est solidement installée.',
    challenge: 'Écris 5 affirmations au présent qui décrivent qui tu es dans ce domaine (pas qui tu veux devenir — qui tu es MAINTENANT, à ce niveau actuel). Lis-les à voix haute matin et soir pendant 7 jours.',
    deeper: 'L\'ancrage identitaire n\'est pas de l\'auto-persuasion ou du wishful thinking — c\'est de la cohérence comportementale. On n\'agit pas en contradiction avec notre identité déclarée. On cherche à être cohérent avec elle.',
    identity: 'Dis à voix haute : « Je suis quelqu\'un dont cette pratique fait partie intégrante de l\'identité — ce n\'est plus un effort, c\'est simplement qui je suis. »',
    keyPoint: 'Les habitudes durables naissent de l\'identité, pas des objectifs. Décider qui on est d\'abord — et laisser les comportements en découler naturellement — est le mécanisme le plus robuste de changement durable.',
    schema: 'Décision d\'identité → Actions alignées quotidiennes → Preuves accumulées → Identité renforcée → Actions encore plus naturelles. L\'identité et le comportement se renforcent mutuellement dans une spirale positive.',
    goFurther: 'Dans 5 ans, quelle est la version de toi qui a pleinement intégré ce domaine à son identité ? Décris sa journée type, ses habitudes concrètes, comment les autres le voient et comment il se voit.',
    mcq: (
      'Selon la recherche, quel facteur prédit le mieux la durabilité d\'une habitude à long terme ?',
      ['La force de la motivation initiale au démarrage', 'L\'identification à la pratique comme partie intégrante de son identité', 'La sévérité des conséquences en cas d\'abandon', 'La fréquence des récompenses externes'],
      1,
    ),
    trueFalse: ('Se définir comme « quelqu\'un qui pratique » plutôt que « quelqu\'un qui essaie » est associé à une persistance significativement supérieure dans l\'habitude.', true),
    swipe: ('Je me décris déjà, au moins en partie, comme quelqu\'un qui appartient à ce domaine de pratique — pas seulement comme quelqu\'un qui essaie.', true),
    exercises: [
      ('Déclaration d\'identité affichée', 'Complète et affiche cette phrase où tu la vois chaque jour : « Je suis quelqu\'un qui [comportement clé] parce que [valeur profonde]. » Sois précis, personnel et au présent.', 'reflection'),
      ('Collection de preuves d\'identité', 'Liste 10 moments — même minuscules — où tu as agi en accord avec cette identité. Ces preuves réelles renforcent la croyance que c\'est vraiment qui tu es, pas qui tu voudrais être.', 'fact'),
      ('Plan des 90 prochains jours', 'Crée un plan précis pour les 3 prochains mois : objectifs par mois, fréquence de pratique, jalons de progression et indicateurs de réussite. L\'identité a besoin d\'une roadmap concrète.', 'challenge'),
      ('Environnement identitaire', 'Modifie un aspect de ton environnement pour qu\'il reflète visuellement ton identité de praticien (livre visible, espace dédié, objet symbolique). L\'environnement reflète et renforce l\'identité.', 'action'),
      ('Engagement identitaire public', 'Dis à 3 personnes de ton entourage que tu es quelqu\'un qui pratique sérieusement ce domaine. L\'engagement public solidifie l\'identité intérieure de façon mesurable.', 'action'),
      ('Lettre d\'ancrage futur', 'Écris une lettre à toi-même dans 1 an. Décris qui tu es dans ce domaine, ce que tu pratiques régulièrement et ce que ça a concrètement changé dans ta vie. Relis-la dans 12 mois.', 'challenge'),
    ],
  ),

  // ─── Ch 11 : Devenir expert et autonome ───────────────────────────────────
  _ChapterDNA(
    essential: 'L\'expertise n\'est pas un niveau atteint une fois pour toutes — c\'est une pratique permanente d\'apprentissage, d\'enseignement et d\'adaptation. L\'expert autonome n\'a plus besoin d\'un programme extérieur : il crée le sien et s\'en devient lui-même le meilleur architecte.',
    fact: 'La recherche sur l\'expertise montre que les vrais experts apprennent différemment des novices : en enseignant, en créant, en challengeant leurs propres modèles mentaux. La rétention par l\'enseignement atteint 90 % (contre 10 % en lecture passive) — c\'est la méthode d\'ancrage la plus puissante connue.',
    change: 'Sans autonomie développée, on reste dépendant de programmes extérieurs, de validations externes et d\'instructions détaillées. L\'autonomie, c\'est pouvoir naviguer en terrain inconnu sans GPS — en s\'appuyant sur des principes profondément intégrés.',
    reflect: 'Qu\'est-ce que tu sais maintenant sur ce domaine que tu ne savais pas au début de ce programme ? Et quel est le principe le plus contre-intuitif que tu as découvert et que tu pourrais transmettre à un débutant ?',
    tip: 'La meilleure façon de mesurer ton niveau d\'expertise : essaie d\'enseigner un concept à quelqu\'un qui débute. Les questions qu\'il pose révèlent exactement les zones où ta compréhension a encore des lacunes invisibles.',
    challenge: 'Crée un mini-guide — même une seule page — sur ce domaine à destination d\'un débutant. Ce que tu inclus et ce que tu choisis d\'omettre révèle ce que tu as vraiment profondément intégré.',
    deeper: 'L\'expert autonome continue d\'apprendre — mais par curiosité profonde, pas par obligation. Il cherche activement les zones d\'ignorance plutôt que de les éviter, parce qu\'il sait que c\'est là que se cache la prochaine croissance.',
    identity: 'Dis à voix haute : « Je suis quelqu\'un qui maîtrise suffisamment ce domaine pour le transmettre — et qui continue de progresser par pure curiosité, pas par obligation. »',
    keyPoint: 'L\'autonomie complète, c\'est ne plus avoir besoin d\'être guidé pour pratiquer, progresser et s\'adapter. C\'est le but ultime de tout apprentissage : faire de ce domaine une partie permanente et créative de ta vie.',
    schema: 'Maîtrise des fondations → Pratique délibérée variée → Transmission à d\'autres → Création de sa propre méthode → Autonomie complète et curiosité permanente.',
    goFurther: 'Dans quelle direction ce domaine va-t-il t\'emmener ensuite — quels sous-domaines, quelles applications, quelles connexions avec d\'autres domaines t\'excitent le plus maintenant que tu as les bases ?',
    mcq: (
      'Pourquoi l\'enseignement est-il considéré comme l\'une des méthodes d\'apprentissage les plus efficaces pour ancrer durablement ?',
      ['Parce que ça impressionne l\'entourage', 'Parce qu\'expliquer à voix haute force à clarifier sa compréhension et révèle les lacunes invisibles', 'Parce que c\'est plus facile que de pratiquer soi-même', 'Parce que ça remplace la pratique personnelle régulière'],
      1,
    ),
    trueFalse: ('Un expert autonome dans un domaine n\'a plus besoin d\'apprendre — il sait déjà tout ce qu\'il y a à savoir.', false),
    swipe: ('Je suis capable de guider un débutant dans les bases essentielles de ce domaine en m\'appuyant sur mes propres expériences et apprentissages.', true),
    exercises: [
      ('Guide du débutant complet', 'Rédige un guide d\'une page pour quelqu\'un qui commence dans ce domaine. Inclus : les 3 premiers pas essentiels, les 2 erreurs à absolument éviter, et la chose la plus importante à comprendre dès le début.', 'challenge'),
      ('Synthèse du parcours complet', 'Relis tes notes depuis le début du programme. Identifie les 5 idées les plus importantes que tu as retenues et intégrées. Ordonne-les du plus fondamental au plus avancé.', 'reflection'),
      ('Session d\'enseignement réelle', 'Enseigne un concept clé du domaine à quelqu\'un — en personne, par message ou en écrivant. Note les questions posées : elles révèlent exactement tes zones grises restantes.', 'action'),
      ('Ton programme personnel sur 3 mois', 'Conçois ton propre programme des 3 prochains mois : thèmes à explorer, pratiques à développer, ressources à consulter, indicateurs de progression. Deviens l\'architecte de ton propre apprentissage.', 'challenge'),
      ('Référence au niveau suivant', 'Identifie 1-2 références au niveau que tu vises maintenant (livre, praticien, approche). Qu\'est-ce qui distingue fondamentalement leur rapport au domaine de celui d\'un débutant ?', 'research'),
      ('Bilan de transformation avant/après', 'Compare ta version du premier jour à ta version aujourd\'hui sur 5 dimensions : connaissance, pratique, mindset, régularité, confiance en soi. Note de 1 à 10 pour chaque dimension. Célèbre la distance parcourue.', 'reflection'),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Module builder — uses _ChapterDNA for unique per-chapter content
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
    m['question'] = {'question': qText, 'options': qOptions, 'answerIndex': qAnswer};
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
  final dna = _dna[i];
  final intensity = _levelMeta[level - 1].$4;

  // 12 steps — each chapter has unique bodies via _ChapterDNA.
  final steps = <Map<String, dynamic>>[
    // 0 — text · L'essentiel
    _step('L\'essentiel', dna.essential, 'text',
        qText: 'Tu connais déjà ce sujet ?',
        qOptions: ['Un peu', 'Pas du tout']),
    // 1 — fact · Le savais-tu ?
    _step('Le savais-tu ?', dna.fact, 'fact',
        qText: 'Ce fait te surprend ?',
        qOptions: ['Oui, vraiment !', 'Je le savais déjà']),
    // 2 — text · Ce que ça change
    _step('Ce que ça change', dna.change, 'text',
        qText: 'Tu as déjà ressenti cet enjeu ?',
        qOptions: ['Oui, plusieurs fois', 'Pas vraiment']),
    // 3 — reflection · Et toi ?
    _step('Et toi ?', dna.reflect, 'reflection',
        qText: 'As-tu réfléchi à cette question récemment ?',
        qOptions: ['Oui, souvent', 'Rarement']),
    // 4 — action · Mini-action (TIMER AUTO) — domain-specific via flavor
    _step('Mini-action maintenant',
        'Lance le timer et fais-le maintenant : ${f.practice}.', 'action',
        qText: 'Tu es prêt à passer à l\'action ?',
        qOptions: ['À fond ! 🔥', 'J\'y vais doucement']),
    // 5 — tip · Astuce de pro
    _step('Astuce de pro', dna.tip, 'tip',
        qText: 'Cette astuce te semble applicable ?',
        qOptions: ['Oui, je l\'adopte', 'J\'y réfléchis']),
    // 6 — challenge · Défi du chapitre
    _step('Défi du chapitre', dna.challenge, 'challenge',
        qText: 'Quand tu relèves ce défi ?',
        qOptions: ['Aujourd\'hui même', 'Dans les 48h']),
    // 7 — text · Un cran plus loin
    _step('Un cran plus loin', dna.deeper, 'text',
        qText: 'Ce niveau de réflexion t\'interpelle ?',
        qOptions: ['Oui, fortement', 'Je vais y revenir']),
    // 8 — reflection · Ancrage identitaire
    _step('Ancrage identitaire', dna.identity, 'reflection',
        qText: 'Comment ancrer durablement cette pratique ?',
        qOptions: ['En la reliant à son identité', 'En comptant sur la volonté'],
        qAnswer: 0),
    // 9 — text · Le point clé
    _step('Le point clé', dna.keyPoint, 'text',
        qText: 'Ce point clé est clair pour toi ?',
        qOptions: ['Oui, c\'est limpide', 'J\'y réfléchis encore']),
    // 10 — framework · Le schéma mental
    _step('Le schéma', dna.schema, 'framework',
        qText: 'Tu visualises ce schéma mentalement ?',
        qOptions: ['Oui, clairement', 'Pas encore tout à fait']),
    // 11 — research · Pour aller plus loin
    _step('Pour aller plus loin', dna.goFurther, 'research',
        qText: 'Cette question t\'ouvre de nouvelles pistes ?',
        qOptions: ['Oui, plusieurs', 'Je vais explorer']),
  ];

  // Exercises: unique per chapter via _ChapterDNA.
  final exercises = dna.exercises
      .map((e) => _exercise(e.$1, e.$2, e.$3))
      .toList();

  final levelBonus = level - 1;
  final stepSet = {..._kStepIndices[tier]!};
  var added = 0;
  for (var k = 0; k < steps.length && added < levelBonus; k++) {
    if (stepSet.add(k)) added++;
  }
  final filteredSteps = [
    for (var k = 0; k < steps.length; k++)
      if (stepSet.contains(k)) steps[k],
  ];

  final exerciseCount =
      (_kExerciseCount[tier]! + levelBonus).clamp(0, exercises.length);
  final filteredExercises = exercises.take(exerciseCount).toList();

  return {
    'id': 'm${i + 1}',
    'level': level,
    'title': 'Ch. ${i + 1} — ${ch.title}',
    'summary': ch.summary,
    'content': 'Niveau $intensity. ${ch.content(d, f)}',
    'steps': filteredSteps,
    'exercises': filteredExercises,
    'quiz': _moduleQuiz(i),
  };
}

// ---------------------------------------------------------------------------
// Per-chapter quiz — unique questions via _ChapterDNA
// ---------------------------------------------------------------------------

List<Map<String, dynamic>> _moduleQuiz(int i) {
  final dna = _dna[i];
  final mcq = dna.mcq;
  final tf = dna.trueFalse;
  final sw = dna.swipe;
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
      'question': tf.$1,
      'answer': tf.$2,
      'chapter': i,
    },
    {
      'type': 'swipe',
      'question': 'Glisse à droite si c\'est vrai pour toi : « ${sw.$1} »',
      'answer': sw.$2,
      'chapter': i,
    },
  ];
}

// ---------------------------------------------------------------------------
// Parts: 3 groups of 4 chapters + transversal quiz
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
        'quiz': _partQuiz(chapterGroups[li]),
      },
  ];
}

List<Map<String, dynamic>> _partQuiz(List<int> chs) {
  final q = <Map<String, dynamic>>[];
  for (final i in chs) {
    final mcq = _dna[i].mcq;
    q.add({'type': 'mcq', 'question': mcq.$1, 'options': mcq.$2, 'answerIndex': mcq.$3, 'chapter': i});
  }
  for (final i in [chs.first, chs.last]) {
    final tf = _dna[i].trueFalse;
    q.add({'type': 'truefalse', 'question': tf.$1, 'answer': tf.$2, 'chapter': i});
  }
  for (final i in [chs[1], chs[2]]) {
    final sw = _dna[i].swipe;
    q.add({'type': 'swipe', 'question': 'Glisse à droite si vrai : « ${sw.$1} »', 'answer': sw.$2, 'chapter': i});
  }
  return q;
}

// ---------------------------------------------------------------------------
// Final quiz — covers all 12 chapters
// ---------------------------------------------------------------------------

List<Map<String, dynamic>> _finalQuiz(String d, _Flavor f) {
  final q = <Map<String, dynamic>>[];
  for (var i = 0; i < _dna.length; i++) {
    final mcq = _dna[i].mcq;
    q.add({'type': 'mcq', 'question': mcq.$1, 'options': mcq.$2, 'answerIndex': mcq.$3, 'chapter': i});
  }
  for (final i in const [0, 2, 4, 6, 8, 10]) {
    final tf = _dna[i].trueFalse;
    q.add({'type': 'truefalse', 'question': tf.$1, 'answer': tf.$2, 'chapter': i});
  }
  for (final i in const [1, 3, 5, 7, 9, 11]) {
    final sw = _dna[i].swipe;
    q.add({'type': 'swipe', 'question': 'Glisse à droite si vrai : « ${sw.$1} »', 'answer': sw.$2, 'chapter': i});
  }
  q.add({
    'type': 'mcq',
    'question': 'Pour ancrer durablement « ${f.goal} », mieux vaut :',
    'options': [
      'La relier à ton identité et à un moment fixe quotidien',
      'Compter uniquement sur la motivation du moment',
      'Tout faire en une seule grande session hebdomadaire',
      'Attendre le moment parfait pour commencer',
    ],
    'answerIndex': 0,
    'difficulty': 2,
  });
  return q;
}

// ---------------------------------------------------------------------------
// Detail quiz bank — harder questions for retention checks
// ---------------------------------------------------------------------------

List<Map<String, dynamic>> _detailQuiz() {
  final q = <Map<String, dynamic>>[];
  for (var i = 0; i < _dna.length; i++) {
    final dna = _dna[i];
    final mcq = dna.mcq;
    q.add({
      'type': 'mcq',
      'question': 'Approfondissement Ch.${i + 1} — ${mcq.$1}',
      'options': mcq.$2,
      'answerIndex': mcq.$3,
      'difficulty': 2,
      'chapter': i,
    });
    final tf = dna.trueFalse;
    q.add({
      'type': 'truefalse',
      'question': tf.$1,
      'answer': tf.$2,
      'difficulty': 3,
      'chapter': i,
    });
  }
  return q;
}
