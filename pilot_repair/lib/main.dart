import 'package:flutter/material.dart';
import 'package:pilot_repair/widgets/auth_wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pilot Repair',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16A07A)),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const AuthWrapper(),
      },
    );
  }
}
