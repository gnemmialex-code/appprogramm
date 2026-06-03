import 'package:flutter/material.dart';

import '../domain_selection/domains_data.dart';

/// One bite-sized, full-screen knowledge card in the TikTok-style feed.
class FeedCard {
  final String title;
  final String body;
  final String domainId;
  final String domainLabel;
  final IconData icon;
  final Color color;

  const FeedCard({
    required this.title,
    required this.body,
    required this.domainId,
    required this.domainLabel,
    required this.icon,
    required this.color,
  });
}

/// Short, punchy learning snippets per domain (id matches [kDomains]).
const Map<String, List<(String, String)>> _tips = {
  'psychologie': [
    (
      'L\'effet de simple exposition',
      'Plus on est exposé à quelque chose, plus on a tendance à l\'apprécier. La familiarité crée la sympathie.',
    ),
    (
      'Le biais de négativité',
      'Notre cerveau retient plus fortement le négatif que le positif. En avoir conscience aide à relativiser.',
    ),
    (
      'Nommer pour apaiser',
      'Mettre un mot sur une émotion réduit son intensité : c\'est l\'« affect labeling ».',
    ),
    (
      'Le pouvoir des micro-réussites',
      'Chaque petite victoire libère de la dopamine et entretient la motivation.',
    ),
  ],
  'anxiete': [
    (
      'Respiration 4-7-8',
      'Inspire 4 s, retiens 7 s, expire 8 s. Trois cycles suffisent souvent à calmer le système nerveux.',
    ),
    (
      'Ancrage 5-4-3-2-1',
      'Nomme 5 choses que tu vois, 4 que tu touches, 3 que tu entends, 2 que tu sens, 1 que tu goûtes.',
    ),
    (
      'Une pensée n\'est pas un fait',
      'Une inquiétude est une hypothèse, pas une vérité. Demande-toi : quelles preuves réelles ?',
    ),
    (
      'Bouger pour décharger',
      '10 minutes de marche font baisser le cortisol, l\'hormone du stress.',
    ),
  ],
  'productivite': [
    (
      'La règle des 2 minutes',
      'Si une tâche prend moins de 2 minutes, fais-la tout de suite plutôt que de la noter.',
    ),
    (
      'Le time-blocking',
      'Réserve des plages horaires dédiées : ce qui est planifié a bien plus de chances d\'être fait.',
    ),
    (
      'La loi de Parkinson',
      'Le travail s\'étire jusqu\'à remplir le temps disponible. Fixe-toi des délais courts.',
    ),
    (
      'Mono-tâche',
      'Le multitâche peut réduire l\'efficacité jusqu\'à 40 %. Une seule chose à la fois.',
    ),
  ],
  'sport': [
    (
      'Le NEAT compte',
      'Les calories brûlées hors sport (marcher, bouger) pèsent souvent plus que la séance elle-même.',
    ),
    (
      'La surcharge progressive',
      'Pour progresser, augmente peu à peu la difficulté : poids, répétitions ou durée.',
    ),
    (
      'La récupération, c\'est le progrès',
      'Les muscles se renforcent au repos, pas pendant l\'effort. Dors et alterne.',
    ),
    (
      '2 minutes pour démarrer',
      'La vraie barrière, c\'est le démarrage. Promets-toi juste 2 minutes : tu continueras souvent.',
    ),
  ],
  'nutrition': [
    (
      'L\'assiette repère',
      'Moitié légumes, un quart protéines, un quart féculents : simple et efficace.',
    ),
    (
      'Manger lentement',
      'La satiété met ~20 min à arriver. Poser sa fourchette entre les bouchées aide à moins manger.',
    ),
    (
      'L\'eau d\'abord',
      'On confond souvent soif et faim. Un verre d\'eau avant de grignoter peut suffire.',
    ),
    (
      'Le sucre caché',
      'Beaucoup de produits salés contiennent du sucre ajouté. Prends l\'habitude de lire les étiquettes.',
    ),
  ],
  'relations': [
    (
      'L\'écoute active',
      'Reformuler ce que dit l\'autre (« si je comprends bien… ») désamorce les malentendus.',
    ),
    (
      'Les langages de l\'amour',
      'Chacun reçoit l\'affection différemment : mots, temps, gestes, services, cadeaux.',
    ),
    (
      'Le ratio 5:1',
      'Les relations solides comptent ~5 interactions positives pour 1 négative.',
    ),
    (
      'Demander clairement',
      'Exprimer un besoin précis vaut mieux qu\'espérer que l\'autre le devine.',
    ),
  ],
  'sommeil': [
    (
      'La lumière du matin',
      'S\'exposer à la lumière au réveil cale l\'horloge interne et facilite l\'endormissement le soir.',
    ),
    (
      'La régularité avant tout',
      'Se coucher et se lever à heures fixes est le facteur n°1 d\'un bon sommeil.',
    ),
    (
      'La sieste éclair',
      '10 à 20 minutes maximum : au-delà, on entre en sommeil profond et on se réveille groggy.',
    ),
    (
      'Écrans et mélatonine',
      'La lumière bleue retarde la mélatonine. Coupe les écrans 30 à 60 min avant le coucher.',
    ),
  ],
  'confiance': [
    (
      'La posture ouverte',
      'Tenir une posture ample 2 minutes peut augmenter le sentiment de confiance avant un défi.',
    ),
    (
      'Le dialogue interne',
      'Se parler à la 2e personne (« tu peux le faire ») améliore la performance.',
    ),
    (
      'Collectionne les preuves',
      'Note tes réussites : la confiance se construit sur des faits, pas sur l\'humeur du jour.',
    ),
    (
      'Agir avant de se sentir prêt',
      'La confiance suit l\'action autant qu\'elle la précède. Commence, le reste vient.',
    ),
  ],
  'bien-etre': [
    (
      'La cohérence cardiaque',
      'Respire 6 fois par minute pendant 5 min (3 fois/jour) : un grand classique pour apaiser le système nerveux.',
    ),
    (
      'Le scan corporel',
      'Passer son attention de la tête aux pieds relâche les tensions qu\'on ne remarquait même plus.',
    ),
    (
      'La règle des 20 minutes sans écran',
      'Couper toute notification 20 min avant une pause recharge l\'attention bien plus qu\'un scroll.',
    ),
    (
      'Bouger pour l\'énergie',
      'L\'énergie ne se trouve pas dans le repos seul : un peu de mouvement en crée plus qu\'il n\'en consomme.',
    ),
  ],
  'apprentissage': [
    (
      'La répétition espacée',
      'Revoir une notion à intervalles croissants (1j, 3j, 7j) ancre la mémoire bien plus que tout relire d\'un coup.',
    ),
    (
      'S\'auto-tester',
      'Se réciter de mémoire est 2 à 3 fois plus efficace que relire passivement ses notes.',
    ),
    (
      'Enseigner pour comprendre',
      'Expliquer une idée à voix haute révèle instantanément ce qu\'on n\'a pas vraiment compris.',
    ),
    (
      'Le palais mental',
      'Associer des infos à des lieux familiers permet de retenir des listes entières sans effort.',
    ),
  ],
  'business': [
    (
      'Vendre, c\'est écouter',
      'Les meilleurs vendeurs parlent moins : ils posent des questions et écoutent le besoin réel.',
    ),
    (
      'Le MVP d\'abord',
      'Lance une version minimale et imparfaite : le marché t\'apprendra plus que des mois de préparation.',
    ),
    (
      'Ne négocie jamais le prix en premier',
      'Crée d\'abord de la valeur perçue ; le prix se discute toujours mieux ensuite.',
    ),
    (
      'Ton réseau est un actif',
      'Donne avant de demander : les relations entretenues sans intérêt immédiat ouvrent le plus de portes.',
    ),
  ],
  'finance': [
    (
      'Paie-toi en premier',
      'Mets de côté dès que tu reçois ton revenu, avant de dépenser : l\'épargne devient automatique.',
    ),
    (
      'Les intérêts composés',
      'Placé tôt, ton argent génère des intérêts… sur tes intérêts. Le temps est ton meilleur allié.',
    ),
    (
      'La règle 50/30/20',
      '50 % besoins, 30 % envies, 20 % épargne : un repère simple pour équilibrer ton budget.',
    ),
    (
      'Diversifier le risque',
      'Ne mets pas tout au même endroit : répartir tes placements réduit fortement le risque.',
    ),
  ],
  'spiritualite': [
    (
      'Trois gratitudes par jour',
      'Noter chaque soir 3 choses positives recâble peu à peu le cerveau vers le positif.',
    ),
    (
      'Le pouvoir du silence',
      'Quelques minutes de silence quotidien réduisent le bruit mental et clarifient les décisions.',
    ),
    (
      'Vivre selon ses valeurs',
      'Quand tes actions s\'alignent avec tes valeurs profondes, le sentiment de vide laisse place à la paix.',
    ),
    (
      'L\'instant présent',
      'La plupart de nos souffrances vivent dans le passé ou le futur ; revenir au présent les apaise.',
    ),
  ],
  'creativite-arts': [
    (
      'La quantité crée la qualité',
      'Produire beaucoup, même imparfait, fait progresser plus vite que viser le chef-d\'œuvre du premier coup.',
    ),
    (
      'Contraindre pour créer',
      'Une contrainte (temps, couleur, format) libère paradoxalement plus de créativité que la page blanche.',
    ),
    (
      'Copier pour apprendre',
      'Reproduire les œuvres qu\'on admire est une école : on en extrait les principes, puis on s\'en détache.',
    ),
    (
      'Créer tous les jours',
      'Une petite création quotidienne entretient l\'élan créatif mieux que de rares sessions intenses.',
    ),
  ],
  'habitudes': [
    (
      'L\'empilement d\'habitudes',
      'Accroche une nouvelle habitude à une existante : « après mon café, je médite 2 min ».',
    ),
    (
      'La règle des 2 minutes',
      'Rends l\'habitude si petite qu\'elle prend moins de 2 min à démarrer : commencer est le plus dur.',
    ),
    (
      'Soigner son environnement',
      'Rendre une bonne habitude facile (et une mauvaise difficile) compte plus que la volonté.',
    ),
    (
      'Ne jamais manquer deux fois',
      'Rater un jour arrive ; l\'important est de ne pas enchaîner deux jours d\'affilée.',
    ),
  ],
};

List<FeedCard> _cardsFor(DomainItem d) {
  final tips = _tips[d.id] ?? const [];
  return [
    for (final (title, body) in tips)
      FeedCard(
        title: title,
        body: body,
        domainId: d.id,
        domainLabel: d.label,
        icon: d.icon,
        color: d.color,
      ),
  ];
}

/// Round-robin interleave so consecutive cards come from different domains.
List<FeedCard> _interleave(List<List<FeedCard>> lists) {
  final result = <FeedCard>[];
  var i = 0;
  var added = true;
  while (added) {
    added = false;
    for (final l in lists) {
      if (i < l.length) {
        result.add(l[i]);
        added = true;
      }
    }
    i++;
  }
  return result;
}

/// "Tout" feed: a bit of everything, all domains mixed.
List<FeedCard> allFeed() => _interleave(kDomains.map(_cardsFor).toList());

/// Themed feed: only the chosen domains (falls back to everything if empty).
List<FeedCard> themedFeed(Set<String> domainIds) {
  if (domainIds.isEmpty) return allFeed();
  final lists = kDomains
      .where((d) => domainIds.contains(d.id))
      .map(_cardsFor)
      .toList();
  return _interleave(lists);
}
