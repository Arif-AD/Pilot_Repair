// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Merk _$MerkFromJson(Map<String, dynamic> json) => Merk(
      id: (json['id'] as num).toInt(),
      namaMerk: json['nama_merk'] as String,
    );

Map<String, dynamic> _$MerkToJson(Merk instance) => <String, dynamic>{
      'id': instance.id,
      'nama_merk': instance.namaMerk,
    };

Seri _$SeriFromJson(Map<String, dynamic> json) => Seri(
      id: (json['id'] as num).toInt(),
      idMerk: (json['id_merk'] as num).toInt(),
      namaSeri: json['nama_seri'] as String,
    );

Map<String, dynamic> _$SeriToJson(Seri instance) => <String, dynamic>{
      'id': instance.id,
      'id_merk': instance.idMerk,
      'nama_seri': instance.namaSeri,
    };

Layanan _$LayananFromJson(Map<String, dynamic> json) => Layanan(
      id: (json['id'] as num).toInt(),
      namaLayanan: json['nama_layanan'] as String,
      iconLayanan: json['icon_layanan'] as String?,
    );

Map<String, dynamic> _$LayananToJson(Layanan instance) => <String, dynamic>{
      'id': instance.id,
      'nama_layanan': instance.namaLayanan,
      'icon_layanan': instance.iconLayanan,
    };

Kerusakan _$KerusakanFromJson(Map<String, dynamic> json) => Kerusakan(
      id: (json['id'] as num).toInt(),
      idLayanan: (json['id_layanan'] as num).toInt(),
      namaKerusakan: json['nama_kerusakan'] as String,
    );

Map<String, dynamic> _$KerusakanToJson(Kerusakan instance) => <String, dynamic>{
      'id': instance.id,
      'id_layanan': instance.idLayanan,
      'nama_kerusakan': instance.namaKerusakan,
    };

JenisSparepart _$JenisSparepartFromJson(Map<String, dynamic> json) =>
    JenisSparepart(
      id: (json['id'] as num).toInt(),
      idLayanan: (json['id_layanan'] as num).toInt(),
      namaLayanan: json['nama_layanan'] as String,
      namaJenis: json['nama_jenis'] as String,
      idMerk: (json['id_merk'] as num?)?.toInt(),
      namaMerk: json['nama_merk'] as String?,
      idSeri: (json['id_seri'] as num?)?.toInt(),
      namaSeri: json['nama_seri'] as String?,
    );

Map<String, dynamic> _$JenisSparepartToJson(JenisSparepart instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_layanan': instance.idLayanan,
      'nama_layanan': instance.namaLayanan,
      'nama_jenis': instance.namaJenis,
      'id_merk': instance.idMerk,
      'nama_merk': instance.namaMerk,
      'id_seri': instance.idSeri,
      'nama_seri': instance.namaSeri,
    };

HargaLayanan _$HargaLayananFromJson(Map<String, dynamic> json) => HargaLayanan(
      id: (json['id'] as num).toInt(),
      idLayanan: (json['idLayanan'] as num).toInt(),
      idMerk: (json['idMerk'] as num).toInt(),
      idSeri: (json['idSeri'] as num).toInt(),
      idJenisSparepart: (json['idJenisSparepart'] as num).toInt(),
      harga: (json['harga'] as num).toInt(),
    );

Map<String, dynamic> _$HargaLayananToJson(HargaLayanan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'idLayanan': instance.idLayanan,
      'idMerk': instance.idMerk,
      'idSeri': instance.idSeri,
      'idJenisSparepart': instance.idJenisSparepart,
      'harga': instance.harga,
    };

HargaSparepart _$HargaSparepartFromJson(Map<String, dynamic> json) =>
    HargaSparepart(
      id: (json['id'] as num).toInt(),
      idMerk: (json['id_merk'] as num).toInt(),
      idSeri: (json['id_seri'] as num).toInt(),
      idLayanan: (json['id_layanan'] as num).toInt(),
      idJenisSparepart: (json['id_jenis_sparepart'] as num).toInt(),
      harga: (json['harga'] as num).toInt(),
    );

Map<String, dynamic> _$HargaSparepartToJson(HargaSparepart instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_merk': instance.idMerk,
      'id_seri': instance.idSeri,
      'id_layanan': instance.idLayanan,
      'id_jenis_sparepart': instance.idJenisSparepart,
      'harga': instance.harga,
    };
