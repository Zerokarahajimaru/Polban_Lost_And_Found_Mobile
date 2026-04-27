import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/models/report.dart';
import 'package:backend/src/services/database_service.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _onGet(context);
    case HttpMethod.post:
      return _onPost(context);
    case HttpMethod.delete:
    case HttpMethod.put:
    case HttpMethod.patch:
    case HttpMethod.head:
    case HttpMethod.options:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _onGet(RequestContext context) async {
  try {
    final dbService = context.read<DatabaseService>();
    final reports = await dbService.reports.find().toList();
    
    return Response.json(
      body: {
        'status': 'success',
        'data': reports,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'status': 'error', 'message': e.toString()},
    );
  }
}

Future<Response> _onPost(RequestContext context) async {
  try {
    final dbService = context.read<DatabaseService>();
    final json = await context.request.json() as Map<String, dynamic>;

    final report = ReportModel(
      userId: json['userId'] as String? ?? '',
      namaBarang: json['title'] as String? ?? 'Tanpa Judul',
      kategoriBarang: json['category'] as String? ?? 'Umum',
      statusPostingan: json['status'] as String? ?? 'pending',
      deskripsiBarang: json['description'] as String? ?? '',
      lokasiKehilangan: json['location'] as String? ?? '',
      warnaBarang: json['color'] as String? ?? '',
      images: json['imageUrl'] != null ? [json['imageUrl'] as String] : [],
      lastActivityAt: DateTime.now().toUtc(),
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
      isSynced: true,
      reportCount: 0,
      bounty: json['reward'] != null 
          ? BountyModel(amount: int.tryParse(json['reward'].toString()) ?? 0, description: '') 
          : null,
    );

    final result = await dbService.reports.insertOne(report.toMap());

    if (result.isSuccess) {
      return Response.json(
        statusCode: HttpStatus.created,
        body: {
          'status': 'success',
          'message': 'Laporan berhasil dibuat',
          'data': report.toMap(),
        },
      );
    } else {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'status': 'error', 'message': 'Gagal menyimpan ke database'},
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'status': 'error', 'message': e.toString()},
    );
  }
}