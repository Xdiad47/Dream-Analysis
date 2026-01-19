import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../dream_journal/data/models/dream_analysis_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/text_formatter.dart';

class AnalysisResultScreen extends ConsumerWidget {
  final DreamAnalysisModel analysis;

  const AnalysisResultScreen({super.key, required this.analysis});

  Future<void> _shareAnalysis(BuildContext context) async {
    try {
      final dateStr = DateFormat('MMMM dd, yyyy').format(analysis.analyzedAt);

      final buffer = StringBuffer();
      buffer.writeln('🌙 Dream Analysis - $dateStr');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln();

      // Summary
      if (analysis.displaySummary.isNotEmpty) {
        buffer.writeln('📝 Summary:');
        buffer.writeln(
          analysis.displaySummary.replaceAll('**', '').replaceAll('*', ''),
        );
        buffer.writeln();
      }

      // Themes
      if (analysis.themes.isNotEmpty) {
        buffer.writeln('🎯 Themes:');
        for (final t in analysis.themes) {
          buffer.writeln('• $t');
        }
        buffer.writeln();
      }

      // Symbol Insights
      if (analysis.symbolInsights.isNotEmpty) {
        buffer.writeln('🔮 Key Symbols:');
        for (final s in analysis.symbolInsights) {
          final symbol = (s['symbol'] ?? '').toString();
          final meaning = (s['meaning'] ?? '').toString();
          final evidence = (s['evidence'] ?? '').toString();

          if (symbol.trim().isNotEmpty) {
            buffer.writeln('• $symbol: $meaning');
            if (evidence.trim().isNotEmpty) {
              buffer.writeln('  Evidence: "$evidence"');
            }
          }
        }
        buffer.writeln();
      }

      // Actions
      if (analysis.actions.isNotEmpty) {
        buffer.writeln('✅ Action Steps:');
        for (final a in analysis.actions) {
          buffer.writeln('• $a');
        }
        buffer.writeln();
      }

      // Emotions
      if (analysis.emotions.isNotEmpty) {
        buffer.writeln('💭 Emotions Detected:');
        for (final e in analysis.emotions) {
          buffer.writeln('• $e');
        }
        buffer.writeln();
      }

      // Detailed analysis (optional)
      if (analysis.analysisFull.trim().isNotEmpty) {
        buffer.writeln('📊 Detailed Analysis:');
        final cleaned = analysis.analysisFull
            .replaceAll('**', '')
            .replaceAll('*', '')
            .replaceAll('###', '')
            .replaceAll('##', '');
        buffer.writeln(cleaned);
        buffer.writeln();
      }

      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('✨ Analyzed by DreamScape AI');

      await Share.share(
        buffer.toString(),
        subject: 'My Dream Analysis - $dateStr',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareAnalysis(context),
            tooltip: 'Share Analysis',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Card(
            color: AppColors.primaryColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 40,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Analysis Complete',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Here’s a clean breakdown of your dream',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ✅ Summary
          if (analysis.displaySummary.isNotEmpty) ...[
            _sectionTitle(context, 'Summary'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  analysis.displaySummary,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ✅ Themes
          if (analysis.themes.isNotEmpty) ...[
            _sectionTitle(context, 'Themes'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: analysis.themes.map((t) {
                    return Chip(
                      label: Text(t),
                      backgroundColor: AppColors.primaryColor.withOpacity(0.12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ✅ Symbol Insights
          if (analysis.symbolInsights.isNotEmpty) ...[
            _sectionTitle(context, 'Key Symbols'),
            const SizedBox(height: 12),
            ...analysis.symbolInsights.map((s) {
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
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        meaning,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(height: 1.5),
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
            }).toList(),
            const SizedBox(height: 24),
          ],

          // ✅ Actions (Questions removed)
          if (analysis.actions.isNotEmpty) ...[
            _sectionTitle(context, 'Action Steps'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: analysis.actions.map((a) {
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ✅ Emotions
          if (analysis.emotions.isNotEmpty) ...[
            _sectionTitle(context, 'Emotions Detected'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: analysis.emotions.map((emotion) {
                    return Chip(
                      label: Text(emotion),
                      backgroundColor: AppColors.secondaryColor.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Optional full markdown
          if (analysis.analysisFull.trim().isNotEmpty) ...[
            _sectionTitle(context, 'Detailed Analysis (Full)'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormatter.buildFormattedText(
                  analysis.analysisFull,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(height: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Footer
          Card(
            color: Colors.grey.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Analysis based on ${analysis.sourcesUsed} psychological sources',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
































/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../dream_journal/data/models/dream_analysis_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/text_formatter.dart';

class AnalysisResultScreen extends ConsumerWidget {
  final DreamAnalysisModel analysis;

  const AnalysisResultScreen({super.key, required this.analysis});

  // ---------- Helpers ----------
  String _cleanMd(String s) {
    return s
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('###', '')
        .replaceAll('##', '')
        .replaceAll('#', '')
        .trim();
  }

  String _safeStr(dynamic v) => (v ?? '').toString().trim();

  // SymbolInsights item is Map<String, dynamic>
  String _symbol(Map<String, dynamic> m) => _safeStr(m['symbol']);
  String _meaning(Map<String, dynamic> m) => _safeStr(m['meaning']);
  String _evidence(Map<String, dynamic> m) => _safeStr(m['evidence']);

  Future<void> _shareAnalysis(BuildContext context) async {
    try {
      final dateStr = DateFormat('MMMM dd, yyyy').format(analysis.analyzedAt);

      final buffer = StringBuffer();
      buffer.writeln('🌙 Dream Analysis - $dateStr');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln();

      // Summary
      if (analysis.displaySummary.isNotEmpty) {
        buffer.writeln('📝 Summary:');
        buffer.writeln(_cleanMd(analysis.displaySummary));
        buffer.writeln();
      }

      // Themes
      if (analysis.themes.isNotEmpty) {
        buffer.writeln('🎯 Themes:');
        for (final t in analysis.themes) {
          buffer.writeln('• ${_cleanMd(t)}');
        }
        buffer.writeln();
      }

      // Symbol insights
      if (analysis.symbolInsights.isNotEmpty) {
        buffer.writeln('🔮 Key Symbols:');
        for (final s in analysis.symbolInsights) {
          final sym = _symbol(s);
          final mean = _meaning(s);
          final ev = _evidence(s);

          if (sym.isEmpty && mean.isEmpty && ev.isEmpty) continue;

          if (sym.isNotEmpty) {
            buffer.writeln('• $sym${mean.isNotEmpty ? ': $mean' : ''}');
          } else if (mean.isNotEmpty) {
            buffer.writeln('• $mean');
          }

          if (ev.isNotEmpty) {
            buffer.writeln('  Evidence: "$ev"');
          }
        }
        buffer.writeln();
      }

      // Questions
      if (analysis.questions.isNotEmpty) {
        buffer.writeln('❓ Reflection Questions:');
        for (final q in analysis.questions) {
          buffer.writeln('• ${_cleanMd(q)}');
        }
        buffer.writeln();
      }

      // Actions
      if (analysis.actions.isNotEmpty) {
        buffer.writeln('✅ Action Steps:');
        for (final a in analysis.actions) {
          buffer.writeln('• ${_cleanMd(a)}');
        }
        buffer.writeln();
      }

      // Emotions
      if (analysis.emotions.isNotEmpty) {
        buffer.writeln('💭 Emotions Detected:');
        for (final e in analysis.emotions) {
          buffer.writeln('• ${_cleanMd(e)}');
        }
        buffer.writeln();
      }

      // Symbols list (legacy)
      if (analysis.symbols.isNotEmpty) {
        buffer.writeln('🧩 Symbols Identified (List):');
        for (final s in analysis.symbols) {
          buffer.writeln('• ${_cleanMd(s)}');
        }
        buffer.writeln();
      }

      // Entities (optional)
      if (analysis.entities.isNotEmpty) {
        buffer.writeln('🏷️ Entities:');
        for (final pair in analysis.entities) {
          if (pair.isEmpty) continue;
          if (pair.length == 1) {
            buffer.writeln('• ${pair[0]}');
          } else {
            buffer.writeln('• ${pair[0]} (${pair[1]})');
          }
        }
        buffer.writeln();
      }

      // Full analysis (optional)
      if (analysis.analysisFull.trim().isNotEmpty) {
        buffer.writeln('📊 Detailed Analysis:');
        buffer.writeln(_cleanMd(analysis.analysisFull));
        buffer.writeln();
      }

      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('✨ Analyzed by DreamScape AI');

      await Share.share(
        buffer.toString(),
        subject: 'My Dream Analysis - $dateStr',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareAnalysis(context),
            tooltip: 'Share Analysis',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(context),
          const SizedBox(height: 24),

          if (analysis.displaySummary.isNotEmpty) ...[
            _sectionTitle(context, 'Summary'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormatter.buildFormattedText(
                  analysis.displaySummary,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (analysis.themes.isNotEmpty) ...[
            _sectionTitle(context, 'Themes'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: analysis.themes.map((t) {
                    return Chip(
                      label: Text(t),
                      backgroundColor: AppColors.primaryColor.withOpacity(0.12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (analysis.symbolInsights.isNotEmpty) ...[
            _sectionTitle(context, 'Key Symbols'),
            const SizedBox(height: 12),
            ...analysis.symbolInsights.map((m) {
              final sym = _symbol(m);
              final mean = _meaning(m);
              final ev = _evidence(m);

              // skip empty cards
              if (sym.isEmpty && mean.isEmpty && ev.isEmpty) {
                return const SizedBox.shrink();
              }

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
                          Expanded(
                            child: Text(
                              sym.isNotEmpty ? sym : 'Symbol',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (mean.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          mean,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(height: 1.5),
                        ),
                      ],
                      if (ev.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '“$ev”',
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
            }).toList(),
            const SizedBox(height: 24),
          ],

          if (analysis.questions.isNotEmpty) ...[
            _sectionTitle(context, 'Reflection Questions'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: analysis.questions.map((q) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  '),
                          Expanded(
                            child: Text(
                              q,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (analysis.actions.isNotEmpty) ...[
            _sectionTitle(context, 'Action Steps'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: analysis.actions.map((a) {
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (analysis.emotions.isNotEmpty) ...[
            _sectionTitle(context, 'Emotions Detected'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: analysis.emotions.map((emotion) {
                    return Chip(
                      label: Text(emotion),
                      backgroundColor: AppColors.secondaryColor.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (analysis.symbols.isNotEmpty) ...[
            _sectionTitle(context, 'Symbols Identified'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: analysis.symbols.map((s) {
                    return Chip(
                      label: Text(s),
                      backgroundColor: AppColors.accentColor.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (analysis.entities.isNotEmpty) ...[
            _sectionTitle(context, 'Entities'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: analysis.entities.map((pair) {
                    final label = pair.isEmpty
                        ? ''
                        : (pair.length == 1 ? pair[0] : '${pair[0]} • ${pair[1]}');
                    if (label.trim().isEmpty) return const SizedBox.shrink();
                    return Chip(
                      label: Text(label),
                      backgroundColor: Colors.grey.withOpacity(0.15),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (analysis.analysisFull.trim().isNotEmpty) ...[
            _sectionTitle(context, 'Detailed Analysis (Full)'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormatter.buildFormattedText(
                  analysis.analysisFull,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          _footer(context),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // ---------- Small widgets ----------
  Widget _header(BuildContext context) {
    return Card(
      color: AppColors.primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, size: 40, color: AppColors.primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Analysis Complete',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here’s a clean breakdown of your dream',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Card(
      color: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Analysis based on ${analysis.sourcesUsed} psychological sources',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

*/
