import 'package:dream_analysis_flutter/features/dream_journal/presentation/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dream_provider.dart';
import '../widgets/dream_card.dart';
import 'dream_detail_screen.dart';
import '../../../../core/utils/usage_tracker_service.dart';
import '../../../ai_analysis/presentation/providers/ai_provider.dart';
import '../../../ai_analysis/presentation/screens/analysis_result_screen.dart';
import '../../../../core/widgets/loading_dialog.dart';
import '../../../../core/widgets/success_animation.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dreams = ref.watch(dreamsProvider);
    final remainingAnalyses = ref.watch(usageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dreams'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => _showUsageDialog(context),
              borderRadius: BorderRadius.circular(20),
              child: Chip(
                label: Text('$remainingAnalyses/4'),
                backgroundColor: _getUsageColor(remainingAnalyses),
                side: BorderSide.none,
              ),
            ),
          ),
          if (dreams.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
            ),
        ],
      ),
      body: dreams.isEmpty
          ? _buildEmptyState(context)
          : _buildDreamsList(context, ref, dreams),
    );
  }

  Color _getUsageColor(int remaining) {
    if (remaining >= 3) return Colors.green.withOpacity(0.2);
    if (remaining >= 1) return Colors.orange.withOpacity(0.2);
    return Colors.red.withOpacity(0.2);
  }

  void _showUsageDialog(BuildContext context) {
    final remaining = UsageTrackerService.getRemainingAnalyses();
    final used = 4 - remaining;
    final timeUntilReset = UsageTrackerService.getFormattedTimeUntilReset();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Daily Analysis Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$used out of 4 analyses used today'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: used / 4,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text('Resets in: $timeUntilReset'),
              ],
            ),
            if (remaining == 0) ...[
              const SizedBox(height: 16),
              const Text(
                '💎 Want unlimited analyses? Upgrade to Premium!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nightlight_round,
            size: 100,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Start Your Dream Journey',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to record your first dream',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDreamsList(BuildContext context, WidgetRef ref, List dreams) {
    return RefreshIndicator(
      onRefresh: () async {
        // loadDreams() returns void, so just call it
        ref.read(dreamsProvider.notifier).loadDreams();

        // if you want RefreshIndicator to keep spinner a bit until UI updates:
        await Future.delayed(const Duration(milliseconds: 300));

        ref.read(usageProvider.notifier).state =
            UsageTrackerService.getRemainingAnalyses();
      },

      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: dreams.length,
        itemBuilder: (context, index) {
          final dream = dreams[index];

          return DreamCard(
            dream: dream,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DreamDetailScreen(dream: dream),
                ),
              );
            },
            onAnalyze: () => _handleAnalyze(context, ref, dream),
          );
        },
      ),
    );
  }

  Future<void> _handleAnalyze(BuildContext context, WidgetRef ref, dream) async {
    if (!UsageTrackerService.canAnalyze()) {
      _showLimitReachedDialog(context);
      return;
    }

    showLoadingDialog(context, message: 'Analyzing your dream...');

    try {
      final aiService = ref.read(aiServiceProvider);
      final analysis = await aiService.analyzeDream(
        dreamText: dream.dreamText,
        dreamDate: dream.dreamDate,
        moodBeforeSleep: dream.moodBeforeSleep,
      );

      dream.analysis = analysis;
      dream.isAnalyzed = true;
      await ref.read(dreamRepositoryProvider).updateDream(dream);

      await UsageTrackerService.incrementAnalysisCount();

      ref.read(usageProvider.notifier).state =
          UsageTrackerService.getRemainingAnalyses();
      ref.read(dreamsProvider.notifier).loadDreams();

      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        await showSuccessAnimation(context, message: 'Analysis Complete!');
      }

      if (context.mounted) {
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




















/*
import 'package:dream_analysis_flutter/features/dream_journal/presentation/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dream_provider.dart';
import '../widgets/dream_card.dart';
import 'dream_detail_screen.dart';
import '../../../../core/utils/usage_tracker_service.dart';
import '../../../ai_analysis/presentation/providers/ai_provider.dart';
import '../../../ai_analysis/presentation/screens/analysis_result_screen.dart';
import '../../../../core/widgets/loading_dialog.dart';
import '../../../../core/widgets/success_animation.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dreams = ref.watch(dreamsProvider);
    final remainingAnalyses = ref.watch(usageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dreams'),
        actions: [
          // Usage indicator badge - now shows real count
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => _showUsageDialog(context),
              borderRadius: BorderRadius.circular(20),
              child: Chip(
                label: Text('$remainingAnalyses/4'),
                backgroundColor: _getUsageColor(remainingAnalyses),
                side: BorderSide.none,
              ),
            ),
          ),
          if (dreams.isNotEmpty)
          IconButton(
          icon: const Icon(Icons.search),
    onPressed: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => const SearchScreen(),
    ),
    );
    },
    ),

        ],
      ),
      body: dreams.isEmpty
          ? _buildEmptyState(context)
          : _buildDreamsList(context, ref, dreams),
    );
  }

  Color _getUsageColor(int remaining) {
    if (remaining >= 3) return Colors.green.withOpacity(0.2);
    if (remaining >= 1) return Colors.orange.withOpacity(0.2);
    return Colors.red.withOpacity(0.2);
  }

  void _showUsageDialog(BuildContext context) {
    final remaining = UsageTrackerService.getRemainingAnalyses();
    final used = 4 - remaining;
    final timeUntilReset = UsageTrackerService.getFormattedTimeUntilReset();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Analysis Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$used out of 4 analyses used today'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: used / 4,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text('Resets in: $timeUntilReset'),
              ],
            ),
            if (remaining == 0) ...[
              const SizedBox(height: 16),
              const Text(
                '💎 Want unlimited analyses? Upgrade to Premium!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nightlight_round,
            size: 100,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Start Your Dream Journey',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to record your first dream',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDreamsList(BuildContext context, WidgetRef ref, dreams) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(dreamsProvider.notifier).loadDreams();
        ref.read(usageProvider.notifier).state =
            UsageTrackerService.getRemainingAnalyses();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: dreams.length,
        itemBuilder: (context, index) {
          final dream = dreams[index];
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
            onAnalyze: () => _handleAnalyze(context, ref, dream),
          );
        },
      ),
    );
  }

  Future<void> _handleAnalyze(
      BuildContext context,
      WidgetRef ref,
      dream,
      ) async {
    // Check if can analyze
    if (!UsageTrackerService.canAnalyze()) {
      _showLimitReachedDialog(context);
      return;
    }

    // Show loading dialog
    showLoadingDialog(context, message: 'Analyzing your dream...');

    try {
      // Call AI service
      final aiService = ref.read(aiServiceProvider);
      final analysis = await aiService.analyzeDream(
        dreamText: dream.dreamText,
        dreamDate: dream.dreamDate,
        moodBeforeSleep: dream.moodBeforeSleep,
      );

      // Update dream with analysis
      dream.analysis = analysis;
      dream.isAnalyzed = true;
      await ref.read(dreamRepositoryProvider).updateDream(dream);

      // Increment usage
      await UsageTrackerService.incrementAnalysisCount();

      // Update providers
      ref.read(usageProvider.notifier).state =
          UsageTrackerService.getRemainingAnalyses();
      ref.read(dreamsProvider.notifier).loadDreams();

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Show success animation
      if (context.mounted) {
        await showSuccessAnimation(
          context,
          message: 'Analysis Complete!',
        );
      }

      // Show analysis result
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(analysis: analysis),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Show error
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
}
*/