import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  final int? id;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'technician_id')
  final int? technicianId;
  @JsonKey(name: 'id_merk')
  final int idMerk;
  @JsonKey(name: 'nama_merk')
  final String? namaMerk;
  @JsonKey(name: 'id_seri')
  final int idSeri;
  @JsonKey(name: 'nama_seri')
  final String? namaSeri;
  @JsonKey(name: 'id_layanan')
  final int idLayanan;
  @JsonKey(name: 'nama_layanan')
  final String? namaLayanan;
  @JsonKey(name: 'id_kerusakan')
  final int? idKerusakan;
  @JsonKey(name: 'nama_kerusakan')
  final String? namaKerusakan;
  @JsonKey(name: 'id_jenis_sparepart')
  final int idJenisSparepart;
  @JsonKey(name: 'nama_jenis')
  final String? namaJenis;
  @JsonKey(name: 'deskripsi_kerusakan')
  final String? deskripsiKerusakan;
  @JsonKey(name: 'harga_layanan')
  final int? hargaLayanan;
  final String status;
  @JsonKey(name: 'waiting_created_at')
  final DateTime? waitingCreatedAt;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
  @JsonKey(name: 'payment_token')
  final String? paymentToken;
  @JsonKey(name: 'payment_url')
  final String? paymentUrl;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Order({
    this.id,
    this.userId,
    this.technicianId,
    required this.idMerk,
    this.namaMerk,
    required this.idSeri,
    this.namaSeri,
    required this.idLayanan,
    this.namaLayanan,
    this.idKerusakan,
    this.namaKerusakan,
    required this.idJenisSparepart,
    this.namaJenis,
    this.deskripsiKerusakan,
    this.hargaLayanan,
    this.status = 'waiting',
    this.waitingCreatedAt,
    this.paymentMethod = 'cash',
    this.paymentStatus = 'unpaid',
    this.paymentToken,
    this.paymentUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
} 