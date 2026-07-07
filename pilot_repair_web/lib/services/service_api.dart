import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/service.dart';
import 'dart:async';

class ServiceApi {
  static const String baseUrl = 'http://localhost:8080';
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

  static Future<void> createMerk(String namaMerk) async {
    try {
      print('Creating merk: $namaMerk');
      final response = await http.post(
        Uri.parse('$baseUrl/merk'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nama_merk': namaMerk}),
      );
      print('Create Merk Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Gagal membuat merk: ${response.body}');
      }
    } catch (e) {
      print('Error creating merk: $e');
      rethrow;
    }
  }

  static Future<void> updateMerk(int id, String namaMerk) async {
    try {
      print('Updating merk: $id with name: $namaMerk');
      final response = await http.put(
        Uri.parse('$baseUrl/merk/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nama_merk': namaMerk}),
      );
      print('Update Merk Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Gagal mengupdate merk: ${response.body}');
      }
    } catch (e) {
      print('Error updating merk: $e');
      rethrow;
    }
  }

  static Future<void> deleteMerk(int id) async {
    try {
      print('Deleting merk: $id');
      final response = await http.delete(
        Uri.parse('$baseUrl/merk/$id'),
      );
      print('Delete Merk Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus merk: ${response.body}');
      }
    } catch (e) {
      print('Error deleting merk: $e');
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

  static Future<void> createSeri(int idMerk, String namaSeri) async {
    try {
      print('Creating seri: $namaSeri for merk: $idMerk');
      final response = await http.post(
        Uri.parse('$baseUrl/seri'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_merk': idMerk,
          'nama_seri': namaSeri,
        }),
      );
      print('Create Seri Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Gagal membuat seri: ${response.body}');
      }
    } catch (e) {
      print('Error creating seri: $e');
      rethrow;
    }
  }

  static Future<void> updateSeri(int id, int idMerk, String namaSeri) async {
    try {
      print('Updating seri: $id with name: $namaSeri for merk: $idMerk');
      final response = await http.put(
        Uri.parse('$baseUrl/seri/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_merk': idMerk,
          'nama_seri': namaSeri,
        }),
      );
      print('Update Seri Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Gagal mengupdate seri: ${response.body}');
      }
    } catch (e) {
      print('Error updating seri: $e');
      rethrow;
    }
  }

  static Future<void> deleteSeri(int id) async {
    try {
      print('Deleting seri: $id');
      final response = await http.delete(
        Uri.parse('$baseUrl/seri/$id'),
      );
      print('Delete Seri Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus seri: ${response.body}');
      }
    } catch (e) {
      print('Error deleting seri: $e');
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

  static Future<String> uploadIconWeb(html.File file, String namaLayanan) async {
    // Ubah nama file: nama layanan (spasi jadi underscore) + ekstensi file asli
    final ext = file.name.contains('.') ? file.name.substring(file.name.lastIndexOf('.')) : '';
    final safeName = namaLayanan.trim().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '').toLowerCase();
    final newFileName = '$safeName$ext';
    final uri = Uri.parse('http://localhost:8080/upload_icon');
    final request = http.MultipartRequest('POST', uri);
    final reader = html.FileReader();
    final completer = Completer<List<int>>();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((event) {
      completer.complete(reader.result as List<int>);
    });
    final bytes = await completer.future;
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: newFileName, contentType: MediaType('image', 'png')));
    final response = await request.send();
    final respStr = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final fileName = jsonDecode(respStr)['file_name'];
      return fileName;
    } else {
      String errorMsg = 'Gagal upload icon';
      try {
        final err = jsonDecode(respStr);
        if (err is Map && err['error'] != null) errorMsg = err['error'];
      } catch (_) {
        errorMsg = respStr;
      }
      errorMsg = 'Status: ${response.statusCode}\n$errorMsg';
      throw Exception(errorMsg);
    }
  }

  static Future<void> createLayanan(String nama, String iconFileName) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/layanan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nama_layanan': nama, 'icon_layanan': iconFileName}),
    );
    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal tambah layanan');
    }
  }

  static Future<void> updateLayanan(int id, String nama, String? iconFileName) async {
    final response = await http.put(
      Uri.parse('http://localhost:8080/layanan/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nama_layanan': nama, 'icon_layanan': iconFileName}),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Gagal update layanan');
    }
  }

  static Future<void> deleteLayanan(int id) async {
    try {
      print('Deleting layanan: $id');
      final response = await http.delete(
        Uri.parse('$baseUrl/layanan/$id'),
      );
      print('Delete Layanan Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus layanan: ${response.body}');
      }
    } catch (e) {
      print('Error deleting layanan: $e');
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

  // Get all kerusakan (for web app)
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

  static Future<void> createKerusakan(int idLayanan, String namaKerusakan) async {
    try {
      print('Creating kerusakan: $namaKerusakan for layanan: $idLayanan');
      final response = await http.post(
        Uri.parse('$baseUrl/kerusakan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_layanan': idLayanan,
          'nama_kerusakan': namaKerusakan,
        }),
      );
      print('Create Kerusakan Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Gagal membuat kerusakan: ${response.body}');
      }
    } catch (e) {
      print('Error creating kerusakan: $e');
      rethrow;
    }
  }

  static Future<void> updateKerusakan(int id, int idLayanan, String namaKerusakan) async {
    try {
      print('Updating kerusakan: $id with name: $namaKerusakan for layanan: $idLayanan');
      final response = await http.put(
        Uri.parse('$baseUrl/kerusakan/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_layanan': idLayanan,
          'nama_kerusakan': namaKerusakan,
        }),
      );
      print('Update Kerusakan Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Gagal mengupdate kerusakan: ${response.body}');
      }
    } catch (e) {
      print('Error updating kerusakan: $e');
      rethrow;
    }
  }

  static Future<void> deleteKerusakan(int id) async {
    try {
      print('Deleting kerusakan: $id');
      final response = await http.delete(
        Uri.parse('$baseUrl/kerusakan/$id'),
      );
      print('Delete Kerusakan Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus kerusakan: ${response.body}');
      }
    } catch (e) {
      print('Error deleting kerusakan: $e');
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

  static Future<void> createJenisSparepart({
    required int idMerk,
    required int idSeri,
    required int idLayanan,
    required String namaJenis,
  }) async {
    try {
      print('Creating jenis sparepart: $namaJenis, idMerk: $idMerk, idSeri: $idSeri, idLayanan: $idLayanan');
      final response = await http.post(
        Uri.parse('$baseUrl/jenis_sparepart'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_merk': idMerk,
          'id_seri': idSeri,
          'id_layanan': idLayanan,
          'nama_jenis': namaJenis,
        }),
      );
      print('Create Jenis Sparepart Response: \\${response.statusCode} - \\${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Gagal membuat jenis sparepart: \\${response.body}');
      }
    } catch (e) {
      print('Error creating jenis sparepart: $e');
      rethrow;
    }
  }

  static Future<void> updateJenisSparepart(int id, String namaJenis, int idMerk, int idSeri, int idLayanan) async {
    try {
      print('Updating jenis sparepart: $id with name: $namaJenis, idMerk: $idMerk, idSeri: $idSeri, idLayanan: $idLayanan');
      final response = await http.put(
        Uri.parse('$baseUrl/jenis_sparepart/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nama_jenis': namaJenis,
          'id_merk': idMerk,
          'id_seri': idSeri,
          'id_layanan': idLayanan,
        }),
      );
      print('Update Jenis Sparepart Response: [200~[200~${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Gagal mengupdate jenis sparepart: ${response.body}');
      }
    } catch (e) {
      print('Error updating jenis sparepart: $e');
      rethrow;
    }
  }

  static Future<void> deleteJenisSparepart(int id) async {
    try {
      print('Deleting jenis sparepart: $id');
      final response = await http.delete(
        Uri.parse('$baseUrl/jenis_sparepart/$id'),
      );
      print('Delete Jenis Sparepart Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus jenis sparepart: ${response.body}');
      }
    } catch (e) {
      print('Error deleting jenis sparepart: $e');
      rethrow;
    }
  }

  // Harga Layanan
  static Future<List<HargaLayanan>> getHargaLayanan() async {
    try {
      print('Fetching harga layanan');
      final response = await http.get(Uri.parse('$baseUrl/harga_layanan'));
      print('Get Harga Layanan Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => HargaLayanan.fromJson(json)).toList();
      }
      throw Exception('Gagal mengambil data harga layanan: ${response.body}');
    } catch (e) {
      print('Error fetching harga layanan: $e');
      rethrow;
    }
  }

  static Future<void> createHargaLayanan(HargaLayanan harga) async {
    try {
      print('Creating harga layanan: ${harga.toJson()}');
      final response = await http.post(
        Uri.parse('$baseUrl/harga_layanan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(harga.toJson()),
      );
      print('Create Harga Layanan Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Gagal membuat harga layanan: ${response.body}');
      }
    } catch (e) {
      print('Error creating harga layanan: $e');
      rethrow;
    }
  }

  static Future<void> updateHargaLayanan(HargaLayanan harga) async {
    try {
      print('Updating harga layanan: ${harga.toJson()}');
      final response = await http.put(
        Uri.parse('$baseUrl/harga_layanan/${harga.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(harga.toJson()),
      );
      print('Update Harga Layanan Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Gagal mengupdate harga layanan: ${response.body}');
      }
    } catch (e) {
      print('Error updating harga layanan: $e');
      rethrow;
    }
  }

  static Future<void> deleteHargaLayanan(int id) async {
    try {
      print('Deleting harga layanan: $id');
      final response = await http.delete(
        Uri.parse('$baseUrl/harga_layanan/$id'),
      );
      print('Delete Harga Layanan Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus harga layanan: ${response.body}');
      }
    } catch (e) {
      print('Error deleting harga layanan: $e');
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

  static Future<void> createHargaSparepart(HargaSparepart harga) async {
    try {
      print('Creating harga sparepart: ${harga.toJson()}');
      final response = await http.post(
        Uri.parse('$baseUrl/harga_sparepart'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(harga.toJson()),
      );
      print('Create Harga Sparepart Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode != 201) {
        throw Exception('Gagal membuat harga sparepart: ${response.body}');
      }
    } catch (e) {
      print('Error creating harga sparepart: ${e}');
      rethrow;
    }
  }

  static Future<void> updateHargaSparepart(HargaSparepart harga) async {
    try {
      print('Updating harga sparepart: ${harga.toJson()}');
      final response = await http.put(
        Uri.parse('$baseUrl/harga_sparepart/${harga.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(harga.toJson()),
      );
      print('Update Harga Sparepart Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Gagal mengupdate harga sparepart: ${response.body}');
      }
    } catch (e) {
      print('Error updating harga sparepart: ${e}');
      rethrow;
    }
  }

  static Future<void> deleteHargaSparepart(int id) async {
    try {
      print('Deleting harga sparepart: ${id}');
      final response = await http.delete(
        Uri.parse('$baseUrl/harga_sparepart/${id}'),
      );
      print('Delete Harga Sparepart Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus harga sparepart: ${response.body}');
      }
    } catch (e) {
      print('Error deleting harga sparepart: ${e}');
      rethrow;
    }
  }

  static Future<void> deleteIcon(String fileName) async {
    final response = await http.delete(Uri.parse('http://localhost:8080/assets/database/$fileName'));
    if (response.statusCode != 200) {
      throw Exception('Gagal hapus icon: ${response.body}');
    }
  }
} 