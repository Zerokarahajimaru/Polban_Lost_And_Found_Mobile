import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../services/hive_service.dart';
import '../services/network_service.dart';
import '../services/cloudinary_service.dart';

class ReportRepository {
  final _networkService = NetworkService();
  final _hiveService = HiveService();
  final _cloudinaryService = CloudinaryService();

  Future<List<ReportModel>> getReports({String? userId}) async {
    try {
      await _syncPendingReports();
      final queryParams = userId != null ? {'userId': userId} : null;
      final response = await _networkService.dio.get('/reports', queryParameters: queryParams);
      final serverData = response.data as List;
      final serverReports =
          serverData.map((item) => ReportModel.fromMap(item)).toList();
      
      // Update cache with server results. 
      await _updateCache(serverReports);
      
      return _loadAllFromCache(filterByUserId: userId);
    } catch (e) {
      debugPrint('Network unavailable or server error. Loading from cache. Error: $e');
      return _loadAllFromCache(filterByUserId: userId);
    }
  }

  /// Merges server reports into the Hive cache.
  Future<void> _updateCache(List<ReportModel> serverReports) async {
    // Put each server report into Hive. 
    for (final report in serverReports) {
      await _hiveService.reportsBox.put(report.id, report.toMap());
    }
  }

  Future<void> saveAsDraft({
    required Map<String, dynamic> reportData,
    String? localImagePath,
    String? existingId,
  }) async {
    final key = existingId ?? 'draft_${DateTime.now().millisecondsSinceEpoch}';
    final dataToCache = {
      'id': key,
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

  Future<void> updateReportStatus({
    required String id,
    required String status,
    String? claimantName,
    String? claimantId,
  }) async {
    final data = {
      'status': status,
      'claimant_name': claimantName,
      'claimant_id': claimantId,
      'resolved_at': DateTime.now().toIso8601String(),
    };
    await _networkService.dio.put('/reports/$id', data: data);
  }
  
  Future<void> queueCreateForSync({
    required Map<String, dynamic> reportData,
    required String localImagePath,
  }) async {
    final key = 'pending_create_${DateTime.now().millisecondsSinceEpoch}';
    final dataToCache = {
      'id': key,
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
      'id': key,
      ...reportData,
      'local_image_path': localImagePath,
      'status': 'pending_sync_update',
    };
    await _hiveService.reportsBox.put(key, dataToCache);
  }

  Future<void> queueDeleteForSync(String reportId) async {
    final key = 'pending_delete_$reportId';
    await _hiveService.reportsBox.put(key, {'id': reportId});
  }

  Future<void> deleteReport(String id, String status) async {
    if (status.contains('pending') || status == 'draft') {
      await _hiveService.reportsBox.delete(id);
    } else {
      try {
        await _networkService.dio.delete('/reports/$id');
        await _hiveService.reportsBox.delete(id);
      } on DioException catch (e) {
        if (_isNetworkError(e)) {
          await queueDeleteForSync(id);
        } else {
          rethrow;
        }
      }
    }
  }
  
  Future<void> _syncPendingReports() async {
    final keys = _hiveService.reportsBox.keys.toList();
    
    // Sync creations and updates
    final pendingSyncKeys = keys.where((k) => k.toString().startsWith('pending_') && !k.toString().startsWith('pending_delete_')).toList();
    for (final key in pendingSyncKeys) {
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
      } catch (e) {
        debugPrint('Failed to sync item $key: $e');
        if (e is DioException && _isNetworkError(e)) break;
      }
    }

    // Sync deletions
    final pendingDeleteKeys = keys.where((k) => k.toString().startsWith('pending_delete_')).toList();
    for (final key in pendingDeleteKeys) {
      final data = _hiveService.reportsBox.get(key);
      if (data == null) continue;
      final reportId = data['id'] as String;
      try {
        await _networkService.dio.delete('/reports/$reportId');
        await _hiveService.reportsBox.delete(key);
        await _hiveService.reportsBox.delete(reportId);
      } catch (e) {
        debugPrint('Failed to sync deletion for $reportId: $e');
        if (e is DioException && _isNetworkError(e)) break;
      }
    }
  }

  Future<List<ReportModel>> loadFromCacheOnly({String? userId}) async {
    return _loadAllFromCache(filterByUserId: userId);
  }

  List<ReportModel> _loadAllFromCache({String? filterByUserId}) {
    final reports = <ReportModel>[];
    for (final key in _hiveService.reportsBox.keys) {
      final map = _hiveService.reportsBox.get(key);
      if (map != null && !key.toString().startsWith('pending_delete_')) {
        final dataWithId = Map<String, dynamic>.from(map);
        final report = ReportModel.fromMap(dataWithId);
        
        if (filterByUserId != null) {
          if (report.userId == filterByUserId) {
            reports.add(report);
          }
        } else {
          reports.add(report);
        }
      }
    }
    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reports;
  }

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
           e.type == DioExceptionType.connectionTimeout ||
           e.type == DioExceptionType.unknown;
  }
}
