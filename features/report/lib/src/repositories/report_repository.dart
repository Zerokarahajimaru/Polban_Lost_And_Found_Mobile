import 'dart:io';
import 'package:core_module/core_module.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ReportRepository {
  final _networkService = NetworkService();
  final _hiveService = HiveService();
  final _cloudinaryService = CloudinaryService();

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
      debugPrint('Network unavailable. Loading from cache. Error: $e');
      return _loadAllFromCache();
    }
  }

  Future<void> saveAsDraft({
    required Map<String, dynamic> reportData,
    String? localImagePath,
    String? existingId,
  }) async {
    final key = existingId ?? 'draft_${DateTime.now().millisecondsSinceEpoch}';
    final dataToCache = {
      ...reportData,
      'local_image_path': localImagePath,
      'status': 'draft',
    };
    await _hiveService.reportsBox.put(key, dataToCache);
  }

  Future<void> postReportOnline({
    required Map<String, dynamic> reportData,
    required File imageFile,
  }) async {
    final imageUrl = await _cloudinaryService.uploadImage(imageFile);
    final postData = {...reportData, 'imageUrl': imageUrl};
    await _networkService.dio.post('/reports', data: postData);
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
    final postData = {...reportData, 'imageUrl': imageUrl ?? reportData['imageUrl']};
    await _networkService.dio.put('/reports/$id', data: postData);
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

  Future<void> deleteReport(String id, String status) async {
    if (status.contains('pending') || status == 'draft') {
      await _hiveService.reportsBox.delete(id);
    } else {
      await _networkService.dio.delete('/reports/$id');
    }
  }
  
  Future<void> _syncPendingReports() async {
    final pendingKeys = _hiveService.reportsBox.keys.where((k) => k.toString().startsWith('pending_')).toList();
    if (pendingKeys.isEmpty) return;

    for (final key in pendingKeys) {
      final data = Map<String, dynamic>.from(_hiveService.reportsBox.get(key)!);
      final imagePath = data['local_image_path'] as String?;
      File? imageFile = imagePath != null ? File(imagePath) : null;
      
      try {
        if (key.toString().startsWith('pending_create_')) {
          if (imageFile == null) continue;
          await postReportOnline(reportData: data, imageFile: imageFile);
        } else if (key.toString().startsWith('pending_update_')) {
          final id = key.toString().split('pending_update_').last;
          await updateReportOnline(id: id, reportData: data, imageFile: imageFile);
        }
        await _hiveService.reportsBox.delete(key);
      } on DioException {
        break; 
      } catch (e) {
        debugPrint('Failed to sync item $key. Error: $e');
      }
    }
  }
  
  Future<void> _updateCacheWithServerData(List<ReportModel> serverReports) async {
    final pendingData = _loadPendingDataAsMap();
    await _hiveService.reportsBox.clear();
    for (final report in serverReports) {
      _hiveService.reportsBox.put(report.id, report.toMap());
    }
    await _hiveService.reportsBox.putAll(pendingData);
  }

  List<ReportModel> _loadAllFromCache() {
    return _hiveService.reportsBox.values.map((map) => ReportModel.fromMap(map)).toList();
  }

  Map<dynamic, Map> _loadPendingDataAsMap() {
    final pending = <dynamic, Map>{};
    for (final key in _hiveService.reportsBox.keys) {
      if (key.toString().startsWith('pending_') || key.toString().startsWith('draft_')) {
        pending[key] = Map<String, dynamic>.from(_hiveService.reportsBox.get(key)!);
      }
    }
    return pending;
  }
}



