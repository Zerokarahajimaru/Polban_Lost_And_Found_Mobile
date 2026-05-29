import 'package:core_module/core_module.dart';
import 'package:flutter/foundation.dart';
import '../models/claim_model.dart';

class ClaimRepository {
  final _networkService = NetworkService();

  Future<List<ClaimModel>> fetchClaims() async {
    try {
      final response = await _networkService.dio.get('/claims');
      final data = response.data as List<dynamic>;
      return data.map((json) => ClaimModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[ClaimRepository] fetchClaims error: $e');
      return []; // Return empty list on error for safety
    }
  }

  Future<void> submitClaim(ClaimModel claim) async {
    try {
      await _networkService.dio.post('/claims', data: claim.toJson());
    } catch (e) {
      debugPrint('[ClaimRepository] submitClaim error: $e');
      rethrow;
    }
  }

  Future<void> verifyClaim(String claimId, String action) async {
    try {
      await _networkService.dio.post('/claims/$claimId', data: {'action': action});
    } catch (e) {
      debugPrint('[ClaimRepository] verifyClaim error: $e');
      rethrow;
    }
  }
}
