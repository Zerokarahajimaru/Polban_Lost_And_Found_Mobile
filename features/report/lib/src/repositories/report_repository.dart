import 'package:core_module/core_module.dart' hide ReportModel;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:report/src/models/report_model.dart';

/// A custom exception to indicate that a report was saved locally
/// due to a network failure and will be synced later.
class OfflinePostException implements Exception {
  final String message =
      'Koneksi gagal. Laporan disimpan secara lokal dan akan dikirim nanti.';
  @override
  String toString() => message;
}

/// The repository for handling report data.
///
/// It acts as a single source of truth for report data, abstracting away
/// the data source (network or local cache).
class ReportRepository {
  final _networkService = NetworkService();
  final _hiveService = HiveService();

  /// Fetches reports.
  ///
  /// Tries to fetch from the network first. If successful, it updates the local
  /// cache. If the network request fails due to connection issues, it returns
  /// data from the local cache.
  Future<List<ReportModel>> getReports() async {
    try {
      final response = await _networkService.dio.get('/reports');

      if (response.statusCode == 200) {
        final data = response.data as List;
        final reports = data.map((item) => ReportModel.fromMap(item)).toList();
        debugPrint('Fetched ${reports.length} reports from network.');

        // Update cache
        await _hiveService.reportsBox.clear();
        for (final report in reports) {
          _hiveService.reportsBox.put(report.id, report.toMap());
        }
        debugPrint('Cache updated with new data.');
        return reports;
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        debugPrint('Network failed, loading from cache.');
        final cachedMaps = _hiveService.reportsBox.values.toList();
        return cachedMaps.map((map) => ReportModel.fromMap(map)).toList();
      }
      rethrow; // Rethrow other Dio-related errors.
    } catch (e) {
      debugPrint('Error in getReports: $e');
      throw Exception('Gagal memuat laporan.');
    }
  }

  /// Posts a new report.
  ///
  /// Tries to post the report to the backend. If it fails due to a network
  /// issue, it saves the report data locally for a future sync attempt.
  Future<void> postReport({
    required Map<String, dynamic> postData,
  }) async {
    try {
      final response = await _networkService.dio.post(
        '/reports',
        data: postData,
      );

      if (response.statusCode != 201) {
        throw Exception('Gagal membuat laporan: ${response.statusCode}');
      }
      debugPrint('Report created successfully on the server.');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        debugPrint('Network failed, caching report for later sync.');
        // Use a timestamp as a unique key for pending posts
        final key = 'pending_${DateTime.now().millisecondsSinceEpoch}';
        await _hiveService.reportsBox.put(key, postData);
        // Throw a specific exception to let the UI know it was cached.
        throw OfflinePostException();
      }
      rethrow;
    } catch (e) {
      debugPrint('Error in postReport: $e');
      throw Exception('Gagal membuat laporan.');
    }
  }
}
