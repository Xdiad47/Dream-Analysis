import 'package:dio/dio.dart';
import '../../../dream_journal/data/models/dream_analysis_model.dart';
import '../../../../core/constants/api_constants.dart';

class AIService {
  final Dio _dio;

  AIService() : _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': ApiConstants.contentType,
      },
    ),
  );

  // Analyze dream
  Future<DreamAnalysisModel> analyzeDream({
    required String dreamText,
    required DateTime dreamDate,
    required String moodBeforeSleep,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.apiVersion}${ApiConstants.analyzeDreamEndpoint}',
        data: {
          'dreamText': dreamText,
          'dreamDate': dreamDate.toIso8601String().split('T')[0], // YYYY-MM-DD
          'moodBeforeSleep': moodBeforeSleep,
        },
      );

      if (response.statusCode == 200) {
        return DreamAnalysisModel.fromJson(response.data);
      } else {
        throw Exception('Failed to analyze dream: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server took too long to respond. Please try again.');
      } else if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error. Please check your internet connection.');
      }
    } catch (e) {
      throw Exception('Failed to analyze dream: $e');
    }
  }
}
