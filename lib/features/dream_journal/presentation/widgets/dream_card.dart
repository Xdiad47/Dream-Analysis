import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/dream_model.dart';
import '../../../../core/constants/app_colors.dart';

class DreamCard extends StatelessWidget {
  final DreamModel dream;
  final VoidCallback onTap;
  final VoidCallback onAnalyze;

  const DreamCard({
    super.key,
    required this.dream,
    required this.onTap,
    required this.onAnalyze,
  });

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dreamDay = DateTime(date.year, date.month, date.day);

    if (dreamDay == today) return 'Today';
    if (dreamDay == yesterday) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }

  Color _getMoodColor() {
    switch (dream.moodBeforeSleep) {
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

  @override
  Widget build(BuildContext context) {
    final analysis = dream.analysis; // DreamAnalysisModel?
    final hasAnalysis = dream.isAnalyzed && analysis != null;

    final summary = hasAnalysis ? (analysis.displaySummary ?? '') : '';
    final themes = hasAnalysis ? (analysis.themes ?? <String>[]) : <String>[];

    final emotionsCount = hasAnalysis ? (analysis.emotions.length) : 0;
    final symbolsCount = hasAnalysis ? (analysis.symbols.length) : 0;
    final sourcesUsed = hasAnalysis ? (analysis.sourcesUsed) : 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Date and Mood
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('🌙', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getRelativeDate(dream.dreamDate),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(dream.moodEmoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              dream.moodBeforeSleep.capitalize(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getMoodColor(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (hasAnalysis)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 16, color: AppColors.successColor),
                          const SizedBox(width: 4),
                          Text(
                            'Analyzed',
                            style: TextStyle(
                              color: AppColors.successColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Dream preview text
              Text(
                dream.shortPreview,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // ✅ Summary preview (from new JSON)
              if (hasAnalysis && summary.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accentColor.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📝', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          summary,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Tags (original tags)
              if (dream.tags != null && dream.tags!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: dream.tags!.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(fontSize: 12, color: AppColors.primaryColor),
                      ),
                    );
                  }).toList(),
                ),

              // ✅ Themes preview (from new JSON)
              if (hasAnalysis && themes.isNotEmpty) ...[
                if (dream.tags != null && dream.tags!.isNotEmpty) const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: themes.take(3).map((t) {
                    return Chip(
                      label: Text(t),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: AppColors.secondaryColor.withOpacity(0.15),
                      side: BorderSide.none,
                      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ],

              // ✅ Mini stats row
              if (hasAnalysis) ...[
                const SizedBox(height: 10),
                Text(
                  '💭 $emotionsCount emotions  •  🔮 $symbolsCount symbols  •  📚 $sourcesUsed sources',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  if (hasAnalysis)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Analysis'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAnalyze,
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: const Text('Analyze Dream'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}























/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/dream_model.dart';
import '../../../../core/constants/app_colors.dart';

class DreamCard extends StatelessWidget {
  final DreamModel dream;
  final VoidCallback onTap;
  final VoidCallback onAnalyze;

  const DreamCard({
    super.key,
    required this.dream,
    required this.onTap,
    required this.onAnalyze,
  });

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dreamDay = DateTime(date.year, date.month, date.day);

    if (dreamDay == today) {
      return 'Today';
    } else if (dreamDay == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  Color _getMoodColor() {
    switch (dream.moodBeforeSleep) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Date and Mood
              Row(
                children: [
                  // Moon icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '🌙',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Date and mood
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getRelativeDate(dream.dreamDate),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              dream.moodEmoji,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dream.moodBeforeSleep.capitalize(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getMoodColor(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Analyzed badge
                  if (dream.isAnalyzed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.successColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Analyzed',
                            style: TextStyle(
                              color: AppColors.successColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Dream preview text
              Text(
                dream.shortPreview,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Tags if available
              if (dream.tags != null && dream.tags!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: dream.tags!.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  if (dream.isAnalyzed)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Analysis'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAnalyze,
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: const Text('Analyze Dream'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
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