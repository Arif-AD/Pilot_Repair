import 'package:flutter/material.dart';
import 'package:pilot_repair/models/order.dart';
import 'package:pilot_repair/models/service.dart';
import 'package:pilot_repair/services/api_service.dart';
import 'package:pilot_repair/services/service_api.dart';
import 'package:pilot_repair/services/auth_service.dart';
import 'package:pilot_repair/widgets/auth_prompt_dialog.dart';
import 'package:marquee/marquee.dart';

class OrderPage extends StatefulWidget {
  final Order? order;
  final Layanan? layanan;

  const OrderPage({super.key, this.order, this.layanan});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Merk? _selectedMerk;
  Seri? _selectedSeri;
  Layanan? _selectedLayanan;
  Kerusakan? _selectedKerusakan;
  JenisSparepart? _selectedJenisSparepart;
  double? _selectedPrice;
  double? _selectedHargaLayanan;
  String _manualKerusakanText = '';

  List<HargaSparepart> _hargaSparepartList = [];
  List<Merk> _merkList = [];
  List<Seri> _seriList = [];
  List<Layanan> _layananList = [];
  List<Kerusakan> _kerusakanList = [];
  List<JenisSparepart> _jenisSparepartList = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _manualKerusakanController = TextEditingController();
  Kerusakan? _lainnyaKerusakan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _manualKerusakanController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hargaSparepart = await ServiceApi.getHargaSparepart();
      final layananDb = await ServiceApi.getLayananList();
      // Generate unique Merk, Seri, JenisSparepart dari hargaSparepart
      final merkMap = <int, Merk>{};
      final seriMap = <int, Seri>{};
      final jenisSparepartMap = <int, JenisSparepart>{};
      for (var h in hargaSparepart) {
        if (!merkMap.containsKey(h.idMerk)) {
          merkMap[h.idMerk] = Merk(id: h.idMerk, namaMerk: h.namaMerk ?? '');
        }
        if (!seriMap.containsKey(h.idSeri)) {
          seriMap[h.idSeri] = Seri(id: h.idSeri, idMerk: h.idMerk, namaSeri: h.namaSeri ?? '');
        }
        if (!jenisSparepartMap.containsKey(h.idJenisSparepart)) {
          jenisSparepartMap[h.idJenisSparepart] = JenisSparepart(id: h.idJenisSparepart, namaJenis: h.namaJenis ?? '');
        }
      }
      _merkList = merkMap.values.toList();
      _seriList = seriMap.values.toList();
      _jenisSparepartList = jenisSparepartMap.values.toList();
      _layananList = layananDb;
      _hargaSparepartList = hargaSparepart;
      _isLoading = false;

      // Set instance khusus 'Lainnya (isi manual)' setelah _layananList terisi
      if (_layananList.isNotEmpty) {
        _lainnyaKerusakan = Kerusakan(id: -999, idLayanan: _layananList.first.id, namaKerusakan: 'Lainnya (isi manual)');
      }

      // Set initial values if editing
      if (widget.order != null) {
        print('DEBUG deskripsiKerusakan dari order: \'${widget.order!.deskripsiKerusakan}\'');
        final merk = _merkList.where((m) => m.id == widget.order!.idMerk);
        if (merk.isNotEmpty) _selectedMerk = merk.first;
        final seri = _seriList.where((s) => s.id == widget.order!.idSeri);
        if (seri.isNotEmpty) _selectedSeri = seri.first;
        final layanan = _layananList.where((l) => l.id == widget.order!.idLayanan);
        if (layanan.isNotEmpty) _selectedLayanan = layanan.first;
        await _loadKerusakan(_selectedLayanan?.id);
        // Setelah _kerusakanList terisi, set _selectedKerusakan dan deskripsi
        final kerusakan = _kerusakanList.where((k) => k.id == widget.order!.idKerusakan);
        if (kerusakan.isNotEmpty) {
          _selectedKerusakan = kerusakan.first;
          _manualKerusakanText = '';
          _manualKerusakanController.text = '';
        } else if (widget.order!.idKerusakan == null) {
          // Pilih sumber deskripsi: deskripsi_kerusakan > nama_kerusakan
          final manualDesc = (widget.order!.deskripsiKerusakan?.isNotEmpty ?? false)
              ? widget.order!.deskripsiKerusakan!
              : (widget.order!.namaKerusakan ?? '');
          _lainnyaKerusakan = Kerusakan(
            id: -999,
            idLayanan: _selectedLayanan?.id ?? 0,
            namaKerusakan: 'Lainnya: $manualDesc',
          );
          _selectedKerusakan = _lainnyaKerusakan;
          _manualKerusakanText = manualDesc;
          _manualKerusakanController.text = manualDesc;
        } else {
          _lainnyaKerusakan = Kerusakan(
            id: -999,
            idLayanan: _selectedLayanan?.id ?? 0,
            namaKerusakan: 'Lainnya (isi manual)',
          );
          _selectedKerusakan = _lainnyaKerusakan;
          _manualKerusakanText = '';
          _manualKerusakanController.text = '';
        }
        final jenis = _jenisSparepartList.where((j) => j.id == widget.order!.idJenisSparepart);
        if (jenis.isNotEmpty) _selectedJenisSparepart = jenis.first;
        _updatePrice();
      } else if (widget.layanan != null) {
        // Pilih otomatis layanan sesuai yang diklik
        final layananSelected = _layananList.where((l) => l.id == widget.layanan!.id);
        if (layananSelected.isNotEmpty) _selectedLayanan = layananSelected.first;
        await _loadKerusakan(_selectedLayanan?.id);
      } else {
        // Pilih otomatis layanan id 1 jika ada
        final layanan1 = _layananList.where((l) => l.id == 1);
        if (layanan1.isNotEmpty) _selectedLayanan = layanan1.first;
        await _loadKerusakan(_selectedLayanan?.id);
      }
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Coba Lagi',
            onPressed: _loadData,
            textColor: Colors.white,
          ),
        ),
      );
    }
  }

  Future<void> _loadKerusakan(int? idLayanan) async {
    if (idLayanan == null) {
      setState(() {
        _kerusakanList = [];
      });
      return;
    }
    try {
      final kerusakan = await ServiceApi.getKerusakan(idLayanan);
      setState(() {
        _kerusakanList = kerusakan;
      });
    } catch (e) {
      setState(() {
        _kerusakanList = [];
      });
    }
  }

  List<Seri> getSeriByMerk(int? merkId) {
    if (merkId == null) return [];
    // Filter seri yang ada di harga sparepart dan sesuai merk
    final seriIds = _hargaSparepartList.where((h) => h.idMerk == merkId).map((h) => h.idSeri).toSet();
    return _seriList.where((s) => seriIds.contains(s.id)).toList();
  }

  List<JenisSparepart> getJenisSparepartByMerkSeriLayanan(int? merkId, int? seriId, int? layananId) {
    if (merkId == null || seriId == null || layananId == null) return [];
    final jenisIds = _hargaSparepartList
        .where((h) => h.idMerk == merkId && h.idSeri == seriId && h.idLayanan == layananId)
        .map((h) => h.idJenisSparepart)
        .toSet();
    return _jenisSparepartList.where((j) => jenisIds.contains(j.id)).toList();
  }

  void _updatePrice() {
    if (_selectedMerk != null && _selectedSeri != null && _selectedJenisSparepart != null) {
      final harga = _hargaSparepartList.firstWhere(
        (h) => h.idMerk == _selectedMerk!.id && 
               h.idSeri == _selectedSeri!.id && 
               h.idJenisSparepart == _selectedJenisSparepart!.id,
        orElse: () => HargaSparepart(
          id: 0,
          idMerk: _selectedMerk!.id,
          idSeri: _selectedSeri!.id,
          idJenisSparepart: _selectedJenisSparepart!.id,
          harga: 0,
        ),
      );
      setState(() {
        _selectedPrice = harga.harga.toDouble();
        _selectedHargaLayanan = _hitungHargaLayanan(harga.harga.toDouble());
      });
    }
  }

  double _hitungHargaLayanan(double hargaSparepart) {
    double margin = 0.0;
    double resiko = 0.0;
    double jasa = 75000.0;
    if (hargaSparepart < 100000) {
      margin = 0.70;
      resiko = 0.02;
    } else if (hargaSparepart < 200000) {
      margin = 0.60;
      resiko = 0.04;
    } else if (hargaSparepart < 300000) {
      margin = 0.50;
      resiko = 0.10;
    } else if (hargaSparepart < 400000) {
      margin = 0.45;
      resiko = 0.20;
    } else if (hargaSparepart < 600000) {
      margin = 0.40;
      resiko = 0.34;
    }
    double nilaiMargin = hargaSparepart * margin;
    double nilaiResiko = hargaSparepart * resiko;
    double total = hargaSparepart + nilaiMargin + nilaiResiko + jasa;
    return total;
  }

  bool _isFormValid() {
    final isManualKerusakan = _kerusakanList.isEmpty || (_selectedKerusakan != null && _selectedKerusakan!.id == -999);
    return _selectedMerk != null &&
        _selectedSeri != null &&
        _selectedLayanan != null &&
        _selectedJenisSparepart != null &&
        (
          (isManualKerusakan && _manualKerusakanController.text.trim().isNotEmpty) ||
          (!isManualKerusakan && _selectedKerusakan != null)
        );
  }

  void _saveOrder() async {
    // Check if user is logged in
    if (!AuthService.isLoggedIn) {
      showDialog(
        context: context,
        builder: (context) => const AuthPromptDialog(
          action: 'make_order',
          message: 'Anda harus login untuk membuat pesanan.',
        ),
      );
      return;
    }

    // Cek alamat pelanggan
    final user = AuthService.currentUser;
    if (user == null || user.address == null || user.address!.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Icon(Icons.location_off_rounded, color: Colors.redAccent, size: 26),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Alamat Belum Lengkap',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: const Text(
            'Silakan lengkapi alamat Anda di profil sebelum melakukan pemesanan.',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    if (_isFormValid()) {
      int? idKerusakan;
      String? deskripsiKerusakan;
      if (_selectedKerusakan != null && _selectedKerusakan!.id > 0) {
        // Pilihan dari dropdown
        idKerusakan = _selectedKerusakan!.id;
        deskripsiKerusakan = null;
      } else if (_selectedKerusakan != null && _selectedKerusakan!.id == -999) {
        // Pilihan 'Lainnya (isi manual)' -> ambil dari textbox
        idKerusakan = null;
        deskripsiKerusakan = _manualKerusakanController.text;
      } else if (_selectedKerusakan != null && _selectedKerusakan!.id <= 0) {
        // Input manual lain (misal kerusakanList kosong)
        idKerusakan = null;
        deskripsiKerusakan = _manualKerusakanController.text;
      }
      Order newOrder = Order(
        id: widget.order?.id,
        userId: AuthService.currentUser?.id,
        technicianId: widget.order?.technicianId,
        idMerk: _selectedMerk!.id,
        idSeri: _selectedSeri!.id,
        idLayanan: _selectedLayanan!.id,
        idKerusakan: idKerusakan,
        idJenisSparepart: _selectedJenisSparepart!.id,
        deskripsiKerusakan: deskripsiKerusakan,
        status: widget.order?.status ?? 'pending',
        createdAt: widget.order?.createdAt ?? DateTime.now(),
        hargaLayanan: _selectedHargaLayanan?.toInt() ?? 0,
      );

      try {
        if (widget.order == null) {
          await ApiService.addOrder(newOrder);
        } else {
          await ApiService.updateOrder(widget.order!.id!, newOrder);
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Berhasil'),
            content: const Text('Pesanan berhasil disimpan!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua pilihan!')),
      );
    }
  }

  InputDecoration _kerusakanInputDecoration() {
    return InputDecoration(
      hintText: 'Contoh : Layar Pecah, Baterai Boros, dll',
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F5FF),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F5FF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 12),
              Text('Error: $_error', style: TextStyle(fontFamily: 'Poppins', fontSize: 16)),
              SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A07A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _loadData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern AppBar
              // Bagian AppBar modern elegan (tanpa gradient)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        widget.order == null
                            ? (_selectedLayanan?.namaLayanan ?? '-')
                            : 'Edit Pesanan',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  height: 124,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    image: const DecorationImage(
                      image: AssetImage('assets/banner2.png'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Modern Card for Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  color: Colors.white.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDropdown('Merk Handphone', _merkList, _selectedMerk, (value) {
                          setState(() {
                            _selectedMerk = value;
                            _selectedSeri = null;
                            _selectedJenisSparepart = null;
                            _updatePrice();
                          });
                        }),
                        if (_selectedMerk != null) ...[
                          const SizedBox(height: 10),
                          _buildDropdown(
                            'Seri Handphone',
                            getSeriByMerk(_selectedMerk!.id),
                            _selectedSeri,
                            (value) {
                              setState(() {
                                _selectedSeri = value;
                                _selectedJenisSparepart = null;
                                _updatePrice();
                              });
                            },
                          ),
                        ],
                        const SizedBox(height: 10),
                        _buildDropdown('Layanan',
                          _selectedLayanan != null ? [_selectedLayanan!] : [],
                          _selectedLayanan,
                          (value) {},
                        ),
                        if (_selectedLayanan != null) ...[
                          const SizedBox(height: 10),
                          _buildDropdown(
                            'Jenis Kerusakan',
                            [
                              ..._kerusakanList,
                              if (_lainnyaKerusakan != null) _lainnyaKerusakan!,
                            ],
                            _selectedKerusakan,
                            (value) {
                              setState(() {
                                _selectedKerusakan = value;
                                if (value != null && value.id == -999) {
                                  if (_manualKerusakanController.text.isEmpty) {
                                    if (widget.order != null && widget.order!.deskripsiKerusakan?.isNotEmpty == true) {
                                      _manualKerusakanText = widget.order!.deskripsiKerusakan!;
                                      _manualKerusakanController.text = widget.order!.deskripsiKerusakan!;
                                    }
                                  }
                                }
                              });
                            },
                          ),
                          if (_selectedKerusakan?.id == -999)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Deskripsi Kerusakan', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w400)),
                                  const SizedBox(height: 5),
                                  Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      TextField(
                                        controller: _manualKerusakanController,
                                        decoration: _kerusakanInputDecoration().copyWith(hintText: ''),
                                        onChanged: (val) {
                                          setState(() {
                                            _manualKerusakanText = val;
                                          });
                                        },
                                      ),
                                      if (_manualKerusakanText.isEmpty)
                                        Positioned(
                                          left: 20,
                                          right: 20,
                                          child: IgnorePointer(
                                            child: SizedBox(
                                              height: 20,
                                              child: Marquee(
                                                text: 'Contoh : Layar Pecah, Baterai Boros, dll',
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontFamily: 'Poppins',
                                                  fontSize: 15,
                                                ),
                                                scrollAxis: Axis.horizontal,
                                                blankSpace: 40.0,
                                                velocity: 30.0,
                                                pauseAfterRound: const Duration(seconds: 1),
                                                startPadding: 0.0,
                                                accelerationDuration: const Duration(seconds: 1),
                                                accelerationCurve: Curves.linear,
                                                decelerationDuration: const Duration(milliseconds: 500),
                                                decelerationCurve: Curves.easeOut,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                        const SizedBox(height: 10),
                        if (_selectedMerk != null && _selectedSeri != null && _selectedLayanan != null)
                          Builder(
                            builder: (context) {
                              final jenisList = getJenisSparepartByMerkSeriLayanan(_selectedMerk!.id, _selectedSeri!.id, _selectedLayanan!.id);
                              if (jenisList.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Info'),
                                          content: const Text('Maaf, untuk saat ini sparepart belum tersedia'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[100],
                                      ),
                                      child: const Text(
                                        'Jenis Sparepart (belum tersedia)',
                                        style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return _buildDropdown('Jenis Sparepart', jenisList, _selectedJenisSparepart, (value) {
                                setState(() {
                                  _selectedJenisSparepart = value;
                                  _updatePrice();
                                });
                              });
                            },
                          ),
                        if (_selectedHargaLayanan != null && _selectedHargaLayanan! > 0) ...[
                          const SizedBox(height: 15),
                          Text(
                            'Harga Layanan: Rp ${_selectedHargaLayanan!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        // Modern Gradient Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF16A07A), Color(0xFF4F8FFF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: _saveOrder,
                              child: Text(
                                widget.order == null ? 'Buat Pesanan' : 'Simpan Perubahan',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(String label, List<T> items, T? selectedItem, ValueChanged<T?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: DropdownButton<T>(
              value: selectedItem,
              isExpanded: true,
              underline: const SizedBox(),
              hint: Text('Pilih $label'),
              items: items.map((e) {
                String displayText = '';
                if (e is Merk) {
                  displayText = e.namaMerk;
                } else if (e is Seri) {
                  displayText = e.namaSeri;
                } else if (e is Layanan) {
                  displayText = e.namaLayanan;
                } else if (e is Kerusakan) {
                  displayText = e.namaKerusakan;
                } else if (e is JenisSparepart) {
                  displayText = e.namaJenis;
                }
                return DropdownMenuItem(value: e, child: Text(displayText));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
