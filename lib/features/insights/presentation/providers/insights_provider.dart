import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dream_journal/data/models/dream_model.dart';
import '../../../dream_journal/presentation/providers/dream_provider.dart';

// Insights Statistics Model
class InsightsStatistics {
  final int totalDreams;
  final int analyzedDreams;
  final int unanalyzedDreams;
  final Map<String, int> moodDistribution;
  final List<MapEntry<String, int>> topSymbols;
  final List<MapEntry<String, int>> topEmotions;
  final int currentStreak;
  final List<DreamModel> recentAnalyzed;

  InsightsStatistics({
    required this.totalDreams,
    required this.analyzedDreams,
    required this.unanalyzedDreams,
    required this.moodDistribution,
    required this.topSymbols,
    required this.topEmotions,
    required this.currentStreak,
    required this.recentAnalyzed,
  });
}

// Insights Provider
final insightsProvider = Provider<InsightsStatistics>((ref) {
  final dreams = ref.watch(dreamsProvider);

  // Calculate total and analyzed
  final totalDreams = dreams.length;
  final analyzedDreams = dreams.where((d) => d.isAnalyzed).length;
  final unanalyzedDreams = totalDreams - analyzedDreams;

  // Calculate mood distribution
  final moodDistribution = <String, int>{};
  for (var dream in dreams) {
    moodDistribution[dream.moodBeforeSleep] =
        (moodDistribution[dream.moodBeforeSleep] ?? 0) + 1;
  }

  // Calculate top symbols
  final symbolsMap = <String, int>{};
  for (var dream in dreams) {
    if (dream.isAnalyzed && dream.analysis != null) {
      for (var symbol in dream.analysis!.symbols) {
        symbolsMap[symbol] = (symbolsMap[symbol] ?? 0) + 1;
      }
    }
  }
  final topSymbols = symbolsMap.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  // Calculate top emotions
  final emotionsMap = <String, int>{};
  for (var dream in dreams) {
    if (dream.isAnalyzed && dream.analysis != null) {
      for (var emotion in dream.analysis!.emotions) {
        emotionsMap[emotion] = (emotionsMap[emotion] ?? 0) + 1;
      }
    }
  }
  final topEmotions = emotionsMap.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  // Calculate current streak (days with dreams)
  int currentStreak = 0;
  if (dreams.isNotEmpty) {
    final sortedDreams = dreams.toList()
      ..sort((a, b) => b.dreamDate.compareTo(a.dreamDate));

    var currentDate = DateTime.now();
    for (var dream in sortedDreams) {
      final dreamDay = DateTime(
        dream.dreamDate.year,
        dream.dreamDate.month,
        dream.dreamDate.day,
      );
      final checkDay = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      if (dreamDay == checkDay || dreamDay == checkDay.subtract(const Duration(days: 1))) {
        currentStreak++;
        currentDate = dream.dreamDate;
      } else {
        break;
      }
    }
  }

  // Get recent analyzed dreams
  final recentAnalyzed = dreams
      .where((d) => d.isAnalyzed)
      .toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  return InsightsStatistics(
    totalDreams: totalDreams,
    analyzedDreams: analyzedDreams,
    unanalyzedDreams: unanalyzedDreams,
    moodDistribution: moodDistribution,
    topSymbols: topSymbols.take(10).toList(),
    topEmotions: topEmotions.take(10).toList(),
    currentStreak: currentStreak,
    recentAnalyzed: recentAnalyzed.take(5).toList(),
  );
});
