import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dream_model.dart';
import '../../data/repositories/dream_repository.dart';

// Dream Repository Provider
final dreamRepositoryProvider = Provider<DreamRepository>((ref) {
  return DreamRepository();
});

// Dreams List Provider
final dreamsProvider = StateNotifierProvider<DreamsNotifier, List<DreamModel>>((ref) {
  final repository = ref.watch(dreamRepositoryProvider);
  return DreamsNotifier(repository);
});

class DreamsNotifier extends StateNotifier<List<DreamModel>> {
  final DreamRepository _repository;

  DreamsNotifier(this._repository) : super([]) {
    loadDreams();
  }

  void loadDreams() {
    state = _repository.getAllDreams();
  }

  Future<void> addDream(DreamModel dream) async {
    await _repository.saveDream(dream);
    loadDreams();
  }

  Future<void> updateDream(DreamModel dream) async {
    await _repository.updateDream(dream);
    loadDreams();
  }

  Future<void> deleteDream(String id) async {
    await _repository.deleteDream(id);
    loadDreams();
  }
}
