import 'package:flutter/material.dart';
import 'package:pilot_repair/curved_navigation_bar.dart';
import 'package:pilot_repair/screens/home_screen.dart';
import 'package:pilot_repair/screens/pengembangan.dart';
import 'package:pilot_repair/screens/teknisi_dashboard.dart';
import 'package:pilot_repair/screens/profile_page.dart';
import 'package:pilot_repair/screens/notification_page.dart';
import 'package:pilot_repair/screens/chat_page.dart';
import 'package:pilot_repair/services/api_service.dart';
import 'package:pilot_repair/services/auth_service.dart';
import 'package:pilot_repair/models/order.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with WidgetsBindingObserver {
  int _page = 1;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _pages = [
    TeknisiDashboardPage(technicianId: "TECH-001"),
    HomeScreen(),
    PengembanganPage(),
    PengembanganPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reset to home when app is resumed
      setState(() {
        _page = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page,
        items: <Widget>[
          _buildNavItem("assets/icons/store.png", "Toko", 0),
          _buildNavItem("assets/icons/home.png", "Beranda", 1),
          _buildNavItem("assets/icons/chat.png", "Pesan", 2),
          _buildNavItem("assets/icons/notif.png", "Notifikasi", 3),
          _buildNavItem("assets/icons/setting.png", "Profil", 4),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: const Color(0xFF16A07A),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 200),
        onTap: (index) async {
          if (index == 2) {
            // Chat icon - navigate directly to available chat
            setState(() {
              _page = index; // Update page to show chat as active
            });
            _navigateToAvailableChat();
          } else if (index == 3) {
            setState(() {
              _page = index; // Update page to show notification as active
            });
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
            // Reset to home when returning from notification
            setState(() {
              _page = 1;
            });
          } else {
            setState(() {
              _page = index;
            });
          }
        },
        letIndexChange: (index) => true,
      ),
      body: _pages[_page],
    );
  }

  void _navigateToAvailableChat() async {
    final user = AuthService.currentUser;
    if (user == null || user.id == null) {
      _showNoChatMessage();
      // Reset to home after showing message
      setState(() {
        _page = 1;
      });
      return;
    }

    try {
      final orders = await ApiService.fetchUserOrders(user.id!);
      final acceptedOrders = orders.where((order) => order.status == 'accepted').toList();

      if (acceptedOrders.isEmpty) {
        _showNoChatMessage();
        // Reset to home after showing message
        setState(() {
          _page = 1;
        });
        return;
      }

      // Navigate to the first available chat
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(order: acceptedOrders.first),
        ),
      );
      
      // Reset to home when returning from chat
      setState(() {
        _page = 1;
      });
    } catch (e) {
      _showNoChatMessage();
      // Reset to home after showing message
      setState(() {
        _page = 1;
      });
    }
  }

  void _showNoChatMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Belum ada chat tersedia. Chat akan muncul setelah teknisi menerima pesanan Anda.'),
        duration: Duration(seconds: 3),
        backgroundColor: Color(0xFF16A07A),
      ),
    );
  }

  Widget _buildNavItem(String assetPath, String label, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: _page == index ? const Color(0xFF16A07A) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: _page == index ? 0 : 10),
                child: Image.asset(
                  assetPath,
                  width: 20,
                  height: 20,
                  color: _page == index ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (_page != index)
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                color: Colors.black,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
} 