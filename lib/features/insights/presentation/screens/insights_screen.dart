import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/insights_provider.dart';
import '../../../dream_journal/presentation/screens/dream_detail_screen.dart';
import '../widgets/stat_card.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: insights.totalDreams == 0
          ? _buildEmptyState(context)
          : _buildInsightsContent(context, insights),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insights,
            size: 100,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No insights yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging dreams to see patterns',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsContent(BuildContext context, InsightsStatistics insights) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh is automatic via provider
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overview Stats
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Dreams',
                  value: '${insights.totalDreams}',
                  icon: Icons.nightlight_round,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Analyzed',
                  value: '${insights.analyzedDreams}',
                  icon: Icons.auto_awesome,
                  color: AppColors.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Pending',
                  value: '${insights.unanalyzedDreams}',
                  icon: Icons.pending,
                  color: AppColors.warningColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Day Streak',
                  value: '${insights.currentStreak}',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Mood Distribution
          if (insights.moodDistribution.isNotEmpty) ...[
            Text(
              'Mood Distribution',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: insights.moodDistribution.entries.map((entry) {
                    final percentage = (entry.value / insights.totalDreams * 100).toInt();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(_getMoodEmoji(entry.key)),
                              const SizedBox(width: 8),
                              Text(
                                StringExtension(entry.key).capitalize(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const Spacer(),
                              Text(
                                '${entry.value} ($percentage%)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: entry.value / insights.totalDreams,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                              _getMoodColor(entry.key),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Top Symbols
          if (insights.topSymbols.isNotEmpty) ...[
            Text(
              'Common Symbols',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: insights.topSymbols.map((entry) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: AppColors.accentColor,
                        child: Text(
                          '${entry.value}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      label: Text(entry.key),
                      backgroundColor: AppColors.accentColor.withOpacity(0.1),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Top Emotions
          if (insights.topEmotions.isNotEmpty) ...[
            Text(
              'Common Emotions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: insights.topEmotions.map((entry) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: AppColors.secondaryColor,
                        child: Text(
                          '${entry.value}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      label: Text(entry.key),
                      backgroundColor: AppColors.secondaryColor.withOpacity(0.1),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Recent Analyzed Dreams
          if (insights.recentAnalyzed.isNotEmpty) ...[
            Text(
              'Recently Analyzed',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...insights.recentAnalyzed.map((dream) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(dream.moodEmoji, style: const TextStyle(fontSize: 20)),
                  ),
                  title: Text(
                    dream.shortPreview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    DateFormat('MMM d, yyyy').format(dream.dreamDate),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DreamDetailScreen(dream: dream),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
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

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'calm':
        return AppColors.moodCalm;
      case 'anxious':
        return AppColors.moodAnxious;
      case 'happy':
        return AppColors.moodHappy;
      case 'sad':
        return AppColors.moodSad;
      case 'neutral':
        return AppColors.moodNeutral;
      case 'stressed':
        return AppColors.moodStressed;
      default:
        return AppColors.moodNeutral;
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Insights'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview Stats', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Total Dreams: All saved dreams'),
              Text('• Analyzed: Dreams with AI analysis'),
              Text('• Pending: Dreams waiting for analysis'),
              Text('• Day Streak: Consecutive days with dreams'),
              SizedBox(height: 16),
              Text('Mood Distribution', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Shows how often you experience each mood before sleep.'),
              SizedBox(height: 16),
              Text('Common Symbols & Emotions', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('The most frequently appearing symbols and emotions across your analyzed dreams.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
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
