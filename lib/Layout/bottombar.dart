import 'package:flutter/material.dart';
import 'package:iss/Siswa/DaftarBuku.dart';
import 'package:iss/Siswa/HasilAssesment.dart';
import 'package:iss/Siswa/HasilPembelajaranTugas.dart';
import 'package:iss/Siswa/Profile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iss/Siswa/homeSiswa.dart';

class CustomBottomBar extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.home, color: Colors.black),
            label: 'Dashboard',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(FontAwesomeIcons.chartLine, color: Colors.black),
          //   label: 'Hasil Pembelajaran',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(FontAwesomeIcons.book, color: Colors.black),
          //   label: 'Perpustakaan',
          // ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user, color: Colors.black),
            label: 'Profil',
          ),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeSiswa()),
              );
              break;
            // case 1:
            //   _showHasilPembelajaranOptions(context);
            //   break;
            // case 2:
            //   Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(builder: (context) => PerpustakaanPage()),
            //   );
            //   break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
          }
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black.withOpacity(0.7),
        selectedFontSize: 14,
        unselectedFontSize: 14,
        selectedLabelStyle: TextStyle(fontSize: 14),
        unselectedLabelStyle: TextStyle(fontSize: 14),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  void _showHasilPembelajaranOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Opsi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Assessment'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HasilAssesmentPage()),
                  );
                },
              ),
              ListTile(
                title: Text('Tugas'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HasilTugasPage()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

