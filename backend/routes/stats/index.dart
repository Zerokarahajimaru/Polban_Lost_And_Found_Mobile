import 'package:dart_frog/dart_frog.dart';
import 'package:backend/src/services/mongodb_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  try {
    // 1. Panggil static getter 'db' langsung menggunakan nama Class MongodbService, lalu beri 'await'
    final database = await MongodbService.db;
    
    // 2. Ambil koleksi reports dari database asli
    final collection = database.collection('reports');

    // 3. Ambil data mentah dan konversi tipenya secara eksplisit agar kebal dari error type/inference
    final rawData = await collection.find().toList();
    final List<Map<String, dynamic>> allReports = List<Map<String, dynamic>>.from(rawData);
    
    int lostCount = 0;
    int foundCount = 0;
    int claimedCount = 0;
    final Map<String, int> categories = {};
    final Map<String, int> locations = {};

    for (final report in allReports) {
      final status = (report['status'] ?? '').toString().toLowerCase();
      if (status == 'lost') {
        lostCount++;
      } else if (status == 'found') {
        foundCount++;
      }

      if (status == 'claimed' || status == 'resolved') {
        claimedCount++;
      }

      final category = (report['category'] ?? 'Lainnya').toString().trim();
      final validCategory = category.isEmpty ? 'Lainnya' : category;
      categories[validCategory] = (categories[validCategory] ?? 0) + 1;

      final location = (report['location'] ?? 'Lokasi Umum').toString().trim();
      final validLocation = location.isEmpty ? 'Lokasi Umum' : location;
      locations[validLocation] = (locations[validLocation] ?? 0) + 1;
    }

    return Response.json(
      body: {
        'totalReports': allReports.length,
        'totalLost': lostCount,
        'foundReports': foundCount,
        'totalClaimed': claimedCount,
        'reportsByCategory': categories,
        'reportsByLocation': locations,
      },
    );
  } catch (e) {
    return Response(statusCode: 500, body: 'Internal Server Error: $e');
  }
}