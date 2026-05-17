// features/inventaris/lib/src/repositories/inventaris_repository.dart

import 'package:flutter/foundation.dart';
import 'package:core_module/core_module.dart';
import '../models/inventaris_item.dart';

class InventarisRepository {
  final _networkService = NetworkService();

  /// Ambil semua barang dengan status finished atau inactive
  Future<List<InventarisItem>> fetchInventaris({String? query}) async {
    try {
      final response = await _networkService.dio.get(
        '/inventaris',
        queryParameters: {
          'status': 'finished,inactive',
          if (query != null && query.isNotEmpty) 'q': query,
        },
      );
      final data = response.data as List<dynamic>;
      return data
          .map((item) => InventarisItem.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[InventarisRepository] fetchInventaris error: $e');
      rethrow;
    }
  }

  /// Ambil detail satu barang berdasarkan id
  Future<InventarisItem> fetchDetail(String id) async {
    try {
      final response = await _networkService.dio.get('/inventaris/$id');
      return InventarisItem.fromMap(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[InventarisRepository] fetchDetail error: $e');
      rethrow;
    }
  }

  /// Update status barang (misal: proses serah terima)
  Future<void> prosesSerahTerima(String id) async {
    try {
      await _networkService.dio.patch(
        '/inventaris/$id',
        data: {'status': 'finished'},
      );
    } catch (e) {
      debugPrint('[InventarisRepository] prosesSerahTerima error: $e');
      rethrow;
    }
  }
}
