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
      namaJenis: json['nama_jenis'] as String,
    );

Map<String, dynamic> _$JenisSparepartToJson(JenisSparepart instance) =>
    <String, dynamic>{'id': instance.id, 'nama_jenis': instance.namaJenis};

HargaSparepart _$HargaSparepartFromJson(Map<String, dynamic> json) =>
    HargaSparepart(
      id: (json['id'] as num).toInt(),
      idMerk: (json['id_merk'] as num).toInt(),
      namaMerk: json['nama_merk'] as String?,
      idSeri: (json['id_seri'] as num).toInt(),
      namaSeri: json['nama_seri'] as String?,
      idLayanan: (json['id_layanan'] as num?)?.toInt(),
      namaLayanan: json['nama_layanan'] as String?,
      idJenisSparepart: (json['id_jenis_sparepart'] as num).toInt(),
      namaJenis: json['nama_jenis'] as String?,
      harga: (json['harga'] as num).toInt(),
    );

Map<String, dynamic> _$HargaSparepartToJson(HargaSparepart instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id_merk': instance.idMerk,
      'nama_merk': instance.namaMerk,
      'id_seri': instance.idSeri,
      'nama_seri': instance.namaSeri,
      'id_layanan': instance.idLayanan,
      'nama_layanan': instance.namaLayanan,
      'id_jenis_sparepart': instance.idJenisSparepart,
      'nama_jenis': instance.namaJenis,
      'harga': instance.harga,
    };
