import 'package:flutter/material.dart';
import 'package:pilot_repair/services/auth_service.dart';
import 'package:pilot_repair/screens/profile_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
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
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;
    final isProfileComplete = _isProfileComplete(currentUser);

          return Scaffold(
      backgroundColor: surfaceColor,
            appBar: AppBar(
        backgroundColor: Colors.white,
              elevation: 0,
        title: Text(
                'Notifikasi',
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
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome notification
          _buildNotificationCard(
            icon: Icons.celebration_rounded,
            title: 'Selamat Datang! 🎉',
            message: 'Terima kasih telah bergabung dengan Pilot Repair. Kami siap membantu memperbaiki smartphone Anda.',
            time: DateTime.now(),
            color: successColor,
            isRead: false,
          ),
          
          const SizedBox(height: 16),
          
          // Profile completion reminder
          if (!isProfileComplete)
            _buildNotificationCard(
              icon: Icons.person_add_rounded,
              title: 'Lengkapi Profil Anda',
              message: 'Mohon lengkapi data profil Anda untuk pengalaman yang lebih baik.',
              time: DateTime.now().subtract(const Duration(hours: 1)),
              color: warningColor,
              isRead: false,
              actionButton: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Lengkapi Profil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: warningColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          
          if (isProfileComplete) ...[
            const SizedBox(height: 16),
            _buildNotificationCard(
              icon: Icons.check_circle_rounded,
              title: 'Profil Lengkap ✅',
              message: 'Terima kasih telah melengkapi profil Anda. Sekarang Anda dapat menggunakan semua fitur aplikasi.',
              time: DateTime.now().subtract(const Duration(hours: 2)),
              color: successColor,
              isRead: true,
            ),
          ],
          
          const SizedBox(height: 16),
          
          // App info notification
          _buildNotificationCard(
            icon: Icons.info_rounded,
            title: 'Tentang Aplikasi',
            message: 'Pilot Repair adalah aplikasi servis smartphone yang menghubungkan Anda dengan teknisi profesional.',
            time: DateTime.now().subtract(const Duration(days: 1)),
            color: primaryColor,
            isRead: true,
          ),
        ],
      ),
    );
  }

  bool _isProfileComplete(dynamic user) {
    if (user == null) return false;
    
    // Check if essential profile fields are filled
    return user.name != null && 
           user.name.isNotEmpty && 
           user.phone != null && 
           user.phone.isNotEmpty;
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String message,
    required DateTime time,
    required Color color,
    required bool isRead,
    Widget? actionButton,
  }) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                            child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                                  Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(time),
                        style: GoogleFonts.inter(
                                      fontSize: 12,
                          color: textColor.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                ),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                                  decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textColor.withOpacity(0.8),
                height: 1.4,
              ),
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 12),
              actionButton,
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
          begin: 0.2,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
    );
  }
} 