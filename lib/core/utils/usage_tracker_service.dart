import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../database/hive_service.dart';
import '../database/models/usage_tracker_model.dart';
import '../constants/app_constants.dart';
import 'device_id_generator.dart';

class UsageTrackerService {
  // Get or create usage tracker for today
  static UsageTrackerModel getTodayUsage() {
    final box = HiveService.usageBox;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    UsageTrackerModel? usage = box.get('current');

    // If no usage or different date, create new
    if (usage == null || usage.currentDate != today) {
      usage = _createNewUsageTracker(today);
      box.put('current', usage);
    }

    // Check if needs reset (past 1 AM reset time)
    if (usage.shouldReset()) {
      usage = _resetUsageTracker(usage);
      box.put('current', usage);
    }

    return usage;
  }

  // Create new usage tracker
  static UsageTrackerModel _createNewUsageTracker(String date) {
    final now = DateTime.now();
    final resetTime = _getNextResetTime(now);

    return UsageTrackerModel(
      deviceId: DeviceIdGenerator.getDeviceId(),
      currentDate: date,
      analysisCount: 0,
      nextResetTime: resetTime,
      timezone: AppConstants.defaultTimezone,
    );
  }

  // Reset usage tracker
  static UsageTrackerModel _resetUsageTracker(UsageTrackerModel oldUsage) {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final resetTime = _getNextResetTime(now);

    return UsageTrackerModel(
      deviceId: oldUsage.deviceId,
      currentDate: today,
      analysisCount: 0,
      nextResetTime: resetTime,
      timezone: oldUsage.timezone,
    );
  }

  // Calculate next reset time (1 AM next day or today if before 1 AM)
  static DateTime _getNextResetTime(DateTime now) {
    final today1AM = DateTime(
      now.year,
      now.month,
      now.day,
      AppConstants.resetHour, // 1 AM
      0,
      0,
    );

    // If current time is before 1 AM today, reset at 1 AM today
    if (now.isBefore(today1AM)) {
      return today1AM;
    }

    // Otherwise, reset at 1 AM tomorrow
    return today1AM.add(const Duration(days: 1));
  }

  // Check if can analyze
  static bool canAnalyze() {
    final usage = getTodayUsage();
    return usage.canAnalyze;
  }

  // Get remaining analyses
  static int getRemainingAnalyses() {
    final usage = getTodayUsage();
    return usage.remainingAnalyses;
  }

  // Increment analysis count
  static Future<void> incrementAnalysisCount() async {
    final box = HiveService.usageBox;
    final usage = getTodayUsage();

    if (usage.canAnalyze) {
      usage.analysisCount++;
      await box.put('current', usage);
    }
  }

  // Get time until reset
  static Duration getTimeUntilReset() {
    final usage = getTodayUsage();
    return usage.timeUntilReset;
  }

  // Format time until reset
  static String getFormattedTimeUntilReset() {
    final duration = getTimeUntilReset();
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
