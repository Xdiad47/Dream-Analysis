import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/dream_model.dart';
import '../providers/dream_provider.dart';
import '../../../../core/widgets/success_animation.dart';
import '../../../../core/utils/page_transitions.dart';


class AddDreamScreen extends ConsumerStatefulWidget {
  const AddDreamScreen({super.key});

  @override
  ConsumerState<AddDreamScreen> createState() => _AddDreamScreenState();
}

class _AddDreamScreenState extends ConsumerState<AddDreamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dreamTextController = TextEditingController();
  final _tagController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedMood = 'neutral';
  List<String> _tags = [];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _moods = [
    {'value': 'calm', 'emoji': '😌', 'label': 'Calm'},
    {'value': 'anxious', 'emoji': '😰', 'label': 'Anxious'},
    {'value': 'happy', 'emoji': '😊', 'label': 'Happy'},
    {'value': 'sad', 'emoji': '😢', 'label': 'Sad'},
    {'value': 'neutral', 'emoji': '😐', 'label': 'Neutral'},
    {'value': 'stressed', 'emoji': '😫', 'label': 'Stressed'},
  ];

  @override
  void dispose() {
    _dreamTextController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty && _tags.length < 5) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _removeTag(int index) {
    setState(() {
      _tags.removeAt(index);
    });
  }

  Future<void> _saveDream() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create dream object
      final dream = DreamModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dreamText: _dreamTextController.text.trim(),
        dreamDate: _selectedDate,
        moodBeforeSleep: _selectedMood,
        tags: _tags.isEmpty ? null : _tags,
        isAnalyzed: false,
        analysis: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      await ref.read(dreamRepositoryProvider).saveDream(dream);

      if (mounted) {
        // Show success animation
        await showSuccessAnimation(
          context,
          message: 'Dream Saved!',
        );

        // Return to home
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving dream: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Dream'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveDream,
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Dream Text Input
            TextFormField(
              controller: _dreamTextController,
              maxLines: 8,
              maxLength: 2000,
              decoration: InputDecoration(
                hintText: 'Describe your dream...',
                labelText: 'Dream Description',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please describe your dream';
                }
                if (value.trim().length < 10) {
                  return 'Please write at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Date Picker
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'When did you dream this?',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(_selectedDate),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mood Selection
            Text(
              'How did you feel before sleep?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood['value'];
                return FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mood['emoji'],
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(mood['label']),
                    ],
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedMood = mood['value'];
                    });
                  },
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedColor: AppColors.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppColors.primaryColor,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Tags Input
            Text(
              'Add tags (optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: 'e.g., flying, ocean',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _tags.length < 5 ? _addTag : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.asMap().entries.map((entry) {
                  return Chip(
                    label: Text(entry.value),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeTag(entry.key),
                  );
                }).toList(),
              ),
            if (_tags.length >= 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Maximum 5 tags reached',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveDream,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text(
                'Save Dream',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
