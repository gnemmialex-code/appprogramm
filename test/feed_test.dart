import 'package:flutter_test/flutter_test.dart';
import 'package:lumina/features/feed/knowledge_feed.dart';

void main() {
  group('knowledge feed', () {
    test('"Tout" feed mixes several domains', () {
      final cards = allFeed();
      expect(cards.length, greaterThan(10));
      final domains = cards.map((c) => c.domainId).toSet();
      expect(domains.length, greaterThanOrEqualTo(5));
    });

    test('"Tout" feed interleaves domains (no long runs)', () {
      final cards = allFeed();
      // Consecutive cards should usually differ in domain.
      var sameNeighbour = 0;
      for (var i = 1; i < cards.length; i++) {
        if (cards[i].domainId == cards[i - 1].domainId) sameNeighbour++;
      }
      expect(sameNeighbour, 0);
    });

    test('themed feed only contains the chosen domains', () {
      final cards = themedFeed({'sommeil', 'sport'});
      expect(cards, isNotEmpty);
      expect(
        cards.every((c) => c.domainId == 'sommeil' || c.domainId == 'sport'),
        isTrue,
      );
    });

    test('themed feed falls back to everything when empty', () {
      expect(themedFeed(const {}).length, allFeed().length);
    });
  });
}
