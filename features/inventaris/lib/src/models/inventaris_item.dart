// features/inventaris/lib/src/models/inventaris_item.dart

enum InventarisStatus { finished, inactive }

class InventarisItem {
  final String id;
  final String nama;
  final String kategori;
  final String? imageUrl;
  final String tanggalMasuk;
  final String tanggalKeluar;
  final InventarisStatus status;
  final String deskripsi;
  final String lokasi;

  const InventarisItem({
    required this.id,
    required this.nama,
    required this.kategori,
    this.imageUrl,
    required this.tanggalMasuk,
    required this.tanggalKeluar,
    required this.status,
    required this.deskripsi,
    required this.lokasi,
  });

  factory InventarisItem.fromMap(Map<String, dynamic> map) {
    return InventarisItem(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      nama: map['nama']?.toString() ?? '',
      kategori: map['kategori']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString(),
      tanggalMasuk: map['tanggalMasuk']?.toString() ?? '',
      tanggalKeluar: map['tanggalKeluar']?.toString() ?? '',
      status: map['status'] == 'inactive'
          ? InventarisStatus.inactive
          : InventarisStatus.finished,
      deskripsi: map['deskripsi']?.toString() ?? '',
      lokasi: map['lokasi']?.toString() ?? '',
    );
  }

  // ---- Dummy Data ----
  static List<InventarisItem> dummyList() {
    return [
      const InventarisItem(
        id: 'inv_001',
        nama: 'Kunci Motor Ferrari',
        kategori: 'KUNCI',
        tanggalMasuk: '2026-04-26',
        tanggalKeluar: '2026-04-28',
        status: InventarisStatus.finished,
        deskripsi: 'Kunci motor warna hitam dengan gantungan kuda Ferrari',
        lokasi: 'Ruang FJBL 1',
      ),
      const InventarisItem(
        id: 'inv_002',
        nama: 'Kabel Casan Iphone',
        kategori: 'ELEKTRONIK',
        imageUrl:
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=200&fit=crop',
        tanggalMasuk: '2026-04-02',
        tanggalKeluar: '2026-04-04',
        status: InventarisStatus.finished,
        deskripsi: 'Warna hitam, ada stiker SEVENTEEN di belakang',
        lokasi: 'Ruang 108',
      ),
      const InventarisItem(
        id: 'inv_003',
        nama: 'Kunci Mobil BMW',
        kategori: 'KUNCI',
        tanggalMasuk: '2026-03-03',
        tanggalKeluar: '2026-03-07',
        status: InventarisStatus.inactive,
        deskripsi: 'Kunci lipat BMW seri 3, ada remote dengan tombol unlock/lock',
        lokasi: 'Ruang Serbaguna',
      ),
    ];
  }
}
