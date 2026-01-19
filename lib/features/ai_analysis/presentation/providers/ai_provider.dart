import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dream_journal/data/models/dream_model.dart';
import '../../../dream_journal/data/models/dream_analysis_model.dart';
import '../../../dream_journal/presentation/providers/dream_provider.dart';
import '../../data/services/ai_service.dart';
import '../../../../core/utils/usage_tracker_service.dart';

// AI Service Provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

// Usage Provider (to watch usage changes)
final usageProvider = StateProvider<int>((ref) {
  return UsageTrackerService.getRemainingAnalyses();
});

// Analyze Dream Provider
final analyzeDreamProvider = FutureProvider.family<DreamAnalysisModel, DreamModel>(
      (ref, dream) async {
    final aiService = ref.read(aiServiceProvider);

    // Call API
    final analysis = await aiService.analyzeDream(
      dreamText: dream.dreamText,
      dreamDate: dream.dreamDate,
      moodBeforeSleep: dream.moodBeforeSleep,
    );

    // Update dream with analysis
    dream.analysis = analysis;
    dream.isAnalyzed = true;
    await ref.read(dreamRepositoryProvider).updateDream(dream);

    // Increment usage count
    await UsageTrackerService.incrementAnalysisCount();

    // Update usage provider
    ref.read(usageProvider.notifier).state =
        UsageTrackerService.getRemainingAnalyses();

    // Reload dreams list
    ref.read(dreamsProvider.notifier).loadDreams();

    return analysis;
  },
);
