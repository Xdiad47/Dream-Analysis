import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/dream_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/dream_provider.dart';
import 'edit_dream_screen.dart';
import '../../../../core/utils/text_formatter.dart';
import '../../../../core/utils/usage_tracker_service.dart';
import '../../../ai_analysis/presentation/providers/ai_provider.dart';
import '../../../ai_analysis/presentation/screens/analysis_result_screen.dart';
import '../../../../core/widgets/loading_dialog.dart';
import '../../../../core/widgets/success_animation.dart';

class DreamDetailScreen extends ConsumerWidget {
  final DreamModel dream;

  const DreamDetailScreen({super.key, required this.dream});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditDreamScreen(dream: dream),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context); // refresh list
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date & Mood
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(dream.dreamDate),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Mood',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(dream.moodEmoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          Text(
                            dream.moodBeforeSleep.capitalize(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dream Text
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.nightlight_round, color: AppColors.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Dream Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(dream.dreamText, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tags
          if (dream.tags != null && dream.tags!.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dream.tags!.map((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Analysis
          if (dream.isAnalyzed && dream.analysis != null)
            _buildAnalysisSection(context, dream)
          else
            _buildAnalyzeButton(context),
        ],
      ),
    );
  }

  Widget _title(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAnalysisSection(BuildContext context, DreamModel dream) {
    final analysis = dream.analysis!;

    return Card(
      color: AppColors.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header row
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'AI Analysis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${analysis.sourcesUsed} sources',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.successColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ Summary (uses summary or analysisShort fallback)
            if (analysis.displaySummary.isNotEmpty) ...[
              _title(context, 'Summary'),
              const SizedBox(height: 8),
              Text(
                analysis.displaySummary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 16),
            ],

            // ✅ Themes
            if (analysis.themes.isNotEmpty) ...[
              _title(context, 'Themes'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analysis.themes.map((t) {
                  return Chip(
                    label: Text(t),
                    backgroundColor: AppColors.primaryColor.withOpacity(0.12),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // ✅ Symbol Insights
            if (analysis.symbolInsights.isNotEmpty) ...[
              _title(context, 'Key Symbols'),
              const SizedBox(height: 8),
              ...analysis.symbolInsights.map((s) {
                final symbol = (s['symbol'] ?? '').toString();
                final meaning = (s['meaning'] ?? '').toString();
                final evidence = (s['evidence'] ?? '').toString();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              symbol.isNotEmpty ? symbol : 'Symbol',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          meaning,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                        if (evidence.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '“$evidence”',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 8),
            ],

            // ✅ Actions (NO Questions)
            if (analysis.actions.isNotEmpty) ...[
              _title(context, 'Action Steps'),
              const SizedBox(height: 8),
              ...analysis.actions.map((a) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          a,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],

            // Emotions
            if (analysis.emotions.isNotEmpty) ...[
              _title(context, 'Emotions Detected'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analysis.emotions.map((emotion) {
                  return Chip(
                    label: Text(emotion),
                    backgroundColor: AppColors.secondaryColor.withOpacity(0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Full Analysis
            if (analysis.analysisFull.trim().isNotEmpty) ...[
              _title(context, 'Full Analysis'),
              const SizedBox(height: 8),
              TextFormatter.buildFormattedText(
                analysis.analysisFull,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
              const SizedBox(height: 16),
            ],

            // Button: View in full screen
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnalysisResultScreen(analysis: analysis),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('Open Analysis Screen'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleAnalyzeFromDetail(context),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Analyze This Dream'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Dream?'),
        content: const Text(
          'This action cannot be undone. The dream and its analysis will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(dreamsProvider.notifier).deleteDream(dream.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dream deleted')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAnalyzeFromDetail(BuildContext context) async {
    if (!UsageTrackerService.canAnalyze()) {
      _showLimitReachedDialog(context);
      return;
    }

    showLoadingDialog(context, message: 'Analyzing your dream...');

    try {
      final container = ProviderScope.containerOf(context);
      final aiService = container.read(aiServiceProvider);

      final analysis = await aiService.analyzeDream(
        dreamText: dream.dreamText,
        dreamDate: dream.dreamDate,
        moodBeforeSleep: dream.moodBeforeSleep,
      );

      dream.analysis = analysis;
      dream.isAnalyzed = true;
      await container.read(dreamRepositoryProvider).updateDream(dream);

      await UsageTrackerService.incrementAnalysisCount();

      container.read(usageProvider.notifier).state =
          UsageTrackerService.getRemainingAnalyses();
      container.read(dreamsProvider.notifier).loadDreams();

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        await showSuccessAnimation(context, message: 'Analysis Complete!');
      }

      if (context.mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AnalysisResultScreen(analysis: analysis),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Analysis Failed'),
              ],
            ),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showLimitReachedDialog(BuildContext context) {
    final timeUntilReset = UsageTrackerService.getFormattedTimeUntilReset();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Daily Limit Reached'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_clock, size: 64, color: Colors.orange),
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
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
































/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/dream_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/dream_provider.dart';
import 'edit_dream_screen.dart';
import '../../../../core/utils/text_formatter.dart';
import '../../../../core/utils/usage_tracker_service.dart';
import '../../../ai_analysis/presentation/providers/ai_provider.dart';
import '../../../ai_analysis/presentation/screens/analysis_result_screen.dart';
import '../../../../core/widgets/loading_dialog.dart';
import '../../../../core/widgets/success_animation.dart';

class DreamDetailScreen extends ConsumerWidget {
  final DreamModel dream;

  const DreamDetailScreen({super.key, required this.dream});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditDreamScreen(dream: dream),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context); // Go back to refresh
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date and Mood Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(dream.dreamDate),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  // Mood
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Mood',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            dream.moodEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dream.moodBeforeSleep.capitalize(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dream Text
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.nightlight_round,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Dream Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dream.dreamText,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tags
          if (dream.tags != null && dream.tags!.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dream.tags!.map((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Analysis Section
          if (dream.isAnalyzed && dream.analysis != null)
            _buildAnalysisSection(context, dream)
          else
            _buildAnalyzeButton(context),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(BuildContext context, DreamModel dream) {
    final analysis = dream.analysis!;

    // Safe: symbolInsights is List<Map<String, dynamic>>
    Widget buildSymbolInsightCard(Map<String, dynamic> s) {
      final symbol = (s['symbol'] ?? '').toString();
      final meaning = (s['meaning'] ?? '').toString();
      final evidence = (s['evidence'] ?? '').toString();

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    symbol.isNotEmpty ? symbol : 'Symbol',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (meaning.trim().isNotEmpty)
                Text(
                  meaning,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              if (evidence.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '“$evidence”',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Card(
      color: AppColors.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Analysis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${analysis.sourcesUsed} sources',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.successColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ Summary (new JSON)
            if (analysis.displaySummary.isNotEmpty) ...[
              Text(
                'Summary',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                analysis.displaySummary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
              const SizedBox(height: 16),
            ],

            // ✅ Themes (new JSON)
            if (analysis.themes.isNotEmpty) ...[
              Text(
                'Themes',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analysis.themes.map((t) {
                  return Chip(
                    label: Text(t),
                    backgroundColor: AppColors.primaryColor.withOpacity(0.12),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Emotions
            if (analysis.emotions.isNotEmpty) ...[
              Text(
                'Emotions Detected',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analysis.emotions.map((emotion) {
                  return Chip(
                    label: Text(emotion),
                    backgroundColor: AppColors.secondaryColor.withOpacity(0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Symbols (basic list)
            if (analysis.symbols.isNotEmpty) ...[
              Text(
                'Symbols Identified',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: analysis.symbols.map((symbol) {
                  return Chip(
                    label: Text(symbol),
                    backgroundColor: AppColors.accentColor.withOpacity(0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // ✅ Symbol Insights (new JSON)
            if (analysis.symbolInsights.isNotEmpty) ...[
              Text(
                'Key Symbols',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...analysis.symbolInsights.take(3).map(buildSymbolInsightCard).toList(),
              const SizedBox(height: 16),
            ],

            // ✅ Reflection Questions (new JSON)
            if (analysis.questions.isNotEmpty) ...[
              Text(
                'Reflection Questions',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...analysis.questions.take(3).map((q) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(
                        child: Text(
                          q,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],

            // ✅ Action Steps (new JSON)
            if (analysis.actions.isNotEmpty) ...[
              Text(
                'Action Steps',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...analysis.actions.take(3).map((a) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          a,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],

            // Optional: keep markdown full analysis
            if (analysis.analysisFull.trim().isNotEmpty) ...[
              Text(
                'Detailed Analysis',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormatter.buildFormattedText(
                analysis.analysisFull,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleAnalyzeFromDetail(context),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Analyze This Dream'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dream?'),
        content: const Text(
          'This action cannot be undone. The dream and its analysis will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(dreamsProvider.notifier).deleteDream(dream.id);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to home
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dream deleted')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAnalyzeFromDetail(BuildContext context) async {
    if (!UsageTrackerService.canAnalyze()) {
      _showLimitReachedDialog(context);
      return;
    }

    showLoadingDialog(context, message: 'Analyzing your dream...');

    try {
      final container = ProviderScope.containerOf(context);
      final aiService = container.read(aiServiceProvider);

      final analysis = await aiService.analyzeDream(
        dreamText: dream.dreamText,
        dreamDate: dream.dreamDate,
        moodBeforeSleep: dream.moodBeforeSleep,
      );

      dream.analysis = analysis;
      dream.isAnalyzed = true;
      await container.read(dreamRepositoryProvider).updateDream(dream);

      await UsageTrackerService.incrementAnalysisCount();

      container.read(usageProvider.notifier).state =
          UsageTrackerService.getRemainingAnalyses();
      container.read(dreamsProvider.notifier).loadDreams();

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        await showSuccessAnimation(
          context,
          message: 'Analysis Complete!',
        );
      }

      if (context.mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(analysis: analysis),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Analysis Failed'),
              ],
            ),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showLimitReachedDialog(BuildContext context) {
    final timeUntilReset = UsageTrackerService.getFormattedTimeUntilReset();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Limit Reached'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_clock, size: 64, color: Colors.orange),
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
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
*/