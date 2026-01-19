class AppConstants {
  // App Info
  static const String appName = 'Dream Analysis';
  static const String appVersion = '1.0.0';

  // Usage Limits
  static const int maxDailyAnalysis = 4;
  static const int resetHour = 1; // 1 AM

  // Storage Keys
  static const String deviceIdKey = 'device_id';
  static const String usageTrackerKey = 'usage_tracker';
  static const String dreamsBoxKey = 'dreams_box';
  static const String themeKey = 'theme_mode';
  static const String timezoneKey = 'timezone';

  // Validation
  static const int minDreamTextLength = 10;
  static const int maxDreamTextLength = 2000;
  static const int maxTagsCount = 5;

  // Default Values
  static const String defaultTimezone = 'Asia/Kolkata';
}
