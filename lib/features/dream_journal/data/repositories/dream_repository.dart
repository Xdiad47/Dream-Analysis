import 'package:hive/hive.dart';
import '../models/dream_model.dart';
import '../../../../core/database/hive_service.dart';

class DreamRepository {
  // Save a dream
  Future<void> saveDream(DreamModel dream) async {
    final box = HiveService.dreamsBox;
    await box.put(dream.id, dream);
  }

  // Get all dreams
  List<DreamModel> getAllDreams() {
    final box = HiveService.dreamsBox;
    return box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
  }

  // Get a single dream by ID
  DreamModel? getDream(String id) {
    final box = HiveService.dreamsBox;
    return box.get(id);
  }

  // Update a dream
  Future<void> updateDream(DreamModel dream) async {
    dream.updatedAt = DateTime.now();
    final box = HiveService.dreamsBox;
    await box.put(dream.id, dream);
  }

  // Delete a dream
  Future<void> deleteDream(String id) async {
    final box = HiveService.dreamsBox;
    await box.delete(id);
  }

  // Get dreams count
  int getDreamsCount() {
    return HiveService.dreamsBox.length;
  }

  // Get analyzed dreams
  List<DreamModel> getAnalyzedDreams() {
    final box = HiveService.dreamsBox;
    return box.values.where((dream) => dream.isAnalyzed).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
