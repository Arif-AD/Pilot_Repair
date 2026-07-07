class LcdOrder {
  final int? id;
  final String? brand;
  final String? series;
  final String? damageType;
  final String? lcdQuality;
  final double? price;
  final String? status; // 'pending', 'accepted', 'completed'
  final String? technicianId;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? paymentToken;
  final String? paymentUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LcdOrder({
    this.id,
    this.brand,
    this.series,
    this.damageType,
    this.lcdQuality,
    this.price,
    this.status = 'pending',
    this.technicianId,
    this.paymentMethod = 'cash',
    this.paymentStatus = 'unpaid',
    this.paymentToken,
    this.paymentUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory LcdOrder.fromJson(Map<String, dynamic> json) {
    return LcdOrder(
      id: json['id'] as int?,
      brand: json['brand'] as String?,
      series: json['series'] as String?,
      damageType: json['damageType'] as String?,
      lcdQuality: json['lcdQuality'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'pending',
      technicianId: json['technicianId'] as String?,
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      paymentStatus: json['paymentStatus'] as String? ?? 'unpaid',
      paymentToken: json['paymentToken'] as String?,
      paymentUrl: json['paymentUrl'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'series': series,
      'damageType': damageType,
      'lcdQuality': lcdQuality,
      'price': price,
      'status': status,
      'technicianId': technicianId,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentToken': paymentToken,
      'paymentUrl': paymentUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
