import 'package:hive/hive.dart';

part 'usage_tracker_model.g.dart';

@HiveType(typeId: 2)
class UsageTrackerModel {
  @HiveField(0)
  String deviceId;

  @HiveField(1)
  String currentDate; // YYYY-MM-DD format

  @HiveField(2)
  int analysisCount; // 0-4 for freemium

  @HiveField(3)
  DateTime nextResetTime; // 1 AM next day

  @HiveField(4)
  String timezone; // Asia/Kolkata

  UsageTrackerModel({
    required this.deviceId,
    required this.currentDate,
    this.analysisCount = 0,
    required this.nextResetTime,
    this.timezone = 'Asia/Kolkata',
  });

  // Check if usage should be reset
  bool shouldReset() {
    return DateTime.now().isAfter(nextResetTime);
  }

  // Get remaining analyses
  int get remainingAnalyses {
    return 4 - analysisCount;
  }

  // Check if can analyze
  bool get canAnalyze {
    return analysisCount < 4;
  }

  // Get time until reset
  Duration get timeUntilReset {
    return nextResetTime.difference(DateTime.now());
  }
}
