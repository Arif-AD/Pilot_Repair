import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pilot_repair/models/user.dart';

class AuthService {
  static const String _baseUrl = 'http://192.168.100.206:8080';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  static User? _currentUser;
  static String? _token;
  static bool _hasSeenOnboarding = false;
  static bool _useMemoryStorage = false;

  // Get current user
  static User? get currentUser => _currentUser;
  
  // Get current token
  static String? get token => _token;
  
  // Check if user is logged in
  static bool get isLoggedIn => _token != null && _currentUser != null;

  // Initialize auth service
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      final userData = prefs.getString(_userKey);
      _hasSeenOnboarding = prefs.getBool(_hasSeenOnboardingKey) ?? false;
      
      if (userData != null) {
        try {
          _currentUser = User.fromJson(jsonDecode(userData));
        } catch (e) {
          print('Error parsing user data: $e');
          await logout();
        }
      }
    } catch (e) {
      print('Error initializing auth service, using memory storage: $e');
      _useMemoryStorage = true;
      // Continue with memory storage
    }
  }

  // Update current user data
  static Future<void> updateCurrentUser(User updatedUser) async {
    _currentUser = updatedUser;
    await _saveToStorage();
  }

  // Check if user has seen onboarding
  static Future<bool> hasSeenOnboarding() async {
    if (_useMemoryStorage) {
      return _hasSeenOnboarding;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_hasSeenOnboardingKey) ?? false;
    } catch (e) {
      print('Error checking onboarding status: $e');
      return _hasSeenOnboarding;
    }
  }

  // Mark onboarding as seen
  static Future<void> markOnboardingAsSeen() async {
    _hasSeenOnboarding = true;
    
    if (_useMemoryStorage) {
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasSeenOnboardingKey, true);
    } catch (e) {
      print('Error marking onboarding as seen: $e');
    }
  }

  // Login
  static Future<bool> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);
        
        // Save to storage
        await _saveToStorage();
        
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Register (without auto-login)
  static Future<bool> register(String name, String phone, String password, String role, {String? address, double? latitude, double? longitude}) async {
    try {
      final Map<String, dynamic> requestBody = {
        'name': name,
        'phone': phone,
        'password': password,
        'role': role,
      };

      // Add address only if provided (for technicians)
      if (address != null && address.isNotEmpty) {
        requestBody['address'] = address;
      }
      if (latitude != null) {
        requestBody['latitude'] = latitude;
      }
      if (longitude != null) {
        requestBody['longitude'] = longitude;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        // Don't auto-login after registration
        // Just return success
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Save to storage (shared preferences or memory)
  static Future<void> _saveToStorage() async {
    if (_useMemoryStorage) {
      return; // Already saved in memory
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
    } catch (e) {
      print('Error saving to shared preferences: $e');
      _useMemoryStorage = true;
    }
  }

  // Logout
  static Future<void> logout() async {
    _token = null;
    _currentUser = null;
    
    if (_useMemoryStorage) {
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      print('Error clearing shared preferences: $e');
    }
  }

  // Check if authentication is required for an action
  static bool isAuthRequired(String action) {
    // Actions that require authentication
    const authRequiredActions = [
      'make_order',
      'view_orders',
      'edit_profile',
      'payment',
    ];
    
    return authRequiredActions.contains(action);
  }

  // Get auth headers for API requests
  static Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
} 