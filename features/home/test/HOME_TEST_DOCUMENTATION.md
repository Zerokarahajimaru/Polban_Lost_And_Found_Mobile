# Home Feature Whitebox Test Documentation

## Overview
This document provides comprehensive test coverage for the HomePage feature following a **Whitebox (Internal Logic) Testing** approach. Tests are organized in 7 groups, mirroring the login test structure.

## Test Groups & Coverage

### GROUP A — HomePage Display (Empty State & Data Loading)
Tests for basic HomePage rendering and tab functionality.

| Test ID | TC | Name | Purpose |
|---------|-----|------|---------|
| WB-H-01 | TC-008 | Empty state saat tidak ada laporan | Verify empty state when no reports available |
| WB-H-02 | TC-009 | Menampilkan laporan berstatus "lost" | Verify only "lost" status reports show in Kehilangan tab |
| WB-H-03 | TC-010 | Menampilkan laporan berstatus "found" | Verify only "found" status reports show in Penemuan tab |
| WB-H-04 | — | Filter resolved/blocked/under_review | Verify these statuses are hidden from public feed |
| WB-H-05 | — | Tab state change listener | Verify state changes trigger notifyListeners |

### GROUP B — Search Functionality
Tests for search/filter by title and location.

| Test ID | TC | Name | Purpose |
|---------|-----|------|---------|
| WB-H-06 | TC-011 | Search berhasil filter laporan | Verify search filters by title |
| WB-H-07 | TC-012 | Search keyword tidak ditemukan | Verify empty state for no matches |
| WB-H-08 | — | Search case-insensitive | Verify search is case-insensitive |
| WB-H-09 | — | Search juga di location field | Verify search includes location field |
| WB-H-10 | — | updateSearchQuery listener | Verify search triggers notifyListeners |

### GROUP C — Category Filter
Tests for category-based filtering.

| Test ID | TC | Name | Purpose |
|---------|-----|------|---------|
| WB-H-11 | — | Filter kategori "Semua" | Verify "Semua" shows all categories |
| WB-H-12 | — | Filter kategori spesifik | Verify specific category filter works |
| WB-H-13 | — | Category filter case-insensitive | Verify category matching is case-insensitive |

### GROUP D — Multi-Filter (Combined Filters)
Tests for combining multiple filters simultaneously.

| Test ID | TC | Name | Purpose |
|---------|-----|------|---------|
| WB-H-14 | TC-013 | Filter kombinasi kategori + search | Verify combined tab + category + search filter |
| WB-H-15 | — | Multi-filter tab + kategori | Verify tab and category filter together |
| WB-H-16 | — | Filter sangat ketat | Verify strict filter returns empty |

### GROUP E — Sorting Functionality
Tests for sorting/ordering reports.

| Test ID | TC | Name | Purpose |
|---------|-----|------|---------|
| WB-H-17 | — | Sort terbaru (newest first) | Verify newest-first sorting |
| WB-H-18 | — | Sort abjad A-Z | Verify alphabetical A-Z sorting |
| WB-H-19 | — | Sort imbalanTerbesar (highest reward) | Verify reward-based sorting |
| WB-H-20 | — | Sort listener | Verify sort change triggers notifyListeners |

### GROUP F — Filter Reset
Tests for resetting all filters to default state.

| Test ID | TC | Name | Purpose |
|---------|-----|------|---------|
| WB-H-21 | — | resetFilters default state | Verify all filters reset to defaults |
| WB-H-22 | — | Reset listener | Verify reset triggers notifyListeners |

### GROUP G — Unsync Count
Tests for counting unsynced (pending_*) reports.

| Test ID | TC | Name | Purpose |
|---------|-----|------|---------|
| WB-H-23 | — | Count pending reports | Verify unsynced count calculation |
| WB-H-24 | — | Zero pending count | Verify returns 0 when no pending |

---

## Test Architecture

### Arrange-Act-Assert Pattern
Each test follows the standard AAA pattern:

```dart
test('description', () {
  // Arrange: Setup test data
  final reports = [...];
  
  // Act: Execute the logic being tested
  homeController.setCategory('Dokumen');
  final filtered = homeController.filterReports(reports);
  
  // Assert: Verify expected results
  expect(filtered.length, equals(1));
});
```

### Mock Strategy
- **MockReportController**: Mocked to isolate HomeController logic
- **ReportModel**: Extended with `category` and `reward` fields for test purposes
- **_ReportModelExtended**: Custom test model supporting category/reward

### Helper Functions

#### `_createReportModel()`
Factory function for creating test ReportModel instances with customizable fields.

```dart
_createReportModel(
  id: 'r001',
  title: 'KTM',
  status: 'lost',
  category: 'Dokumen',
  reward: '500000',
)
```

---

## Running the Tests

### Run all tests in the home feature
```bash
cd features/home
flutter test
```

### Run specific test group
```bash
flutter test --name "GROUP A"
flutter test --name "GROUP B"
```

### Run specific test
```bash
flutter test --name "WB-H-01"
flutter test --name "TC-008"
```

### Run with coverage
```bash
flutter test --coverage
```

---

## Test Data Structure

### Status Values
- `lost`: Laporan kehilangan
- `found`: Laporan penemuan
- `resolved`: Sudah diselesaikan (hidden from public feed)
- `blocked`: Dilaporkan/diblokir (hidden from public feed)
- `under_review`: Dalam review (hidden from public feed)

### Category Values
- `Dokumen`: KTM, Kartu Pelajar, dll
- `Barang`: Dompet, Tas, dll
- `Aksesoris`: Kunci, Cincin, dll

### Sort Options
- `terbaru`: Newest first (default)
- `abjadAZ`: Alphabetical A-Z
- `imbalanTerbesar`: Highest reward first

### Tab Options
- `HomeTab.kehilangan`: Lost items
- `HomeTab.penemuan`: Found items

---

## Key Test Scenarios

### Empty State
- No reports in data → Empty list returned
- Search matches nothing → Empty list returned
- All filters too strict → Empty list returned

### Tab Filtering
- Reports filtered by status (lost/found)
- Resolved/Blocked/Under Review always hidden
- Tab switch triggers state change

### Search Functionality
- Case-insensitive matching on title and location
- Whitespace trimmed from search query
- Returns empty if no matches

### Category Filtering
- "Semua" (All) shows all categories
- Specific category filters correctly
- Case-insensitive category matching

### Multi-Filtering
- Tab + Category filters combined correctly
- Tab + Category + Search all applied
- Strict combinations return empty when appropriate

### Sorting
- Terbaru: DateTime comparison (newest → oldest)
- AbjadAZ: String comparison (A → Z)
- ImbalanTerbesar: Reward parsing and comparison

### State Management
- setActiveTab → notifyListeners
- updateSearchQuery → notifyListeners
- setCategory → notifyListeners
- setActiveSort → notifyListeners
- resetFilters → notifyListeners

---

## Notes for Implementation

1. **Category & Reward Fields**: These are not in the current ReportModel. When implemented, remove the `_ReportModelExtended` class and update helper functions.

2. **Hidden Posts**: The `_hiddenPosts` filtering logic is included in the test but may need integration with actual HiveService implementation.

3. **Edge Cases**: Tests cover case-insensitive matching, empty states, and combined filters to ensure robustness.

4. **Listener Verification**: Tests verify that state changes trigger `notifyListeners()` for proper UI updates.

---

## Related Files
- `home_test.dart` - Main test file
- `home_test.mocks.dart` - Generated Mockito mocks
- `lib/src/controllers/home_controller.dart` - Controller under test
- `lib/models/report_model.dart` - Data model

---

## Future Enhancements

1. Add integration tests with actual UI widgets
2. Add tests for hidden posts/reported items filtering
3. Add performance tests for large datasets
4. Add tests for state persistence
5. Add tests for error handling in data loading
