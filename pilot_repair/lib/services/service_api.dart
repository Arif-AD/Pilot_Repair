import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service.dart';

class ServiceApi {
  static const String baseUrl = 'http://192.168.100.206:8080';

  // Merk
  static Future<List<Merk>> getMerk() async {
    try {
      print('Fetching merk from: $baseUrl/merk');
      final response = await http.get(Uri.parse('$baseUrl/merk'));
      print('Get Merk Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Merk.fromJson(json)).toList();
      }
      throw Exception('Gagal mengambil data merk: ${response.body}');
    } catch (e) {
      print('Error fetching merk: $e');
      rethrow;
    }
  }

  // Seri
  static Future<List<Seri>> getSeri(int idMerk) async {
    try {
      print('Fetching seri for merk: $idMerk');
      final url = idMerk == 0 
          ? Uri.parse('$baseUrl/seri')
          : Uri.parse('$baseUrl/seri?merk_id=$idMerk');
      final response = await http.get(url);
      print('Get Seri Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Seri.fromJson(json)).toList();
      }
      throw Exception('Gagal mengambil data seri: ${response.body}');
    } catch (e) {
      print('Error fetching seri: $e');
      rethrow;
    }
  }

  // Layanan
  static Future<List<Layanan>> getLayanan() async {
    try {
      print('Fetching layanan');
      final response = await http.get(Uri.parse('$baseUrl/layanan'));
      print('Get Layanan Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Layanan.fromJson(json)).toList();
      }
      throw Exception('Gagal mengambil data layanan: ${response.body}');
    } catch (e) {
      print('Error fetching layanan: $e');
      rethrow;
    }
  }

  // Kerusakan
  static Future<List<Kerusakan>> getKerusakan(int idLayanan) async {
    try {
      print('Fetching kerusakan for layanan: $idLayanan');
      String url = '$baseUrl/kerusakan';
      if (idLayanan > 0) {
        url += '?layanan_id=$idLayanan';
      }
      final response = await http.get(Uri.parse(url));
      print('Get Kerusakan Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Kerusakan.fromJson(json)).toList();
      }
      throw Exception('Gagal mengambil data kerusakan: ${response.body}');
    } catch (e) {
      print('Error fetching kerusakan: $e');
      rethrow;
    }
  }

  // Get all kerusakan (for mobile app)
  static Future<List<Kerusakan>> getAllKerusakan() async {
    try {
      print('Fetching all kerusakan');
      final response = await http.get(Uri.parse('$baseUrl/kerusakan'));
      print('Get All Kerusakan Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Kerusakan.fromJson(json)).toList();
      }
      throw Exception('Gagal mengambil data kerusakan: ${response.body}');
    } catch (e) {
      print('Error fetching all kerusakan: $e');
      rethrow;
    }
  }

  // Jenis Sparepart
  static Future<List<JenisSparepart>> getJenisSparepart() async {
    try {
      print('Fetching jenis sparepart');
      final response = await http.get(Uri.parse('$baseUrl/jenis_sparepart'));
      print('Get Jenis Sparepart Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => JenisSparepart.fromJson(json)).toList();
      }
      throw Exception('Gagal mengambil data jenis sparepart: ${response.body}');
    } catch (e) {
      print('Error fetching jenis sparepart: $e');
      rethrow;
    }
  }

  // Harga Sparepart
  static Future<List<HargaSparepart>> getHargaSparepart() async {
    try {
      print('Fetching harga sparepart');
      final response = await http.get(Uri.parse('$baseUrl/harga_sparepart'));
      print('Get Harga Sparepart Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => HargaSparepart.fromJson(json)).toList();
      }
      throw Exception('Gagal mengambil data harga sparepart: ${response.body}');
    } catch (e) {
      print('Error fetching harga sparepart: ${e}');
      rethrow;
    }
  }

  static Future<List<Layanan>> getLayananList() async {
    try {
      final response = await http.get(Uri.parse(baseUrl + '/layanan'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Layanan.fromJson(e)).toList();
      } else {
        print('Gagal mengambil data layanan: status ${response.statusCode}, body: ${response.body}');
        throw Exception('Gagal mengambil data layanan');
      }
    } catch (e) {
      print('Error getLayananList: $e');
      rethrow;
    }
  }
} 