import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/dream_model.dart';
import '../providers/dream_provider.dart';
import '../../../../core/utils/usage_tracker_service.dart';
import '../../../ai_analysis/presentation/providers/ai_provider.dart';
import '../../../ai_analysis/presentation/screens/analysis_result_screen.dart';
import '../../../../core/widgets/loading_dialog.dart';
import '../../../../core/widgets/success_animation.dart';

class EditDreamScreen extends ConsumerStatefulWidget {
  final DreamModel dream;

  const EditDreamScreen({super.key, required this.dream});

  @override
  ConsumerState<EditDreamScreen> createState() => _EditDreamScreenState();
}

class _EditDreamScreenState extends ConsumerState<EditDreamScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dreamTextController;
  final _tagController = TextEditingController();

  late DateTime _selectedDate;
  late String _selectedMood;
  late List<String> _tags;
  bool _isLoading = false;

  // Store original dream text to detect changes
  late String _originalDreamText;

  final List<Map<String, dynamic>> _moods = [
    {'value': 'calm', 'emoji': '😌', 'label': 'Calm'},
    {'value': 'anxious', 'emoji': '😰', 'label': 'Anxious'},
    {'value': 'happy', 'emoji': '😊', 'label': 'Happy'},
    {'value': 'sad', 'emoji': '😢', 'label': 'Sad'},
    {'value': 'neutral', 'emoji': '😐', 'label': 'Neutral'},
    {'value': 'stressed', 'emoji': '😫', 'label': 'Stressed'},
  ];

  @override
  void initState() {
    super.initState();
    _dreamTextController = TextEditingController(text: widget.dream.dreamText);
    _selectedDate = widget.dream.dreamDate;
    _selectedMood = widget.dream.moodBeforeSleep;
    _tags = widget.dream.tags?.toList() ?? [];
    _originalDreamText = widget.dream.dreamText; // Store original text
  }

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


  Future<void> _updateDream() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if dream text changed and was previously analyzed
      final bool wasAnalyzed = widget.dream.isAnalyzed;
      final String newText = _dreamTextController.text.trim();
      final bool textChanged = _originalDreamText != newText;
      final bool shouldPromptReanalysis = wasAnalyzed && textChanged;

      // Update dream object
      widget.dream.dreamText = newText;
      widget.dream.dreamDate = _selectedDate;
      widget.dream.moodBeforeSleep = _selectedMood;
      widget.dream.tags = _tags.isEmpty ? null : _tags;
      widget.dream.updatedAt = DateTime.now();

      // Save to database
      await ref.read(dreamRepositoryProvider).updateDream(widget.dream);

      // Reload dreams list
      ref.read(dreamsProvider.notifier).loadDreams();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success animation
        await showSuccessAnimation(
          context,
          message: 'Dream Updated!',
        );

        // ✅ DON'T CLOSE SCREEN YET - Show dialog BEFORE popping
        if (mounted && shouldPromptReanalysis) {
          // Show dialog and wait for user choice
          final shouldReanalyze = await _showReanalysisPromptDialog();

          if (shouldReanalyze == true) {
            // User wants to re-analyze
            await _handleReanalysis();
          } else {
            // User chose "Maybe Later" - just close edit screen
            if (mounted) {
              Navigator.pop(context, true);
            }
          }
        } else {
          // No re-analysis needed, close edit screen
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating dream: $e'),
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



  void _showReanalysisPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Re-analyze Dream?'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You\'ve changed the dream content.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'The previous analysis may no longer be accurate. Would you like to re-analyze this dream with the updated content?',
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'This will use one of your daily analyses.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _handleReanalysis();
            },
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Re-analyze Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReanalysis() async {
    // Check usage
    if (!UsageTrackerService.canAnalyze()) {
      _showLimitReachedDialog();
      // Close edit screen after showing limit dialog
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context, true);
      return;
    }

    // Show loading
    showLoadingDialog(context, message: 'Re-analyzing your dream...');

    try {
      // Call AI service
      final aiService = ref.read(aiServiceProvider);
      final analysis = await aiService.analyzeDream(
        dreamText: widget.dream.dreamText,
        dreamDate: widget.dream.dreamDate,
        moodBeforeSleep: widget.dream.moodBeforeSleep,
      );

      // Update dream with new analysis
      widget.dream.analysis = analysis;
      widget.dream.isAnalyzed = true;
      await ref.read(dreamRepositoryProvider).updateDream(widget.dream);

      // Increment usage
      await UsageTrackerService.incrementAnalysisCount();

      // Update providers
      ref.read(usageProvider.notifier).state =
          UsageTrackerService.getRemainingAnalyses();
      ref.read(dreamsProvider.notifier).loadDreams();

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success animation
      if (mounted) {
        await showSuccessAnimation(
          context,
          message: 'Re-analysis Complete!',
        );
      }

      // Close edit screen
      if (mounted) {
        Navigator.pop(context, true);
      }

      // Small delay then show analysis result
      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(analysis: analysis),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error dialog
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Re-analysis Failed'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Failed to analyze dream:'),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your dream has been saved. You can try analyzing it again from the home screen.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close error dialog
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );

        // After error dialog closes, close edit screen
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    }
  }


  void _showLimitReachedDialog() {
    final timeUntilReset = UsageTrackerService.getFormattedTimeUntilReset();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Limit Reached'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_clock,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'You\'ve used all 4 analyses for today.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Resets in: $timeUntilReset',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '💎 Upgrade to Premium for unlimited analyses!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.purple),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Dream'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _updateDream,
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

            // Update Button
            ElevatedButton(
              onPressed: _isLoading ? null : _updateDream,
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
                'Update Dream',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showReanalysisPromptDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Re-analyze Dream?'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You\'ve changed the dream content.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'The previous analysis may no longer be accurate. Would you like to re-analyze this dream with the updated content?',
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'This will use one of your daily analyses.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Re-analyze Now'),
          ),
        ],
      ),
    );
  }

}
