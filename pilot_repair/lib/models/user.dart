class User {
  final int id;
  final String phone;
  final String? email;
  final String name;
  final String role;
  final String? address;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;

  User({
    required this.id,
    required this.phone,
    this.email,
    required this.name,
    required this.role,
    this.address,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phone: json['phone'],
      email: json['email'],
      name: json['full_name'] ?? json['name'],
      role: json['role'],
      address: json['address'],
      createdAt: DateTime.parse(json['created_at']),
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'full_name': name,
      'role': role,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  bool get isCustomer => role == 'customer';
  bool get isTechnician => role == 'technician';
  
  // Check if profile is complete
  bool get isProfileComplete {
    return name.isNotEmpty && 
           (email != null && email!.isNotEmpty) && 
           (address != null && address!.isNotEmpty);
  }
} 