import 'package:flutter/foundation.dart';
import '../models/moderation_report.dart';

class ModerationRepository {
  Future<List<ModerationReport>> fetchReports() async {
    try {
      await Future.delayed(const Duration(milliseconds: 700));

      return ModerationReport.dummyList();
    } catch (e) {
      debugPrint('[ModerationRepository] fetchReports error: $e');
      rethrow;
    }
  }

  Future<void> takedown(String reportId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      debugPrint('[ModerationRepository] takedown error: $e');
      rethrow;
    }
  }

  Future<void> ignore(String reportId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('[ModerationRepository] ignore error: $e');
      rethrow;
    }
  }
}