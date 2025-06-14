import 'cosmic_energy_system.dart';

class DailyMessageGenerator {
  static DailyMessage generateMessage({
    required String userName,
    required String eidosType,
    required String ganzhi,
  }) {
    final cosmicEnergy = CosmicEnergySystem.getCosmicEnergy(ganzhi);

    // Generate personalized message based on Eidos + Cosmic Energy combination
    final message =
        _generatePersonalizedMessage(userName, eidosType, cosmicEnergy);

    // Generate action-oriented hashtags based on today's energy
    final hashtags = _generateDailyHashtags(eidosType, cosmicEnergy);

    return DailyMessage(
      text: message,
      hashtags: hashtags,
      cosmicElement: cosmicEnergy.element,
      actionType: cosmicEnergy.actionType,
    );
  }

  static String _generatePersonalizedMessage(
      String userName, String eidosType, CosmicEnergy energy) {
    // Extract key characteristics from Eidos type
    final eidosKeywords = _extractEidosKeywords(eidosType);

    // Create dynamic message templates based on energy combination
    final templates = _getMessageTemplates(energy.element, energy.actionType);
    final selectedTemplate = templates[DateTime.now().day % templates.length];

    return selectedTemplate
        .replaceAll('{userName}', userName)
        .replaceAll('{eidosType}', eidosType)
        .replaceAll('{eidosKeyword}',
            eidosKeywords.isNotEmpty ? eidosKeywords.first : 'unique essence')
        .replaceAll('{intensity}', energy.intensity.toLowerCase())
        .replaceAll('{element}', energy.element.toLowerCase())
        .replaceAll('{actionType}', energy.actionType.toLowerCase());
  }

  static List<String> _extractEidosKeywords(String eidosType) {
    // Extract meaningful keywords from Eidos type name
    final words = eidosType.split(' ');
    return words
        .where((word) =>
            word.length > 3 &&
            !['The', 'of', 'and', 'in', 'with'].contains(word))
        .take(2)
        .toList();
  }

  static List<String> _getMessageTemplates(String element, String actionType) {
    final key = '${element}_$actionType';
    return _messageTemplates[key] ?? _defaultTemplates;
  }

  static List<String> _generateDailyHashtags(
      String eidosType, CosmicEnergy energy) {
    List<String> hashtags = [];

    // Add element-based hashtag
    hashtags.add('#${energy.element}Energy');

    // Add action-based hashtag
    hashtags.add('#${energy.actionType}');

    // Add cosmic energy keywords as hashtags
    hashtags.addAll(energy.keywords.take(2).map((keyword) => '#$keyword'));

    // Add Eidos-specific hashtag based on type
    final eidosKeywords = _extractEidosKeywords(eidosType);
    if (eidosKeywords.isNotEmpty) {
      hashtags.add('#${eidosKeywords.first}');
    }

    return hashtags.take(5).toList(); // Limit to 5 hashtags
  }

  static const List<String> _defaultTemplates = [
    '{userName}, as a \'{eidosType}\', today\'s {element} energy encourages you to embrace {actionType}. Your {eidosKeyword} nature aligns perfectly with this {intensity} cosmic flow.',
    '{userName}, the universe calls upon your \'{eidosType}\' essence today. Channel the {element} element through {actionType} and let your {eidosKeyword} spirit guide you.',
    'Today, {userName}, your \'{eidosType}\' energy resonates with the {intensity} {element} vibration. Focus on {actionType} to unlock your highest potential.',
  ];

  static const Map<String, List<String>> _messageTemplates = {
    // Wood Element Templates
    'Wood_Initiation': [
      '{userName}, as a \'{eidosType}\', today\'s wood energy empowers you to plant new seeds of possibility. Your {eidosKeyword} nature is perfectly aligned for fresh beginnings.',
      'The growing force of wood calls to your \'{eidosType}\' spirit, {userName}. Initiate projects that reflect your {eidosKeyword} essence.',
      '{userName}, channel your \'{eidosType}\' vision into new growth today. The wood element supports your natural {eidosKeyword} abilities.',
    ],
    'Wood_Nurturing': [
      '{userName}, your \'{eidosType}\' heart is called to nurture what matters most today. The gentle wood energy supports your {eidosKeyword} nature.',
      'As a \'{eidosType}\', {userName}, today\'s wood energy invites you to cultivate growth in yourself and others through your {eidosKeyword} gifts.',
      'The nurturing wood element resonates with your \'{eidosType}\' essence, {userName}. Focus on supporting growth and development.',
    ],
    'Wood_Creation': [
      '{userName}, your \'{eidosType}\' creativity is amplified by today\'s wood energy. Let your {eidosKeyword} imagination flourish.',
      'The creative force of wood aligns with your \'{eidosType}\' spirit, {userName}. Express your {eidosKeyword} vision through artistic endeavors.',
      'Today, {userName}, your \'{eidosType}\' nature finds perfect expression through wood\'s creative energy. Bring something beautiful into being.',
    ],

    // Fire Element Templates
    'Fire_Communication': [
      '{userName}, as a \'{eidosType}\', today\'s fire energy illuminates your voice. Share your {eidosKeyword} wisdom with passionate clarity.',
      'The bright fire element amplifies your \'{eidosType}\' message, {userName}. Communicate your {eidosKeyword} truth with confidence.',
      'Your \'{eidosType}\' spirit burns bright today, {userName}. Use fire\'s energy to express your {eidosKeyword} insights.',
    ],
    'Fire_Leadership': [
      '{userName}, your \'{eidosType}\' authority shines with today\'s fire energy. Lead others through your {eidosKeyword} example.',
      'The commanding fire element supports your \'{eidosType}\' leadership, {userName}. Guide others with your {eidosKeyword} vision.',
      'As a \'{eidosType}\', {userName}, today\'s fire energy calls you to lead with passion and {eidosKeyword} purpose.',
    ],
    'Fire_Creation': [
      '{userName}, your \'{eidosType}\' artistry is ignited by today\'s fire energy. Create something that reflects your {eidosKeyword} beauty.',
      'The artistic fire element resonates with your \'{eidosType}\' soul, {userName}. Express your {eidosKeyword} vision through creative flame.',
      'Today, {userName}, your \'{eidosType}\' creativity burns with inspired fire. Channel this energy into {eidosKeyword} expression.',
    ],

    // Earth Element Templates
    'Earth_Planning': [
      '{userName}, as a \'{eidosType}\', today\'s earth energy grounds your vision in practical planning. Your {eidosKeyword} wisdom guides solid foundations.',
      'The stable earth element supports your \'{eidosType}\' strategy, {userName}. Build lasting structures with your {eidosKeyword} insight.',
      'Your \'{eidosType}\' nature finds strength in earth\'s planning energy today, {userName}. Organize your {eidosKeyword} goals methodically.',
    ],
    'Earth_Building': [
      '{userName}, your \'{eidosType}\' determination is supported by earth\'s building energy. Construct something meaningful with your {eidosKeyword} skills.',
      'The foundational earth element aligns with your \'{eidosType}\' purpose, {userName}. Build lasting value through your {eidosKeyword} efforts.',
      'As a \'{eidosType}\', {userName}, today\'s earth energy empowers you to build solid progress with {eidosKeyword} persistence.',
    ],

    // Metal Element Templates
    'Metal_Decision': [
      '{userName}, your \'{eidosType}\' clarity is sharpened by today\'s metal energy. Make decisive choices with your {eidosKeyword} wisdom.',
      'The precise metal element supports your \'{eidosType}\' judgment, {userName}. Cut through confusion with {eidosKeyword} clarity.',
      'As a \'{eidosType}\', {userName}, today\'s metal energy refines your decision-making. Trust your {eidosKeyword} discernment.',
    ],
    'Metal_Mastery': [
      '{userName}, your \'{eidosType}\' skills are honed by metal\'s perfecting energy. Achieve mastery through your {eidosKeyword} dedication.',
      'The refining metal element elevates your \'{eidosType}\' abilities, {userName}. Polish your {eidosKeyword} talents to excellence.',
      'Today, {userName}, your \'{eidosType}\' expertise is enhanced by metal\'s energy. Perfect your {eidosKeyword} craft.',
    ],

    // Water Element Templates
    'Water_Flow': [
      '{userName}, as a \'{eidosType}\', today\'s water energy invites you to flow with change. Your {eidosKeyword} adaptability is your strength.',
      'The flowing water element supports your \'{eidosType}\' flexibility, {userName}. Navigate challenges with {eidosKeyword} grace.',
      'Your \'{eidosType}\' nature moves like water today, {userName}. Embrace change with {eidosKeyword} fluidity.',
    ],
    'Water_Connection': [
      '{userName}, your \'{eidosType}\' empathy is deepened by water\'s connecting energy. Build meaningful bonds through your {eidosKeyword} understanding.',
      'The unifying water element enhances your \'{eidosType}\' relationships, {userName}. Connect with others through {eidosKeyword} compassion.',
      'As a \'{eidosType}\', {userName}, today\'s water energy flows through your {eidosKeyword} connections with others.',
    ],
    'Water_Insight': [
      '{userName}, your \'{eidosType}\' intuition is heightened by water\'s depth. Trust your {eidosKeyword} inner knowing.',
      'The intuitive water element amplifies your \'{eidosType}\' wisdom, {userName}. Dive deep into {eidosKeyword} understanding.',
      'Today, {userName}, your \'{eidosType}\' insight flows like deep water. Access your {eidosKeyword} inner wisdom.',
    ],
  };
}

class DailyMessage {
  final String text;
  final List<String> hashtags;
  final String cosmicElement;
  final String actionType;

  const DailyMessage({
    required this.text,
    required this.hashtags,
    required this.cosmicElement,
    required this.actionType,
  });
}
