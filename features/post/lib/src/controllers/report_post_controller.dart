import 'dart:io';

import 'package:flutter/material.dart';
import 'package:post/src/models/report_post_model.dart';

/// State enum untuk report post
enum ReportPostState { initial, loading, loaded, error }

/// Alasan-alasan pelaporan yang tersedia
enum ReportReason {
  harassment,
  hateSpeech,
  spam,
  falseInformation,
  inappropriate,
  copyright,
  other,
}

extension ReportReasonExtension on ReportReason {
  String get displayName {
    switch (this) {
      case ReportReason.harassment:
        return 'Pelecehan atau Ancaman';
      case ReportReason.hateSpeech:
        return 'Ujaran Kebencian';
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.falseInformation:
        return 'Informasi Palsu atau Menyesatkan';
      case ReportReason.inappropriate:
        return 'Konten Tidak Sesuai';
      case ReportReason.copyright:
        return 'Pelanggaran Hak Cipta';
      case ReportReason.other:
        return 'Alasan Lain';
    }
  }
}

/// Controller untuk melaporkan postingan
class ReportPostController extends ChangeNotifier {
  // Private state properties
  ReportPostState _state = ReportPostState.initial;
  String _message = '';
  List<ReportPostModel> _myReports = [];

  // Form state
  ReportReason? _selectedReason;
  String _description = '';
  List<File> _attachments = [];

  // Public getters
  ReportPostState get state => _state;
  String get message => _message;
  List<ReportPostModel> get myReports => _myReports;
  ReportReason? get selectedReason => _selectedReason;
  String get description => _description;
  List<File> get attachments => _attachments;

  /// Set alasan pelaporan
  void setReason(ReportReason reason) {
    _selectedReason = reason;
    notifyListeners();
  }

  /// Set deskripsi detail
  void setDescription(String desc) {
    _description = desc;
    notifyListeners();
  }

  /// Tambah attachment (foto/screenshot)
  void addAttachment(File file) {
    if (_attachments.length < 5) {
      _attachments.add(file);
      notifyListeners();
    } else {
      _message = 'Maksimal 5 lampiran';
    }
  }

  /// Hapus attachment tertentu
  void removeAttachment(int index) {
    if (index >= 0 && index < _attachments.length) {
      _attachments.removeAt(index);
      notifyListeners();
    }
  }

  /// Clear semua form
  void clearForm() {
    _selectedReason = null;
    _description = '';
    _attachments.clear();
    _message = '';
    notifyListeners();
  }

  /// Validasi form sebelum submit
  bool _validateForm() {
    if (_selectedReason == null) {
      _message = 'Pilih alasan pelaporan';
      return false;
    }
    if (_description.trim().isEmpty) {
      _message = 'Deskripsi tidak boleh kosong';
      return false;
    }
    if (_description.trim().length < 10) {
      _message = 'Deskripsi minimal 10 karakter';
      return false;
    }
    return true;
  }

  /// Submit laporan postingan
  Future<bool> submitReport(String postId, String reporterUserId) async {
    if (!_validateForm()) {
      _setState(ReportPostState.error);
      return false;
    }

    _setState(ReportPostState.loading);
    _message = 'Mengirim laporan...';

    try {
      // TODO: Upload attachments ke Cloudinary / Firebase Storage
      List<String> uploadedAttachmentUrls = [];
      for (final file in _attachments) {
        // const uploadedUrl = await CloudinaryService().uploadImage(file);
        // uploadedAttachmentUrls.add(uploadedUrl);
      }

      // Buat model laporan
      final reportPost = ReportPostModel(
        postId: postId,
        reporterUserId: reporterUserId,
        reason: _selectedReason!.displayName,
        description: _description,
        createdAt: DateTime.now(),
        attachments: uploadedAttachmentUrls,
        status: 'pending',
      );

      // TODO: Kirim ke backend API
      // final response = await _reportRepository.submitReport(reportPost);
      // if (response.isSuccess) {
      //   _myReports.add(response.data);
      // }

      _message = 'Laporan berhasil dikirim. Terima kasih telah membantu.';
      _setState(ReportPostState.loaded);
      clearForm();
      return true;
    } catch (e) {
      _message = 'Gagal mengirim laporan: $e';
      _setState(ReportPostState.error);
      return false;
    }
  }

  /// Ambil laporan yang dibuat oleh user
  Future<void> getMyReports(String userId) async {
    _setState(ReportPostState.loading);
    try {
      // TODO: Ganti dengan API call ke backend
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulasi data
      _myReports = [
        ReportPostModel(
          id: 'report_001',
          postId: 'post_123',
          reporterUserId: userId,
          reason: 'Informasi Palsu atau Menyesatkan',
          description: 'Postingan ini berisi informasi yang tidak akurat tentang barang.',
          status: 'reviewed',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          resolvedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      _setState(ReportPostState.loaded);
      _message = 'Laporan berhasil dimuat';
    } catch (e) {
      _message = 'Gagal memuat laporan: $e';
      _setState(ReportPostState.error);
    }
  }

  /// Helper function untuk update state
  void _setState(ReportPostState newState) {
    _state = newState;
    notifyListeners();
  }
}
