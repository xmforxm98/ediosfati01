class CosmicEnergySystem {
  static CosmicEnergy getCosmicEnergy(String ganzhi) {
    print('🌟 CosmicEnergySystem.getCosmicEnergy called with: "$ganzhi"');
    final energy = _cosmicEnergyMap[ganzhi] ?? _defaultEnergy;
    print('🌟 Returned energy: ${energy.element} - ${energy.actionType}');
    if (_cosmicEnergyMap[ganzhi] == null) {
      print('⚠️  Ganzhi "$ganzhi" not found in map, using default energy');
      print(
          '⚠️  Available ganzhi keys: ${_cosmicEnergyMap.keys.take(10).toList()}...');
    }
    return energy;
  }

  static const CosmicEnergy _defaultEnergy = CosmicEnergy(
    element: 'Neutral',
    intensity: 'Moderate',
    actionType: 'Reflection',
    keywords: ['Balance', 'Harmony', 'Stability'],
  );

  static const Map<String, CosmicEnergy> _cosmicEnergyMap = {
    // Wood Element Days (甲乙 - Growth, Creativity, New Beginnings)
    '甲子': CosmicEnergy(
        element: 'Wood',
        intensity: 'Strong',
        actionType: 'Initiation',
        keywords: ['NewBeginnings', 'Leadership', 'Innovation']),
    '乙丑': CosmicEnergy(
        element: 'Wood',
        intensity: 'Gentle',
        actionType: 'Nurturing',
        keywords: ['Growth', 'Patience', 'Cultivation']),
    '甲寅': CosmicEnergy(
        element: 'Wood',
        intensity: 'Powerful',
        actionType: 'Expansion',
        keywords: ['BoldAction', 'Confidence', 'Growth']),
    '乙卯': CosmicEnergy(
        element: 'Wood',
        intensity: 'Harmonious',
        actionType: 'Creation',
        keywords: ['Creativity', 'Artistic', 'Gentle']),
    '甲辰': CosmicEnergy(
        element: 'Wood',
        intensity: 'Dynamic',
        actionType: 'Vision',
        keywords: ['BigPicture', 'Transformation', 'Power']),
    '乙巳': CosmicEnergy(
        element: 'Wood',
        intensity: 'Refined',
        actionType: 'Strategy',
        keywords: ['Wisdom', 'Planning', 'Flexibility']),
    '甲午': CosmicEnergy(
        element: 'Wood',
        intensity: 'Vibrant',
        actionType: 'Movement',
        keywords: ['Energy', 'Progress', 'Enthusiasm']),
    '乙未': CosmicEnergy(
        element: 'Wood',
        intensity: 'Compassionate',
        actionType: 'Healing',
        keywords: ['Empathy', 'Care', 'Support']),
    '甲申': CosmicEnergy(
        element: 'Wood',
        intensity: 'Innovative',
        actionType: 'Problem-Solving',
        keywords: ['Ingenuity', 'Adaptation', 'Solutions']),
    '乙酉': CosmicEnergy(
        element: 'Wood',
        intensity: 'Detailed',
        actionType: 'Refinement',
        keywords: ['Precision', 'Quality', 'Improvement']),
    '甲戌': CosmicEnergy(
        element: 'Wood',
        intensity: 'Protective',
        actionType: 'Foundation',
        keywords: ['Security', 'Loyalty', 'Building']),
    '乙亥': CosmicEnergy(
        element: 'Wood',
        intensity: 'Generous',
        actionType: 'Connection',
        keywords: ['Community', 'Sharing', 'Abundance']),

    // Fire Element Days (丙丁 - Passion, Communication, Illumination)
    '丙子': CosmicEnergy(
        element: 'Fire',
        intensity: 'Bright',
        actionType: 'Communication',
        keywords: ['Expression', 'Charisma', 'Social']),
    '丁丑': CosmicEnergy(
        element: 'Fire',
        intensity: 'Steady',
        actionType: 'Persistence',
        keywords: ['Determination', 'Focus', 'Endurance']),
    '丙寅': CosmicEnergy(
        element: 'Fire',
        intensity: 'Explosive',
        actionType: 'Breakthrough',
        keywords: ['Courage', 'Revolution', 'Change']),
    '丁卯': CosmicEnergy(
        element: 'Fire',
        intensity: 'Warm',
        actionType: 'Inspiration',
        keywords: ['Creativity', 'Warmth', 'Motivation']),
    '丙辰': CosmicEnergy(
        element: 'Fire',
        intensity: 'Magnificent',
        actionType: 'Leadership',
        keywords: ['Authority', 'Vision', 'Influence']),
    '丁巳': CosmicEnergy(
        element: 'Fire',
        intensity: 'Illuminating',
        actionType: 'Insight',
        keywords: ['Wisdom', 'Understanding', 'Clarity']),
    '丙午': CosmicEnergy(
        element: 'Fire',
        intensity: 'Peak',
        actionType: 'Achievement',
        keywords: ['Success', 'Recognition', 'Glory']),
    '丁未': CosmicEnergy(
        element: 'Fire',
        intensity: 'Artistic',
        actionType: 'Creation',
        keywords: ['Beauty', 'Art', 'Refinement']),
    '丙申': CosmicEnergy(
        element: 'Fire',
        intensity: 'Brilliant',
        actionType: 'Innovation',
        keywords: ['Genius', 'Invention', 'Breakthrough']),
    '丁酉': CosmicEnergy(
        element: 'Fire',
        intensity: 'Precise',
        actionType: 'Perfection',
        keywords: ['Excellence', 'Detail', 'Mastery']),
    '丙戌': CosmicEnergy(
        element: 'Fire',
        intensity: 'Loyal',
        actionType: 'Service',
        keywords: ['Duty', 'Honor', 'Commitment']),
    '丁亥': CosmicEnergy(
        element: 'Fire',
        intensity: 'Passionate',
        actionType: 'Connection',
        keywords: ['Love', 'Emotion', 'Depth']),

    // Earth Element Days (戊己 - Stability, Grounding, Practical Action)
    '戊子': CosmicEnergy(
        element: 'Earth',
        intensity: 'Resourceful',
        actionType: 'Planning',
        keywords: ['Strategy', 'Resources', 'Foundation']),
    '己丑': CosmicEnergy(
        element: 'Earth',
        intensity: 'Methodical',
        actionType: 'Building',
        keywords: ['Structure', 'Patience', 'Reliability']),
    '戊寅': CosmicEnergy(
        element: 'Earth',
        intensity: 'Ambitious',
        actionType: 'Achievement',
        keywords: ['Goals', 'Power', 'Success']),
    '己卯': CosmicEnergy(
        element: 'Earth',
        intensity: 'Nurturing',
        actionType: 'Care',
        keywords: ['Support', 'Kindness', 'Growth']),
    '戊辰': CosmicEnergy(
        element: 'Earth',
        intensity: 'Transformative',
        actionType: 'Change',
        keywords: ['Evolution', 'Breakthrough', 'Power']),
    '己巳': CosmicEnergy(
        element: 'Earth',
        intensity: 'Wise',
        actionType: 'Contemplation',
        keywords: ['Reflection', 'Knowledge', 'Insight']),
    '戊午': CosmicEnergy(
        element: 'Earth',
        intensity: 'Confident',
        actionType: 'Leadership',
        keywords: ['Authority', 'Stability', 'Strength']),
    '己未': CosmicEnergy(
        element: 'Earth',
        intensity: 'Gentle',
        actionType: 'Harmony',
        keywords: ['Peace', 'Balance', 'Care']),
    '戊申': CosmicEnergy(
        element: 'Earth',
        intensity: 'Practical',
        actionType: 'Implementation',
        keywords: ['Efficiency', 'Results', 'Solutions']),
    '己酉': CosmicEnergy(
        element: 'Earth',
        intensity: 'Productive',
        actionType: 'Work',
        keywords: ['Diligence', 'Quality', 'Achievement']),
    '戊戌': CosmicEnergy(
        element: 'Earth',
        intensity: 'Protective',
        actionType: 'Security',
        keywords: ['Safety', 'Trust', 'Foundation']),
    '己亥': CosmicEnergy(
        element: 'Earth',
        intensity: 'Abundant',
        actionType: 'Sharing',
        keywords: ['Generosity', 'Wealth', 'Community']),

    // Metal Element Days (庚辛 - Clarity, Justice, Refinement)
    '庚子': CosmicEnergy(
        element: 'Metal',
        intensity: 'Sharp',
        actionType: 'Decision',
        keywords: ['Clarity', 'Logic', 'Precision']),
    '辛丑': CosmicEnergy(
        element: 'Metal',
        intensity: 'Resilient',
        actionType: 'Endurance',
        keywords: ['Strength', 'Persistence', 'Value']),
    '庚寅': CosmicEnergy(
        element: 'Metal',
        intensity: 'Righteous',
        actionType: 'Justice',
        keywords: ['Fairness', 'Courage', 'Truth']),
    '辛卯': CosmicEnergy(
        element: 'Metal',
        intensity: 'Refined',
        actionType: 'Aesthetics',
        keywords: ['Beauty', 'Elegance', 'Skill']),
    '庚辰': CosmicEnergy(
        element: 'Metal',
        intensity: 'Powerful',
        actionType: 'Transformation',
        keywords: ['Change', 'Strength', 'Will']),
    '辛巳': CosmicEnergy(
        element: 'Metal',
        intensity: 'Strategic',
        actionType: 'Planning',
        keywords: ['Intelligence', 'Strategy', 'Refinement']),
    '庚午': CosmicEnergy(
        element: 'Metal',
        intensity: 'Decisive',
        actionType: 'Action',
        keywords: ['Leadership', 'Decision', 'Power']),
    '辛未': CosmicEnergy(
        element: 'Metal',
        intensity: 'Graceful',
        actionType: 'Harmony',
        keywords: ['Grace', 'Sensitivity', 'Art']),
    '庚申': CosmicEnergy(
        element: 'Metal',
        intensity: 'Skillful',
        actionType: 'Mastery',
        keywords: ['Expertise', 'Skill', 'Excellence']),
    '辛酉': CosmicEnergy(
        element: 'Metal',
        intensity: 'Valuable',
        actionType: 'Perfection',
        keywords: ['Quality', 'Worth', 'Refinement']),
    '庚戌': CosmicEnergy(
        element: 'Metal',
        intensity: 'Principled',
        actionType: 'Duty',
        keywords: ['Honor', 'Responsibility', 'Justice']),
    '辛亥': CosmicEnergy(
        element: 'Metal',
        intensity: 'Refined',
        actionType: 'Enjoyment',
        keywords: ['Pleasure', 'Taste', 'Appreciation']),

    // Water Element Days (壬癸 - Flow, Intuition, Adaptation)
    '壬子': CosmicEnergy(
        element: 'Water',
        intensity: 'Deep',
        actionType: 'Connection',
        keywords: ['Intuition', 'Social', 'Depth']),
    '癸丑': CosmicEnergy(
        element: 'Water',
        intensity: 'Patient',
        actionType: 'Persistence',
        keywords: ['Endurance', 'Depth', 'Wisdom']),
    '壬寅': CosmicEnergy(
        element: 'Water',
        intensity: 'Instinctive',
        actionType: 'Courage',
        keywords: ['Intuition', 'Bravery', 'Flow']),
    '癸卯': CosmicEnergy(
        element: 'Water',
        intensity: 'Gentle',
        actionType: 'Nurturing',
        keywords: ['Care', 'Intuition', 'Growth']),
    '壬辰': CosmicEnergy(
        element: 'Water',
        intensity: 'Dynamic',
        actionType: 'Flow',
        keywords: ['Adaptation', 'Power', 'Wisdom']),
    '癸巳': CosmicEnergy(
        element: 'Water',
        intensity: 'Intuitive',
        actionType: 'Insight',
        keywords: ['Wisdom', 'Intuition', 'Strategy']),
    '壬午': CosmicEnergy(
        element: 'Water',
        intensity: 'Emotional',
        actionType: 'Expression',
        keywords: ['Feeling', 'Flow', 'Movement']),
    '癸未': CosmicEnergy(
        element: 'Water',
        intensity: 'Empathetic',
        actionType: 'Healing',
        keywords: ['Compassion', 'Intuition', 'Care']),
    '壬申': CosmicEnergy(
        element: 'Water',
        intensity: 'Adaptable',
        actionType: 'Innovation',
        keywords: ['Flexibility', 'Intelligence', 'Flow']),
    '癸酉': CosmicEnergy(
        element: 'Water',
        intensity: 'Meticulous',
        actionType: 'Refinement',
        keywords: ['Detail', 'Intuition', 'Quality']),
    '壬戌': CosmicEnergy(
        element: 'Water',
        intensity: 'Protective',
        actionType: 'Trust',
        keywords: ['Loyalty', 'Flow', 'Protection']),
    '癸亥': CosmicEnergy(
        element: 'Water',
        intensity: 'Peaceful',
        actionType: 'Harmony',
        keywords: ['Peace', 'Connection', 'Flow']),
  };
}

class CosmicEnergy {
  final String element;
  final String intensity;
  final String actionType;
  final List<String> keywords;

  const CosmicEnergy({
    required this.element,
    required this.intensity,
    required this.actionType,
    required this.keywords,
  });
}
