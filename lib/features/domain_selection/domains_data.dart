import 'package:flutter/material.dart';

import '../../ui/theme/app_colors.dart';

class SubTheme {
  final String id;
  final String label;
  final String emoji;
  final String description;

  const SubTheme({
    required this.id,
    required this.label,
    required this.emoji,
    required this.description,
  });
}

class DomainItem {
  final String id;
  final String label;
  final String tagline;
  final IconData icon;
  final Color color;
  final String description;
  final String whoIsItFor;
  final String before;
  final String after;
  final List<String> highlights;
  final List<SubTheme> subThemes;

  const DomainItem({
    required this.id,
    required this.label,
    required this.tagline,
    required this.icon,
    required this.color,
    required this.description,
    required this.whoIsItFor,
    required this.before,
    required this.after,
    required this.highlights,
    required this.subThemes,
  });
}

const List<DomainItem> kDomains = [
  DomainItem(
    id: 'psychologie',
    label: 'Psychologie',
    tagline: 'Mieux te comprendre',
    icon: Icons.psychology_rounded,
    color: AppColors.lavender,
    description:
        'Plonge au cœur de ton fonctionnement mental et émotionnel. '
        'Comprendre pourquoi tu penses, ressens et réagis comme tu le fais '
        'change tout — dans tes relations, tes choix et ton rapport à toi-même.',
    whoIsItFor:
        'Pour ceux qui veulent se comprendre mieux, surmonter des schémas '
        'répétitifs ou simplement être plus en paix avec eux-mêmes.',
    before:
        'Tu subis tes réactions émotionnelles sans vraiment comprendre d\'où '
        'elles viennent, et tu te retrouves souvent pris dans les mêmes boucles.',
    after:
        'Tu observes tes pensées avec recul, tu comprends tes déclencheurs '
        'et tu agis avec plus de clarté et de bienveillance envers toi-même.',
    highlights: [
      'Les biais cognitifs qui influencent tes décisions au quotidien',
      'Nommer et réguler tes émotions efficacement',
      'Briser les schémas de pensée limitants',
      'Développer une conscience de soi profonde et durable',
    ],
    subThemes: [
      SubTheme(
        id: 'biais',
        label: 'Biais cognitifs',
        emoji: '🧠',
        description:
            'Comprends les erreurs de raisonnement qui guident tes décisions à ton insu.',
      ),
      SubTheme(
        id: 'emotions',
        label: 'Intelligence émotionnelle',
        emoji: '💭',
        description:
            'Identifie, comprends et régule tes émotions avec finesse.',
      ),
      SubTheme(
        id: 'estime',
        label: 'Estime de soi',
        emoji: '🪞',
        description:
            'Construis une image de toi stable et bienveillante, loin des comparaisons.',
      ),
      SubTheme(
        id: 'resilience',
        label: 'Résilience & trauma',
        emoji: '💪',
        description:
            'Apprends à traverser et dépasser les épreuves de façon saine.',
      ),
      SubTheme(
        id: 'attachement',
        label: 'Schémas d\'attachement',
        emoji: '🔗',
        description:
            'Comprends comment ton histoire façonne tes relations actuelles.',
      ),
      SubTheme(
        id: 'motivation',
        label: 'Motivation profonde',
        emoji: '🎯',
        description:
            'Découvre ce qui te pousse vraiment à agir, au-delà de la volonté.',
      ),
      SubTheme(
        id: 'memoire',
        label: 'Mémoire & apprentissage',
        emoji: '📚',
        description:
            'Optimise ton cerveau pour retenir et apprendre plus vite.',
      ),
      SubTheme(
        id: 'pleine-conscience',
        label: 'Pleine conscience',
        emoji: '🧘',
        description:
            'Cultive une présence attentive pour sortir du pilote automatique.',
      ),
      SubTheme(
        id: 'identite',
        label: 'Identité & valeurs',
        emoji: '🌱',
        description:
            'Clarifie qui tu es vraiment et ce qui compte profondément pour toi.',
      ),
    ],
  ),
  DomainItem(
    id: 'anxiete',
    label: 'Anxiété',
    tagline: 'Apaiser ton mental',
    icon: Icons.spa_rounded,
    color: AppColors.sky,
    description:
        'L\'anxiété n\'est pas un ennemi — c\'est un signal mal calibré. '
        'Ce programme te donne des outils concrets pour calmer ton système '
        'nerveux, changer ton rapport aux pensées anxieuses et retrouver '
        'un équilibre durable.',
    whoIsItFor:
        'Pour ceux qui vivent avec une anxiété chronique, des ruminations, '
        'du stress ou qui veulent prévenir l\'épuisement avant qu\'il arrive.',
    before:
        'Les pensées anxieuses gouvernent tes journées et tu ne sais pas '
        'comment les apaiser durablement sans que ça revienne.',
    after:
        'Tu as un arsenal de techniques qui marchent pour toi, tu préviens '
        'les montées d\'anxiété avant qu\'elles débordent.',
    highlights: [
      'Techniques de respiration et de régulation du système nerveux',
      'Changer ton rapport aux pensées négatives et aux ruminations',
      'Créer des routines anti-stress efficaces et plaisantes',
      'S\'ancrer dans le moment présent même sous pression',
    ],
    subThemes: [
      SubTheme(
        id: 'anxiete-sociale',
        label: 'Anxiété sociale',
        emoji: '👥',
        description:
            'Apprivoise la peur du jugement et reprends confiance en société.',
      ),
      SubTheme(
        id: 'stress-burnout',
        label: 'Stress & burnout',
        emoji: '🔥',
        description:
            'Identifie les signaux d\'alarme et restaure ton énergie vitale.',
      ),
      SubTheme(
        id: 'phobies',
        label: 'Phobies & peurs',
        emoji: '😰',
        description:
            'Affronte progressivement et désensibilise tes peurs spécifiques.',
      ),
      SubTheme(
        id: 'perf',
        label: 'Anxiété de performance',
        emoji: '🎭',
        description:
            'Dépasse le trac et l\'anxiété avant les examens, présentations, défis.',
      ),
      SubTheme(
        id: 'ruminations',
        label: 'Ruminations mentales',
        emoji: '💫',
        description:
            'Brise les boucles de pensées négatives qui tournent en rond.',
      ),
      SubTheme(
        id: 'panique',
        label: 'Crises de panique',
        emoji: '⚡',
        description:
            'Comprends et désamorces les crises d\'angoisse dès les premiers signes.',
      ),
      SubTheme(
        id: 'anxiete-nuit',
        label: 'Anxiété nocturne',
        emoji: '🌙',
        description:
            'Apaise ton mental le soir pour retrouver un sommeil paisible.',
      ),
      SubTheme(
        id: 'hyperactivite',
        label: 'Mental surchargé',
        emoji: '🌀',
        description:
            'Calme l\'hyperactivité mentale et retrouve le silence intérieur.',
      ),
    ],
  ),
  DomainItem(
    id: 'productivite',
    label: 'Productivité',
    tagline: 'Avancer sans t\'épuiser',
    icon: Icons.bolt_rounded,
    color: AppColors.sun,
    description:
        'La vraie productivité n\'est pas de travailler plus, c\'est de '
        'travailler mieux — et de préserver ton énergie. Apprends à '
        'organiser ta journée, prioriser l\'essentiel et créer des systèmes '
        'qui fonctionnent sans volonté.',
    whoIsItFor:
        'Pour ceux qui se sentent dépassés, procrastinent, ou cherchent '
        'à faire plus avec moins d\'effort et sans se vider.',
    before:
        'Tu finis tes journées épuisé mais avec le sentiment de n\'avoir '
        'rien accompli de vraiment important. La liste grossit sans cesse.',
    after:
        'Tu avances sur ce qui compte vraiment, avec un système simple '
        'qui tient sur le long terme et te laisse de l\'énergie.',
    highlights: [
      'Prioriser l\'essentiel avec la méthode qui te convient',
      'Vaincre la procrastination à la racine (pas la symptôme)',
      'Créer des systèmes autonomes qui travaillent à ta place',
      'Protéger ton énergie et ta concentration comme des ressources rares',
    ],
    subThemes: [
      SubTheme(
        id: 'gestion-temps',
        label: 'Gestion du temps',
        emoji: '⏰',
        description:
            'Reprends le contrôle de ton agenda et arrête de courir après le temps.',
      ),
      SubTheme(
        id: 'procrastination',
        label: 'Procrastination',
        emoji: '😴',
        description:
            'Comprends et dépasse enfin ce qui te bloque à passer à l\'action.',
      ),
      SubTheme(
        id: 'focus',
        label: 'Focus & concentration',
        emoji: '🎯',
        description:
            'Entraîne ton attention comme un muscle dans un monde de distractions.',
      ),
      SubTheme(
        id: 'energie',
        label: 'Gestion de l\'énergie',
        emoji: '⚡',
        description:
            'Optimise tes pics d\'énergie pour travailler moins mais mieux.',
      ),
      SubTheme(
        id: 'organisation',
        label: 'Organisation & systèmes',
        emoji: '📋',
        description:
            'Crée des systèmes fiables pour ne plus te fier à ta mémoire.',
      ),
      SubTheme(
        id: 'priorisation',
        label: 'Priorisation',
        emoji: '🏆',
        description:
            'Identifie les 20 % d\'efforts qui produisent 80 % des résultats.',
      ),
      SubTheme(
        id: 'creativite',
        label: 'Créativité & flow',
        emoji: '🎨',
        description:
            'Entre dans l\'état de flow et libère ta créativité à la demande.',
      ),
      SubTheme(
        id: 'teletravail',
        label: 'Télétravail & freelance',
        emoji: '💻',
        description:
            'Maîtrise le travail à distance sans perdre discipline ni bien-être.',
      ),
      SubTheme(
        id: 'projet',
        label: 'Gestion de projet',
        emoji: '🚀',
        description:
            'Pilote tes projets du début à la fin sans te noyer dans les détails.',
      ),
    ],
  ),
  DomainItem(
    id: 'sport',
    label: 'Sport',
    tagline: 'Bouger avec plaisir',
    icon: Icons.fitness_center_rounded,
    color: AppColors.mint,
    description:
        'Le sport n\'est pas une punition — c\'est l\'une des meilleures '
        'choses que tu puisses faire pour ton corps ET ton cerveau. '
        'Ce programme t\'aide à trouver une pratique qui te ressemble '
        'et à l\'ancrer durablement dans ta vie.',
    whoIsItFor:
        'Pour ceux qui veulent commencer, reprendre ou approfondir une '
        'pratique sportive sans se blesser ni se décourager en route.',
    before:
        'Tu veux bouger davantage mais tu manques de régularité, de '
        'motivation ou tu ne sais pas par où commencer vraiment.',
    after:
        'Tu as un rituel sportif qui s\'intègre naturellement dans ta vie, '
        'que tu apprécies et que tu maintiens même les jours difficiles.',
    highlights: [
      'Construire une routine d\'entraînement durable et plaisante',
      'Progresser sans se blesser grâce à la surcharge progressive',
      'Trouver le plaisir dans le mouvement (pas la souffrance)',
      'Optimiser la récupération pour mieux performer',
    ],
    subThemes: [
      SubTheme(
        id: 'course',
        label: 'Course à pied',
        emoji: '🏃',
        description:
            'De tes premiers kilomètres aux longues distances — progresser sans se blesser.',
      ),
      SubTheme(
        id: 'muscu',
        label: 'Musculation & force',
        emoji: '💪',
        description:
            'Construis du muscle, de la force et une silhouette à ton image.',
      ),
      SubTheme(
        id: 'yoga',
        label: 'Yoga & souplesse',
        emoji: '🧘',
        description:
            'Développe souplesse, mobilité et calme mental par le mouvement conscient.',
      ),
      SubTheme(
        id: 'cardio',
        label: 'Cardio & endurance',
        emoji: '❤️',
        description:
            'Booste ton cœur et ton souffle pour une énergie au quotidien.',
      ),
      SubTheme(
        id: 'arts-martiaux',
        label: 'Arts martiaux',
        emoji: '🥊',
        description:
            'Discipline du corps et de l\'esprit à travers les arts de combat.',
      ),
      SubTheme(
        id: 'natation',
        label: 'Natation',
        emoji: '🏊',
        description:
            'Technique, endurance et plaisir dans l\'eau — le sport complet.',
      ),
      SubTheme(
        id: 'cyclisme',
        label: 'Cyclisme',
        emoji: '🚴',
        description:
            'Du vélo quotidien à l\'endurance longue distance — pédaler avec méthode.',
      ),
      SubTheme(
        id: 'maison',
        label: 'Fitness à la maison',
        emoji: '🏠',
        description:
            'Entraîne-toi efficacement sans salle ni équipement coûteux.',
      ),
      SubTheme(
        id: 'recuperation',
        label: 'Récupération sportive',
        emoji: '🌿',
        description:
            'Apprends à récupérer pour progresser — le secret des athlètes.',
      ),
    ],
  ),
  DomainItem(
    id: 'nutrition',
    label: 'Nutrition',
    tagline: 'Manger en conscience',
    icon: Icons.restaurant_rounded,
    color: AppColors.peach,
    description:
        'Manger mieux ne demande pas un régime strict — ça demande de la '
        'conscience. Ce programme t\'aide à comprendre ton rapport à la '
        'nourriture, faire de meilleurs choix et trouver un équilibre '
        'qui dure vraiment.',
    whoIsItFor:
        'Pour ceux qui veulent manger plus sainement sans se priver, '
        'comprendre leur corps et sortir du cycle régime-culpabilité.',
    before:
        'Tu oscilles entre bonnes intentions et mauvaises habitudes '
        'alimentaires, sans jamais trouver un équilibre qui tient.',
    after:
        'Tu manges avec conscience, tu comprends les signaux de ton corps '
        'et tu fais des choix alignés avec ton bien-être naturellement.',
    highlights: [
      'Décoder les bases de la nutrition sans mythe ni régime',
      'Développer une alimentation intuitive et durable',
      'Lire et comprendre les étiquettes des produits',
      'Gérer les émotions liées à la nourriture et les compulsions',
    ],
    subThemes: [
      SubTheme(
        id: 'perte-poids',
        label: 'Perte de poids saine',
        emoji: '⚖️',
        description:
            'Perds du poids durablement sans régime draconien ni privation.',
      ),
      SubTheme(
        id: 'prise-masse',
        label: 'Prise de masse',
        emoji: '💪',
        description:
            'Mange stratégiquement pour construire du muscle et de l\'énergie.',
      ),
      SubTheme(
        id: 'vegan',
        label: 'Végétarisme & véganisme',
        emoji: '🌱',
        description:
            'Adopte une alimentation sans viande qui soit complète et savoureuse.',
      ),
      SubTheme(
        id: 'sport-nutrition',
        label: 'Nutrition sportive',
        emoji: '🏋️',
        description:
            'Optimise tes repas avant, pendant et après l\'effort physique.',
      ),
      SubTheme(
        id: 'intuitif',
        label: 'Alimentation intuitive',
        emoji: '🍎',
        description:
            'Reconnecte-toi aux signaux naturels de faim et satiété de ton corps.',
      ),
      SubTheme(
        id: 'sucre',
        label: 'Sucre & addictions',
        emoji: '🍬',
        description:
            'Brise les compulsions sucrées et régule ta glycémie naturellement.',
      ),
      SubTheme(
        id: 'microbiome',
        label: 'Intestin & microbiome',
        emoji: '🦠',
        description:
            'Prends soin de ton deuxième cerveau pour mieux digérer et te sentir bien.',
      ),
      SubTheme(
        id: 'jejun',
        label: 'Jeûne intermittent',
        emoji: '⏱️',
        description:
            'Comprends et pratique le jeûne pour sa santé et sa clarté mentale.',
      ),
      SubTheme(
        id: 'anti-inflam',
        label: 'Anti-inflammatoire',
        emoji: '🌿',
        description:
            'Adopte les aliments qui réduisent l\'inflammation et boostent la vitalité.',
      ),
    ],
  ),
  DomainItem(
    id: 'relations',
    label: 'Relations',
    tagline: 'Des liens plus sains',
    icon: Icons.favorite_rounded,
    color: AppColors.rose,
    description:
        'La qualité de tes relations détermine en grande partie ta qualité '
        'de vie. Ce programme t\'apprend à communiquer avec authenticité, '
        'poser des limites saines et créer des connexions plus profondes '
        'et plus nourrissantes.',
    whoIsItFor:
        'Pour ceux qui veulent améliorer leurs relations amoureuses, '
        'amicales ou professionnelles, ou qui sortent d\'une période difficile.',
    before:
        'Tu te sens souvent mal compris, tu évites les conflits ou tu te '
        'perds dans tes relations au détriment de toi-même.',
    after:
        'Tu t\'exprimes clairement, tu poses des limites avec bienveillance '
        'et tes relations sont nourrissantes et équilibrées.',
    highlights: [
      'Communication non-violente et expression authentique',
      'Poser et respecter ses limites sans culpabilité',
      'Gérer les conflits de manière constructive',
      'Cultiver l\'intimité et la confiance dans la durée',
    ],
    subThemes: [
      SubTheme(
        id: 'couple',
        label: 'Communication de couple',
        emoji: '💑',
        description:
            'Améliore l\'écoute, l\'expression et la complicité dans ta relation.',
      ),
      SubTheme(
        id: 'amitie',
        label: 'Amitié & liens sociaux',
        emoji: '👫',
        description:
            'Crée et entretiens des amitiés profondes et nourrissantes.',
      ),
      SubTheme(
        id: 'pro',
        label: 'Relations professionnelles',
        emoji: '💼',
        description:
            'Navigue avec aisance dans les dynamiques au travail et en réunion.',
      ),
      SubTheme(
        id: 'famille',
        label: 'Famille & parentalité',
        emoji: '👨‍👩‍👧',
        description:
            'Améliore les liens familiaux et communique mieux avec tes proches.',
      ),
      SubTheme(
        id: 'limites',
        label: 'Limites & assertivité',
        emoji: '🛡️',
        description:
            'Dis non sans culpabilité et pose des frontières saines et respectées.',
      ),
      SubTheme(
        id: 'rupture',
        label: 'Ruptures & guérison',
        emoji: '💔',
        description:
            'Traverse et dépasse une rupture ou une perte relationnelle.',
      ),
      SubTheme(
        id: 'confiance-rel',
        label: 'Confiance & jalousie',
        emoji: '🔐',
        description:
            'Comprends et dépasse la jalousie pour des relations plus sereines.',
      ),
      SubTheme(
        id: 'seduction',
        label: 'Séduction & rencontres',
        emoji: '💝',
        description:
            'Développe ta présence, ton aisance et ta capacité à créer des liens.',
      ),
      SubTheme(
        id: 'cnv',
        label: 'Communication non-violente',
        emoji: '🕊️',
        description:
            'Exprime tes besoins et écoute ceux des autres sans conflit.',
      ),
    ],
  ),
  DomainItem(
    id: 'sommeil',
    label: 'Sommeil',
    tagline: 'Des nuits réparatrices',
    icon: Icons.nightlight_round,
    color: AppColors.lavender,
    description:
        'Le sommeil est le fondement de tout le reste — humeur, '
        'concentration, santé, poids. Ce programme t\'aide à comprendre '
        'ton sommeil, identifier ce qui le sabote et créer un rituel '
        'du soir qui change vraiment tout.',
    whoIsItFor:
        'Pour ceux qui ont du mal à s\'endormir, se réveillent fatigués, '
        'ou veulent optimiser leur récupération et leur énergie au quotidien.',
    before:
        'Tu dors suffisamment d\'heures mais tu te réveilles épuisé, '
        'tu as du mal à t\'endormir ou tu dépends d\'aides pour dormir.',
    after:
        'Tu as un rituel du soir efficace, tu t\'endors rapidement et '
        'tu te réveilles frais, plein d\'énergie et de clarté mentale.',
    highlights: [
      'Comprendre les cycles du sommeil et ton chronotype',
      'Créer un rituel du soir efficace et personnalisé',
      'Optimiser son environnement de sommeil',
      'Gérer les insomnies, les réveils nocturnes et la fatigue',
    ],
    subThemes: [
      SubTheme(
        id: 'insomnie',
        label: 'Insomnie chronique',
        emoji: '😴',
        description:
            'Reprends le contrôle de tes nuits grâce à des techniques validées.',
      ),
      SubTheme(
        id: 'rythme',
        label: 'Rythme circadien',
        emoji: '🌍',
        description:
            'Recalibre ton horloge biologique pour t\'endormir et te lever facilement.',
      ),
      SubTheme(
        id: 'rituel-soir',
        label: 'Rituel du soir',
        emoji: '🕯️',
        description:
            'Crée une routine apaisante qui prépare ton corps et ton esprit au repos.',
      ),
      SubTheme(
        id: 'sieste',
        label: 'Sieste & micro-repos',
        emoji: '💤',
        description:
            'Maîtrise l\'art de la sieste pour booster ton énergie sans perturber la nuit.',
      ),
      SubTheme(
        id: 'perf-sommeil',
        label: 'Sommeil & performance',
        emoji: '🏆',
        description:
            'Optimise ton sommeil comme un athlète pour performer au quotidien.',
      ),
      SubTheme(
        id: 'reves',
        label: 'Rêves & sommeil paradoxal',
        emoji: '🌙',
        description:
            'Comprends et explore le sommeil profond et le monde des rêves.',
      ),
      SubTheme(
        id: 'detox-ecran',
        label: 'Détox numérique soir',
        emoji: '📵',
        description:
            'Coupe des écrans et crée un espace mental propice à l\'endormissement.',
      ),
      SubTheme(
        id: 'environnement',
        label: 'Environnement de sommeil',
        emoji: '🛏️',
        description:
            'Optimise lumière, température et bruit pour une chambre sanctuaire.',
      ),
    ],
  ),
  DomainItem(
    id: 'confiance',
    label: 'Confiance',
    tagline: 'Oser être toi',
    icon: Icons.auto_awesome_rounded,
    color: AppColors.sun,
    description:
        'La confiance en soi ne tombe pas du ciel — elle se construit, '
        'action après action. Ce programme te guide pour identifier tes '
        'croyances limitantes, agir malgré la peur et développer une '
        'confiance solide et durable.',
    whoIsItFor:
        'Pour ceux qui se sous-estiment, ont peur du regard des autres, '
        'ou veulent oser davantage dans leur vie personnelle et professionnelle.',
    before:
        'Tu laisses la peur du jugement, le doute ou la comparaison '
        't\'empêcher d\'agir et de montrer qui tu es vraiment.',
    after:
        'Tu agis malgré l\'inconfort, tu te fies à ton propre jugement '
        'et tu avances sans attendre d\'être parfait ou d\'avoir la permission.',
    highlights: [
      'Identifier et dépasser ses croyances limitantes profondes',
      'Agir malgré la peur — le courage se pratique',
      'Développer l\'estime de soi sur des bases solides',
      'S\'affirmer avec assurance dans toutes les situations',
    ],
    subThemes: [
      SubTheme(
        id: 'timidite',
        label: 'Timidité & estime de soi',
        emoji: '😊',
        description:
            'Surmonte la timidité et construis une image de toi positive et solide.',
      ),
      SubTheme(
        id: 'prise-parole',
        label: 'Prise de parole',
        emoji: '🎤',
        description:
            'Exprime-toi avec aisance en public, en réunion ou en conversation.',
      ),
      SubTheme(
        id: 'confiance-pro',
        label: 'Confiance au travail',
        emoji: '💼',
        description:
            'Ose t\'affirmer, proposer tes idées et négocier dans le monde pro.',
      ),
      SubTheme(
        id: 'assertivite',
        label: 'Assertivité',
        emoji: '🗣️',
        description:
            'Exprime tes besoins et opinions fermement, sans agressivité.',
      ),
      SubTheme(
        id: 'image-corpo',
        label: 'Image corporelle',
        emoji: '🪞',
        description:
            'Réconcilie-toi avec ton corps et construis une image de toi bienveillante.',
      ),
      SubTheme(
        id: 'imposteur',
        label: 'Syndrome de l\'imposteur',
        emoji: '🎭',
        description:
            'Reconnais et dépasse cette voix qui te dit que tu ne mérites pas ta place.',
      ),
      SubTheme(
        id: 'leadership',
        label: 'Leadership & charisme',
        emoji: '👑',
        description:
            'Développe ta présence, ton influence et ta capacité à inspirer.',
      ),
      SubTheme(
        id: 'independance',
        label: 'Indépendance & autonomie',
        emoji: '🦋',
        description:
            'Deviens pleinement toi-même, sans dépendre du regard ou de l\'approbation d\'autrui.',
      ),
    ],
  ),
  DomainItem(
    id: 'bien-etre',
    label: 'Bien-être',
    tagline: 'Retrouver ton calme',
    icon: Icons.self_improvement_rounded,
    color: AppColors.teal,
    description:
        'Le bien-être n\'est pas un luxe — c\'est la base sur laquelle tout '
        'le reste tient. Ce programme te donne des pratiques simples pour '
        'apaiser ton corps, calmer ton mental et recharger ton énergie, '
        'jour après jour.',
    whoIsItFor:
        'Pour ceux qui se sentent tendus, fatigués ou hyperconnectés, et '
        'qui veulent intégrer des moments de calme et de recentrage dans leur quotidien.',
    before:
        'Tu cours toute la journée, le corps tendu et l\'esprit saturé, '
        'sans jamais vraiment te poser ni recharger tes batteries.',
    after:
        'Tu sais te recentrer en quelques minutes, tu protèges ton énergie '
        'et tu cultives un calme intérieur qui résiste au tumulte.',
    highlights: [
      'Des techniques de relaxation et de respiration qui marchent vite',
      'Méditer simplement, même sans expérience ni temps',
      'Réduire l\'emprise des écrans et retrouver ton attention',
      'Recharger ton énergie physique et mentale durablement',
    ],
    subThemes: [
      SubTheme(
        id: 'meditation',
        label: 'Méditation guidée',
        emoji: '🧘',
        description:
            'Débute la méditation pas à pas et installe une pratique qui tient.',
      ),
      SubTheme(
        id: 'relaxation',
        label: 'Relaxation profonde',
        emoji: '🌊',
        description:
            'Relâche les tensions du corps et descends en quelques minutes.',
      ),
      SubTheme(
        id: 'detox-digitale',
        label: 'Détox digitale',
        emoji: '📵',
        description:
            'Reprends le contrôle de ton attention face aux écrans et notifications.',
      ),
      SubTheme(
        id: 'energie-vitale',
        label: 'Énergie & vitalité',
        emoji: '⚡',
        description:
            'Retrouve un niveau d\'énergie stable grâce à des routines simples.',
      ),
      SubTheme(
        id: 'respiration',
        label: 'Respiration & cohérence',
        emoji: '🫁',
        description:
            'Utilise ton souffle comme un interrupteur pour ton système nerveux.',
      ),
      SubTheme(
        id: 'douleur',
        label: 'Gestion de la douleur',
        emoji: '🌿',
        description:
            'Apaise tensions et douleurs chroniques par la détente et l\'attention.',
      ),
      SubTheme(
        id: 'ancrage',
        label: 'Ancrage & présence',
        emoji: '🌳',
        description:
            'Reviens dans l\'instant et dans ton corps quand tout s\'emballe.',
      ),
      SubTheme(
        id: 'lacher-prise',
        label: 'Lâcher-prise',
        emoji: '🍃',
        description:
            'Apprends à relâcher le contrôle et à accueillir ce qui est.',
      ),
    ],
  ),
  DomainItem(
    id: 'apprentissage',
    label: 'Apprentissage',
    tagline: 'Apprendre à apprendre',
    icon: Icons.school_rounded,
    color: AppColors.indigo,
    description:
        'Savoir apprendre est la compétence qui démultiplie toutes les autres. '
        'Ce programme te transmet les méthodes des meilleurs apprenants : '
        'mémoriser durablement, lire plus vite, t\'exprimer clairement et '
        'penser avec rigueur.',
    whoIsItFor:
        'Pour les étudiants, curieux et professionnels qui veulent apprendre '
        'plus vite, retenir plus longtemps et progresser dans n\'importe quel domaine.',
    before:
        'Tu lis, tu écoutes, tu révises… mais tout s\'efface vite et tu as '
        'l\'impression de repartir de zéro à chaque fois.',
    after:
        'Tu apprends avec méthode, tu retiens durablement et tu sais '
        'transmettre clairement ce que tu sais.',
    highlights: [
      'Mémoriser durablement avec la répétition espacée et les associations',
      'Lire plus vite sans rien perdre en compréhension',
      'Structurer ta pensée et tes idées avec clarté',
      'Développer ton esprit critique et ta logique',
    ],
    subThemes: [
      SubTheme(
        id: 'lecture-rapide',
        label: 'Lecture rapide',
        emoji: '📖',
        description:
            'Double ta vitesse de lecture tout en gardant ta compréhension.',
      ),
      SubTheme(
        id: 'memoire-palais',
        label: 'Mémoire & mnémotechnie',
        emoji: '🧠',
        description:
            'Palais mental, associations, répétition espacée : retiens tout.',
      ),
      SubTheme(
        id: 'eloquence',
        label: 'Prise de parole',
        emoji: '🎤',
        description:
            'Structure et délivre tes idées avec aisance devant un public.',
      ),
      SubTheme(
        id: 'langues',
        label: 'Apprendre une langue',
        emoji: '🗣️',
        description:
            'Vocabulaire, immersion et méthode pour parler vite et durablement.',
      ),
      SubTheme(
        id: 'ecriture',
        label: 'Écriture & style',
        emoji: '✍️',
        description:
            'Écris clairement et avec impact, du mail à l\'essai structuré.',
      ),
      SubTheme(
        id: 'pensee-critique',
        label: 'Pensée critique',
        emoji: '🔍',
        description:
            'Analyse, raisonne et déjoue les sophismes et les fausses évidences.',
      ),
      SubTheme(
        id: 'methode-etude',
        label: 'Méthode d\'étude',
        emoji: '📚',
        description:
            'Organise tes révisions et apprends de façon active et efficace.',
      ),
      SubTheme(
        id: 'revision',
        label: 'Révisions & examens',
        emoji: '🔁',
        description:
            'Prépare tes échéances sans stress avec un plan de révision malin.',
      ),
    ],
  ),
  DomainItem(
    id: 'business',
    label: 'Business',
    tagline: 'Construire ta réussite',
    icon: Icons.business_center_rounded,
    color: AppColors.gold,
    description:
        'Que tu veuilles lancer ton projet ou faire décoller ta carrière, '
        'les principes du business se travaillent. Ce programme te guide de '
        'l\'idée à l\'exécution : vendre, négocier, diriger et faire grandir '
        'ce que tu construis.',
    whoIsItFor:
        'Pour les entrepreneurs, freelances et professionnels ambitieux qui '
        'veulent passer à l\'action et développer leur impact.',
    before:
        'Tu as des idées et de l\'ambition, mais tu ne sais pas par où '
        'commencer ni comment transformer tout ça en résultats concrets.',
    after:
        'Tu avances avec une stratégie claire, tu sais vendre tes idées et '
        'tu fais grandir tes projets avec méthode et confiance.',
    highlights: [
      'Valider une idée et la transformer en projet concret',
      'Vendre et convaincre sans te trahir',
      'Négocier pour créer de la valeur des deux côtés',
      'Diriger et fédérer une équipe autour d\'une vision',
    ],
    subThemes: [
      SubTheme(
        id: 'entrepreneuriat',
        label: 'Entrepreneuriat',
        emoji: '🚀',
        description:
            'De l\'idée au MVP : lance ton projet sans attendre la perfection.',
      ),
      SubTheme(
        id: 'marketing',
        label: 'Marketing & branding',
        emoji: '📣',
        description:
            'Fais connaître ton offre et construis une marque qui marque.',
      ),
      SubTheme(
        id: 'vente',
        label: 'Vente & closing',
        emoji: '🤝',
        description:
            'Maîtrise l\'art de convaincre et de conclure sans forcer.',
      ),
      SubTheme(
        id: 'management',
        label: 'Management & équipe',
        emoji: '👥',
        description:
            'Anime, motive et fais grandir une équipe avec justesse.',
      ),
      SubTheme(
        id: 'negociation',
        label: 'Négociation',
        emoji: '♟️',
        description:
            'Décroche de meilleurs accords grâce à la psychologie et la méthode.',
      ),
      SubTheme(
        id: 'carriere',
        label: 'Évolution de carrière',
        emoji: '📈',
        description:
            'Pilote ta progression, négocie ton salaire et saisis les opportunités.',
      ),
      SubTheme(
        id: 'reseau',
        label: 'Réseau & influence',
        emoji: '🌐',
        description:
            'Crée et entretiens un réseau qui ouvre des portes durablement.',
      ),
      SubTheme(
        id: 'prise-decision',
        label: 'Prise de décision',
        emoji: '🎯',
        description:
            'Décide vite et bien, même sous incertitude et sous pression.',
      ),
    ],
  ),
  DomainItem(
    id: 'finance',
    label: 'Finance',
    tagline: 'Maîtriser ton argent',
    icon: Icons.savings_rounded,
    color: AppColors.lime,
    description:
        'L\'argent est un outil, pas un tabou. Ce programme te donne les '
        'bases pour reprendre le contrôle de tes finances : budgéter sans '
        'frustration, épargner sans effort et faire travailler ton argent '
        'pour toi.',
    whoIsItFor:
        'Pour ceux qui veulent sortir du stress financier, mieux gérer leur '
        'budget et commencer à investir, quel que soit leur point de départ.',
    before:
        'Ton argent file sans que tu saches vraiment où, et l\'idée '
        'd\'épargner ou d\'investir te paraît floue ou inaccessible.',
    after:
        'Tu sais exactement où va ton argent, tu épargnes automatiquement '
        'et tu fais tes premiers pas vers l\'indépendance financière.',
    highlights: [
      'Construire un budget simple qui tient dans la vraie vie',
      'Automatiser ton épargne pour qu\'elle se fasse toute seule',
      'Comprendre les bases de l\'investissement sans jargon',
      'Changer tes croyances limitantes autour de l\'argent',
    ],
    subThemes: [
      SubTheme(
        id: 'budget',
        label: 'Budget & dépenses',
        emoji: '📊',
        description:
            'Reprends le contrôle de tes dépenses avec un budget vivant et simple.',
      ),
      SubTheme(
        id: 'epargne',
        label: 'Épargne intelligente',
        emoji: '🐷',
        description:
            'Automatise ton épargne et atteins tes objectifs sans te priver.',
      ),
      SubTheme(
        id: 'investissement',
        label: 'Investissement débutant',
        emoji: '📈',
        description:
            'Comprends ETF, risques et intérêts composés pour bien démarrer.',
      ),
      SubTheme(
        id: 'mindset-argent',
        label: 'Mindset financier',
        emoji: '💭',
        description:
            'Déprogramme tes croyances limitantes et crée une relation saine à l\'argent.',
      ),
      SubTheme(
        id: 'dettes',
        label: 'Sortir des dettes',
        emoji: '🧾',
        description:
            'Établis un plan clair pour rembourser et retrouver de l\'air.',
      ),
      SubTheme(
        id: 'revenus',
        label: 'Revenus complémentaires',
        emoji: '💼',
        description:
            'Développe des sources de revenus en plus de ton activité principale.',
      ),
      SubTheme(
        id: 'independance-fin',
        label: 'Indépendance financière',
        emoji: '🏝️',
        description:
            'Comprends les leviers pour gagner en liberté à long terme.',
      ),
      SubTheme(
        id: 'immobilier',
        label: 'Immobilier',
        emoji: '🏠',
        description:
            'Les bases pour acheter, louer ou investir dans la pierre sereinement.',
      ),
    ],
  ),
  DomainItem(
    id: 'spiritualite',
    label: 'Spiritualité',
    tagline: 'Revenir à l\'essentiel',
    icon: Icons.filter_vintage_rounded,
    color: AppColors.blush,
    description:
        'Au-delà du quotidien, il y a une vie intérieure à explorer. Ce '
        'programme t\'invite à ralentir, à te reconnecter à tes valeurs et à '
        'cultiver gratitude, présence et sens — sans dogme, à ton rythme.',
    whoIsItFor:
        'Pour ceux qui cherchent plus de sens, de paix intérieure et '
        'd\'alignement, quelle que soit leur sensibilité ou leurs croyances.',
    before:
        'Tu enchaînes les journées sans vraiment savoir pourquoi, avec un '
        'vague sentiment de vide ou de déconnexion intérieure.',
    after:
        'Tu vis plus aligné avec tes valeurs, tu cultives la gratitude et '
        'tu ressens un sens et une paix plus profonds au quotidien.',
    highlights: [
      'Approfondir une pratique méditative et contemplative',
      'Tenir un journal introspectif qui éclaire ton chemin',
      'Cultiver la gratitude et en ressentir les effets réels',
      'Clarifier tes valeurs et vivre plus aligné avec elles',
    ],
    subThemes: [
      SubTheme(
        id: 'meditation-profonde',
        label: 'Méditation profonde',
        emoji: '🧘',
        description:
            'Va au-delà de la détente vers une présence et une clarté profondes.',
      ),
      SubTheme(
        id: 'journal',
        label: 'Journal introspectif',
        emoji: '📔',
        description:
            'Écris pour te comprendre, clarifier tes pensées et avancer.',
      ),
      SubTheme(
        id: 'gratitude',
        label: 'Gratitude',
        emoji: '🙏',
        description:
            'Installe une pratique de gratitude qui transforme ton regard.',
      ),
      SubTheme(
        id: 'alignement',
        label: 'Alignement personnel',
        emoji: '🧭',
        description:
            'Aligne tes actions avec tes valeurs profondes et ta vérité.',
      ),
      SubTheme(
        id: 'sens-vie',
        label: 'Quête de sens',
        emoji: '✨',
        description:
            'Explore ce qui donne du sens à ta vie et trace ta direction.',
      ),
      SubTheme(
        id: 'pleine-presence',
        label: 'Pleine présence',
        emoji: '🌸',
        description:
            'Habite pleinement l\'instant et savoure le moment présent.',
      ),
      SubTheme(
        id: 'silence',
        label: 'Silence & solitude',
        emoji: '🕊️',
        description:
            'Apprivoise le silence et la solitude comme des espaces de ressource.',
      ),
      SubTheme(
        id: 'rituels',
        label: 'Rituels & ancrage',
        emoji: '🕯️',
        description:
            'Crée des rituels porteurs de sens qui rythment et nourrissent ta vie.',
      ),
    ],
  ),
  DomainItem(
    id: 'creativite-arts',
    label: 'Créativité',
    tagline: 'Libérer ton artiste',
    icon: Icons.palette_rounded,
    color: AppColors.coral,
    description:
        'La créativité n\'est pas un don réservé à quelques-uns — c\'est un '
        'muscle qui se travaille. Ce programme te guide pour explorer le '
        'dessin, la musique, l\'écriture ou la photo et libérer l\'artiste '
        'qui sommeille en toi.',
    whoIsItFor:
        'Pour les débutants curieux comme les créatifs en quête d\'inspiration, '
        'qui veulent oser créer et progresser avec plaisir.',
    before:
        'Tu aimerais créer mais tu te sens bloqué, intimidé par la page '
        'blanche ou persuadé de « ne pas être doué ».',
    after:
        'Tu crées régulièrement avec plaisir, tu maîtrises les bases de ton '
        'art et l\'inspiration vient parce que tu sais comment la provoquer.',
    highlights: [
      'Maîtriser les fondamentaux de ton art (traits, rythme, lumière)',
      'Vaincre le blocage de la page blanche',
      'Provoquer l\'inspiration au lieu de l\'attendre',
      'Développer ta voix et ton style personnels',
    ],
    subThemes: [
      SubTheme(
        id: 'dessin',
        label: 'Dessin & croquis',
        emoji: '✏️',
        description:
            'Bases, proportions et ombres : apprends à voir et à dessiner.',
      ),
      SubTheme(
        id: 'musique',
        label: 'Musique & rythme',
        emoji: '🎵',
        description:
            'Rythme, oreille et improvisation pour jouer et créer de la musique.',
      ),
      SubTheme(
        id: 'ecriture-creative',
        label: 'Écriture créative',
        emoji: '📝',
        description:
            'Raconte des histoires et trouve ta voix d\'écrivain.',
      ),
      SubTheme(
        id: 'photographie',
        label: 'Photographie',
        emoji: '📷',
        description:
            'Cadrage, lumière et composition pour des photos qui racontent.',
      ),
      SubTheme(
        id: 'peinture',
        label: 'Peinture & couleur',
        emoji: '🎨',
        description:
            'Joue avec les couleurs et la matière pour exprimer ce que tu ressens.',
      ),
      SubTheme(
        id: 'improvisation',
        label: 'Improvisation',
        emoji: '🎭',
        description:
            'Lâche le contrôle et crée dans l\'instant, sans peur de te tromper.',
      ),
      SubTheme(
        id: 'inspiration',
        label: 'Trouver l\'inspiration',
        emoji: '💡',
        description:
            'Des méthodes concrètes pour nourrir et déclencher tes idées.',
      ),
      SubTheme(
        id: 'artisanat',
        label: 'Créativité manuelle',
        emoji: '🪡',
        description:
            'Crée de tes mains et reconnecte-toi au plaisir de fabriquer.',
      ),
    ],
  ),
  DomainItem(
    id: 'habitudes',
    label: 'Habitudes',
    tagline: 'Des journées qui te ressemblent',
    icon: Icons.event_repeat_rounded,
    color: AppColors.aqua,
    description:
        'Ta vie, c\'est la somme de tes habitudes. Ce programme t\'aide à '
        'construire des routines simples et durables — du matin au soir — '
        'pour rendre ton quotidien plus fluide, plus léger et plus aligné '
        'avec ce qui compte.',
    whoIsItFor:
        'Pour ceux qui veulent structurer leur quotidien, créer de bonnes '
        'habitudes durables et désencombrer leur vie comme leur esprit.',
    before:
        'Tes journées se ressemblent sans vraiment te porter, et tes bonnes '
        'résolutions s\'effondrent au bout de quelques jours.',
    after:
        'Tu as des routines qui tiennent, un quotidien plus organisé et '
        'léger, et des habitudes qui travaillent pour toi sans effort.',
    highlights: [
      'Construire des habitudes qui durent (et briser les mauvaises)',
      'Créer des routines matin et soir qui te portent',
      'Désencombrer ton espace et ton esprit',
      'Simplifier ton quotidien pour gagner en sérénité',
    ],
    subThemes: [
      SubTheme(
        id: 'routine-matinale',
        label: 'Routine matinale',
        emoji: '🌅',
        description:
            'Démarre tes journées du bon pied avec un rituel du matin sur mesure.',
      ),
      SubTheme(
        id: 'routine-soir',
        label: 'Routine du soir',
        emoji: '🌙',
        description:
            'Clôture tes journées en douceur et prépare un lendemain serein.',
      ),
      SubTheme(
        id: 'organisation-maison',
        label: 'Organisation maison',
        emoji: '🏠',
        description:
            'Mets de l\'ordre chez toi et garde un intérieur qui respire.',
      ),
      SubTheme(
        id: 'minimalisme',
        label: 'Minimalisme',
        emoji: '🧹',
        description:
            'Possède moins, vis mieux : fais de la place à l\'essentiel.',
      ),
      SubTheme(
        id: 'habitudes-saines',
        label: 'Créer des habitudes',
        emoji: '🔁',
        description:
            'Comprends le mécanisme des habitudes et installe-les durablement.',
      ),
      SubTheme(
        id: 'desencombrement',
        label: 'Désencombrer',
        emoji: '📦',
        description:
            'Allège ton espace et ta charge mentale, pièce par pièce.',
      ),
      SubTheme(
        id: 'equilibre-vie',
        label: 'Équilibre de vie',
        emoji: '⚖️',
        description:
            'Trouve ton équilibre entre travail, repos, relations et plaisirs.',
      ),
      SubTheme(
        id: 'ecologie-quotidien',
        label: 'Gestes écolo',
        emoji: '🌍',
        description:
            'Adopte des gestes du quotidien plus durables, simplement et sans culpabilité.',
      ),
    ],
  ),
];
