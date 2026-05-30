import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';

/// Representasi Tab yang ada di desain Figma
enum HomeTab { kehilangan, penemuan }

class HomeController extends ChangeNotifier {
  // --- State Properties ---
  HomeTab _activeTab = HomeTab.kehilangan;
  String _searchQuery = '';
  String _selectedCategory = 'Semua'; // Sesuai filter ikon di Figma

  // --- Getters ---
  HomeTab get activeTab => _activeTab;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // --- Logic Functions ---

  /// Mengubah tab aktif (Kehilangan/Penemuan)
  void setActiveTab(HomeTab tab) {
    if (_activeTab == tab) return;
    _activeTab = tab;
    notifyListeners();
  }

  /// Mengubah kategori filter (Elektronik, Dokumen, dll)
  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  /// Update query pencarian
  void updateSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  /// Reset semua filter ke kondisi awal
  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = 'Semua';
    notifyListeners();
  }

  // --- The Core Logic: Multi-Level Filtering ---

  /// Fungsi utama untuk menyaring data yang diambil dari ReportController.
  List<ReportModel> filterReports(List<ReportModel> allReports) {
    return allReports.where((report) {
      
      // 0. Filter out RESOLVED items from public feed
      if (report.status.toLowerCase() == 'resolved') return false;

      // 1. Filter berdasarkan Tab (Status Postingan)
      final bool matchesTab = (_activeTab == HomeTab.kehilangan)
          ? report.status.toLowerCase() == 'lost'
          : report.status.toLowerCase() == 'found';

      // 2. Filter berdasarkan Kategori
      final bool matchesCategory = (_selectedCategory == 'Semua')
          ? true
          : report.category.toLowerCase() == _selectedCategory.toLowerCase();

      // 3. Filter berdasarkan Pencarian (Judul atau Lokasi)
      final bool matchesSearch = report.title.toLowerCase().contains(_searchQuery) ||
                                 report.location.toLowerCase().contains(_searchQuery);

      return matchesTab && matchesCategory && matchesSearch;
    }).toList();
  }

  /// Menghitung berapa banyak laporan yang belum tersinkron (isSynced == false)
  int getUnsyncedCount(List<ReportModel> allReports) {
    return allReports.where((report) => report.id.startsWith('pending_')).length;
  }
}
