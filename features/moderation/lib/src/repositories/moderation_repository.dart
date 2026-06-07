import 'package:core_module/core_module.dart';
import 'package:flutter/foundation.dart';
import '../models/moderation_report.dart';

class ModerationRepository {
  final _networkService = NetworkService();

  Future<List<ModerationReport>> fetchReports({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }
      
      final response = await _networkService.dio.get('/moderation', queryParameters: queryParams);
      final data = response.data as List<dynamic>;
      return data
          .map((item) => ModerationReport.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ModerationRepository] fetchReports error: $e');
      rethrow;
    }
  }

  Future<void> takedown(String reportId) async {
    try {
      await _networkService.dio.post(
        '/moderation/$reportId',
        data: {'action': 'takedown'},
      );
    } catch (e) {
      debugPrint('[ModerationRepository] takedown error: $e');
      rethrow;
    }
  }

  Future<void> ignore(String reportId) async {
    try {
      await _networkService.dio.post(
        '/moderation/$reportId',
        data: {'action': 'ignore'},
      );
    } catch (e) {
      debugPrint('[ModerationRepository] ignore error: $e');
      rethrow;
    }
  }

  Future<void> submitReport({
    required String postId,
    required String postTitle,
    required String reportReason,
    required String uploaderName,
    String? postImageUrl,
    required String reporterName,
    required String reporterNim,
  }) async {
    try {
      await _networkService.dio.post(
        '/moderation',
        data: {
          'postId': postId,
          'postTitle': postTitle,
          'reportReason': reportReason,
          'uploaderName': uploaderName,
          'postImageUrl': postImageUrl,
          'reporterName': reporterName,
          'reporterNim': reporterNim,
        },
      );
    } catch (e) {
      debugPrint('[ModerationRepository] submitReport error: $e');
      rethrow;
    }
  }
}
