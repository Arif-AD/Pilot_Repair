import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080'; 

  static Future<void> addOrder(Order order) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(order.toJson()),
      );

      print('Add Order Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Gagal menambahkan pesanan: ${response.body}');
      }
    } catch (e) {
      print('Error adding order: $e');
      rethrow;
    }
  }

  static Future<void> updateOrder(int id, Order order) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(order.toJson()),
      );

      print('Update Order Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Gagal mengupdate pesanan: ${response.body}');
      }
    } catch (e) {
      print('Error updating order: $e');
      rethrow;
    }
  }

  static Future<List<Order>> fetchOrders() async {
    try {
      print('Fetching orders from: $baseUrl/orders');
      final response = await http.get(Uri.parse('$baseUrl/orders'));

      print('Fetch Orders Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil daftar pesanan: ${response.body}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      rethrow;
    }
  }

  static Future<void> deleteOrder(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/orders/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus pesanan');
    }
  }

  // Technician specific endpoints
  static Future<List<Order>> fetchPendingOrders() async {
    try {
      print('Fetching pending orders from: $baseUrl/orders/pending');
      final response = await http.get(Uri.parse('$baseUrl/orders/pending'));

      print('Fetch Pending Orders Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil daftar pesanan pending: ${response.body}');
      }
    } catch (e) {
      print('Error fetching pending orders: $e');
      rethrow;
    }
  }

  static Future<void> acceptOrder(int orderId, String technicianId) async {
    try {
      print('Accepting order: $orderId by technician: $technicianId');
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/accept'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'technicianId': technicianId,
        }),
      );

      print('Accept Order Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Gagal menerima pesanan: ${response.body}');
      }
    } catch (e) {
      print('Error accepting order: $e');
      rethrow;
    }
  }

  static Future<List<Order>> fetchTechnicianOrders(String technicianId) async {
    try {
      print('Fetching orders for technician: $technicianId');
      final response = await http.get(
        Uri.parse('$baseUrl/orders/technician/$technicianId'),
      );

      print('Fetch Technician Orders Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);
        return decoded.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil daftar pesanan teknisi: ${response.body}');
      }
    } catch (e) {
      print('Error fetching technician orders: $e');
      rethrow;
    }
  }

  static Future<void> completeOrder(int orderId) async {
    try {
      print('Completing order: $orderId');
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/complete'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Complete Order Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Gagal menyelesaikan pesanan: ${response.body}');
      }
    } catch (e) {
      print('Error completing order: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createPayment(int orderId, String paymentMethod) async {
    try {
      print('Creating payment for order: $orderId with method: $paymentMethod');
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'payment_method': paymentMethod,
        }),
      );

      print('Create Payment Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal membuat pembayaran: ${response.body}');
      }
    } catch (e) {
      print('Error creating payment: $e');
      rethrow;
    }
  }

  static Future<String> getPaymentStatus(int orderId) async {
    try {
      print('Getting payment status for order: $orderId');
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
      );

      print('Get Payment Status Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['payment_status'] ?? 'unpaid';
      } else {
        throw Exception('Gagal mendapatkan status pembayaran: ${response.body}');
      }
    } catch (e) {
      print('Error getting payment status: $e');
      rethrow;
    }
  }
} 