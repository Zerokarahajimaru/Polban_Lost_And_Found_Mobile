// features/inventaris/lib/src/controllers/inventaris_controller.dart

import 'package:flutter/foundation.dart';
import '../models/inventaris_item.dart';
import '../repository/inventaris_repository.dart';

class InventarisController extends ChangeNotifier {
  final _repository = InventarisRepository();

  List<InventarisItem> _items = [];
  List<InventarisItem> _filtered = [];
  bool _isLoading = false;
  String _message = '';
  bool _lastOperationFailed = false;
  String _searchQuery = '';

  List<InventarisItem> get items => _filtered;
  bool get isLoading => _isLoading;
  String get message => _message;
  bool get lastOperationFailed => _lastOperationFailed;
  String get searchQuery => _searchQuery;

  void clearMessage() {
    _message = '';
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filtered = List.from(_items);
    } else {
      final q = _searchQuery.toLowerCase();
      _filtered = _items
          .where((item) =>
              item.nama.toLowerCase().contains(q) ||
              item.kategori.toLowerCase().contains(q) ||
              item.lokasi.toLowerCase().contains(q))
          .toList();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  // ---- Load semua inventaris (finished + inactive) ----
  Future<void> loadInventaris() async {
    _isLoading = true;
    notifyListeners();

    try {
      // MOHON DI PERHATIKAN, INI UNTUK SEMENTARA
      // KALAU UDAH ADA DATA NYA BARU DI UNCOMMENT DAN HAPUS DUMMY DATA
      _items = InventarisItem.dummyList();
      // Uncomment baris di bawah saat backend sudah siap:
      // _items = await _repository.fetchInventaris();
      _applyFilter();
      _lastOperationFailed = false;
    } catch (e) {
      _message = 'Gagal memuat data inventaris.';
      _lastOperationFailed = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- Proses serah terima barang ----
  Future<void> prosesSerahTerima(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.prosesSerahTerima(id);
      // Update status lokal
      final idx = _items.indexWhere((i) => i.id == id);
      if (idx != -1) {
        _items[idx] = InventarisItem(
          id: _items[idx].id,
          nama: _items[idx].nama,
          kategori: _items[idx].kategori,
          imageUrl: _items[idx].imageUrl,
          tanggalMasuk: _items[idx].tanggalMasuk,
          tanggalKeluar: _items[idx].tanggalKeluar,
          status: InventarisStatus.finished,
          deskripsi: _items[idx].deskripsi,
          lokasi: _items[idx].lokasi,
        );
      }
      _applyFilter();
      _message = 'Serah terima berhasil diproses.';
      _lastOperationFailed = false;
    } catch (e) {
      _message = 'Gagal memproses serah terima.';
      _lastOperationFailed = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
