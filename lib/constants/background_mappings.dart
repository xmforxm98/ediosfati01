// Auto-generated background image URL mappings
class BackgroundMappings {
  static const Map<String, String> backgroundUrls = {
    "second_bg": "https://storage.googleapis.com/innerfive.firebasestorage.app/backgrounds/second_bg.png",
    "loading_bg": "https://storage.googleapis.com/innerfive.firebasestorage.app/backgrounds/loading_bg.png",
    "login2": "https://storage.googleapis.com/innerfive.firebasestorage.app/backgrounds/login2.png",
    "login3": "https://storage.googleapis.com/innerfive.firebasestorage.app/backgrounds/login3.png",
    "login1": "https://storage.googleapis.com/innerfive.firebasestorage.app/backgrounds/login1.png",
    "login4": "https://storage.googleapis.com/innerfive.firebasestorage.app/backgrounds/login4.png",
    "input_bg": "https://storage.googleapis.com/innerfive.firebasestorage.app/backgrounds/input_bg.png",
  };
  
  /// Get background URL by name
  static String? getBackgroundUrl(String backgroundName) {
    return backgroundUrls[backgroundName];
  }
  
  /// Get all available background names
  static List<String> getAllBackgroundNames() {
    return backgroundUrls.keys.toList();
  }
  
  // Convenience getters for specific backgrounds
  static String? get inputBg => backgroundUrls['input_bg'];
  static String? get loadingBg => backgroundUrls['loading_bg'];
  static String? get secondBg => backgroundUrls['second_bg'];
  static String? get login1 => backgroundUrls['login1'];
  static String? get login2 => backgroundUrls['login2'];
  static String? get login3 => backgroundUrls['login3'];
  static String? get login4 => backgroundUrls['login4'];
}
