import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/services/service_screen.dart';

final Map<String, WidgetBuilder> routes = {
  '/login': (context) => const LoginScreen(),
  '/dashboard': (context) => const DashboardScreen(),
  '/orders': (context) => const OrdersScreen(),
  '/services': (context) => const ServiceScreen(),
}; 