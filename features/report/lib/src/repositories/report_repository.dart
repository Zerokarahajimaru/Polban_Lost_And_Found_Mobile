import 'dart:io';
import 'package:core_module/core_module.dart' hide ReportModel;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:report/src/models/report_model.dart';

/// The repository for handling report data with a "try-online-first" approach.
class ReportRepository {
  final _networkService = NetworkService();
  final _hiveService = HiveService();
  final _cloudinaryService = CloudinaryService();

  // --- PUBLIC API ---

  Future<List<ReportModel>> getReports() async {
    try {
      await _syncPendingReports();
      final response = await _networkService.dio.get('/reports');
      final serverData = response.data as List;
      final serverReports =
          serverData.map((item) => ReportModel.fromMap(item)).toList();
      await _updateCacheWithServerData(serverReports);
      return _loadAllFromCache();
    } catch (e) {
      debugPrint(
          'Network unavailable during getReports. Loading all from cache. Error: $e');
      return _loadAllFromCache();
    }
  }

  Future<void> postReportOnline({
    required Map<String, dynamic> reportData,
    File? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _cloudinaryService.uploadImage(imageFile);
    }
    final postData = {...reportData, 'imageUrl': imageUrl ?? reportData['imageUrl']};
    await _networkService.dio.post('/reports', data: postData);
    debugPrint('Report posted directly to server.');
  }

  Future<void> updateReportOnline({
    required String id,
    required Map<String, dynamic> reportData,
    File? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _cloudinaryService.uploadImage(imageFile);
    }
    final postData = {...reportData, 'imageUrl': imageUrl};
    await _networkService.dio.put('/reports/$id', data: postData);
    debugPrint('Report updated directly on server.');
  }

  Future<void> queueCreateForSync({
    required Map<String, dynamic> reportData,
    required String localImagePath,
  }) async {
    final key = 'pending_create_${DateTime.now().millisecondsSinceEpoch}';
    final dataToCache = {
      ...reportData,
      'local_image_path': localImagePath,
      'status': 'pending_sync_create',
    };
    await _hiveService.reportsBox.put(key, dataToCache);
  }

  Future<void> queueUpdateForSync({
    required String id,
    required Map<String, dynamic> reportData,
    String? localImagePath,
  }) async {
    final key = 'pending_update_$id';
    final dataToCache = {
      ...reportData,
      'local_image_path': localImagePath,
      'status': 'pending_sync_update',
    };
    await _hiveService.reportsBox.put(key, dataToCache);
  }

  Future<void> deletePendingReport(String id) async {
    // The ID of a pending report is its key in the Hive box.
    await _hiveService.reportsBox.delete(id);
    debugPrint('Deleted pending report with key: $id');
  }

  // --- INTERNAL & SYNC LOGIC ---

  Future<void> _syncPendingReports() async {
    final pendingKeys = _hiveService.reportsBox.keys
        .where((key) => key.toString().startsWith('pending_'))
        .toList();
    if (pendingKeys.isEmpty) return;

    debugPrint('Syncing ${pendingKeys.length} pending reports...');
    for (final key in pendingKeys) {
      final data = Map<String, dynamic>.from(_hiveService.reportsBox.get(key)!);
      final imagePath = data['local_image_path'] as String?;
      File? imageFile = imagePath != null ? File(imagePath) : null;
      
      try {
        if (key.toString().startsWith('pending_create_')) {
          await postReportOnline(reportData: data, imageFile: imageFile!);
        } else if (key.toString().startsWith('pending_update_')) {
          final id = key.toString().split('_').last;
          await updateReportOnline(id: id, reportData: data, imageFile: imageFile);
        }
        await _hiveService.reportsBox.delete(key);
        debugPrint('Successfully synced and deleted pending item: $key');
      } on DioException catch (e) {
        debugPrint('Network error during sync. Aborting. Error: ${e.message}');
        break;
      } catch (e) {
        debugPrint('Failed to sync pending item $key. Error: $e');
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

  Map<dynamic, Map> _loadPendingDataAsMap() {
    final pending = <dynamic, Map>{};
    for (final key in _hiveService.reportsBox.keys) {
      if (key.toString().startsWith('pending_')) {
        pending[key] = Map<String, dynamic>.from(_hiveService.reportsBox.get(key)!);
      }
    }
    return pending;
  }
}

