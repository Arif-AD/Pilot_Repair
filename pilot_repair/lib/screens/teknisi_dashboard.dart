import 'package:flutter/material.dart';
import 'package:pilot_repair/models/order.dart';
import 'package:pilot_repair/screens/chat_page.dart';
import 'package:pilot_repair/services/api_service.dart';
import 'package:pilot_repair/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:marquee/marquee.dart';
import 'package:pilot_repair/services/user_api_service.dart';
import 'package:pilot_repair/models/user.dart';

class TeknisiDashboardPage extends StatefulWidget {
  final String technicianId;

  const TeknisiDashboardPage({
    super.key,
    required this.technicianId,
  });

  @override
  _TeknisiDashboardPageState createState() => _TeknisiDashboardPageState();
}

class _TeknisiDashboardPageState extends State<TeknisiDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Order>> _ordersFuture;
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Add listener for tab changes to check content
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _ordersFuture.then((orders) {
          final pendingCount = orders.where((order) => order.status == 'pending').length;
          final acceptedCount = orders.where((order) => order.status == 'accepted').length;
          final completedCount = orders.where((order) => order.status == 'completed').length;

          final targetIndex = _tabController.index;
          if (targetIndex == 0 && pendingCount == 0) {
            if (acceptedCount > 0) {
              _tabController.animateTo(1);
            } else if (completedCount > 0) {
              _tabController.animateTo(2);
            }
          } else if (targetIndex == 1 && acceptedCount == 0) {
            if (pendingCount > 0) {
              _tabController.animateTo(0);
            } else if (completedCount > 0) {
              _tabController.animateTo(2);
            }
          } else if (targetIndex == 2 && completedCount == 0) {
            if (pendingCount > 0) {
              _tabController.animateTo(0);
            } else if (acceptedCount > 0) {
              _tabController.animateTo(1);
            }
          }
        });
      }
      setState(() {});
    });

    _refreshOrders();
  }

  void _refreshOrders() {
    setState(() {
      // Fetch both pending and technician orders
      _ordersFuture = Future.wait([
        ApiService.fetchPendingOrders(),
        ApiService.fetchTechnicianOrders(widget.technicianId),
      ]).then((results) {
        final pendingOrders = results[0];
        final technicianOrders = results[1];

        // Combine and remove duplicates based on order ID
        final allOrders = [...pendingOrders];
        for (var order in technicianOrders) {
          if (!allOrders.any((o) => o.id == order.id)) {
            allOrders.add(order);
          }
        }

        // DEBUG: print userId dan hargaLayanan setiap order
        for (var order in allOrders) {
          print('ORDER DEBUG: id=${order.id}, userId=${order.userId}, hargaLayanan=${order.hargaLayanan}');
        }

        // Auto switch to tab with content
        if (mounted) {
          final pendingCount = allOrders.where((order) => order.status == 'pending').length;
          final acceptedCount = allOrders.where((order) => order.status == 'accepted').length;
          final completedCount = allOrders.where((order) => order.status == 'completed').length;

          // If current tab is empty, switch to the first non-empty tab
          if (_tabController.index == 0 && pendingCount == 0) {
            if (acceptedCount > 0) {
              _tabController.animateTo(1);
            } else if (completedCount > 0) {
              _tabController.animateTo(2);
            }
          } else if (_tabController.index == 1 && acceptedCount == 0) {
            if (pendingCount > 0) {
              _tabController.animateTo(0);
            } else if (completedCount > 0) {
              _tabController.animateTo(2);
            }
          } else if (_tabController.index == 2 && completedCount == 0) {
            if (pendingCount > 0) {
              _tabController.animateTo(0);
            } else if (acceptedCount > 0) {
              _tabController.animateTo(1);
            }
          }
        }

        return allOrders;
      });
    });
  }

  // Add state for expanded completed orders
  bool _showAllCompleted = false;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard Teknisi',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                        _buildTab(Icons.inbox_rounded, 'Masuk', 0),
                        _buildTab(Icons.engineering_rounded, 'Proses', 1),
                        _buildTab(Icons.check_circle_rounded, 'Selesai', 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrderList('pending'),
                  _buildOrderList('accepted'),
                  _buildOrderList('completed'),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
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

  Widget _buildOrderList(String status) {
    return FutureBuilder<List<Order>>(
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
          return _buildEmptyState(
            'Gagal memuat pesanan\nCoba lagi nanti',
            Icons.error_outline_rounded,
          );
        }

        final allOrders = snapshot.data?.where((order) {
          final match = order.status == status && order.technicianId == int.parse(widget.technicianId);
          print('DEBUG: order.id=${order.id}, order.technicianId=${order.technicianId}, widget.technicianId=${widget.technicianId}, match=$match');
          return match;
        }).toList() ?? [];

        if (allOrders.isEmpty) {
          return _buildEmptyState(
            status == 'pending' ? 'Tidak ada pesanan masuk' :
            status == 'accepted' ? 'Tidak ada pesanan dalam proses' :
            'Tidak ada pesanan selesai',
            status == 'pending' ? Icons.inbox_rounded :
            status == 'accepted' ? Icons.engineering_rounded :
            Icons.task_alt_rounded,
          );
        }

        // For completed orders, show only one unless expanded
        final orders = status == 'completed' && !_showAllCompleted
            ? allOrders.take(1).toList()
            : allOrders;

        return RefreshIndicator(
          onRefresh: () async => _refreshOrders(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...orders.map((order) => _buildOrderCard(
                order,
                showAcceptButton: status == 'pending',
                showCompleteButton: status == 'accepted',
              )),

              // Show "Tampilkan Semua" button for completed orders
              if (status == 'completed' && allOrders.length > 1)
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
                              : 'Lihat ${allOrders.length - 1} Pesanan Lainnya',
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
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(Order order, {
    bool showAcceptButton = false,
    bool showCompleteButton = false,
  }) {
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
                            // Baris 2: Merk + Seri + Kerusakan/deskripsi
                            SizedBox(
                              height: 20,
                              child: Marquee(
                                text: '${order.namaMerk ?? 'Merk'} ${order.namaSeri ?? 'Seri'} - ${order.namaKerusakan ?? order.deskripsiKerusakan ?? 'Kerusakan'}',
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
                  // Customer info di atas tanggal
                  if (order.userId != null)
                    FutureBuilder<User>(
                      future: UserApiService.getUserProfile(order.userId!),
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
                                Text('Memuat data pelanggan...', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text('Gagal memuat pelanggan', style: GoogleFonts.inter(color: Colors.red, fontSize: 13)),
                          );
                        } else if (snapshot.hasData) {
                          return _buildCustomerInfo(snapshot.data!);
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  // Status and Date row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                      _buildStatusBadge(order.status ?? 'pending'),
                    ],
                  ),
                  if (showAcceptButton || showCompleteButton) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                if (showAcceptButton) {
                                  await ApiService.acceptOrder(order.id!, widget.technicianId);
                                  _tabController.animateTo(1); // Switch to "Proses" tab
                                } else if (showCompleteButton) {
                                  await ApiService.completeOrder(order.id!);
                                  _tabController.animateTo(2); // Switch to "Selesai" tab
                                }
                                _refreshOrders();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        showAcceptButton
                                            ? 'Pesanan berhasil diterima'
                                            : 'Pesanan berhasil diselesaikan',
                                        style: GoogleFonts.inter(),
                                      ),
                                      backgroundColor: successColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Terjadi kesalahan: $e',
                                        style: GoogleFonts.inter(),
                                      ),
                                      backgroundColor: dangerColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: Icon(
                              showAcceptButton ? Icons.check_circle_rounded : Icons.engineering_rounded,
                              size: 18,
                            ),
                            label: Text(
                              showAcceptButton ? 'Terima Pesanan' : 'Selesaikan Pesanan',
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
                  // Chat button untuk pesanan yang sudah diterima
                  if (order.status == 'accepted') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(order: order),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                        label: Text(
                          'Chat dengan Pelanggan',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
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

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String label;
    IconData icon;

    switch (status) {
      case 'pending':
        badgeColor = warningColor;
        label = 'Masuk';
        icon = Icons.schedule_rounded;
        break;
      case 'accepted':
        badgeColor = successColor;
        label = 'Diterima';
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

  Widget _buildCustomerInfo(User customer) {
    String initials = customer.name.isNotEmpty
        ? customer.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            backgroundColor: primaryColor.withOpacity(0.13),
            child: Text(
              initials,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, color: textColor)),
                const SizedBox(height: 2),
                Text(customer.phone, style: GoogleFonts.inter(fontSize: 13, color: textColor.withOpacity(0.7))),
                if (customer.email != null && customer.email!.isNotEmpty)
                  Text(customer.email!, style: GoogleFonts.inter(fontSize: 12, color: textColor.withOpacity(0.5))),
              ],
            ),
          ),
          // Badge role
          Container(
            margin: const EdgeInsets.only(left: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.13),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              customer.role == 'customer' ? 'Pelanggan' : customer.role.capitalize(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: 0.2,
              ),
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