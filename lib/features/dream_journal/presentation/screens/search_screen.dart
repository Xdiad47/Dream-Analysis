import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dream_provider.dart';
import '../../data/models/dream_model.dart';
import '../widgets/dream_card.dart';
import 'dream_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  List<DreamModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final allDreams = ref.read(dreamsProvider);
    final lowerQuery = query.toLowerCase();

    _searchResults = allDreams.where((dream) {
      // Search in dream text
      final textMatch = dream.dreamText.toLowerCase().contains(lowerQuery);

      // Search in tags
      final tagMatch = dream.tags?.any(
            (tag) => tag.toLowerCase().contains(lowerQuery),
      ) ?? false;

      // Search in mood
      final moodMatch = dream.moodBeforeSleep.toLowerCase().contains(lowerQuery);

      return textMatch || tagMatch || moodMatch;
    }).toList();

    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search dreams...',
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_searchController.text.isEmpty) {
      return _buildSearchSuggestions();
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final dream = _searchResults[index];
        return DreamCard(
          dream: dream,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DreamDetailScreen(dream: dream),
              ),
            );
          },
          onAnalyze: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Analysis feature coming!')),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchSuggestions() {
    final allDreams = ref.watch(dreamsProvider);
    final allTags = <String>{};
    for (var dream in allDreams) {
      if (dream.tags != null) {
        allTags.addAll(dream.tags!);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Search Tips',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const ListTile(
          leading: Icon(Icons.search),
          title: Text('Search by keywords'),
          subtitle: Text('e.g., "flying", "ocean", "family"'),
        ),
        const ListTile(
          leading: Icon(Icons.tag),
          title: Text('Search by tags'),
          subtitle: Text('e.g., "ocean", "nightmare"'),
        ),
        const ListTile(
          leading: Icon(Icons.mood),
          title: Text('Search by mood'),
          subtitle: Text('e.g., "calm", "anxious", "happy"'),
        ),
        if (allTags.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Popular Tags',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allTags.take(10).map((tag) {
              return ActionChip(
                label: Text('#$tag'),
                onPressed: () {
                  _searchController.text = tag;
                  _performSearch(tag);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No dreams found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
