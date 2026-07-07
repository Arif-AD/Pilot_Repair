import 'package:flutter/material.dart';

class PengembanganPage extends StatelessWidget {
  const PengembanganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih untuk halaman kosong
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo di tengah
            Image.asset(
              'assets/logo.png', // Ganti dengan path logo Anda
              width: 140, // Ukuran logo diperbesar
              height: 30, // Menyesuaikan ukuran tinggi logo
            ),
            const SizedBox(height: 10), // Jarak antara logo dan teks
            // Teks di bawah logo
            const Text(
              'Halaman saat ini belum tersedia\nsedang dalam pengembangan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 88, 88, 88),
              ),
            ),
            const SizedBox(height: 20), // Jarak sebelum tombol
          ],
        ),
      ),
    );
  }
}
