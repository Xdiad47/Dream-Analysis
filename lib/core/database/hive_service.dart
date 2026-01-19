import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/dream_journal/data/models/dream_model.dart';
import '../../features/dream_journal/data/models/dream_analysis_model.dart';
import 'models/usage_tracker_model.dart';
import '../constants/app_constants.dart';

class HiveService {
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(DreamModelAdapter());
    Hive.registerAdapter(DreamAnalysisModelAdapter());
    Hive.registerAdapter(UsageTrackerModelAdapter());

    // Open boxes
    await Hive.openBox<DreamModel>(AppConstants.dreamsBoxKey);
    await Hive.openBox<UsageTrackerModel>(AppConstants.usageTrackerKey);
    await Hive.openBox(AppConstants.themeKey); // For settings
  }

  // Get dreams box
  static Box<DreamModel> get dreamsBox =>
      Hive.box<DreamModel>(AppConstants.dreamsBoxKey);

  // Get usage tracker box
  static Box<UsageTrackerModel> get usageBox =>
      Hive.box<UsageTrackerModel>(AppConstants.usageTrackerKey);

  // Get settings box
  static Box get settingsBox =>
      Hive.box(AppConstants.themeKey);
}
