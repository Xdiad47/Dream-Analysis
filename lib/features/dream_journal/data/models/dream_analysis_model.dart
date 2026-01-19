import 'package:hive/hive.dart';

part 'dream_analysis_model.g.dart';

@HiveType(typeId: 1)
class DreamAnalysisModel {
  @HiveField(0)
  final List<String> emotions;

  @HiveField(1)
  final List<String> symbols;

  @HiveField(2)
  final String analysisShort;

  @HiveField(3)
  final String analysisFull;

  @HiveField(4)
  final int sourcesUsed;

  @HiveField(5)
  final DateTime analyzedAt;

  // ✅ NEW FIELDS (latest JSON)
  @HiveField(6)
  final String summary;

  @HiveField(7)
  final List<String> themes;

  /// Keep as raw list of maps to avoid creating extra adapters
  /// Each item: {"symbol": "...", "meaning": "...", "evidence": "..."}
  @HiveField(8)
  final List<Map<String, dynamic>> symbolInsights;

  @HiveField(9)
  final List<String> questions;

  @HiveField(10)
  final List<String> actions;

  /// API sends entities like: [ ["X","ENTITY"], ... ]
  @HiveField(11)
  final List<List<String>> entities;

  // ✅ IMPORTANT:
  // New fields are NOT required in constructor, they have defaults.
  // This allows old Hive records (only 0..5 fields) to still load.
  DreamAnalysisModel({
    required this.emotions,
    required this.symbols,
    required this.analysisShort,
    required this.analysisFull,
    required this.sourcesUsed,
    required this.analyzedAt,

    // new fields with defaults
    this.summary = '',
    List<String>? themes,
    List<Map<String, dynamic>>? symbolInsights,
    List<String>? questions,
    List<String>? actions,
    List<List<String>>? entities,
  })  : themes = themes ?? const <String>[],
        symbolInsights = symbolInsights ?? const <Map<String, dynamic>>[],
        questions = questions ?? const <String>[],
        actions = actions ?? const <String>[],
        entities = entities ?? const <List<String>>[];

  /// Prefer API "summary" else "analysisShort"
  String get displaySummary {
    if (summary.trim().isNotEmpty) return summary.trim();
    if (analysisShort.trim().isNotEmpty) return analysisShort.trim();
    return '';
  }

  factory DreamAnalysisModel.fromJson(Map<String, dynamic> json) {
    // helpers
    List<String> _stringList(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return <String>[];
    }

    List<Map<String, dynamic>> _mapList(dynamic v) {
      if (v is List) {
        return v
            .where((e) => e is Map)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      return <Map<String, dynamic>>[];
    }

    List<List<String>> _entities(dynamic v) {
      if (v is List) {
        return v
            .map((e) {
          if (e is List) return e.map((x) => x.toString()).toList();
          return <String>[];
        })
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return <List<String>>[];
    }

    final summary = (json['summary'] ?? json['analysisShort'] ?? '').toString();
    final analysisShort = (json['analysisShort'] ?? summary).toString();

    DateTime parsedAnalyzedAt;
    try {
      parsedAnalyzedAt = DateTime.parse((json['analyzedAt'] ?? '').toString());
    } catch (_) {
      parsedAnalyzedAt = DateTime.now();
    }

    return DreamAnalysisModel(
      emotions: _stringList(json['emotions']),
      symbols: _stringList(json['symbols']),
      analysisShort: analysisShort,
      analysisFull: (json['analysisFull'] ?? '').toString(),
      sourcesUsed: (json['sourcesUsed'] is int)
          ? json['sourcesUsed'] as int
          : int.tryParse((json['sourcesUsed'] ?? 0).toString()) ?? 0,
      analyzedAt: parsedAnalyzedAt,

      // new
      summary: summary,
      themes: _stringList(json['themes']),
      symbolInsights: _mapList(json['symbolInsights']),
      questions: _stringList(json['questions']),
      actions: _stringList(json['actions']),
      entities: _entities(json['entities']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emotions': emotions,
      'symbols': symbols,
      'analysisShort': analysisShort,
      'analysisFull': analysisFull,
      'sourcesUsed': sourcesUsed,
      'analyzedAt': analyzedAt.toIso8601String(),
      'summary': summary,
      'themes': themes,
      'symbolInsights': symbolInsights,
      'questions': questions,
      'actions': actions,
      'entities': entities,
    };
  }
}






















// import 'package:hive/hive.dart';
//
// part 'dream_analysis_model.g.dart';
//
// @HiveType(typeId: 1)
// class DreamAnalysisModel {
//   @HiveField(0)
//   List<String> emotions;
//
//   @HiveField(1)
//   List<String> symbols;
//
//   @HiveField(2)
//   String analysisShort;
//
//   @HiveField(3)
//   String analysisFull;
//
//   @HiveField(4)
//   int sourcesUsed;
//
//   @HiveField(5)
//   DateTime analyzedAt;
//
//   DreamAnalysisModel({
//     required this.emotions,
//     required this.symbols,
//     required this.analysisShort,
//     required this.analysisFull,
//     required this.sourcesUsed,
//     required this.analyzedAt,
//   });
//
//   // Factory method to create from API response
//   factory DreamAnalysisModel.fromJson(Map<String, dynamic> json) {
//     return DreamAnalysisModel(
//       emotions: List<String>.from(json['emotions'] ?? []),
//       symbols: List<String>.from(json['symbols'] ?? []),
//       analysisShort: json['analysisShort'] ?? '',
//       analysisFull: json['analysisFull'] ?? '',
//       sourcesUsed: json['sourcesUsed'] ?? 0,
//       analyzedAt: DateTime.now(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'emotions': emotions,
//       'symbols': symbols,
//       'analysisShort': analysisShort,
//       'analysisFull': analysisFull,
//       'sourcesUsed': sourcesUsed,
//       'analyzedAt': analyzedAt.toIso8601String(),
//     };
//   }
// }
