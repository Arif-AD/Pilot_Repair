import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

@JsonSerializable()
class Merk {
  final int id;
  @JsonKey(name: 'nama_merk')
  final String namaMerk;

  Merk({required this.id, required this.namaMerk});

  factory Merk.fromJson(Map<String, dynamic> json) => _$MerkFromJson(json);
  Map<String, dynamic> toJson() => _$MerkToJson(this);
}

@JsonSerializable()
class Seri {
  final int id;
  @JsonKey(name: 'id_merk')
  final int idMerk;
  @JsonKey(name: 'nama_seri')
  final String namaSeri;

  Seri({required this.id, required this.idMerk, required this.namaSeri});

  factory Seri.fromJson(Map<String, dynamic> json) => _$SeriFromJson(json);
  Map<String, dynamic> toJson() => _$SeriToJson(this);
}

@JsonSerializable()
class Layanan {
  final int id;
  @JsonKey(name: 'nama_layanan')
  final String namaLayanan;
  @JsonKey(name: 'icon_layanan')
  final String? iconLayanan;

  Layanan({required this.id, required this.namaLayanan, this.iconLayanan});

  factory Layanan.fromJson(Map<String, dynamic> json) => _$LayananFromJson(json);
  Map<String, dynamic> toJson() => _$LayananToJson(this);
}

@JsonSerializable()
class Kerusakan {
  final int id;
  @JsonKey(name: 'id_layanan')
  final int idLayanan;
  @JsonKey(name: 'nama_kerusakan')
  final String namaKerusakan;

  Kerusakan({required this.id, required this.idLayanan, required this.namaKerusakan});

  factory Kerusakan.fromJson(Map<String, dynamic> json) => _$KerusakanFromJson(json);
  Map<String, dynamic> toJson() => _$KerusakanToJson(this);
}

@JsonSerializable()
class JenisSparepart {
  final int id;
  @JsonKey(name: 'id_layanan')
  final int idLayanan;
  @JsonKey(name: 'nama_layanan')
  final String namaLayanan;
  @JsonKey(name: 'nama_jenis')
  final String namaJenis;

  // Kolom opsional (nullable)
  @JsonKey(name: 'id_merk')
  final int? idMerk;
  @JsonKey(name: 'nama_merk')
  final String? namaMerk;
  @JsonKey(name: 'id_seri')
  final int? idSeri;
  @JsonKey(name: 'nama_seri')
  final String? namaSeri;

  JenisSparepart({
    required this.id,
    required this.idLayanan,
    required this.namaLayanan,
    required this.namaJenis,
    this.idMerk,
    this.namaMerk,
    this.idSeri,
    this.namaSeri,
  });

  factory JenisSparepart.fromJson(Map<String, dynamic> json) => JenisSparepart(
    id: json['id'] as int,
    idLayanan: json['id_layanan'] as int,
    namaLayanan: json['nama_layanan'] as String,
    namaJenis: json['nama_jenis'] as String,
    idMerk: json['id_merk'] as int?,
    namaMerk: json['nama_merk'] as String?,
    idSeri: json['id_seri'] as int?,
    namaSeri: json['nama_seri'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_layanan': idLayanan,
    'nama_layanan': namaLayanan,
    'nama_jenis': namaJenis,
    if (idMerk != null) 'id_merk': idMerk,
    if (namaMerk != null) 'nama_merk': namaMerk,
    if (idSeri != null) 'id_seri': idSeri,
    if (namaSeri != null) 'nama_seri': namaSeri,
  };
}

@JsonSerializable()
class HargaLayanan {
  final int id;
  final int idLayanan;
  final int idMerk;
  final int idSeri;
  final int idJenisSparepart;
  final int harga;

  HargaLayanan({
    required this.id,
    required this.idLayanan,
    required this.idMerk,
    required this.idSeri,
    required this.idJenisSparepart,
    required this.harga,
  });

  factory HargaLayanan.fromJson(Map<String, dynamic> json) => _$HargaLayananFromJson(json);
  Map<String, dynamic> toJson() => _$HargaLayananToJson(this);
}

@JsonSerializable()
class HargaSparepart {
  final int id;
  @JsonKey(name: 'id_merk')
  final int idMerk;
  @JsonKey(name: 'id_seri')
  final int idSeri;
  @JsonKey(name: 'id_layanan')
  final int idLayanan;
  @JsonKey(name: 'id_jenis_sparepart')
  final int idJenisSparepart;
  final int harga;

  HargaSparepart({
    required this.id,
    required this.idMerk,
    required this.idSeri,
    required this.idLayanan,
    required this.idJenisSparepart,
    required this.harga,
  });

  factory HargaSparepart.fromJson(Map<String, dynamic> json) => HargaSparepart(
    id: json['id'] as int,
    idMerk: json['id_merk'] as int,
    idSeri: json['id_seri'] as int,
    idLayanan: json['id_layanan'] as int,
    idJenisSparepart: json['id_jenis_sparepart'] as int,
    harga: json['harga'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_merk': idMerk,
    'id_seri': idSeri,
    'id_layanan': idLayanan,
    'id_jenis_sparepart': idJenisSparepart,
    'harga': harga,
  };
} 