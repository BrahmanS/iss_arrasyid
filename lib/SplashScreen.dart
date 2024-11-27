import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iss/Services/shared_prefs.dart'; // Pastikan untuk mengimpor SharedPrefs

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SharedPrefs _sharedPrefs = SharedPrefs(); // Buat instance SharedPrefs

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Ambil session ID dan tipe user
    String? sessionId = await _sharedPrefs.getSessionId();
    String? userType = await _sharedPrefs.getTipeUser();

    // Tambahkan delay untuk menampilkan splash screen selama beberapa detik
    await Future.delayed(Duration(seconds: 3));

    // Navigasi ke halaman yang sesuai berdasarkan status login
    if (sessionId != null && userType != null) {
      switch (userType) {
        case 'siswa':
          Navigator.pushReplacementNamed(context, '/siswaHome');
          break;
        case 'ortu':
          Navigator.pushReplacementNamed(context, '/ortuHome');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/login');
          break;
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo arrasyid.png',
              width: 250,
              height: 250,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
