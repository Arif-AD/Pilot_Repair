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
  @JsonKey(name: 'nama_jenis')
  final String namaJenis;

  JenisSparepart({required this.id, required this.namaJenis});

  factory JenisSparepart.fromJson(Map<String, dynamic> json) => _$JenisSparepartFromJson(json);
  Map<String, dynamic> toJson() => _$JenisSparepartToJson(this);
}

@JsonSerializable()
class HargaSparepart {
  final int id;
  @JsonKey(name: 'id_merk')
  final int idMerk;
  @JsonKey(name: 'nama_merk')
  final String? namaMerk;
  @JsonKey(name: 'id_seri')
  final int idSeri;
  @JsonKey(name: 'nama_seri')
  final String? namaSeri;
  @JsonKey(name: 'id_layanan')
  final int? idLayanan;
  @JsonKey(name: 'nama_layanan')
  final String? namaLayanan;
  @JsonKey(name: 'id_jenis_sparepart')
  final int idJenisSparepart;
  @JsonKey(name: 'nama_jenis')
  final String? namaJenis;
  final int harga;

  HargaSparepart({
    required this.id,
    required this.idMerk,
    this.namaMerk,
    required this.idSeri,
    this.namaSeri,
    this.idLayanan,
    this.namaLayanan,
    required this.idJenisSparepart,
    this.namaJenis,
    required this.harga,
  });

  factory HargaSparepart.fromJson(Map<String, dynamic> json) => _$HargaSparepartFromJson(json);
  Map<String, dynamic> toJson() => _$HargaSparepartToJson(this);
} 