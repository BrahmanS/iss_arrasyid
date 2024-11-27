import 'package:flutter/material.dart';
import 'package:iss/siswa/homeSiswa.dart';
import 'package:iss/Auth/login.dart';
import 'package:iss/SplashScreen.dart';
import 'package:iss/Ortu/HomeOrtu.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iss/Services/auth_service.dart';
void main() {
  runApp(
    ChangeNotifierProvider(
        create: (context) => UserDataProvider(),
        child: MyApp(), 
      ),
  );
} 

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arrasyid',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/siswaHome': (context) => HomeSiswa(),
        '/ortuHome': (context) => HomeOrtuPage(),
      },
    );
  }
}
