import 'package:flutter/material.dart';
import 'package:pilot_repair/screens/onboarding_screen.dart';
import 'package:pilot_repair/screens/login_page.dart';
import 'package:pilot_repair/services/auth_service.dart';
import 'package:pilot_repair/widgets/bottom_nav_bar.dart';
import 'package:pilot_repair/widgets/bottom_nav_bar_teknisi.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize auth service
      await AuthService.initialize();
      
      // Check if user has seen onboarding
      _hasSeenOnboarding = await AuthService.hasSeenOnboarding();
      
      // Check if user is logged in
      _isLoggedIn = AuthService.isLoggedIn;
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing app: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F5FF),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF16A07A),
          ),
        ),
      );
    }

    // If user hasn't seen onboarding, show onboarding screen
    if (!_hasSeenOnboarding) {
      return const OnboardingScreen();
    }

    // If user is logged in, show main app based on role
    if (_isLoggedIn) {
      final user = AuthService.currentUser;
      if (user != null && user.role == 'technician') {
        return BottomNavBarTeknisi(technicianId: user.id.toString());
      } else {
        return const BottomNavBar();
      }
    }

    // If user has seen onboarding but not logged in, show login page
    return const LoginPage();
  }
} 