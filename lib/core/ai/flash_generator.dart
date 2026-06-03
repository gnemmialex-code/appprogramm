/// Flash mode: 7 punchy, full-screen swipe cards covering a sub-theme in
/// ~5 minutes. No exercises, no quiz — pure distilled learning.
library;

class FlashCard {
  final String emoji;
  final String tag; // small caps label
  final String headline;
  final String body;
  final String actionTip; // 1-line action the user can do right now
  const FlashCard({
    required this.emoji,
    required this.tag,
    required this.headline,
    required this.body,
    required this.actionTip,
  });
}

List<FlashCard> generateFlashCards(String domain, String subTheme) {
  final d = domain.trim();
  final s = subTheme.trim().isNotEmpty ? subTheme.trim() : d;

  return [
    FlashCard(
      emoji: '🔑',
      tag: 'LE CONCEPT CLÉ',
      headline: 'Ce qu\'est vraiment $s',
      body:
          '$s, c\'est avant tout une compétence qui se développe — '
          'pas un trait de personnalité fixe. '
          'La plupart des gens la subissent passivement; '
          'les meilleurs en font un levier conscient et actif.',
      actionTip: 'Définis $s en une phrase dans tes propres mots.',
    ),
    FlashCard(
      emoji: '🤯',
      tag: 'LE FAIT SURPRENANT',
      headline: 'Ce que personne ne te dit sur $s',
      body:
          'Contre-intuitivement, progresser en $s nécessite d\'abord '
          'de comprendre pourquoi tu as échoué jusqu\'ici — '
          'pas de faire plus d\'efforts. '
          '80 % des blocages viennent d\'un seul schéma répété, '
          'pas d\'un manque de volonté.',
      actionTip: 'Identifie ton schéma bloquant n°1 en $s.',
    ),
    FlashCard(
      emoji: '🛠️',
      tag: 'LA TECHNIQUE #1',
      headline: 'La méthode la plus efficace',
      body:
          'Les experts en $s utilisent tous une pratique en commun : '
          'la micro-répétition quotidienne. '
          '5 minutes chaque jour surpassent 2 heures le week-end. '
          'Le cerveau consolide ce qui est régulier, pas ce qui est intense.',
      actionTip: 'Fixe un moment précis chaque jour pour pratiquer $s.',
    ),
    FlashCard(
      emoji: '⚠️',
      tag: "L'ERREUR FRÉQUENTE",
      headline: 'Ce que tout le monde fait mal',
      body:
          'L\'erreur la plus commune en $s : '
          'chercher la solution parfaite avant d\'agir. '
          'Cela crée un cycle de procrastination déguisée en préparation. '
          'L\'action imparfaite maintenant bat toujours '
          'la stratégie parfaite de demain.',
      actionTip:
          'Fais une action imparfaite en $s dans les 10 prochaines minutes.',
    ),
    FlashCard(
      emoji: '🏆',
      tag: 'LA RÈGLE D\'OR',
      headline: 'Le principe qui change tout',
      body:
          'En $s, la règle d\'or est simple : '
          'mesure tes progrès, pas tes efforts. '
          'Ce qu\'on ne mesure pas stagne. '
          'Un indicateur simple et personnel — '
          'même subjectif — suffit pour maintenir la direction.',
      actionTip: 'Choisis un indicateur pour suivre ta progression en $s.',
    ),
    FlashCard(
      emoji: '⚡',
      tag: 'À FAIRE MAINTENANT',
      headline: 'Ton action immédiate',
      body:
          'Tu viens d\'absorber 4 concepts clés sur $s. '
          'Pour ancrer tout ça, ton cerveau a besoin d\'une action concrète '
          'dans les 24 prochaines heures. '
          'Pas une grande action — une petite, précise, mesurable.',
      actionTip: 'Écris une micro-action $s que tu feras ce soir.',
    ),
    FlashCard(
      emoji: '🚀',
      tag: 'POUR ALLER PLUS LOIN',
      headline: 'Ta prochaine étape',
      body:
          'Tu as les bases solides de $s en 5 minutes. '
          'Pour vraiment maîtriser ce domaine, '
          'la prochaine étape est de passer au programme complet : '
          '12 chapitres progressifs qui transforment '
          'cette connaissance en habitude profonde.',
      actionTip: 'Lance le programme $s pour ancrer ces insights durablement.',
    ),
  ];
}
