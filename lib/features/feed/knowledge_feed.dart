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
    ('L\'effet de simple exposition',
        'Plus on est exposé à quelque chose, plus on a tendance à l\'apprécier. La familiarité crée la sympathie.'),
    ('Le biais de négativité',
        'Notre cerveau retient plus fortement le négatif que le positif. En avoir conscience aide à relativiser.'),
    ('Nommer pour apaiser',
        'Mettre un mot sur une émotion réduit son intensité : c\'est l\'« affect labeling ».'),
    ('Le pouvoir des micro-réussites',
        'Chaque petite victoire libère de la dopamine et entretient la motivation.'),
  ],
  'anxiete': [
    ('Respiration 4-7-8',
        'Inspire 4 s, retiens 7 s, expire 8 s. Trois cycles suffisent souvent à calmer le système nerveux.'),
    ('Ancrage 5-4-3-2-1',
        'Nomme 5 choses que tu vois, 4 que tu touches, 3 que tu entends, 2 que tu sens, 1 que tu goûtes.'),
    ('Une pensée n\'est pas un fait',
        'Une inquiétude est une hypothèse, pas une vérité. Demande-toi : quelles preuves réelles ?'),
    ('Bouger pour décharger',
        '10 minutes de marche font baisser le cortisol, l\'hormone du stress.'),
  ],
  'productivite': [
    ('La règle des 2 minutes',
        'Si une tâche prend moins de 2 minutes, fais-la tout de suite plutôt que de la noter.'),
    ('Le time-blocking',
        'Réserve des plages horaires dédiées : ce qui est planifié a bien plus de chances d\'être fait.'),
    ('La loi de Parkinson',
        'Le travail s\'étire jusqu\'à remplir le temps disponible. Fixe-toi des délais courts.'),
    ('Mono-tâche',
        'Le multitâche peut réduire l\'efficacité jusqu\'à 40 %. Une seule chose à la fois.'),
  ],
  'sport': [
    ('Le NEAT compte',
        'Les calories brûlées hors sport (marcher, bouger) pèsent souvent plus que la séance elle-même.'),
    ('La surcharge progressive',
        'Pour progresser, augmente peu à peu la difficulté : poids, répétitions ou durée.'),
    ('La récupération, c\'est le progrès',
        'Les muscles se renforcent au repos, pas pendant l\'effort. Dors et alterne.'),
    ('2 minutes pour démarrer',
        'La vraie barrière, c\'est le démarrage. Promets-toi juste 2 minutes : tu continueras souvent.'),
  ],
  'nutrition': [
    ('L\'assiette repère',
        'Moitié légumes, un quart protéines, un quart féculents : simple et efficace.'),
    ('Manger lentement',
        'La satiété met ~20 min à arriver. Poser sa fourchette entre les bouchées aide à moins manger.'),
    ('L\'eau d\'abord',
        'On confond souvent soif et faim. Un verre d\'eau avant de grignoter peut suffire.'),
    ('Le sucre caché',
        'Beaucoup de produits salés contiennent du sucre ajouté. Prends l\'habitude de lire les étiquettes.'),
  ],
  'relations': [
    ('L\'écoute active',
        'Reformuler ce que dit l\'autre (« si je comprends bien… ») désamorce les malentendus.'),
    ('Les langages de l\'amour',
        'Chacun reçoit l\'affection différemment : mots, temps, gestes, services, cadeaux.'),
    ('Le ratio 5:1',
        'Les relations solides comptent ~5 interactions positives pour 1 négative.'),
    ('Demander clairement',
        'Exprimer un besoin précis vaut mieux qu\'espérer que l\'autre le devine.'),
  ],
  'sommeil': [
    ('La lumière du matin',
        'S\'exposer à la lumière au réveil cale l\'horloge interne et facilite l\'endormissement le soir.'),
    ('La régularité avant tout',
        'Se coucher et se lever à heures fixes est le facteur n°1 d\'un bon sommeil.'),
    ('La sieste éclair',
        '10 à 20 minutes maximum : au-delà, on entre en sommeil profond et on se réveille groggy.'),
    ('Écrans et mélatonine',
        'La lumière bleue retarde la mélatonine. Coupe les écrans 30 à 60 min avant le coucher.'),
  ],
  'confiance': [
    ('La posture ouverte',
        'Tenir une posture ample 2 minutes peut augmenter le sentiment de confiance avant un défi.'),
    ('Le dialogue interne',
        'Se parler à la 2e personne (« tu peux le faire ») améliore la performance.'),
    ('Collectionne les preuves',
        'Note tes réussites : la confiance se construit sur des faits, pas sur l\'humeur du jour.'),
    ('Agir avant de se sentir prêt',
        'La confiance suit l\'action autant qu\'elle la précède. Commence, le reste vient.'),
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
