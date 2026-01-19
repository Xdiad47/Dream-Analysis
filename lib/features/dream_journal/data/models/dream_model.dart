import 'package:hive/hive.dart';
import 'dream_analysis_model.dart';

part 'dream_model.g.dart';

@HiveType(typeId: 0)
class DreamModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String dreamText;

  @HiveField(2)
  DateTime dreamDate;

  @HiveField(3)
  String moodBeforeSleep; // calm, anxious, happy, sad, neutral, stressed

  @HiveField(4)
  List<String>? tags;

  @HiveField(5)
  bool isAnalyzed;

  @HiveField(6)
  DreamAnalysisModel? analysis;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  DreamModel({
    required this.id,
    required this.dreamText,
    required this.dreamDate,
    required this.moodBeforeSleep,
    this.tags,
    this.isAnalyzed = false,
    this.analysis,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper method to get mood emoji
  String get moodEmoji {
    switch (moodBeforeSleep) {
      case 'calm':
        return '😌';
      case 'anxious':
        return '😰';
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'neutral':
        return '😐';
      case 'stressed':
        return '😫';
      default:
        return '😐';
    }
  }

  // Helper method to get short preview
  String get shortPreview {
    if (dreamText.length <= 100) return dreamText;
    return '${dreamText.substring(0, 100)}...';
  }
}
