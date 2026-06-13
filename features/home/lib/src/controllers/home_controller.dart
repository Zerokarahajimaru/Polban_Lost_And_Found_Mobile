import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';

/// Representasi Tab yang ada di desain Figma
enum HomeTab { kehilangan, penemuan }

/// Opsi Pengurutan
enum HomeSort { terbaru, imbalanTerbesar, abjadAZ }

class HomeController extends ChangeNotifier {
  // --- State Properties ---
  HomeTab _activeTab = HomeTab.kehilangan;
  String _searchQuery = '';
  String _selectedCategory = 'Semua'; 
  HomeSort _activeSort = HomeSort.terbaru;
  List<String> _hiddenPosts = []; // Local filter for reported posts

  // --- Getters ---
  HomeTab get activeTab => _activeTab;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  HomeSort get activeSort => _activeSort;

  // --- Logic Functions ---

  void setActiveTab(HomeTab tab) {
    if (_activeTab == tab) return;
    _activeTab = tab;
    notifyListeners();
  }

  void setActiveSort(HomeSort sort) {
    if (_activeSort == sort) return;
    _activeSort = sort;
    notifyListeners();
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = 'Semua';
    _activeSort = HomeSort.terbaru;
    notifyListeners();
  }

  /// Loads hidden posts from local storage
  Future<void> loadHiddenPosts() async {
    final hive = HiveService();
    final data = hive.settingsBox.get('hidden_posts', defaultValue: <String>[]) as List<dynamic>;
    _hiddenPosts = List<String>.from(data);
    notifyListeners();
  }

  // --- The Core Logic: Multi-Level Filtering & Sorting ---

  List<ReportModel> filterReports(List<ReportModel> allReports, {HomeTab? tab}) {
    final targetTab = tab ?? _activeTab;
    
    final filtered = allReports.where((report) {
      
      // 0. Filter out RESOLVED, BLOCKED, and UNDER_REVIEW items from public feed
      final reportStatus = report.status.toLowerCase();
      if (reportStatus == 'resolved' || reportStatus == 'blocked' || reportStatus == 'under_review') return false;

      // 0.1 Filter out locally hidden posts (reported by user)
      if (_hiddenPosts.contains(report.id)) return false;

      // 1. Filter berdasarkan Tab (Status Postingan)
      final bool matchesTab = (targetTab == HomeTab.kehilangan)
          ? reportStatus == 'lost'
          : reportStatus == 'found';

      // 2. Filter berdasarkan Kategori
      final bool matchesCategory = (_selectedCategory == 'Semua')
          ? true
          : report.category.toLowerCase() == _selectedCategory.toLowerCase();

      // 3. Filter berdasarkan Pencarian (Judul atau Lokasi)
      final bool matchesSearch = report.title.toLowerCase().contains(_searchQuery) ||
                                 report.location.toLowerCase().contains(_searchQuery);

      return matchesTab && matchesCategory && matchesSearch;
    }).toList();

    // 4. Sorting
    switch (_activeSort) {
      case HomeSort.terbaru:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case HomeSort.imbalanTerbesar:
        filtered.sort((a, b) {
          final rewardA = double.tryParse(a.reward ?? '0') ?? 0;
          final rewardB = double.tryParse(b.reward ?? '0') ?? 0;
          return rewardB.compareTo(rewardA);
        });
        break;
      case HomeSort.abjadAZ:
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }

    return filtered;
  }

  int getUnsyncedCount(List<ReportModel> allReports) {
    return allReports.where((report) => report.id.startsWith('pending_')).length;
  }
}
