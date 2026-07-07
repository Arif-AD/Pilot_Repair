import 'package:flutter/material.dart';
import 'package:pilot_repair/screens/teknisi_dashboard.dart';
import 'package:pilot_repair/screens/pengembangan.dart';
import 'package:pilot_repair/screens/profile_page.dart';
import 'package:pilot_repair/curved_navigation_bar.dart';
import 'package:pilot_repair/screens/chat_list_page.dart';
import 'package:pilot_repair/screens/notification_page.dart';
import 'package:pilot_repair/screens/chat_page.dart';
import 'package:pilot_repair/services/api_service.dart';

class BottomNavBarTeknisi extends StatefulWidget {
  final String technicianId;
  const BottomNavBarTeknisi({super.key, required this.technicianId});

  @override
  State<BottomNavBarTeknisi> createState() => _BottomNavBarTeknisiState();
}

class _BottomNavBarTeknisiState extends State<BottomNavBarTeknisi> {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      TeknisiDashboardPage(technicianId: widget.technicianId),
      PengembanganPage(), // Pesan
      PengembanganPage(), // Notifikasi
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page,
        items: <Widget>[
          _buildNavItem("assets/icons/home.png", "Dashboard", 0),
          _buildNavItem("assets/icons/chat.png", "Pesan", 1),
          _buildNavItem("assets/icons/notif.png", "Notifikasi", 2),
          _buildNavItem("assets/icons/setting.png", "Profil", 3),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: const Color(0xFF16A07A),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 200),
        onTap: (index) async {
          if (index == 1) {
            setState(() {
              _page = index;
            });
            // Ambil order teknisi yang statusnya accepted
            final orders = await ApiService.fetchTechnicianOrders(widget.technicianId);
            final acceptedOrders = orders.where((order) => order.status == 'accepted').toList();
            if (acceptedOrders.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Belum ada chat tersedia. Chat akan muncul setelah menerima pesanan.'),
                  duration: Duration(seconds: 3),
                  backgroundColor: Color(0xFF16A07A),
                ),
              );
              setState(() {
                _page = 0;
              });
              return;
            }
            // Navigasi ke chat order accepted pertama
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatPage(order: acceptedOrders.first)),
            );
            setState(() {
              _page = 0;
            });
          } else if (index == 2) {
            setState(() {
              _page = index;
            });
            // Navigasi ke halaman notifikasi
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
            setState(() {
              _page = 0;
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