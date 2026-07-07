// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  technicianId: (json['technician_id'] as num?)?.toInt(),
  idMerk: (json['id_merk'] as num).toInt(),
  namaMerk: json['nama_merk'] as String?,
  idSeri: (json['id_seri'] as num).toInt(),
  namaSeri: json['nama_seri'] as String?,
  idLayanan: (json['id_layanan'] as num).toInt(),
  namaLayanan: json['nama_layanan'] as String?,
  idKerusakan: (json['id_kerusakan'] as num?)?.toInt(),
  namaKerusakan: json['nama_kerusakan'] as String?,
  idJenisSparepart: (json['id_jenis_sparepart'] as num).toInt(),
  namaJenis: json['nama_jenis'] as String?,
  deskripsiKerusakan: json['deskripsi_kerusakan'] as String?,
  status: json['status'] as String? ?? 'pending',
  hargaLayanan: (json['harga_layanan'] as num?)?.toInt(),
  paymentMethod: json['payment_method'] as String? ?? 'cash',
  paymentStatus: json['payment_status'] as String? ?? 'unpaid',
  paymentToken: json['payment_token'] as String?,
  paymentUrl: json['payment_url'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  waitingCreatedAt: json['waiting_created_at'] == null
      ? null
      : DateTime.parse(json['waiting_created_at'] as String),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'technician_id': instance.technicianId,
  'id_merk': instance.idMerk,
  'nama_merk': instance.namaMerk,
  'id_seri': instance.idSeri,
  'nama_seri': instance.namaSeri,
  'id_layanan': instance.idLayanan,
  'nama_layanan': instance.namaLayanan,
  'id_kerusakan': instance.idKerusakan,
  'nama_kerusakan': instance.namaKerusakan,
  'id_jenis_sparepart': instance.idJenisSparepart,
  'nama_jenis': instance.namaJenis,
  'deskripsi_kerusakan': instance.deskripsiKerusakan,
  'status': instance.status,
  'harga_layanan': instance.hargaLayanan,
  'payment_method': instance.paymentMethod,
  'payment_status': instance.paymentStatus,
  'payment_token': instance.paymentToken,
  'payment_url': instance.paymentUrl,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'waiting_created_at': instance.waitingCreatedAt?.toIso8601String(),
};
