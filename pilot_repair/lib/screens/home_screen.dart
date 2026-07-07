import 'package:flutter/material.dart';
import 'package:pilot_repair/screens/pengembangan.dart';
import 'package:pilot_repair/screens/profile_page.dart';
import 'package:pilot_repair/screens/pesanan.dart';
import 'package:pilot_repair/screens/order.dart';
import 'dart:async';
import 'package:intl/intl.dart'; // Import package untuk format tanggal
import 'package:intl/date_symbol_data_local.dart'; // Import untuk inisialisasi locale
import 'package:pilot_repair/models/service.dart';
import 'package:pilot_repair/services/service_api.dart';
import 'package:pilot_repair/services/api_service.dart';
import 'package:pilot_repair/services/auth_service.dart';
import 'package:flutter/widgets.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  late Timer _timer;
  bool _isScrollingForward = true;
  List<Layanan> _layananList = [];
  bool _isLoadingLayanan = true;
  String? _errorLayanan;

  // Mendapatkan tanggal dan hari saat ini
  String getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, d MMMM', 'id'); // Format: Hari, Tanggal Bulan Tahun
    return formatter.format(now);
  }

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    // Inisialisasi locale Indonesia untuk format tanggal
    initializeDateFormatting('id', null).then((_) {
      setState(() {}); // Memastikan UI diperbarui setelah inisialisasi
    });
    _fetchLayanan();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  Future<void> _fetchLayanan() async {
    setState(() {
      _isLoadingLayanan = true;
      _errorLayanan = null;
    });
    try {
      final layanan = await ServiceApi.getLayananList();
      setState(() {
        _layananList = layanan;
        _isLoadingLayanan = false;
      });
    } catch (e) {
      setState(() {
        _errorLayanan = e.toString();
        _isLoadingLayanan = false;
      });
    }
  }

  // Fungsi untuk memulai scroll otomatis
  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final minScroll = _scrollController.position.minScrollExtent;

        // Scroll ke depan
        if (_isScrollingForward) {
          if (_scrollController.offset < maxScroll) {
            _scrollController.jumpTo(_scrollController.offset + 1);
          } else {
            _isScrollingForward = false;
          }
        }
        // Scroll ke belakang
        else {
          if (_scrollController.offset > minScroll) {
            _scrollController.jumpTo(_scrollController.offset - 1);
          } else {
            _isScrollingForward = true;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }
  
  @override
  void didPopNext() {
    // Called when coming back to this page
    _fetchLayanan();
  }

  Future<bool> _hasActiveOrder() async {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null || currentUser.id == null) return false;

      final orders = await ApiService.fetchUserOrders(currentUser.id!);
      return orders.any((order) => 
        order.status == 'pending' || 
        order.status == 'accepted'
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> _navigateToOrder(Layanan layanan) async {
    final hasActive = await _hasActiveOrder();
    if (hasActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda masih memiliki pesanan yang belum selesai. Selesaikan pesanan sebelumnya terlebih dahulu.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderPage(layanan: layanan)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF), // Warna latar belakang
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50), // Sesuaikan tinggi AppBar
        child: AppBar(
          backgroundColor: Colors.transparent, // Agar AppBar tidak terlihat
          elevation: 0, // Menghilangkan bayangan AppBar
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40, left: 25, right: 25),
            child: Row(
              children: [
                // Logo (ukuran diperbesar)
                Image.asset(
                  'assets/logo.png', // Ganti dengan path logo Anda
                  width: 140, // Ukuran logo diperbesar
                  height: 30, // Menyesuaikan ukuran tinggi logo
                ),
                const Spacer(), // Spacer agar logo tetap ada di kiri
                // Icon Keranjang (diposisikan mepet kanan dan sejajar dengan logo)
                InkWell(
                  onTap: () {
                    // Aksi ketika ikon keranjang diklik
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PesananPage()),
                    );
                  },
                  child: const Icon(
                    Icons.shopping_cart, // Menggunakan icon keranjang
                    size: 25,
                  ),
                ),
                const SizedBox(width: 13), // Jarak antara icon keranjang dan profile
                // Profile Picture (diposisikan paling kanan dan sejajar dengan logo)
                InkWell(
                  onTap: () {
                    // Aksi ketika gambar profil diklik
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20, // 40x40 = radius 20
                    backgroundImage: AssetImage('assets/profile.png'), // Ganti dengan path foto profil PNG
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchLayanan,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // Scroll dengan efek bouncing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Deskripsi dengan RichText dan newline
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 25, right: 25), // Kurangi jarak atas agar lebih dekat dengan logo
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ // Jarak antara deskripsi dan search bar
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins', // Menggunakan font Poppins
                          fontSize: 14, // Ukuran font tetap 14
                          fontWeight: FontWeight.normal,
                          color: Colors.black, // Warna teks
                        ),
                        children: [
                          TextSpan(
                            text: 'Solusi tepat untuk smartphone\n', // \n untuk pindah baris
                          ),
                          TextSpan(
                            text: 'Anda',
                            style: TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15), // Jarak antara deskripsi dan search bar
                  ],
                ),
              ),
              // Padding untuk search bar dengan jarak 15 di kiri dan kanan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15), // Padding kiri dan kanan untuk search bar
                child: Column(
                  children: [
                    Container(
                      height: 45, // Tinggi search bar
                      decoration: BoxDecoration(
                        color: Colors.white, // Warna latar belakang search bar
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: const Color.fromARGB(255, 137, 140, 159), // Border dengan warna #20233F
                          width: 0.2, // Ketebalan border
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10), // Padding dalam search bar
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start, // Mengatur posisi di kiri
                          crossAxisAlignment: CrossAxisAlignment.center, // Menjaga teks dan ikon sejajar vertikal
                          children: [
                            // Mengganti icon search dengan gambar
                            Image.asset(
                              'assets/icon_search.png', // Ganti dengan path gambar Anda
                              width: 23, // Ukuran gambar 23x23
                              height: 23, // Ukuran gambar 23x23
                            ),
                            const SizedBox(width: 5), // Jarak antara ikon dan teks
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Cari layanan jasa servis ...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey, // Warna hint text
                                    fontSize: 14,
                                    fontFamily: 'Poppins', // Font untuk hint text
                                  ),
                                  border: InputBorder.none, // Menghilangkan border
                                  isDense: true, // Menjaga agar teks lebih padat dan rata
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15), // Jarak antara search bar dan banner
                    Container(
                      height: 124, // Tinggi banner
                      width: double.infinity, // Lebar mengikuti search bar
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12), // Sudut melengkung
                        image: DecorationImage(
                          image: AssetImage('assets/banner.png'), // Ganti dengan path banner Anda
                          fit: BoxFit.cover, // Menyesuaikan gambar agar penuh
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Jarak antara banner dan daftar layanan
                      // Horizontal list untuk layanan (kembalikan ke hardcode)
                    SizedBox(
                      height: 50,
                      child: ListView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal, // Scroll secara horizontal
                        children: [
                          _buildServiceItem('Jasa Servis HP', Icons.build),
                          _buildServiceItem('Jual HP Bekas', Icons.sell),
                          _buildServiceItem('Beli HP Bekas', Icons.shopping_bag),
                          _buildServiceItem('Tukar Tambah HP', Icons.swap_horiz),
                          _buildServiceItem('Barter HP Bekas', Icons.sync_alt),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20), // Jarak antara layanan dan tombol tambahan
                    // Menambahkan tombol
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Menyebarkan tombol secara merata
                          children: (() {
                            final sorted = List<Layanan>.from(_layananList)..sort((a, b) => a.id.compareTo(b.id));
                            if (sorted.length >= 4) {
                              return [
                                ...sorted.take(3).map((layanan) => _buildActionButton(
                                  (layanan.iconLayanan != null && layanan.iconLayanan!.isNotEmpty)
                                    ? ServiceApi.baseUrl + '/assets/database/' + layanan.iconLayanan!
                                    : null,
                                  layanan.namaLayanan.replaceAll(' ', '\n'),
                            () {
                              _navigateToOrder(layanan);
                            },
                                )),
                          _buildActionButton(
                            'assets/other.png',
                            'Perbaikan\nLainnya',
                            () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                      ),
                                      builder: (context) {
                                        final sorted = List<Layanan>.from(_layananList)..sort((a, b) => a.id.compareTo(b.id));
                                        final scrollController = ScrollController();
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          if (scrollController.hasClients) {
                                            scrollController.jumpTo(scrollController.position.maxScrollExtent);
                                          }
                                        });
                                        return Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0x22000000),
                                                blurRadius: 16,
                                                offset: Offset(0, -2),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 16),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              sorted.isEmpty
                                                  ? const Center(child: Text('Tidak ada layanan'))
                                                  : SizedBox(
                                                      height: 110,
                                                      child: ListView.separated(
                                                        controller: scrollController,
                                                        scrollDirection: Axis.horizontal,
                                                        itemCount: sorted.length,
                                                        separatorBuilder: (_, __) => const SizedBox(width: 20),
                                                        itemBuilder: (context, idx) {
                                                          final layanan = sorted[idx];
                                                          return GestureDetector(
                                                            onTap: () {
                                                              Navigator.pop(context);
                              _navigateToOrder(layanan);
                                                            },
                                                            child: Container(
                                                              width: 80,
                                                              decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius: BorderRadius.circular(12),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors.black.withOpacity(0.07),
                                                                    blurRadius: 8,
                                                                    offset: const Offset(0, 2),
                                                                  ),
                                                                ],
                                                                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                                                              ),
                                                              margin: const EdgeInsets.only(bottom: 2),
                                                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Container(
                                                                    height: 42,
                                                                    width: 42,
                                                                    decoration: BoxDecoration(
                                                                      color: const Color(0xFFF7F7FA),
                                                                      borderRadius: BorderRadius.circular(8),
                                                                    ),
                                                                    child: Center(
                                                                      child: (layanan.iconLayanan != null && layanan.iconLayanan!.isNotEmpty)
                                                                          ? Image.network(
                                                                              ServiceApi.baseUrl + '/assets/database/' + layanan.iconLayanan!,
                                                                              width: 32,
                                                                              height: 32,
                                                                              fit: BoxFit.contain,
                                                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 32, color: Colors.grey),
                                                                            )
                                                                          : const Icon(Icons.image_not_supported, size: 32, color: Colors.grey),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(height: 8),
                                                                  Text(
                                                                    layanan.namaLayanan.replaceAll(' ', '\n'),
                                                                    textAlign: TextAlign.center,
                                                                    style: const TextStyle(
                                                                      fontFamily: 'Poppins',
                                                                      fontSize: 11,
                                                                      fontWeight: FontWeight.normal,
                                                                      color: Color(0xFF22223B),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ];
                            } else {
                              return sorted.map((layanan) => _buildActionButton(
                                (layanan.iconLayanan != null && layanan.iconLayanan!.isNotEmpty)
                                  ? ServiceApi.baseUrl + '/assets/database/' + layanan.iconLayanan!
                                  : null,
                                layanan.namaLayanan.replaceAll(' ', '\n'),
                                () {
                                  _navigateToOrder(layanan);
                                },
                              )).toList();
                            }
                          })(),
                      ),
                    ),

                    const SizedBox(height: 22), // Jarak antara tombol dan teks tambahan
                    // Teks Hari, Tanggal, Bulan dan tombol di sebelah kanan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Menyebarkan ruang antara teks dan tombol
                      children: [
                        // Teks tanggal dan deskripsi di sebelah kiri
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10), // Menambahkan padding kiri
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getCurrentDate(),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500, // Medium
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2), // Jarak antara teks tanggal dan teks bawahnya
                                Text(
                                  'Siap datang ke lokasi anda',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300, // Light
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Tombol di sebelah kanan
                        Padding(
                          padding: const EdgeInsets.only(right: 0), // Padding kanan
                          child: Container(
                            height: 40, // Tinggi tombol
                            width: 50, // Lebar tombol
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A07A), // Warna tombol
                              borderRadius: BorderRadius.circular(50), // Rounded corners
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_forward, // Ikon panah kanan
                                color: Colors.white, // Warna ikon putih
                                size: 22, // Ukuran ikon
                              ),
                              onPressed: () {
                                // Aksi tombol bisa ditambahkan di sini
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Kotak dengan ukuran 330x150 dan border
                    Padding(
                      padding: const EdgeInsets.only(top: 20), // Jarak atas sekitar 20
                      child: Container(
                        width: 330, // Lebar kotak 330
                        height: 160, // Tinggi kotak 150
                        decoration: BoxDecoration(
                          color: Colors.white, // Background putih
                          borderRadius: BorderRadius.circular(10), // Sudut melengkung
                          border: Border.all(
                            color: const Color.fromARGB(255, 137, 140, 159), // Border yang sama dengan sebelumnya
                            width: 0.2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Kotak kecil di dalam kotak besar
                            Positioned(
                              top: 0, // Mepet atas tanpa jarak
                              left: 22, // Jarak kiri sekitar 20
                              child: Container(
                                width: 45, // Lebar kotak kecil
                                height: 23, // Tinggi kotak kecil
                                decoration: BoxDecoration(
                                  color: const Color(0xFF16A07A).withOpacity(0.2), // Background kotak kecil dengan opacity 20
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(5), // Rounded hanya di pojok kiri bawah
                                    bottomRight: Radius.circular(5), // Rounded hanya di pojok kanan bawah
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Buka', // Teks di dalam kotak kecil
                                    style: TextStyle(
                                      fontFamily: 'Poppins', // Menggunakan font Poppins
                                      fontSize: 12, // Ukuran font 12
                                      fontWeight: FontWeight.normal, // Regular
                                      color: const Color(0xFF036F51), // Warna teks
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Teks "Jasa Servis HP Panggilan" di bawah kotak kecil
                            Positioned(
                              top: 35, // Jarak dari kotak kecil
                              left: 22, // Jarak kiri sama seperti sebelumnya
                              child: Text(
                                'Jasa Servis HP Panggilan', // Teks yang ingin ditampilkan
                                style: TextStyle(
                                  fontFamily: 'Poppins', // Menggunakan font Poppins
                                  fontSize: 16, // Ukuran font 14
                                  fontWeight: FontWeight.w400, // Regular
                                  color: Colors.black, // Warna teks hitam
                                ),
                              ),
                            ),
                            // Teks "Jam Operasional" di bawah teks "Jasa Servis HP Panggilan"
                            Positioned(
                              top: 56, // Jarak dari teks "Jasa Servis HP Panggilan"
                              left: 22, // Jarak kiri sama seperti sebelumnya
                              child: Text(
                                'Jam Operasional', // Teks yang ingin ditampilkan
                                style: TextStyle(
                                  fontFamily: 'Poppins', // Menggunakan font Poppins
                                  fontSize: 14, // Ukuran font 13
                                  fontWeight: FontWeight.w300, // Light
                                  color: Colors.black, // Warna teks hitam
                                ),
                              ),
                            ),
                            // Kotak baru di bawah teks "Jam Operasional"
                            Positioned(
                              top: 90, // Jarak dari teks "Jam Operasional"
                              left: 18, // Jarak kiri sekitar 20
                              child: Container(
                                width: 294, // Lebar kotak 294
                                height: 54, // Tinggi kotak 50
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 248, 251, 255), // Warna kotak
                                  borderRadius: BorderRadius.circular(10), // Sudut rounded
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 137, 140, 159), // Warna border sesuai sebelumnya
                                    width: 0.2, // Ketebalan border yang lebih tipis
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Menyebar konten ke kiri dan kanan
                                  children: [
                                    // Jam buka
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Text(
                                        '09.00', // Jam buka
                                        style: TextStyle(
                                          fontFamily: 'Poppins', // Menggunakan font Poppins
                                          fontSize: 23, // Ukuran font 22
                                          fontWeight: FontWeight.w400, // Regular
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    // Istirahat
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Istirahat', // Teks Istirahat
                                          style: TextStyle(
                                            fontFamily: 'Poppins', // Menggunakan font Poppins
                                            fontSize: 12, // Ukuran font 13
                                            fontWeight: FontWeight.w400, // Regular
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          '12.00 - 13.00', // Jam istirahat
                                          style: TextStyle(
                                            fontFamily: 'Poppins', // Menggunakan font Poppins
                                            fontSize: 14, // Ukuran font 13
                                            fontWeight: FontWeight.w400, // Regular
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Jam tutup
                                    Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: Text(
                                        '19.00', // Jam tutup
                                        style: TextStyle(
                                          fontFamily: 'Poppins', // Menggunakan font Poppins
                                          fontSize: 23, // Ukuran font 22
                                          fontWeight: FontWeight.w400, // Regular
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membangun item layanan dengan padding dan tinggi 40
  Widget _buildServiceItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 10), // Jarak antar item
      child: Container(
        height: 30, // Tinggi item layanan diubah menjadi 40
        padding: const EdgeInsets.symmetric(horizontal: 15), // Padding dalam item
        decoration: BoxDecoration(
          color: Colors.white, // Background putih
          borderRadius: BorderRadius.circular(50), // Sudut melengkung
          border: Border.all(
            color: const Color.fromARGB(255, 137, 140, 159), // Border seperti search bar
            width: 0.2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF16A07A)), // Icon dengan warna yang diinginkan
            const SizedBox(width: 5), // Jarak antara ikon dan teks
            // Text dengan jarak dari kiri dan kanan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5), // Jarak kiri dan kanan teks
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500, // Medium
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membangun tombol aksi dengan gambar dan label
  Widget _buildActionButton(String? imagePath, String label, VoidCallback onPressed) {
  return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color.fromARGB(255, 137, 140, 159),
                width: 0.2,
              ),
            ),
            child: Center(
              child: (imagePath == null || imagePath.isEmpty)
                  ? const Icon(Icons.image_not_supported, size: 42, color: Colors.grey)
                  : imagePath.startsWith('http')
                      ? Image.network(
                          imagePath,
                          width: 42,
                          height: 42,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 42, color: Colors.grey),
                        )
                      : Image.asset(
                          imagePath,
                          width: 42,
                          height: 42,
                          fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
