import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pilot_repair/models/order.dart';
import 'package:pilot_repair/screens/chat_page.dart';
import 'package:pilot_repair/services/api_service.dart';
import 'package:pilot_repair/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late Future<List<Order>> _ordersFuture;
  Timer? _refreshTimer;

  // Modern color scheme
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
    _loadOrders();
    // Auto refresh every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _loadOrders();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadOrders() {
    final user = AuthService.currentUser;
    if (user != null && user.id != null) {
      setState(() {
        _ordersFuture = ApiService.fetchUserOrders(user.id!);
      });
    } else {
      setState(() {
        _ordersFuture = Future.value([]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Chat',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: _loadOrders,
          ),
        ],
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
                    'Memuat chat...',
                    style: GoogleFonts.inter(
                      color: textColor.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: dangerColor),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat daftar chat',
                    style: GoogleFonts.inter(color: dangerColor),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _loadOrders,
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
            );
          }

          final orders = snapshot.data ?? [];
          final acceptedOrders = orders.where((order) => order.status == 'accepted').toList();

          if (acceptedOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada chat tersedia',
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chat akan tersedia setelah teknisi menerima pesanan Anda',
                    style: GoogleFonts.inter(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: acceptedOrders.length,
            itemBuilder: (context, index) {
              final order = acceptedOrders[index];
              return _buildChatCard(order).animate().fadeIn(
                    duration: 300.ms,
                    delay: Duration(milliseconds: index * 100),
                  ).slideX(
                    begin: 0.2,
                    end: 0,
                    duration: 300.ms,
                    delay: Duration(milliseconds: index * 100),
                  );
            },
          );
        },
      ),
    );
  }

  Widget _buildChatCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: successColor.withOpacity(0.13),
          child: Icon(
            Icons.engineering_rounded,
            color: successColor,
            size: 24,
          ),
        ),
        title: Text(
          'Chat dengan Teknisi',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: textColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              order.namaLayanan ?? 'Layanan',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Order #${order.id}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: textColor.withOpacity(0.5),
              ),
            ),
            if (order.createdAt != null) ...[
              const SizedBox(height: 2),
              Text(
                'Diterima: ${DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt!)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: textColor.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(order: order),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(order: order),
            ),
          );
        },
      ),
    );
  }
} 