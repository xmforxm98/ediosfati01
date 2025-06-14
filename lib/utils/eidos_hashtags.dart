class EidosHashtags {
  static List<String> getHashtagsForEidos(String eidosTitle) {
    // Return hashtags based on the Eidos type, with fallback to general tags
    return _eidosHashtagMap[eidosTitle] ?? _defaultHashtags;
  }

  static const List<String> _defaultHashtags = [
    '#DailyEnergy',
    '#SelfDiscovery',
    '#InnerWisdom'
  ];

  static const Map<String, List<String>> _eidosHashtagMap = {
    // Architect types
    'The Inspired Verdant Architect of Red Phoenix': [
      '#CreativeVision',
      '#NaturalLeadership',
      '#InnovativeDesign',
      '#PassionateBuilder'
    ],
    'The Luminous Creator': [
      '#CreativeExpression',
      '#ArtisticFlow',
      '#InspiredAction',
      '#LuminousEnergy'
    ],
    'The Mystic Sage': [
      '#AncientWisdom',
      '#SpiritualInsight',
      '#DeepKnowing',
      '#MysticPath'
    ],
    'The Harmonious Healer': [
      '#HealingEnergy',
      '#CompassionateHeart',
      '#BalanceSeeker',
      '#NurturingSpirit'
    ],
    'The Visionary Pioneer': [
      '#FutureVision',
      '#BoldExploration',
      '#TrailBlazer',
      '#InnovativeSpirit'
    ],
    'The Gentle Guardian': [
      '#ProtectiveNature',
      '#CaringHeart',
      '#StableFoundation',
      '#TrustWorthy'
    ],
    'The Dynamic Catalyst': [
      '#TransformativeForce',
      '#EnergeticAction',
      '#ChangeAgent',
      '#PowerfulImpact'
    ],
    'The Serene Observer': [
      '#MindfulAwareness',
      '#QuietWisdom',
      '#PeacefulPresence',
      '#DeepReflection'
    ],
    'The Radiant Communicator': [
      '#ExpressiveVoice',
      '#CharmingPresence',
      '#SocialConnection',
      '#BrightEnergy'
    ],
    'The Steadfast Builder': [
      '#SolidFoundation',
      '#PersistentEffort',
      '#ReliableStrength',
      '#MethodicalProgress'
    ],
    'The Intuitive Dreamer': [
      '#DreamVision',
      '#IntuitiveInsight',
      '#ImaginativeSpirit',
      '#SoulfulJourney'
    ],
    'The Fierce Warrior': [
      '#CourageousHeart',
      '#WarriorSpirit',
      '#BoldAction',
      '#FearlessPath'
    ],
    'The Wise Teacher': [
      '#KnowledgeSharing',
      '#GuidingLight',
      '#WisdomKeeper',
      '#MentorSpirit'
    ],
    'The Playful Innovator': [
      '#CreativePlay',
      '#JoyfulExploration',
      '#FreshPerspective',
      '#LightHeartedGenius'
    ],
    'The Compassionate Leader': [
      '#EmpathicLeadership',
      '#HeartCentered',
      '#InspiringGuidance',
      '#ServiceOriented'
    ],
    'The Free Spirit': [
      '#UnboundedFreedom',
      '#AdventurousHeart',
      '#SpontaneousJoy',
      '#WildSoul'
    ],
    'The Grounded Nurturer': [
      '#EarthyWisdom',
      '#NurturingCare',
      '#StableSupport',
      '#GrowthFacilitator'
    ],
    'The Electric Transformer': [
      '#ElectricEnergy',
      '#RapidChange',
      '#PowerfulShift',
      '#DynamicForce'
    ],
    'The Peaceful Mediator': [
      '#HarmonySeeker',
      '#ConflictResolver',
      '#BalanceBringer',
      '#PeaceMaker'
    ],
    'The Passionate Artist': [
      '#ArtisticPassion',
      '#CreativeFlame',
      '#ExpressiveArt',
      '#SoulfulCreation'
    ],
  };
}
