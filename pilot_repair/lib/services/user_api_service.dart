import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pilot_repair/services/auth_service.dart';
import '../models/user.dart';

class UserApiService {
  static const String baseUrl = 'http://192.168.100.206:8080';

  // Get user profile
  static Future<User> getUserProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          ...AuthService.getAuthHeaders(),
        },
      );

      print('Get User Profile Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Gagal mengambil profil user');
      }
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow;
    }
  }

  // Update user profile
  static Future<User> updateUserProfile(int userId, {
    required String name,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          ...AuthService.getAuthHeaders(),
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'address': address,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        }),
      );

      print('Update User Profile Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Gagal mengupdate profil user');
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Change password
  static Future<void> changePassword(int userId, {
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/password'),
        headers: {
          'Content-Type': 'application/json',
          ...AuthService.getAuthHeaders(),
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      print('Change Password Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Gagal mengubah password');
      }
    } catch (e) {
      print('Error changing password: $e');
      rethrow;
    }
  }

  // Validate token (optional - for checking if token is still valid)
  static Future<bool> validateToken() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/users/${user.id}'),
        headers: AuthService.getAuthHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error validating token: $e');
      return false;
    }
  }
} 
 