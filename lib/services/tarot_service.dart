import 'dart:math';

class TarotService {
  static const String _baseUrl =
      'https://firebasestorage.googleapis.com/v0/b/innerfive.firebasestorage.app/o/tarot_cards%2F';
  static const String _urlSuffix = '?alt=media';

  // Tarot card name mappings (Firebase filename -> Display name)
  static const Map<String, String> _cardNameMappings = {
    'foolcrown': 'The Fool',
    'magician': 'The Magician',
    'highpriestess': 'The High Priestess',
    'theempress': 'The Empress',
    'emperor': 'The Emperor',
    'hierophant': 'The Hierophant',
    'lover': 'The Lovers',
    'chariot': 'The Chariot',
    'strength': 'Strength',
    'hermit': 'The Hermit',
    'wheeloffortune': 'Wheel of Fortune',
    'justice': 'Justice',
    'hangedman': 'The Hanged Man',
    'death': 'Death',
    'temperance': 'Temperance',
    'devil': 'The Devil',
    'tower': 'The Tower',
    'star': 'The Star',
    'moon': 'The Moon',
    'sun': 'The Sun',
    'judgment': 'Judgment',
    'world': 'The World',
  };

  // Get available tarot card types
  static List<String> get availableCards => _cardNameMappings.keys.toList();

  /// Get a random tarot card image URL for a specific card
  /// [cardName] should be the key from _cardNameMappings (e.g., 'foolcrown', 'magician')
  static String getRandomCardImageUrl(String cardName) {
    if (!_cardNameMappings.containsKey(cardName)) {
      // Fallback to first available card if invalid name
      cardName = availableCards.first;
    }

    // Each card has 4 variations (1-4)
    final random = Random();
    final variation = random.nextInt(4) + 1; // 1, 2, 3, or 4

    // Handle special case for 'hermit' which has capital H in filename
    String filename =
        cardName == 'hermit'
            ? 'Hermit$variation.png'
            : '$cardName$variation.png';

    return '$_baseUrl${Uri.encodeComponent(filename)}$_urlSuffix';
  }

  /// Get the display name for a card
  static String getCardDisplayName(String cardName) {
    return _cardNameMappings[cardName] ?? 'Unknown Card';
  }

  /// Extract card name from tarot insight analysis result
  /// This method analyzes the tarot card name from analysis and finds the best match
  static String extractCardNameFromAnalysis(String tarotCardTitle) {
    final lowerTitle = tarotCardTitle.toLowerCase();

    // Direct mapping attempts
    for (final entry in _cardNameMappings.entries) {
      final cardKey = entry.key;
      final cardDisplayName = entry.value.toLowerCase();

      // Check if the title contains the card name
      if (lowerTitle.contains(cardDisplayName) ||
          lowerTitle.contains(cardKey) ||
          cardDisplayName.contains(
            lowerTitle.replaceAll(RegExp(r'[^a-z\s]'), ''),
          )) {
        return cardKey;
      }
    }

    // Special case mappings for common variations
    final specialMappings = {
      'fool': 'foolcrown',
      'wheel': 'wheeloffortune',
      'hanged': 'hangedman',
      'high priestess': 'highpriestess',
      'the empress': 'theempress',
      'lovers': 'lover',
    };

    for (final entry in specialMappings.entries) {
      if (lowerTitle.contains(entry.key)) {
        return entry.value;
      }
    }

    // If no match found, return a random card
    final random = Random();
    return availableCards[random.nextInt(availableCards.length)];
  }

  /// Get tarot card info including image URL and display name
  static Map<String, String> getCardInfo(String analysisCardTitle) {
    final cardName = extractCardNameFromAnalysis(analysisCardTitle);
    return {
      'cardName': cardName,
      'displayName': getCardDisplayName(cardName),
      'imageUrl': getRandomCardImageUrl(cardName),
    };
  }

  /// Preload a specific card image for caching
  static void preloadCardImage(String cardName) {
    // This method can be called to preload specific card images
    // The actual preloading will be handled by the UI layer using Image.network
    final imageUrl = getRandomCardImageUrl(cardName);
    print('Preloading tarot card: $cardName -> $imageUrl');
  }

  /// Get all 4 variations of a specific card (for testing/debugging)
  static List<String> getAllVariationsOfCard(String cardName) {
    if (!_cardNameMappings.containsKey(cardName)) {
      return [];
    }

    return List.generate(4, (index) {
      final variation = index + 1;
      String filename =
          cardName == 'hermit'
              ? 'Hermit$variation.png'
              : '$cardName$variation.png';
      return '$_baseUrl${Uri.encodeComponent(filename)}$_urlSuffix';
    });
  }
}
