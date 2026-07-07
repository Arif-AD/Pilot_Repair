// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      technicianId: json['technician_id'] as int?,
      idMerk: json['id_merk'] as int,
      namaMerk: json['nama_merk'] as String?,
      idSeri: json['id_seri'] as int,
      namaSeri: json['nama_seri'] as String?,
      idLayanan: json['id_layanan'] as int,
      namaLayanan: json['nama_layanan'] as String?,
      idKerusakan: json['id_kerusakan'] as int?,
      namaKerusakan: json['nama_kerusakan'] as String?,
      idJenisSparepart: json['id_jenis_sparepart'] as int,
      namaJenis: json['nama_jenis'] as String?,
      deskripsiKerusakan: json['deskripsi_kerusakan'] as String?,
      hargaLayanan: json['harga_layanan'] as int?,
      status: json['status'] as String? ?? 'waiting',
      waitingCreatedAt: json['waiting_created_at'] == null
          ? null
          : DateTime.parse(json['waiting_created_at'] as String),
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
      'harga_layanan': instance.hargaLayanan,
      'status': instance.status,
      'waiting_created_at': instance.waitingCreatedAt?.toIso8601String(),
      'payment_method': instance.paymentMethod,
      'payment_status': instance.paymentStatus,
      'payment_token': instance.paymentToken,
      'payment_url': instance.paymentUrl,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    }; 