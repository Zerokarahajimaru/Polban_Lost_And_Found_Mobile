import 'dart:io';

import 'package:backend/src/models/report.dart';
import 'package:backend/src/services/database_service.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.put:
      return _onPut(context, id);
    case HttpMethod.delete:
      return _onDelete(context, id);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _onPut(RequestContext context, String id) async {
  try {
    final reportsCollection = await DatabaseService().reports;
    final objectId = ObjectId.fromHexString(id);
    final json = await context.request.json() as Map<String, dynamic>;

    final existingReportMap = await reportsCollection.findOne(where.id(objectId));
    if (existingReportMap == null) {
      return Response(statusCode: HttpStatus.notFound, body: 'Report not found');
    }
    
    final updateData = Map<String, dynamic>.from(existingReportMap);

    updateData['nama_barang'] = json['title'] ?? updateData['nama_barang'];
    updateData['kategori_barang'] = json['category'] ?? updateData['kategori_barang'];
    updateData['status_postingan'] = json['status'] ?? updateData['status_postingan'];
    updateData['deskripsi_barang'] = json['description'] ?? updateData['deskripsi_barang'];
    updateData['lokasi_kehilangan'] = json['location'] ?? updateData['lokasi_kehilangan'];
    updateData['kontak'] = json['contact'] ?? updateData['kontak'];
    updateData['updated_at'] = DateTime.now().toIso8601String();
    
    if (json['imageUrl'] != null) {
      updateData['images'] = [json['imageUrl'] as String];
    }
    
    if (json['reward'] != null && (json['reward'] as String).isNotEmpty) {
      updateData['bounty'] = {
        'bounty_amount': int.tryParse(json['reward'] as String) ?? 0,
        'bounty_description': 'Imbalan',
      };
    } else {
      updateData['bounty'] = null;
    }
    
    updateData.remove('_id');

    final result = await reportsCollection.updateOne(
      where.id(objectId),
      {r'$set': updateData},
    );

    if (result.isSuccess) {
      return Response.json(body: {'message': 'Report updated successfully'});
    } else {
      return Response(
        statusCode: HttpStatus.internalServerError,
        body: 'Failed to update report.',
      );
    }
  } catch (e, s) {
    print('Error in _onPut: $e\n$s');
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'An internal server error occurred: $e',
    );
  }
}

Future<Response> _onDelete(RequestContext context, String id) async {
  try {
    final reportsCollection = await DatabaseService().reports;
    final objectId = ObjectId.fromHexString(id);

    final result = await reportsCollection.deleteOne(where.id(objectId));

    if (result.isSuccess && result.nRemoved == 1) {
      return Response(statusCode: HttpStatus.noContent);
    } else {
      return Response(
        statusCode: HttpStatus.notFound,
        body: 'Report with ID $id not found.',
      );
    }
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'An internal server error occurred: $e',
    );
  }
}