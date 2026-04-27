import 'dart:io';

import 'package:core_module/core_module.dart' hide ReportModel;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:report/src/models/report_model.dart';

/// The repository for handling report data with robust offline sync capabilities.
class ReportRepository {
  final _networkService = NetworkService();
  final _hiveService = HiveService();
  final _cloudinaryService = CloudinaryService();

  // --- PUBLIC API ---

  /// Fetches reports from the server and updates the local cache.
  /// Also attempts to sync pending reports before fetching.
  /// Falls back to cache if the network request fails.
  Future<List<ReportModel>> getReports() async {
    try {
      await _syncPendingReports(); // Always try to sync first.

      final response = await _networkService.dio.get('/reports');
      final serverData = response.data as List;
      final serverReports =
          serverData.map((item) => ReportModel.fromMap(item)).toList();
      debugPrint('Fetched ${serverReports.length} reports from network.');

      await _updateCacheWithServerData(serverReports);
      
      final pendingReports = _loadPendingModelsFromCache();
      return [...serverReports, ...pendingReports];
    } catch (e) {
      debugPrint(
          'Network unavailable during getReports. Loading all from cache. Error: $e');
      return _loadAllFromCache();
    }
  }

  /// Immediately saves a report to the local cache for future synchronization.
  Future<void> queueReportForSync({
    required Map<String, dynamic> reportData,
    required String localImagePath,
  }) async {
    final key = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    
    final dataToCache = {
      ...reportData,
      'local_image_path': localImagePath,
      'status': 'pending_sync',
    };

    await _hiveService.reportsBox.put(key, dataToCache);
    debugPrint('Report queued for sync with key: $key');
  }

  // --- INTERNAL & SYNC LOGIC ---

  Future<void> _syncPendingReports() async {
    final pendingKeys = _hiveService.reportsBox.keys
        .where((key) => key.toString().startsWith('pending_'))
        .toList();

    if (pendingKeys.isEmpty) return;

    debugPrint('Syncing ${pendingKeys.length} pending reports...');
    for (final key in pendingKeys) {
      final data =
          Map<String, dynamic>.from(_hiveService.reportsBox.get(key)!);
      final imagePath = data['local_image_path'] as String?;

      if (imagePath == null) {
        await _hiveService.reportsBox.delete(key);
        continue;
      }

      try {
        final imageUrl = await _cloudinaryService.uploadImage(File(imagePath));
        final postData = {
          'title': data['title'],
          'description': data['description'],
          'location': data['location'],
          'contact': data['contact'],
          'category': data['category'],
          'reward': data['reward'],
          'status': 'lost', // When syncing, it's a lost/found item
          'imageUrl': imageUrl,
        };
        await _networkService.dio.post('/reports', data: postData);
        await _hiveService.reportsBox.delete(key);
        debugPrint('Successfully synced and deleted pending report: $key');
      } on DioException catch (e) {
        debugPrint(
            'Network error during sync for key $key. Aborting. Error: ${e.message}');
        break; 
      } catch (e) {
        debugPrint(
            'Failed to sync pending report $key. Will be retried later. Error: $e');
      }
    }
  }

  Future<void> _updateCacheWithServerData(
      List<ReportModel> serverReports) async {
    final pendingData = _loadPendingDataAsMap();
    await _hiveService.reportsBox.clear();
    for (final report in serverReports) {
      _hiveService.reportsBox.put(report.id, report.toMap());
    }
    await _hiveService.reportsBox.putAll(pendingData);
  }

  List<ReportModel> _loadAllFromCache() {
    return _hiveService.reportsBox.values
        .map((map) => ReportModel.fromMap(map))
        .toList();
  }

  List<ReportModel> _loadPendingModelsFromCache() {
    final models = <ReportModel>[];
    for (final key in _hiveService.reportsBox.keys) {
      if (key.toString().startsWith('pending_')) {
        final map = _hiveService.reportsBox.get(key)!;
        models.add(ReportModel.fromMap(map..['id_from_key'] = key));
      }
    }
    return models;
  }

  Map<dynamic, Map> _loadPendingDataAsMap() {
    final pending = <dynamic, Map>{};
    for (final key in _hiveService.reportsBox.keys) {
      if (key.toString().startsWith('pending_')) {
        pending[key] =
            Map<String, dynamic>.from(_hiveService.reportsBox.get(key)!);
      }
    }
    return pending;
  }
}
