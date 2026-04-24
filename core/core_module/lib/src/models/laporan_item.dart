// core_module/lib/src/models/laporan_item.dart
import 'package:flutter/material.dart';

class LaporanItem {
  final String nama;
  final String lokasi;
  final String status;
  final Color statusColor;
  final String? badge;
  final String imageUrl;
  final String? imbalan;
  final String kategori;
  final String waktuLapor;
  final String deskripsi;

  const LaporanItem({
    required this.nama,
    required this.lokasi,
    required this.status,
    required this.statusColor,
    this.badge,
    required this.imageUrl,
    this.imbalan,
    required this.kategori,
    required this.waktuLapor,
    required this.deskripsi,
  });
}