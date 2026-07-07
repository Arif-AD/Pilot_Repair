import 'package:flutter/material.dart';
import 'package:pilot_repair/models/order.dart';
import 'package:pilot_repair/screens/order.dart';
import 'package:pilot_repair/screens/chat_page.dart';
import 'package:pilot_repair/services/api_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:pilot_repair/services/user_api_service.dart';
import 'package:pilot_repair/models/user.dart';
import 'package:pilot_repair/services/auth_service.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  _PesananPageState createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> with SingleTickerProviderStateMixin {
  late Future<List<Order>> _ordersFuture;
  late TabController _tabController;
  bool _showAllCompleted = false;
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Modern color scheme with original green
  final Color primaryColor = const Color(0xFF0077FF);
  final Color secondaryColor = const Color(0xFF1ABC9C);
  final Color accentColor = const Color(0xFFE8F8F5);
  final Color successColor = const Color(0xFF16A07A);
  final Color warningColor = const Color(0xFFF59E0B);
  final Color dangerColor = const Color(0xFFDC2626);
  final Color surfaceColor = const Color(0xFFF8FAFC);
  final Color textColor = const Color(0xFF1E293B);

  // --- TIMER PAUSE/RESUME LOGIC ---
  Map<int, Duration> _pausedRemaining = {};
  Map<int, DateTime> _pauseStart = {};
  int? _editingOrderId;
  bool _editSuccess = false;
  DateTime? _serverNow;

  void _pauseTimer(int orderId, DateTime createdAt) {
    final now = DateTime.now();
    final elapsed = now.difference(createdAt);
    final remaining = Duration(seconds: 30) - elapsed;
    _pausedRemaining[orderId] = remaining > Duration.zero ? remaining : Duration.zero;
    _pauseStart[orderId] = now;
    setState(() {
      _editingOrderId = orderId;
      _editSuccess = false;
    });
  }

  void _resumeTimer(int orderId) {
    if (_pausedRemaining.containsKey(orderId) && _pauseStart.containsKey(orderId)) {
      final pauseDuration = DateTime.now().difference(_pauseStart[orderId]!);
      _pausedRemaining[orderId] = _pausedRemaining[orderId]! - pauseDuration;
      if (_pausedRemaining[orderId]! < Duration.zero) {
        _pausedRemaining[orderId] = Duration.zero;
      }
      _pauseStart.remove(orderId);
      setState(() {
        _editingOrderId = null;
      });
    }
  }

  void _resetTimer(int orderId) {
    _pausedRemaining[orderId] = Duration(seconds: 30);
    _pauseStart.remove(orderId);
    setState(() {
      _editingOrderId = null;
      _editSuccess = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    final user = AuthService.currentUser;
    if (user != null) {
      final future = ApiService.fetchUserOrdersWithServerTime(user.id);
      _ordersFuture = future.then((result) {
        _serverNow = result['serverNow'];
        return result['orders'] as List<Order>;
      });
      _ordersFuture.then((orders) {
        if (orders.isNotEmpty) {
          final pendingCount = orders.where((order) => order.status == 'pending').length;
          final acceptedCount = orders.where((order) => order.status == 'accepted').length;
          final completedCount = orders.where((order) => order.status == 'completed').length;
          if (_tabController.index == 0 && pendingCount == 0) {
            if (acceptedCount > 0) {
              _tabController.animateTo(1);
            } else if (completedCount > 0) {
              _tabController.animateTo(2);
            }
          }
        }
      });
    } else {
      _ordersFuture = Future.value([]);
    }
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _loadOrders();
    });
  }

  void _editOrder(Order order) async {
    // Pause timer for this order
    if (order.status == 'waiting' && order.id != null) {
      _pauseTimer(order.id!, order.waitingCreatedAt ?? order.createdAt!);
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(order: order),
      ),
    );
    if (order.status == 'waiting' && order.id != null) {
      if (result == true) {
        // Reset timer if edit success
        _resetTimer(order.id!);
        _refreshOrders();
      } else {
        // Resume timer if edit cancelled
        _resumeTimer(order.id!);
      }
    } else {
      _refreshOrders();
    }
  }

  Future<void> _deleteOrder(int id) async {
    try {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Konfirmasi Hapus',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus pesanan ini?',
            style: GoogleFonts.inter(color: textColor.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.inter(color: textColor.withOpacity(0.6)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ApiService.deleteOrder(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Pesanan berhasil dihapus',
                        style: GoogleFonts.inter(),
                      ),
                      backgroundColor: successColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  _refreshOrders();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: dangerColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Hapus',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus pesanan',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: dangerColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildOrderCard(Order order) {
    final priceGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor,
        Color(0xFF1ABC9C),
      ],
    );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with device info and price
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kolom 1: Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.phone_android_rounded,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Kolom 2: layanan (baris 1), merk+seri (baris 2)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Baris 1: Layanan
                            SizedBox(
                              height: 24,
                              child: Marquee(
                                text: order.namaLayanan ?? 'Layanan',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: 20.0,
                                velocity: 30.0,
                                pauseAfterRound: const Duration(seconds: 1),
                                startPadding: 10.0,
                                accelerationDuration: const Duration(seconds: 1),
                                accelerationCurve: Curves.linear,
                                decelerationDuration: const Duration(milliseconds: 500),
                                decelerationCurve: Curves.easeOut,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Baris 2: Merk + Seri
                            SizedBox(
                              height: 20,
                              child: Marquee(
                                text: '${order.namaMerk ?? 'Merk'} ${order.namaSeri ?? 'Seri'}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: textColor.withOpacity(0.7),
                                ),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                blankSpace: 20.0,
                                velocity: 30.0,
                                pauseAfterRound: const Duration(seconds: 1),
                                startPadding: 10.0,
                                accelerationDuration: const Duration(seconds: 1),
                                accelerationCurve: Curves.linear,
                                decelerationDuration: const Duration(milliseconds: 500),
                                decelerationCurve: Curves.easeOut,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Kolom 3: Harga (center, rowspan 2)
                      if (order.hargaLayanan != null && order.hargaLayanan! > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8, top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: successColor.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: successColor.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: ShaderMask(
                            shaderCallback: (bounds) => priceGradient.createShader(bounds),
                            child: Text(
                              currencyFormat.format(order.hargaLayanan).replaceAll(",00", ""),
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Info section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profil teknisi di atas tanggal jika status accepted
                  if (order.status == 'accepted' && order.technicianId != null)
                    FutureBuilder<User>(
                      future: UserApiService.getUserProfile(order.technicianId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 28, height: 28,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 10),
                                Text('Memuat data teknisi...', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text('Gagal memuat teknisi', style: GoogleFonts.inter(color: Colors.red, fontSize: 13)),
                          );
                        } else if (snapshot.hasData) {
                          return _buildTechnicianInfo(snapshot.data!, background: Colors.transparent);
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  // Status and Date row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Date
                      if (order.status != 'waiting')
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: textColor.withOpacity(0.6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              order.createdAt != null
                                  ? DateFormat('dd/MM/yyyy').format(order.createdAt!)
                                  : 'Tanggal tidak tersedia',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      // Status badge
                      _buildStatusBadge(order.status ?? 'pending', createdAt: order.createdAt, waitingCreatedAt: order.waitingCreatedAt, orderId: order.id),
                    ],
                  ),
                  // Action buttons untuk status waiting
                  if (order.status == 'waiting') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (order.id is int) {
                                _deleteOrder(order.id as int);
                              }
                            },
                            icon: const Icon(Icons.delete_outline_rounded, size: 18),
                            label: Text(
                              'Hapus',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: dangerColor,
                              side: BorderSide(color: dangerColor.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () => _editOrder(order),
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: Text(
                              'Edit Pesanan',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: successColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 50.ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildStatusBadge(String status, {DateTime? createdAt, DateTime? waitingCreatedAt, int? orderId}) {
    Color badgeColor;
    String label;
    IconData icon;

    if (status == 'waiting') {
      final timerStart = waitingCreatedAt ?? createdAt;
      if (timerStart != null) {
        return _buildWaitingCountdownBadge(timerStart, orderId: orderId);
      }
    }

    switch (status) {
      case 'pending':
        badgeColor = warningColor;
        label = 'Menunggu';
        icon = Icons.schedule_rounded;
        break;
      case 'accepted':
        badgeColor = successColor;
        label = 'Dikonfirmasi';
        icon = Icons.engineering_rounded;
        break;
      case 'completed':
        badgeColor = successColor;
        label = 'Selesai';
        icon = Icons.check_circle_rounded;
        break;
      default:
        badgeColor = Colors.grey;
        label = 'Unknown';
        icon = Icons.help_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingCountdownBadge(DateTime createdAt, {int? orderId}) {
    Duration initial = Duration(seconds: 30);
    DateTime now = _serverNow ?? DateTime.now();
    if (orderId != null && _pausedRemaining.containsKey(orderId)) {
      initial = _pausedRemaining[orderId]!;
    } else {
      final elapsed = now.difference(createdAt);
      initial = Duration(seconds: 30) - elapsed;
      if (initial < Duration.zero) initial = Duration.zero;
    }
    return TweenAnimationBuilder<Duration>(
      duration: initial,
      tween: Tween(begin: initial, end: Duration.zero),
      onEnd: () {
        if (mounted) {
          _refreshOrders();
        }
      },
      builder: (context, value, child) {
        final seconds = value.inSeconds > 0 ? value.inSeconds : 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: warningColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer, size: 14, color: warningColor),
              const SizedBox(width: 6),
              Text(
                'Batalkan / Edit Pesanan dalam 00:${seconds.toString().padLeft(2, '0')}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: warningColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            status == 'pending' ? Icons.inbox_rounded :
            status == 'accepted' ? Icons.engineering_rounded :
            Icons.task_alt_rounded,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada pesanan ${status == 'pending' ? 'baru' :
            status == 'accepted' ? 'yang dikonfirmasi' : 'yang selesai'}',
            style: GoogleFonts.inter(
              color: Colors.grey[600],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildOrderList(List<Order> orders, String status) {
    // Untuk tab 'pending', tampilkan juga status 'waiting'
    final filteredOrders = status == 'pending'
        ? orders.where((order) => order.status == 'pending' || order.status == 'waiting').toList()
        : orders.where((order) => order.status == status).toList();

    if (filteredOrders.isEmpty) {
      return _buildEmptyState(status);
    }

    // For completed orders, show only one unless expanded
    final displayOrders = status == 'completed' && !_showAllCompleted
        ? filteredOrders.take(1).toList()
        : filteredOrders;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...displayOrders.map((order) => _buildOrderCard(order)),

        // Show "Tampilkan Semua" button for completed orders
        if (status == 'completed' && filteredOrders.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showAllCompleted = !_showAllCompleted;
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: successColor.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showAllCompleted ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 18,
                    color: successColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _showAllCompleted
                        ? 'Sembunyikan'
                        : 'Lihat ${filteredOrders.length - 1} Pesanan Lainnya',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: successColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daftar Pesanan',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: successColor,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: successColor.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              dividerColor: Colors.transparent,
              labelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              labelPadding: EdgeInsets.zero,
              tabs: [
                _buildTab(Icons.schedule_rounded, 'Menunggu', 0),
                _buildTab(Icons.engineering_rounded, 'Proses', 1),
                _buildTab(Icons.check_circle_rounded, 'Selesai', 2),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(successColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat pesanan...',
                    style: GoogleFonts.inter(
                      color: textColor.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ).animate()
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: dangerColor),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal mengambil daftar pesanan',
                    style: GoogleFonts.inter(color: dangerColor),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _refreshOrders,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      'Coba Lagi',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate()
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
          }

          final orders = snapshot.data ?? [];
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(orders, 'pending'),
              _buildOrderList(orders, 'accepted'),
              _buildOrderList(orders, 'completed'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(IconData icon, String label, int index) {
    final isSelected = _tabController.index == index;
    return Tab(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? successColor : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianInfo(User teknisi, {Color background = Colors.white}) {
    String initials = teknisi.name.isNotEmpty
        ? teknisi.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: successColor.withOpacity(0.13),
            child: Text(
              initials,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: successColor),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(teknisi.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: textColor)),
                const SizedBox(height: 2),
                Text(teknisi.phone, style: GoogleFonts.inter(fontSize: 13, color: textColor.withOpacity(0.7))),
                if (teknisi.email != null && teknisi.email!.isNotEmpty)
                  Text(teknisi.email!, style: GoogleFonts.inter(fontSize: 12, color: textColor.withOpacity(0.5))),
              ],
            ),
          ),
          // Chat button
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: successColor.withOpacity(0.3), width: 1),
            ),
            child: IconButton(
              onPressed: () {
                // Find the order for this technician
                _ordersFuture.then((orders) {
                  final acceptedOrder = orders.firstWhere(
                    (order) => order.status == 'accepted' && order.technicianId == teknisi.id,
                    orElse: () => Order(
                      idMerk: 0,
                      idSeri: 0,
                      idLayanan: 0,
                      idJenisSparepart: 0,
                    ),
                  );
                  if (acceptedOrder.id != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(order: acceptedOrder),
                      ),
                    );
                  }
                });
              },
              icon: Icon(Icons.message_rounded, color: successColor, size: 22),
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
