class AppConfig {
  // API Configuration
  // Real deployed FastAPI backend (see noskipai-backend/main.py). Routers are
  // mounted with their own prefixes (/auth, /medications, /adherence, /ai, ...)
  // and there is NO '/v1' prefix anywhere. The public domain's nginx only
  // proxies backend requests under /api/ (stripped before reaching FastAPI) —
  // several backend paths (medications, adherence, family, doctor) share
  // their exact top-level name with a frontend web page, so a bare path
  // would be ambiguous. Do not drop the /api suffix.
  static const String apiBaseUrl = 'https://noskip.bakhromdev.uz/api';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // App Configuration
  static const String appName = 'NoSkipAI';
  static const String appVersion = '1.0.0';
  
  // Feature Flags
  static const bool enableCamera = true;
  static const bool enableTTS = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  
  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'uz', 'ru'];
  
  // Medication Frequencies
  static const List<String> frequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'Every other day',
    'Weekly',
    'As needed'
  ];
  
  // Default medication times
  static const List<String> defaultMedicationTimes = [
    '08:00',
    '14:00',
    '20:00',
  ];
  
  // Risk score thresholds
  static const double lowRiskThreshold = 0.3;
  static const double mediumRiskThreshold = 0.6;
  static const double highRiskThreshold = 0.8;
}
