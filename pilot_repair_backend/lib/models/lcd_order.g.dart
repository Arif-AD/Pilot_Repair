// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lcd_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LcdOrder _$LcdOrderFromJson(Map<String, dynamic> json) => LcdOrder(
      id: (json['id'] as num?)?.toInt(),
      brand: json['brand'] as String,
      series: json['series'] as String,
      damageType: json['damageType'] as String,
      lcdQuality: json['lcdQuality'] as String,
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      technicianId: json['technicianId'] as String?,
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      paymentStatus: json['paymentStatus'] as String? ?? 'unpaid',
      paymentToken: json['paymentToken'] as String?,
      paymentUrl: json['paymentUrl'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LcdOrderToJson(LcdOrder instance) => <String, dynamic>{
      'id': instance.id,
      'brand': instance.brand,
      'series': instance.series,
      'damageType': instance.damageType,
      'lcdQuality': instance.lcdQuality,
      'price': instance.price,
      'status': instance.status,
      'technicianId': instance.technicianId,
      'paymentMethod': instance.paymentMethod,
      'paymentStatus': instance.paymentStatus,
      'paymentToken': instance.paymentToken,
      'paymentUrl': instance.paymentUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
