/// One multiple-choice question for the domain quiz feed.
class DomainQuizQuestion {
  final String question;
  final List<String> choices; // always 4
  final int correctIndex;
  final String explanation;

  const DomainQuizQuestion({
    required this.question,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
  });
}

List<DomainQuizQuestion> questionsFor(String domainId) =>
    kDomainQuiz[domainId] ?? const [];

const Map<String, List<DomainQuizQuestion>> kDomainQuiz = {
  // ── Psychologie ────────────────────────────────────────────────────────────
  'psychologie': [
    DomainQuizQuestion(
      question: "Qu'explique l'effet de simple exposition ?",
      choices: [
        "La rareté rend les choses plus désirables",
        "La familiarité crée de la sympathie",
        "Le cerveau retient mieux les premières impressions",
        "Les émotions positives s'intensifient avec le temps",
      ],
      correctIndex: 1,
      explanation:
          "Plus on est exposé à quelque chose, plus on a tendance à l'apprécier — sans effort conscient.",
    ),
    DomainQuizQuestion(
      question: "Mettre un mot sur une émotion (affect labeling) a quel effet ?",
      choices: [
        "Elle l'amplifie",
        "Elle la transfère sur autrui",
        "Aucun effet mesurable",
        "Elle réduit son intensité",
      ],
      correctIndex: 3,
      explanation:
          "Nommer pour apaiser : mettre des mots sur ce qu'on ressent calme réellement l'activité de l'amygdale.",
    ),
    DomainQuizQuestion(
      question: "Le biais de négativité nous amène principalement à…",
      choices: [
        "Retenir plus fortement les expériences négatives",
        "Surestimer nos compétences",
        "Oublier les mauvaises expériences rapidement",
        "Prendre des décisions impulsives",
      ],
      correctIndex: 0,
      explanation:
          "Notre cerveau accorde plus de poids au négatif — en avoir conscience aide à relativiser.",
    ),
    DomainQuizQuestion(
      question: "Pourquoi les micro-réussites entretiennent-elles la motivation ?",
      choices: [
        "Elles réduisent le cortisol",
        "Elles libèrent de la dopamine",
        "Elles augmentent la sérotonine",
        "Elles activent l'ocytocine",
      ],
      correctIndex: 1,
      explanation:
          "Chaque petite victoire libère de la dopamine, neurotransmetteur de la récompense et du plaisir.",
    ),
  ],

  // ── Anxiété ────────────────────────────────────────────────────────────────
  'anxiete': [
    DomainQuizQuestion(
      question: "Dans la respiration 4-7-8, que représente le chiffre 8 ?",
      choices: [
        "La durée d'inspiration en secondes",
        "Le nombre de cycles recommandés",
        "La durée d'expiration en secondes",
        "Le nombre de secondes de rétention",
      ],
      correctIndex: 2,
      explanation:
          "Inspire 4 s · retiens 7 s · expire 8 s. Trois cycles suffisent à calmer le système nerveux.",
    ),
    DomainQuizQuestion(
      question: "Dans la technique 5-4-3-2-1, que nomme-t-on en dernier ?",
      choices: [
        "5 sons",
        "1 goût",
        "2 textures",
        "3 odeurs",
      ],
      correctIndex: 1,
      explanation:
          "5 choses vues · 4 touchées · 3 entendues · 2 odeurs · 1 goût. Ce dernier ancre totalement dans le présent.",
    ),
    DomainQuizQuestion(
      question: "Pourquoi dit-on qu'une pensée anxieuse n'est pas un fait ?",
      choices: [
        "Car elle vient toujours du passé",
        "Car le cerveau invente les émotions",
        "Car c'est une hypothèse, pas une réalité prouvée",
        "Car elle disparaît si on l'ignore",
      ],
      correctIndex: 2,
      explanation:
          "Une inquiétude est une hypothèse, pas une vérité. Cherche des preuves réelles avant d'y croire.",
    ),
    DomainQuizQuestion(
      question: "Combien de minutes de marche suffisent à faire baisser le cortisol ?",
      choices: [
        "30 minutes",
        "10 minutes",
        "45 minutes",
        "20 minutes",
      ],
      correctIndex: 1,
      explanation:
          "10 minutes de marche font baisser le cortisol, l'hormone du stress — accessible à tous.",
    ),
  ],

  // ── Productivité ───────────────────────────────────────────────────────────
  'productivite': [
    DomainQuizQuestion(
      question: "Que dit la règle des 2 minutes sur les petites tâches ?",
      choices: [
        "Les reporter au lendemain",
        "Les découper en sous-tâches",
        "Les faire immédiatement",
        "Les déléguer à quelqu'un d'autre",
      ],
      correctIndex: 2,
      explanation:
          "Si une tâche prend moins de 2 minutes, fais-la tout de suite — la noter prendrait autant de temps.",
    ),
    DomainQuizQuestion(
      question: "Le time-blocking consiste à…",
      choices: [
        "Bloquer les réseaux sociaux pendant le travail",
        "Réserver des plages horaires dédiées à chaque tâche",
        "Travailler sans pause pour maximiser le flux",
        "Diviser sa journée en blocs de 25 minutes",
      ],
      correctIndex: 1,
      explanation:
          "Ce qui est planifié a bien plus de chances d'être fait — le calendrier devient la loi.",
    ),
    DomainQuizQuestion(
      question: "Que stipule la loi de Parkinson ?",
      choices: [
        "Plus une tâche est difficile, plus elle prend de temps",
        "Le travail s'étire jusqu'à remplir le temps disponible",
        "La productivité diminue après 4 h de travail",
        "Une tâche urgente chasse toujours l'importante",
      ],
      correctIndex: 1,
      explanation:
          "En fixant des délais courts, tu contres cette loi et tu travailles plus efficacement.",
    ),
    DomainQuizQuestion(
      question: "De combien le multitâche peut-il réduire l'efficacité ?",
      choices: [
        "10 %",
        "20 %",
        "40 %",
        "60 %",
      ],
      correctIndex: 2,
      explanation:
          "Le multitâche peut réduire l'efficacité jusqu'à 40 %. Mieux vaut se concentrer sur une seule chose.",
    ),
  ],

  // ── Sport ──────────────────────────────────────────────────────────────────
  'sport': [
    DomainQuizQuestion(
      question: "Que désigne le NEAT en sport ?",
      choices: [
        "Un programme d'entraînement intensif",
        "L'énergie brûlée lors d'une séance de sport",
        "Les calories brûlées dans les activités hors sport",
        "Une technique d'étirement spécifique",
      ],
      correctIndex: 2,
      explanation:
          "NEAT = Non-Exercise Activity Thermogenesis. Marcher, se lever, bouger — souvent plus impactant que la séance !",
    ),
    DomainQuizQuestion(
      question: "En quoi consiste la surcharge progressive ?",
      choices: [
        "Faire des séances de plus en plus longues",
        "Augmenter peu à peu poids, répétitions ou durée",
        "Varier les exercices à chaque séance",
        "Réduire les temps de repos progressivement",
      ],
      correctIndex: 1,
      explanation:
          "Sans surcharge progressive, le corps s'adapte et la progression stagne. C'est la base de tout entraînement.",
    ),
    DomainQuizQuestion(
      question: "Quand les muscles se renforcent-ils réellement ?",
      choices: [
        "Pendant l'effort intense",
        "Immédiatement après la séance",
        "Durant le sommeil profond uniquement",
        "Au repos, après l'entraînement",
      ],
      correctIndex: 3,
      explanation:
          "Le sport crée des micro-lésions — c'est la récupération qui répare et renforce. Dors et alterne !",
    ),
    DomainQuizQuestion(
      question: "Pourquoi se promettre juste 2 minutes aide-t-il à commencer ?",
      choices: [
        "Le corps se réchauffe en 2 minutes",
        "La vraie barrière est le démarrage, pas l'effort",
        "Le cerveau préfère les objectifs courts",
        "Cela réduit le risque de blessure",
      ],
      correctIndex: 1,
      explanation:
          "Une fois lancé, tu continues souvent bien au-delà — c'est le démarrage le plus difficile.",
    ),
  ],

  // ── Nutrition ──────────────────────────────────────────────────────────────
  'nutrition': [
    DomainQuizQuestion(
      question: "Dans l'assiette repère, quelle proportion est réservée aux légumes ?",
      choices: [
        "Un quart",
        "Les trois quarts",
        "La moitié",
        "Un tiers",
      ],
      correctIndex: 2,
      explanation:
          "Moitié légumes · un quart protéines · un quart féculents. Simple, équilibré, efficace.",
    ),
    DomainQuizQuestion(
      question: "Combien de temps met la satiété à arriver après le début du repas ?",
      choices: [
        "5 minutes",
        "10 minutes",
        "30 minutes",
        "20 minutes",
      ],
      correctIndex: 3,
      explanation:
          "La satiété met environ 20 minutes à arriver — manger lentement évite de dépasser le seuil.",
    ),
    DomainQuizQuestion(
      question: "Que faire avant de grignoter pour vérifier si on a vraiment faim ?",
      choices: [
        "Attendre 15 minutes",
        "Boire un verre d'eau",
        "Manger une pomme",
        "Faire 10 minutes de marche",
      ],
      correctIndex: 1,
      explanation:
          "On confond souvent soif et faim. Un grand verre d'eau peut supprimer l'envie de grignoter.",
    ),
    DomainQuizQuestion(
      question: "Où trouve-t-on souvent du sucre caché ?",
      choices: [
        "Uniquement dans les desserts",
        "Dans les sodas uniquement",
        "Dans beaucoup de produits salés",
        "Dans les produits bio uniquement",
      ],
      correctIndex: 2,
      explanation:
          "Sauces, charcuteries, plats préparés... Prends l'habitude de lire les étiquettes.",
    ),
  ],

  // ── Relations ──────────────────────────────────────────────────────────────
  'relations': [
    DomainQuizQuestion(
      question: "Que permet la reformulation dans l'écoute active ?",
      choices: [
        "De montrer qu'on est d'accord",
        "D'éviter les silences gênants",
        "De désamorcer les malentendus",
        "D'accélérer la conversation",
      ],
      correctIndex: 2,
      explanation:
          "«Si je comprends bien…» montre qu'on écoute vraiment et évite les incompréhensions.",
    ),
    DomainQuizQuestion(
      question: "Combien de langages de l'amour Gary Chapman a-t-il identifiés ?",
      choices: [
        "3",
        "4",
        "6",
        "5",
      ],
      correctIndex: 3,
      explanation:
          "Mots d'affirmation · temps de qualité · cadeaux · services rendus · contact physique.",
    ),
    DomainQuizQuestion(
      question: "Quel est le ratio positif/négatif des relations solides selon la recherche ?",
      choices: [
        "3 pour 1",
        "5 pour 1",
        "10 pour 1",
        "2 pour 1",
      ],
      correctIndex: 1,
      explanation:
          "Les relations épanouissantes comptent environ 5 interactions positives pour 1 négative.",
    ),
    DomainQuizQuestion(
      question: "Pourquoi vaut-il mieux exprimer un besoin précis ?",
      choices: [
        "Cela évite les conflits",
        "L'autre ne peut pas deviner nos besoins",
        "Les besoins flous sont difficiles à retenir",
        "Cela renforce l'autorité dans la relation",
      ],
      correctIndex: 1,
      explanation:
          "Espérer que l'autre devine crée des déceptions. Demander clairement crée la connexion.",
    ),
  ],

  // ── Sommeil ────────────────────────────────────────────────────────────────
  'sommeil': [
    DomainQuizQuestion(
      question: "Pourquoi s'exposer à la lumière le matin est-il bénéfique ?",
      choices: [
        "Cela stimule la production de mélatonine",
        "Cela cale l'horloge interne et aide à s'endormir le soir",
        "Cela réduit le besoin de café",
        "Cela active le cortisol en fin de journée",
      ],
      correctIndex: 1,
      explanation:
          "La lumière du matin synchronise le rythme circadien, facilitant l'endormissement naturel.",
    ),
    DomainQuizQuestion(
      question: "Quel est le facteur n°1 d'un bon sommeil ?",
      choices: [
        "La durée totale de sommeil",
        "La température de la chambre",
        "Se coucher et se lever à heures fixes",
        "Éviter les écrans après 20h",
      ],
      correctIndex: 2,
      explanation:
          "La régularité est le pilier du sommeil. Même le week-end, des horaires stables font toute la différence.",
    ),
    DomainQuizQuestion(
      question: "Quelle est la durée maximale recommandée pour une sieste récupératrice ?",
      choices: [
        "5 minutes",
        "45 minutes",
        "10 à 20 minutes",
        "30 minutes",
      ],
      correctIndex: 2,
      explanation:
          "Au-delà de 20 min, on entre en sommeil profond et on se réveille groggy — l'effet inverse.",
    ),
    DomainQuizQuestion(
      question: "La lumière bleue des écrans impacte le sommeil en…",
      choices: [
        "Réduisant le cortisol du soir",
        "Retardant la production de mélatonine",
        "Activant les rêves plus tôt",
        "Augmentant la température corporelle",
      ],
      correctIndex: 1,
      explanation:
          "Coupe les écrans 30 à 60 min avant de dormir pour laisser la mélatonine faire son travail.",
    ),
  ],

  // ── Confiance ──────────────────────────────────────────────────────────────
  'confiance': [
    DomainQuizQuestion(
      question: "Combien de minutes de posture ouverte peuvent augmenter la confiance ?",
      choices: [
        "10 minutes",
        "5 minutes",
        "2 minutes",
        "30 secondes",
      ],
      correctIndex: 2,
      explanation:
          "Tenir une posture ample 2 minutes avant un défi peut augmenter le sentiment de confiance.",
    ),
    DomainQuizQuestion(
      question: "Se parler à la 2ème personne (« tu peux le faire ») a quel effet ?",
      choices: [
        "Aucun effet prouvé",
        "Améliore la performance",
        "Augmente l'anxiété",
        "Réduit la concentration",
      ],
      correctIndex: 1,
      explanation:
          "Le dialogue intérieur à la 2ème personne crée une distance utile et améliore les résultats.",
    ),
    DomainQuizQuestion(
      question: "Sur quoi repose la vraie confiance en soi ?",
      choices: [
        "Sur l'humeur du moment",
        "Sur les compliments des autres",
        "Sur des faits et des réussites accumulées",
        "Sur la comparaison sociale",
      ],
      correctIndex: 2,
      explanation:
          "Note tes réussites : la confiance se construit sur des preuves concrètes, pas sur l'humeur.",
    ),
    DomainQuizQuestion(
      question: "Que se passe-t-il quand on agit avant de se sentir prêt ?",
      choices: [
        "On échoue plus souvent",
        "La confiance suit l'action",
        "On développe du stress chronique",
        "L'action perd de sa valeur",
      ],
      correctIndex: 1,
      explanation:
          "La confiance ne précède pas toujours l'action — elle en découle souvent. Commence, le reste vient.",
    ),
  ],

  // ── Bien-être ──────────────────────────────────────────────────────────────
  'bien-etre': [
    DomainQuizQuestion(
      question: "À quelle fréquence respiratoire correspond la cohérence cardiaque ?",
      choices: [
        "12 fois par minute",
        "6 fois par minute",
        "10 fois par minute",
        "3 fois par minute",
      ],
      correctIndex: 1,
      explanation:
          "6 respirations par minute pendant 5 min (3x/jour) synchronise cœur et système nerveux.",
    ),
    DomainQuizQuestion(
      question: "Qu'est-ce que le scan corporel permet de relâcher ?",
      choices: [
        "Les pensées négatives",
        "La fatigue mentale",
        "Les tensions physiques inaperçues",
        "L'excès de cortisol",
      ],
      correctIndex: 2,
      explanation:
          "Passer son attention de la tête aux pieds révèle et relâche les tensions qu'on ne remarquait plus.",
    ),
    DomainQuizQuestion(
      question: "Pourquoi couper les notifications 20 min avant une pause est-il plus efficace qu'un scroll ?",
      choices: [
        "Le cerveau se repose uniquement dans le silence total",
        "Cela recharge l'attention bien mieux qu'un scroll",
        "Le scroll fatigue les yeux, pas le cerveau",
        "20 minutes sont nécessaires pour entrer en repos profond",
      ],
      correctIndex: 1,
      explanation:
          "Le scroll consomme de l'énergie cognitive — couper les notifications crée une vraie pause mentale.",
    ),
    DomainQuizQuestion(
      question: "Pourquoi bouger crée-t-il de l'énergie plutôt que d'en consommer ?",
      choices: [
        "L'exercice libère des graisses de réserve",
        "Le mouvement stimule la production d'énergie cellulaire",
        "C'est un effet placebo connu",
        "Le repos seul ne suffit pas à recharger le corps",
      ],
      correctIndex: 3,
      explanation:
          "Un peu de mouvement stimule la circulation et le système nerveux — il crée plus d'énergie qu'il n'en dépense.",
    ),
  ],

  // ── Apprentissage ──────────────────────────────────────────────────────────
  'apprentissage': [
    DomainQuizQuestion(
      question: "Pourquoi la répétition espacée est-elle plus efficace que tout relire d'un coup ?",
      choices: [
        "Elle évite la fatigue cognitive",
        "Elle force le cerveau à reconstruire l'information",
        "Elle prend moins de temps total",
        "Elle utilise les deux hémisphères",
      ],
      correctIndex: 1,
      explanation:
          "Revoir à intervalles croissants (1j · 3j · 7j) force la récupération active et ancre la mémoire en profondeur.",
    ),
    DomainQuizQuestion(
      question: "Se réciter de mémoire est combien de fois plus efficace que relire ?",
      choices: [
        "5 fois",
        "10 fois",
        "2 à 3 fois",
        "Équivalent",
      ],
      correctIndex: 2,
      explanation:
          "L'auto-test (retrieval practice) est l'une des techniques d'apprentissage les plus validées par la science.",
    ),
    DomainQuizQuestion(
      question: "Expliquer une idée à voix haute permet surtout de…",
      choices: [
        "Mémoriser plus vite",
        "Repérer ce qu'on n'a pas vraiment compris",
        "Augmenter la concentration",
        "Créer des connexions entre les domaines",
      ],
      correctIndex: 1,
      explanation:
          "C'est la technique Feynman : si tu ne peux pas l'expliquer simplement, tu ne le comprends pas vraiment.",
    ),
    DomainQuizQuestion(
      question: "Le palais mental consiste à associer des informations à…",
      choices: [
        "Des sons répétés",
        "Des couleurs spécifiques",
        "Des lieux familiers",
        "Des émotions fortes",
      ],
      correctIndex: 2,
      explanation:
          "Associer des infos à des lieux familiers exploite la mémoire spatiale — une des plus puissantes.",
    ),
  ],

  // ── Business ───────────────────────────────────────────────────────────────
  'business': [
    DomainQuizQuestion(
      question: "Que font principalement les meilleurs vendeurs ?",
      choices: [
        "Ils parlent beaucoup pour convaincre",
        "Ils présentent rapidement leur produit",
        "Ils écoutent et posent des questions",
        "Ils négocient agressivement le prix",
      ],
      correctIndex: 2,
      explanation:
          "Vendre c'est écouter : comprendre le besoin réel avant de proposer une solution.",
    ),
    DomainQuizQuestion(
      question: "Pourquoi lancer un MVP (version minimale) d'abord ?",
      choices: [
        "Pour économiser du temps et de l'argent",
        "Pour éviter la concurrence",
        "Car le marché apprend mieux qu'un plan",
        "Pour tester uniquement le prix",
      ],
      correctIndex: 2,
      explanation:
          "Lance une version imparfaite — le marché t'apprendra plus que des mois de préparation.",
    ),
    DomainQuizQuestion(
      question: "Quand doit-on idéalement parler du prix lors d'une négociation ?",
      choices: [
        "Dès le début pour gagner du temps",
        "À la fin, après avoir créé de la valeur perçue",
        "Au milieu, pour garder l'attention",
        "Jamais, le client doit demander",
      ],
      correctIndex: 1,
      explanation:
          "Crée d'abord de la valeur perçue : le prix se discute toujours mieux quand l'intérêt est établi.",
    ),
    DomainQuizQuestion(
      question: "Quelle est la meilleure façon d'entretenir son réseau professionnel ?",
      choices: [
        "Contacter les gens uniquement quand on a besoin",
        "Poster régulièrement sur LinkedIn",
        "Donner avant de demander",
        "Assister à tous les événements possibles",
      ],
      correctIndex: 2,
      explanation:
          "Les relations entretenues sans intérêt immédiat ouvrent le plus de portes — construis avant d'avoir besoin.",
    ),
  ],

  // ── Finance ────────────────────────────────────────────────────────────────
  'finance': [
    DomainQuizQuestion(
      question: "Que signifie «se payer en premier» en finance personnelle ?",
      choices: [
        "Acheter ce dont on a envie avant les charges",
        "Épargner automatiquement dès réception du revenu",
        "Investir avant de payer les impôts",
        "Ne jamais contracter de dette",
      ],
      correctIndex: 1,
      explanation:
          "Mettre de côté avant de dépenser transforme l'épargne en automatisme.",
    ),
    DomainQuizQuestion(
      question: "Quel est l'allié le plus puissant des intérêts composés ?",
      choices: [
        "Un taux d'intérêt élevé",
        "Un capital de départ important",
        "Le temps",
        "La diversification",
      ],
      correctIndex: 2,
      explanation:
          "Placé tôt, ton argent génère des intérêts sur tes intérêts. Plus tu commences tôt, plus l'effet est fort.",
    ),
    DomainQuizQuestion(
      question: "Dans la règle 50/30/20, que représentent les 30 % ?",
      choices: [
        "L'épargne et les investissements",
        "Les besoins essentiels",
        "Les envies et loisirs",
        "Les impôts et charges sociales",
      ],
      correctIndex: 2,
      explanation:
          "50 % besoins · 30 % envies · 20 % épargne — un repère simple pour équilibrer son budget.",
    ),
    DomainQuizQuestion(
      question: "Pourquoi diversifier ses placements est-il essentiel ?",
      choices: [
        "Pour maximiser les gains à court terme",
        "Pour éviter de payer des taxes",
        "Car les meilleurs placements sont inconnus à l'avance",
        "Pour réduire fortement le risque global",
      ],
      correctIndex: 3,
      explanation:
          "Ne pas mettre tous ses œufs dans le même panier : répartir les placements réduit le risque.",
    ),
  ],

  // ── Spiritualité ───────────────────────────────────────────────────────────
  'spiritualite': [
    DomainQuizQuestion(
      question: "Comment noter 3 gratitudes par jour agit-il sur le cerveau ?",
      choices: [
        "Il augmente la sérotonine directement",
        "Il recâble peu à peu le cerveau vers le positif",
        "Il supprime les pensées négatives",
        "Il active la mémoire à long terme",
      ],
      correctIndex: 1,
      explanation:
          "La régularité de cette pratique crée de nouveaux schémas mentaux orientés vers le positif.",
    ),
    DomainQuizQuestion(
      question: "Quel bénéfice apporte quelques minutes de silence quotidien ?",
      choices: [
        "Il supprime le stress immédiatement",
        "Il réduit le bruit mental et clarifie les décisions",
        "Il allonge l'espérance de vie",
        "Il améliore la mémoire de travail",
      ],
      correctIndex: 1,
      explanation:
          "Le silence n'est pas vide — il crée l'espace pour que les pensées importantes émergent.",
    ),
    DomainQuizQuestion(
      question: "Qu'arrive-t-il quand nos actions s'alignent avec nos valeurs profondes ?",
      choices: [
        "On devient plus compétitif",
        "On ressent moins d'émotions",
        "Le vide laisse place à la paix intérieure",
        "On prend de meilleures décisions financières",
      ],
      correctIndex: 2,
      explanation:
          "L'alignement valeurs-actions est l'une des sources les plus durables de bien-être.",
    ),
    DomainQuizQuestion(
      question: "Où vivent la plupart de nos souffrances mentales selon le plein conscience ?",
      choices: [
        "Dans les relations difficiles",
        "Dans les peurs du futur et regrets du passé",
        "Dans le corps, pas dans l'esprit",
        "Dans l'insatisfaction des besoins primaires",
      ],
      correctIndex: 1,
      explanation:
          "Revenir au présent apaise les souffrances qui naissent du passé ou du futur imaginé.",
    ),
  ],

  // ── Créativité & Arts ──────────────────────────────────────────────────────
  'creativite-arts': [
    DomainQuizQuestion(
      question: "Pourquoi produire beaucoup, même imparfait, accélère-t-il la progression ?",
      choices: [
        "La quantité remplace la qualité",
        "On apprend davantage par l'expérience que par la théorie",
        "L'erreur est une source d'inspiration",
        "On développe l'endurance créative",
      ],
      correctIndex: 1,
      explanation:
          "La quantité crée la qualité : chaque œuvre imparfaite enseigne ce qu'aucun cours ne peut donner.",
    ),
    DomainQuizQuestion(
      question: "Pourquoi une contrainte (format, temps, couleur) libère-t-elle la créativité ?",
      choices: [
        "Elle élimine les mauvaises idées",
        "Elle paradoxalement force à trouver des solutions inattendues",
        "Elle réduit le stress lié à la page blanche",
        "Elle impose un cadre professionnel",
      ],
      correctIndex: 1,
      explanation:
          "La page blanche peut paralyser — la contrainte oriente l'énergie créative vers une direction précise.",
    ),
    DomainQuizQuestion(
      question: "Pourquoi reproduire les œuvres qu'on admire est une école précieuse ?",
      choices: [
        "Cela améliore la mémoire visuelle",
        "On en extrait les principes, puis on s'en détache",
        "Cela développe la patience",
        "C'est la seule façon d'apprendre le style",
      ],
      correctIndex: 1,
      explanation:
          "Copier pour comprendre, pas pour imiter. Les grands artistes ont tous commencé par reproduire.",
    ),
    DomainQuizQuestion(
      question: "Que fait une petite création quotidienne comparée à des sessions rares et intenses ?",
      choices: [
        "Elle produit des œuvres de meilleure qualité",
        "Elle entretient mieux l'élan créatif",
        "Elle est moins fatigante mentalement",
        "Elle permet une plus grande variété",
      ],
      correctIndex: 1,
      explanation:
          "La régularité crée l'habitude créative — même 15 minutes par jour nourrissent l'élan.",
    ),
  ],

  // ── Habitudes ──────────────────────────────────────────────────────────────
  'habitudes': [
    DomainQuizQuestion(
      question: "L'empilement d'habitudes consiste à…",
      choices: [
        "Faire plusieurs nouvelles habitudes simultanément",
        "Accrocher une nouvelle habitude à une existante",
        "Remplacer une mauvaise habitude par une bonne",
        "Répéter une habitude jusqu'à 21 jours",
      ],
      correctIndex: 1,
      explanation:
          "«Après mon café, je médite 2 min» — lier le nouveau à l'existant réduit l'effort de démarrage.",
    ),
    DomainQuizQuestion(
      question: "La règle des 2 minutes pour les habitudes signifie…",
      choices: [
        "Faire l'habitude seulement si on a 2 minutes",
        "Ne jamais dépasser 2 minutes pour commencer",
        "Réduire l'habitude pour qu'elle prenne moins de 2 min à démarrer",
        "Attendre 2 minutes avant de décider",
      ],
      correctIndex: 2,
      explanation:
          "Rendre l'habitude si petite qu'elle est ridicule de ne pas la faire — commencer est le plus dur.",
    ),
    DomainQuizQuestion(
      question: "Pourquoi l'environnement compte-t-il plus que la volonté pour les habitudes ?",
      choices: [
        "La volonté n'existe pas scientifiquement",
        "L'environnement agit en automatique, la volonté s'épuise",
        "L'environnement est plus facile à changer",
        "La volonté dépend de l'humeur",
      ],
      correctIndex: 1,
      explanation:
          "Rends la bonne habitude facile et la mauvaise difficile — ton environnement travaille pour toi.",
    ),
    DomainQuizQuestion(
      question: "Pourquoi ne jamais manquer deux fois est-il plus important que la perfection ?",
      choices: [
        "Deux jours d'affilée brisent définitivement l'habitude",
        "L'élan se reconstruit plus vite après un seul manqué",
        "La perfection crée de l'anxiété contre-productive",
        "Un seul écart ne compte pas dans la formation d'habitudes",
      ],
      correctIndex: 1,
      explanation:
          "Rater un jour arrive à tout le monde. L'important est de reprendre le lendemain sans exception.",
    ),
  ],
};
