import 'package:json_annotation/json_annotation.dart';

part 'lcd_order.g.dart';

@JsonSerializable()
class LcdOrder {

  LcdOrder({
    this.id,
    required this.brand,
    required this.series,
    required this.damageType,
    required this.lcdQuality,
    required this.price,
    this.status = 'pending',
    this.technicianId,
    this.paymentMethod = 'cash',
    this.paymentStatus = 'unpaid',
    this.paymentToken,
    this.paymentUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory LcdOrder.fromJson(Map<String, dynamic> json) => _$LcdOrderFromJson(json);
  final int? id;
  final String brand;
  final String series;
  final String damageType;
  final String lcdQuality;
  final double price;
  final String status;
  final String? technicianId;
  final String paymentMethod;
  final String paymentStatus;
  final String? paymentToken;
  final String? paymentUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  Map<String, dynamic> toJson() => _$LcdOrderToJson(this);
}
