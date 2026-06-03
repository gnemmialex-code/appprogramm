/// Expert-mode program generator.
///
/// Produces a 15-chapter, 3-level program with 10 steps and 8 exercises per
/// chapter. Two exclusive step types are used:
///   • `framework` — a named model or analytical framework
///   • `research`  — a research-based insight with scientific backing
///
/// Language is professional, precise and assumes the learner is willing to
/// tackle complexity. No hand-holding; every step challenges thinking.
library;

import 'dart:convert';

// ---------------------------------------------------------------------------
// Public chapter preview for the expert detail screen
// ---------------------------------------------------------------------------

typedef ExpertChapterPreview = ({String title, String summary, int level});

const List<ExpertChapterPreview> kExpertChapters = [
  // Level 1 — Socle Expert (Ch. 1-5)
  (
    title: 'Cadre conceptuel avancé',
    summary: 'Pose les fondations théoriques rigoureuses du domaine.',
    level: 1,
  ),
  (
    title: 'Frameworks de référence',
    summary: 'Maîtrise les modèles analytiques utilisés par les experts.',
    level: 1,
  ),
  (
    title: 'Déconstruction des biais courants',
    summary: 'Identifie et neutralise les erreurs de raisonnement fréquentes.',
    level: 1,
  ),
  (
    title: 'Analyse approfondie du terrain',
    summary:
        'Cartographie ta situation réelle avec précision et sans complaisance.',
    level: 1,
  ),
  (
    title: 'Modèles mentaux de l\'expert',
    summary: 'Adopte les schémas de pensée des praticiens de haut niveau.',
    level: 1,
  ),
  // Level 2 — Maîtrise (Ch. 6-10)
  (
    title: 'Techniques avancées pratiquées',
    summary: 'Applique des méthodes complexes dans des contextes réels.',
    level: 2,
  ),
  (
    title: 'Études de cas complexes',
    summary:
        'Analyse des situations ambiguës et tire des principes transférables.',
    level: 2,
  ),
  (
    title: 'Mesure et optimisation experte',
    summary: 'Conçois des indicateurs précis et optimise ta trajectoire.',
    level: 2,
  ),
  (
    title: 'Nuances et contre-intuitions',
    summary: 'Maîtrise les paradoxes et subtilités que les débutants ignorent.',
    level: 2,
  ),
  (
    title: 'Gestion de la complexité',
    summary: 'Navigue dans l\'ambiguïté avec méthode et sang-froid.',
    level: 2,
  ),
  // Level 3 — Excellence (Ch. 11-15)
  (
    title: 'Innovation dans la pratique',
    summary: 'Crée tes propres approches à partir des principes maîtrisés.',
    level: 3,
  ),
  (
    title: 'Transmission et leadership',
    summary: 'Développe ta capacité à guider et élever les autres.',
    level: 3,
  ),
  (
    title: 'Intégration systémique',
    summary: 'Connecte ce domaine à l\'ensemble de ta vie et de ta stratégie.',
    level: 3,
  ),
  (
    title: 'Recherche et avant-garde',
    summary: 'Explore les frontières du domaine et anticipe son évolution.',
    level: 3,
  ),
  (
    title: 'La voie de la maîtrise',
    summary:
        'Intègre tout — méthode, identité, transmission — en un système personnel.',
    level: 3,
  ),
];

const List<(int, String, String, String)> _expertLevelMeta = [
  (1, 'Socle Expert', 'Fondations théoriques et frameworks', 'socle'),
  (2, 'Maîtrise', 'Application avancée et complexité', 'maîtrise'),
  (
    3,
    'Excellence',
    'Innovation, leadership et intégration totale',
    'excellence',
  ),
];

// ---------------------------------------------------------------------------
// Flavor (same structure as standard generator)
// ---------------------------------------------------------------------------

class _Flavor {
  final String goal;
  final String practice;
  final String win;
  const _Flavor(this.goal, this.practice, this.win);
}

_Flavor _defaultFlavor(String d) => _Flavor(
  'atteindre l\'excellence en $d',
  'une pratique délibérée et critique de 20 minutes',
  'une maîtrise mesurable et transmissible',
);

// Same flavors as standard but with expert framing
const Map<String, _Flavor> _flavors = {
  'Psychologie': _Flavor(
    'maîtriser les mécanismes psychologiques profonds',
    'une analyse critique de tes propres schémas cognitifs',
    'une prise de conscience transformatrice',
  ),
  'Anxiété': _Flavor(
    'comprendre et moduler ton système nerveux autonome',
    'une pratique de régulation neurophysiologique',
    'une réponse calibrée au lieu d\'une réaction automatique',
  ),
  'Productivité': _Flavor(
    'concevoir des systèmes de haute performance durables',
    'une session de travail en profondeur, sans aucune interruption',
    'un livrable complexe terminé',
  ),
  'Sport': _Flavor(
    'optimiser ta performance avec une approche scientifique',
    'un entraînement délibéré axé sur la faiblesse identifiée',
    'une progression mesurable sur un indicateur précis',
  ),
  'Nutrition': _Flavor(
    'maîtriser la science de la nutrition appliquée',
    'une analyse critique de tes apports et leur impact physiologique',
    'un ajustement nutritionnel basé sur des données',
  ),
  'Relations': _Flavor(
    'développer une intelligence relationnelle de haut niveau',
    'une conversation difficile abordée avec intention et méthode',
    'une connexion plus profonde ou un conflit résolu',
  ),
  'Sommeil': _Flavor(
    'optimiser ta neurobiologie du sommeil',
    'un protocole de récupération basé sur la chronobiologie',
    'une nuit à architecture de sommeil optimisée',
  ),
  'Confiance': _Flavor(
    'construire une confiance fondée sur la compétence prouvée',
    'une action délibérément inconfortable, choisie et réflexive',
    'une preuve concrète ajoutée à ton inventaire de capacités',
  ),
};

// ---------------------------------------------------------------------------
// Expert chapter content (15 chapters, technical language)
// ---------------------------------------------------------------------------

class _ExpertChapter {
  final String title;
  final String summary;
  final String Function(String d, _Flavor f) content;
  const _ExpertChapter(this.title, this.summary, this.content);
}

const List<_ExpertChapter> _chapters = [
  _ExpertChapter(
    'Cadre conceptuel avancé',
    'Pose les fondations théoriques rigoureuses.',
    _ec0,
  ),
  _ExpertChapter(
    'Frameworks de référence',
    'Maîtrise les modèles analytiques experts.',
    _ec1,
  ),
  _ExpertChapter(
    'Déconstruction des biais',
    'Identifie et neutralise tes erreurs de raisonnement.',
    _ec2,
  ),
  _ExpertChapter(
    'Analyse du terrain',
    'Cartographie ta situation avec précision.',
    _ec3,
  ),
  _ExpertChapter(
    'Modèles mentaux experts',
    'Adopte les schémas de pensée des pros.',
    _ec4,
  ),
  _ExpertChapter(
    'Techniques avancées',
    'Applique des méthodes complexes sur le terrain.',
    _ec5,
  ),
  _ExpertChapter(
    'Études de cas complexes',
    'Analyse des situations ambiguës réelles.',
    _ec6,
  ),
  _ExpertChapter(
    'Mesure & optimisation',
    'Conçois des indicateurs et optimise.',
    _ec7,
  ),
  _ExpertChapter(
    'Nuances & contre-intuitions',
    'Maîtrise les paradoxes que les débutants ignorent.',
    _ec8,
  ),
  _ExpertChapter(
    'Gestion de la complexité',
    'Navigue dans l\'ambiguïté avec méthode.',
    _ec9,
  ),
  _ExpertChapter(
    'Innovation dans la pratique',
    'Crée tes propres approches.',
    _ec10,
  ),
  _ExpertChapter(
    'Transmission & leadership',
    'Guide et élève les autres.',
    _ec11,
  ),
  _ExpertChapter(
    'Intégration systémique',
    'Connecte ce domaine à ta stratégie globale.',
    _ec12,
  ),
  _ExpertChapter(
    'Recherche & avant-garde',
    'Explore les frontières du domaine.',
    _ec13,
  ),
  _ExpertChapter(
    'La voie de la maîtrise',
    'Intègre méthode, identité et transmission.',
    _ec14,
  ),
];

String _ec0(String d, _Flavor f) =>
    'Niveau expert. Avant toute technique, un expert dispose d\'un cadre '
    'conceptuel précis — une carte mentale de $d qui différencie les causes '
    'des symptômes, les variables contrôlables de celles qui ne le sont pas. '
    'Sans ce cadre, même les meilleures techniques restent des outils sans '
    'système. Ton objectif à ce niveau : ${f.goal}. Commence par formaliser '
    'tes hypothèses actuelles sur $d — y compris celles que tu n\'as jamais '
    'questionnées. Les suppositions invisibles sont les plus dangereuses.';

String _ec1(String d, _Flavor f) =>
    'Les experts n\'inventent pas leurs approches — ils maîtrisent d\'abord '
    'les frameworks existants avant de les adapter. En $d, plusieurs modèles '
    'analytiques font consensus dans la littérature spécialisée. '
    'L\'enjeu n\'est pas de les mémoriser, mais de comprendre les postulats '
    'sous-jacents de chacun : dans quels contextes s\'appliquent-ils ? '
    'Quelles sont leurs limites ? Un expert connaît les conditions de '
    'validité de ses outils — un débutant les applique aveuglément.';

String _ec2(String d, _Flavor f) =>
    'La psychologie cognitive identifie plus de 180 biais cognitifs. '
    'En $d, un sous-ensemble spécifique génère la majorité des erreurs : '
    'le biais de confirmation, l\'ancrage, l\'illusion de compétence '
    'et le biais d\'action. Un expert n\'est pas immunisé — il dispose '
    'de protocoles pour les détecter et les corriger en temps réel. '
    'Ce chapitre t\'equipe de ces protocoles. L\'humilité épistémique '
    'n\'est pas une faiblesse — c\'est la condition de la rigueur.';

String _ec3(String d, _Flavor f) =>
    'L\'analyse du terrain en $d exige plus qu\'une observation superficielle. '
    'Elle requiert une triangulation : données quantitatives, retours '
    'qualitatifs et patterns comportementaux sur la durée. '
    'Un expert sait distinguer corrélation et causalité, signal et bruit. '
    'La cartographie rigoureuse de ta situation actuelle est le prérequis '
    'absolu d\'une intervention efficace. Agir sans diagnistic complet '
    'est l\'une des erreurs expertes les plus fréquentes — et les plus coûteuses.';

String _ec4(String d, _Flavor f) =>
    'Les modèles mentaux sont les lentilles à travers lesquelles les experts '
    'perçoivent $d. Ils comprennent notamment : la pensée systémique '
    '(effets de second ordre), l\'inversion (raisonner depuis la fin), '
    'l\'effet de levier (trouver le point critique) et la pensée contrefactuelle '
    '(qu\'est-ce qui aurait changé si ?). Acquérir ces modèles transforme '
    'ta façon de poser les problèmes — et des problèmes bien posés sont '
    'à moitié résolus.';

String _ec5(String d, _Flavor f) =>
    'La maîtrise de $d s\'acquiert par une pratique délibérée — '
    'terme de la psychologie de l\'expertise développé par Anders Ericsson. '
    'Elle diffère de la simple répétition : elle cible spécifiquement '
    'les zones de faiblesse, intègre un feedback immédiat, et opère '
    'légèrement au-delà de la zone de confort actuelle. '
    '${f.practice.replaceFirst(f.practice[0], f.practice[0].toUpperCase())} — '
    'avec intention et analyse, pas en pilote automatique.';

String _ec6(String d, _Flavor f) =>
    'L\'étude de cas est la méthode pédagogique des meilleures business '
    'schools pour une raison : elle force à raisonner dans l\'ambiguïté '
    'réelle, sans données parfaites ni réponse unique. En $d, analyser '
    'des situations complexes réelles — y compris tes propres échecs — '
    'développe un jugement que nul cours théorique ne peut remplacer. '
    'La question n\'est jamais "quelle est la bonne réponse ?" mais '
    '"quels étaient les facteurs, les contraintes et les compromis ?"';

String _ec7(String d, _Flavor f) =>
    'Ce qui ne se mesure pas avec précision ne s\'optimise pas. '
    'En $d, la plupart des praticiens mesurent des proxies (ce qui est '
    'facile à mesurer) plutôt que des outcomes réels. Un expert conçoit '
    'ses propres indicateurs : lagging (résultats historiques), leading '
    '(prédicteurs futurs) et process (qualité de la pratique). '
    'L\'optimisation experte consiste à itérer sur la méthode elle-même, '
    'pas seulement sur les efforts.';

String _ec8(String d, _Flavor f) =>
    'En $d, plusieurs principes contre-intuitifs opèrent à haut niveau. '
    'Exemple : plus on maîtrise un domaine, plus on perçoit sa complexité '
    '(effet Dunning-Kruger inversé). Autre contre-intuition : ralentir '
    'délibérément pour accélérer — la précision sacrifiée pour la vitesse '
    'crée des erreurs qui coûtent plus de temps à corriger qu\'elles n\'en '
    'font gagner. Maîtriser ces paradoxes est la marque d\'une pensée experte.';

String _ec9(String d, _Flavor f) =>
    'La complexité en $d ne se résout pas — elle se gère. '
    'Les systèmes complexes sont caractérisés par des non-linéarités, '
    'des boucles de rétroaction et des propriétés émergentes. '
    'L\'erreur classique de l\'expert intermédiaire est d\'appliquer '
    'des solutions linéaires à des problèmes complexes. '
    'La méthode : cartographier les boucles, identifier les leviers '
    'systémiques et accepter l\'incertitude résiduelle.';

String _ec10(String d, _Flavor f) =>
    'Après avoir maîtrisé les frameworks existants, l\'étape suivante '
    'est de les synthétiser en une approche personnelle de $d. '
    'Non par ego — mais parce que chaque contexte est unique et que '
    'les meilleures solutions émergent de la collision entre méthodes '
    'établies et contraintes spécifiques. Ton framework personnel '
    'doit être testable (falsifiable), itérable et communicable à d\'autres.';

String _ec11(String d, _Flavor f) =>
    'La capacité à transmettre une expertise est le test ultime de '
    'sa maîtrise — "si tu ne peux pas l\'expliquer simplement, '
    'c\'est que tu ne le comprends pas assez" (Feynman). '
    'En $d, guider quelqu\'un d\'autre révèle les lacunes invisibles '
    'dans ta propre compréhension et consolide les acquis par '
    'le mécanisme de l\'enseignment-apprentissage. '
    'C\'est aussi un acte d\'engagement envers la communauté du domaine.';

String _ec12(String d, _Flavor f) =>
    '$d ne fonctionne pas en silo. À haut niveau, les experts connectent '
    'leur domaine à leurs objectifs de vie plus larges, à d\'autres '
    'disciplines (cross-pollination) et à leur impact sur leur entourage. '
    'Cette intégration systémique transforme une compétence en un '
    'avantage stratégique durable. Comment $d s\'articule-t-il avec '
    'tes autres priorités ? Quelles synergies ou tensions existent ?';

String _ec13(String d, _Flavor f) =>
    'L\'avant-garde de $d évolue constamment. Les experts de demain '
    'seront ceux qui lisent la recherche primaire aujourd\'hui, '
    'pas les résumés d\'il y a cinq ans. Ce chapitre t\'outille pour '
    'naviguer dans la littérature spécialisée : distinguer la preuve '
    'solide de la spéculation, comprendre les méthodologies et '
    'identifier les chercheurs et praticiens dont les travaux comptent '
    'vraiment dans le champ de $d.';

String _ec14(String d, _Flavor f) =>
    'La maîtrise n\'est pas une destination — c\'est un mode d\'être. '
    'À ce stade, ${f.goal} n\'est plus un objectif mais une évidence '
    'quotidienne. Ce dernier chapitre synthétise : ton framework '
    'personnel, tes indicateurs de progression, ta pratique de '
    'transmission et ta place dans l\'écosystème de $d. '
    'L\'expert accompli n\'est plus défini par ce qu\'il sait, '
    'mais par comment il pense, agit et contribue.';

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

String generateExpertContent(String domaine, {String? objectif}) {
  final d = domaine.trim();
  var f = _flavors[d] ?? _defaultFlavor(d);
  if (objectif != null && objectif.trim().isNotEmpty) {
    f = _Flavor(objectif.trim(), f.practice, f.win);
  }

  final modules = [
    for (var i = 0; i < _chapters.length; i++)
      _buildExpertModule(i, (i ~/ 5) + 1, d, f),
  ];

  final program = {
    'domain': d,
    'level': 3,
    'title': 'Programme Expert · $d',
    'subtitle': '🎓 Mode Expert · 15 chapitres · contenu de haut niveau',
    'modules': modules,
    'parts': _buildExpertParts(d, f),
    'quiz': _expertFinalQuiz(d, f),
    'finalSummary':
        'Félicitations — tu as traversé les 15 chapitres du programme '
        'Expert « $d ». Ce niveau de rigueur, peu de gens l\'atteignent. '
        'Tu ne "sais" plus seulement $d — tu le maîtrises, tu peux '
        'l\'enseigner, l\'innover et l\'intégrer à ta stratégie globale. '
        '${f.goal} n\'est plus un horizon lointain : c\'est désormais '
        'qui tu es.',
  };

  return jsonEncode(program);
}

// ---------------------------------------------------------------------------
// Module builder — 10 expert steps + 8 exercises
// ---------------------------------------------------------------------------

Map<String, dynamic> _step(String title, String body, String type) => {
  'title': title,
  'body': body,
  'type': type,
};

Map<String, dynamic> _exercise(String title, String instruction, String type) =>
    {'title': title, 'instruction': instruction, 'type': type};

Map<String, dynamic> _buildExpertModule(int i, int level, String d, _Flavor f) {
  final ch = _chapters[i];
  final lvlLabel = _expertLevelMeta[level - 1].$4;

  final steps = [
    _step(
      'Mise en contexte expert',
      'Niveau $lvlLabel. ${ch.content(d, f)}',
      'text',
    ),
    _step(
      'Framework de référence',
      'Quel modèle analytique reconnu s\'applique à « ${ch.title} » '
          'dans $d ? Identifie-le, nomme ses composants clés et ses '
          'conditions d\'application. Un expert ne travaille jamais sans '
          'cadre — même si ce cadre évolue.',
      'framework',
    ),
    _step(
      'Ce que la recherche montre',
      'Des études dans le domaine de $d montrent que « ${ch.title} » '
          'a des effets mesurables. La recherche scientifique distingue '
          'ce qui est prouvé (réplication, méta-analyses) de ce qui est '
          'plausible (études isolées) et de ce qui est mythe populaire. '
          'Positionne tes croyances actuelles sur cet axe.',
      'research',
    ),
    _step(
      'Réflexion critique',
      'Question experte : quelles hypothèses implicites fais-tu sur '
          '« ${ch.title} » dans $d ? Lesquelles n\'ont jamais été '
          'testées concrètement ? L\'expert interroge ses certitudes '
          'avec la même rigueur qu\'il analyse les données.',
      'reflection',
    ),
    _step(
      'Technique avancée',
      '${f.practice.replaceFirst(f.practice[0], f.practice[0].toUpperCase())} — '
          'mais cette fois avec une grille d\'analyse : avant, pendant, après. '
          'Note les variables contextuelles qui influencent le résultat. '
          'La pratique délibérée sans feedback structuré n\'est que '
          'de la répétition coûteuse.',
      'action',
    ),
    _step(
      'La nuance que les experts connaissent',
      'En $d, « ${ch.title} » cache une subtilité que la majorité '
          'ignore : le contexte détermine quelle approche s\'applique. '
          'Ce qui fonctionne dans un environnement échoue dans un autre. '
          'Un expert calibre son intervention selon le contexte — '
          'il ne cherche pas la solution universelle.',
      'fact',
    ),
    _step(
      'Analyse systémique',
      'Comment « ${ch.title} » s\'inscrit-il dans le système plus large '
          'de $d ? Quels effets de second ordre produit-il ? '
          'Quelles boucles de rétroaction active-t-il ? '
          'La pensée systémique révèle les leviers invisibles que '
          'l\'analyse linéaire rate toujours.',
      'text',
    ),
    _step(
      'L\'erreur subtile des experts',
      'Attention : les praticiens avancés en $d font souvent cette '
          'erreur sur « ${ch.title} » — over-optimiser un composant '
          'au détriment du système global. '
          'La maîtrise crée des angles morts spécifiques. '
          'Lequel guette ta pratique actuelle ?',
      'tip',
    ),
    _step(
      'Défi de maîtrise',
      'Défi expert sur « ${ch.title} » dans $d : conçois une '
          'situation d\'application inédite, où les conditions ne sont '
          'pas idéales et où tu dois improviser avec méthode. '
          'Vise ${f.win}. Documente ta démarche, pas seulement le résultat.',
      'challenge',
    ),
    _step(
      'Ancrage expert',
      'Complète : « En tant qu\'expert de $d, ma façon d\'aborder '
          '« ${ch.title} » est fondamentalement différente parce que… » '
          'Cette phrase ne parle pas de technique — elle parle de '
          'ta transformation épistémique.',
      'reflection',
    ),
  ];

  final exercises = [
    _exercise(
      'Analyse critique',
      'Évalue ton approche actuelle de « ${ch.title} » dans $d '
          'avec un regard de chercheur : qu\'est-ce que tu sais réellement '
          'vs. ce que tu crois savoir ? Quelles preuves as-tu ?',
      'reflection',
    ),
    _exercise(
      'Application avancée',
      'Applique la technique principale de ce chapitre dans '
          'un contexte délibérément difficile — pas idéal, '
          'pas confortable. Note les adaptations nécessaires.',
      'action',
    ),
    _exercise(
      'Revue de recherche',
      'Trouve une étude ou un article sur « ${ch.title} » dans $d. '
          'Identifie la méthodologie, la taille d\'échantillon et '
          'la force des conclusions. Valide ou infirme tes croyances actuelles.',
      'research',
    ),
    _exercise(
      'Étude de cas personnel',
      'Analyse un moment récent dans $d où tu as appliqué '
          '« ${ch.title} ». Quels facteurs ont influencé le résultat ? '
          'Qu\'aurais-tu fait différemment avec ta compréhension actuelle ?',
      'challenge',
    ),
    _exercise(
      'Auto-évaluation experte',
      'Sur une échelle 1-10, évalue ta maîtrise de « ${ch.title} » '
          'sur cinq dimensions : compréhension théorique, application '
          'pratique, adaptabilité contextuelle, capacité d\'enseignement, '
          'et pensée critique. Identifie ta dimension la plus faible.',
      'reflection',
    ),
    _exercise(
      'Framework personnel',
      'Crée ton propre mini-framework pour « ${ch.title} » dans $d. '
          'Il doit tenir en 3-5 principes, être testable et '
          'améliorable. Nomme-le.',
      'framework',
    ),
    _exercise(
      'Enseigner pour apprendre',
      'Explique « ${ch.title} » dans $d à quelqu\'un qui ne connaît '
          'pas le domaine. Sans jargon. En 5 minutes. '
          'Note où tu butes — c\'est là que ta compréhension '
          'a des lacunes.',
      'challenge',
    ),
    _exercise(
      'Plan d\'implémentation',
      'Conçois un plan sur 2 semaines pour intégrer les principes '
          'de « ${ch.title} » dans ta pratique quotidienne de $d. '
          'Avec indicateurs, jalons et protocole de révision.',
      'action',
    ),
  ];

  return {
    'id': 'em${i + 1}',
    'level': level,
    'title': 'Expert Ch. ${i + 1} — ${ch.title}',
    'summary': ch.summary,
    'content': 'Mode Expert · niveau $lvlLabel. ${ch.content(d, f)}',
    'steps': steps,
    'exercises': exercises,
    'quiz': _expertModuleQuiz(i, d, f),
  };
}

// ---------------------------------------------------------------------------
// Expert quiz — harder questions with nuanced distractors
// ---------------------------------------------------------------------------

List<Map<String, dynamic>> _expertModuleQuiz(int i, String d, _Flavor f) {
  final mcq = _expertMcq[i % _expertMcq.length];
  final mcq2 = _expertMcq2[i % _expertMcq2.length];
  return [
    {
      'type': 'mcq',
      'question': mcq.$1,
      'options': mcq.$2,
      'answerIndex': mcq.$3,
    },
    {
      'type': 'mcq',
      'question': mcq2.$1,
      'options': mcq2.$2,
      'answerIndex': mcq2.$3,
    },
    {
      'type': 'truefalse',
      'question': _expertTF[i % _expertTF.length].$1,
      'answer': _expertTF[i % _expertTF.length].$2,
    },
    {
      'type': 'swipe',
      'question':
          'Glisse à droite : « ${_expertSwipe[i % _expertSwipe.length].$1} »',
      'answer': _expertSwipe[i % _expertSwipe.length].$2,
    },
    {
      'type': 'mcq',
      'question': _expertScenario[i % _expertScenario.length].$1,
      'options': _expertScenario[i % _expertScenario.length].$2,
      'answerIndex': _expertScenario[i % _expertScenario.length].$3,
    },
  ];
}

const List<(String, List<String>, int)> _expertMcq = [
  (
    'Quelle est la limite principale d\'un framework appliqué sans contextualisation ?',
    [
      'Il est trop complexe à mémoriser',
      'Il ignore les variables situationnelles déterminantes',
      'Il ne convient qu\'aux débutants',
      'Il manque de données empiriques',
    ],
    1,
  ),
  (
    'En pratique délibérée (Ericsson), quel élément est INDISPENSABLE ?',
    [
      'La répétition massive',
      'Un feedback immédiat et ciblé sur les faiblesses',
      'La motivation intrinsèque élevée',
      'Un mentor certifié',
    ],
    1,
  ),
  (
    'Quelle distinction un expert fait-il systématiquement ?',
    [
      'Simple vs complexe',
      'Corrélation vs causalité',
      'Quantitatif vs qualitatif',
      'Court terme vs long terme',
    ],
    1,
  ),
  (
    'Qu\'est-ce qui distingue un indicateur leading d\'un indicateur lagging ?',
    [
      'Sa précision',
      'Sa capacité à prédire vs à constater',
      'Sa facilité de mesure',
      'Sa fréquence de mise à jour',
    ],
    1,
  ),
  (
    'L\'effet Dunning-Kruger "inversé" chez l\'expert se manifeste par :',
    [
      'Un excès de confiance',
      'Une perception accrue de la complexité et des nuances',
      'Une paralysie décisionnelle',
      'Un rejet des frameworks',
    ],
    1,
  ),
];

const List<(String, List<String>, int)> _expertMcq2 = [
  (
    'Dans un système complexe, quelle approche est la plus appropriée ?',
    [
      'Appliquer une solution linéaire éprouvée',
      'Identifier les boucles de rétroaction et les leviers systémiques',
      'Simplifier le problème jusqu\'à sa forme la plus basic',
      'Déléguer à un spécialiste externe',
    ],
    1,
  ),
  (
    'Pourquoi la pensée contrefactuelle est-elle précieuse pour un expert ?',
    [
      'Elle valide a posteriori les décisions prises',
      'Elle révèle les facteurs causaux en variant les conditions hypothétiquement',
      'Elle prédit le futur avec plus de précision',
      'Elle simplifie l\'analyse rétrospective',
    ],
    1,
  ),
  (
    'L\'inversion (pensée depuis la fin) sert principalement à :',
    [
      'Accélérer la mise en œuvre',
      'Identifier les obstacles et erreurs avant qu\'ils se produisent',
      'Justifier les décisions déjà prises',
      'Simplifier la communication aux équipes',
    ],
    1,
  ),
  (
    'Un expert qui "over-optimise" un composant risque de :',
    [
      'Manquer d\'efficacité sur ce composant',
      'Dégrader la performance globale du système',
      'Perdre de la crédibilité auprès de ses pairs',
      'S\'épuiser prématurément',
    ],
    1,
  ),
  (
    'La transmission d\'une expertise révèle avant tout :',
    [
      'La générosité du transmetteur',
      'Les lacunes invisibles dans sa propre compréhension',
      'La qualité de sa communication',
      'L\'étendue de ses connaissances théoriques',
    ],
    1,
  ),
];

const List<(String, bool)> _expertTF = [
  (
    'Un framework est d\'autant plus utile qu\'on connaît ses limites et ses conditions d\'invalidité.',
    true,
  ),
  (
    'La pratique délibérée et la pratique intensive sont deux termes équivalents.',
    false,
  ),
  ('Un expert expérimenté est immunisé contre les biais cognitifs.', false),
  (
    'Mesurer des proxies plutôt que des outcomes réels est une erreur fréquente d\'optimisation.',
    true,
  ),
  (
    'La complexité d\'un système peut toujours être réduite à une série de causes linéaires.',
    false,
  ),
  (
    'Enseigner un concept à un novice est l\'une des méthodes les plus puissantes pour consolider sa maîtrise.',
    true,
  ),
  (
    'L\'intégration systémique consiste à appliquer un domaine indépendamment des autres.',
    false,
  ),
];

const List<(String, bool)> _expertSwipe = [
  ('Je questionne mes hypothèses implicites avant d\'agir.', true),
  (
    'Un feedback bien conçu sur mes faiblesses vaut mieux que cent répétitions non ciblées.',
    true,
  ),
  (
    'Je cherche une solution universelle applicable à tous les contextes.',
    false,
  ),
  (
    'Je construis mes propres indicateurs plutôt que de copier ceux des autres.',
    true,
  ),
  (
    'La complexité résiduelle d\'un problème est signe d\'une compréhension insuffisante.',
    false,
  ),
  ('Je transmets ce que je sais pour consolider ma propre maîtrise.', true),
  (
    'Maîtriser un framework suffit — l\'adapter au contexte est optionnel.',
    false,
  ),
];

const List<(String, List<String>, int)> _expertScenario = [
  (
    'Tu appliques une méthode éprouvée mais les résultats sont décevants dans ce nouveau contexte. Quelle est ta première action ?',
    [
      'Doubler les efforts en espérant de meilleurs résultats',
      'Analyser les variables contextuelles qui diffèrent du contexte d\'origine',
      'Chercher une méthode plus puissante',
      'Conclure que la méthode est obsolète',
    ],
    1,
  ),
  (
    'Un pair très compétent dit "ça a toujours fonctionné comme ça". Comme expert, tu :',
    [
      'Acceptes — il a plus d\'expérience',
      'Demandes quelles preuves soutiennent cette affirmation',
      'Imposes ta propre méthode',
      'Évites la confrontation',
    ],
    1,
  ),
  (
    'Tu mesures ta progression depuis 3 mois mais ne vois pas d\'amélioration. La première hypothèse à tester est :',
    [
      'Tu ne fais pas assez d\'efforts',
      'Ton indicateur mesure un proxy et non l\'outcome réel',
      'La méthode n\'est pas adaptée à ton profil',
      'Tu as besoin d\'un coach externe',
    ],
    1,
  ),
];

// ---------------------------------------------------------------------------
// Expert parts (3 levels × 5 chapters each)
// ---------------------------------------------------------------------------

List<Map<String, dynamic>> _buildExpertParts(String d, _Flavor f) {
  const ids = ['ep1', 'ep2', 'ep3'];
  const groups = <List<int>>[
    [0, 1, 2, 3, 4],
    [5, 6, 7, 8, 9],
    [10, 11, 12, 13, 14],
  ];
  return [
    for (var li = 0; li < 3; li++)
      <String, dynamic>{
        'id': ids[li],
        'level': _expertLevelMeta[li].$1,
        'title': _expertLevelMeta[li].$2,
        'subtitle': _expertLevelMeta[li].$3,
        'intensity': _expertLevelMeta[li].$4,
        'moduleIds': [for (final i in groups[li]) 'em${i + 1}'],
        'quiz': _expertPartQuiz(groups[li]),
      },
  ];
}

List<Map<String, dynamic>> _expertPartQuiz(List<int> chs) {
  final q = <Map<String, dynamic>>[];
  for (final i in chs) {
    final mcq = _expertMcq[i % _expertMcq.length];
    q.add({
      'type': 'mcq',
      'question': mcq.$1,
      'options': mcq.$2,
      'answerIndex': mcq.$3,
    });
  }
  q.add({
    'type': 'truefalse',
    'question': _expertTF[chs.first % _expertTF.length].$1,
    'answer': _expertTF[chs.first % _expertTF.length].$2,
  });
  q.add({
    'type': 'swipe',
    'question':
        'Glisse à droite : « ${_expertSwipe[chs.last % _expertSwipe.length].$1} »',
    'answer': _expertSwipe[chs.last % _expertSwipe.length].$2,
  });
  return q;
}

List<Map<String, dynamic>> _expertFinalQuiz(String d, _Flavor f) {
  final q = <Map<String, dynamic>>[];
  for (final mcq in _expertMcq) {
    q.add({
      'type': 'mcq',
      'question': mcq.$1,
      'options': mcq.$2,
      'answerIndex': mcq.$3,
    });
  }
  for (final mcq2 in _expertMcq2) {
    q.add({
      'type': 'mcq',
      'question': mcq2.$1,
      'options': mcq2.$2,
      'answerIndex': mcq2.$3,
    });
  }
  for (final tf in _expertTF) {
    q.add({'type': 'truefalse', 'question': tf.$1, 'answer': tf.$2});
  }
  for (final sw in _expertSwipe) {
    q.add({
      'type': 'swipe',
      'question': 'Glisse à droite : « ${sw.$1} »',
      'answer': sw.$2,
    });
  }
  q.add({
    'type': 'mcq',
    'question': 'La marque d\'un vrai expert en $d est :',
    'options': [
      'Connaître toutes les réponses',
      'Savoir quelles questions poser et dans quel contexte',
      'Appliquer le même framework dans tous les contextes',
      'Maîtriser la théorie avant toute pratique',
    ],
    'answerIndex': 1,
  });
  return q;
}
