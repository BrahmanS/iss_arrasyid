import 'package:flutter/material.dart';
import 'package:iss/Ortu/HasilAsesmentOrtu.dart';
import 'package:iss/Siswa/DaftarBuku.dart';
import 'package:iss/Siswa/HasilAssesment.dart';
import 'package:iss/Siswa/HasilPembelajaranTugas.dart';
import 'package:iss/Ortu/ProfileOrtu.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iss/Siswa/homeSiswa.dart';
import 'package:iss/Ortu/HomeOrtu.dart';
import 'package:iss/Ortu/DaftarHasilTugasOrtu.dart';
import 'package:iss/Ortu/HasilAsesmentOrtu.dart';
import 'package:iss/Ortu/DaftarPenyerahanortu.dart'; // Import the new page
import 'package:iss/Ortu/pilih_semester.raport.dart';

class CustomBottomBarortu extends StatelessWidget {
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
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(FontAwesomeIcons.home, color: Colors.black),
            ),
            label: 'Dashboard',
          ),
          // BottomNavigationBarItem(
          //   icon: Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 8.0),
          //     child: Icon(FontAwesomeIcons.chartLine, color: Colors.black),
          //   ),
          //   label: 'Hasil Pembelajaran',
          // ),
          // BottomNavigationBarItem(
          //   icon: Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 8.0),
          //     child: Icon(FontAwesomeIcons.listCheck, color: Colors.black),
          //   ),
          //   label: 'Raport',
          // ),
          // BottomNavigationBarItem(
          //   icon: Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 8.0),
          //     child: Icon(FontAwesomeIcons.clipboardList, color: Colors.black),
          //   ),
          //   label: 'Daftar tugas siswa',
          // ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(FontAwesomeIcons.user, color: Colors.black),
            ),
            label: 'Profil',
          ),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeOrtuPage()),
              );
              break;
            // case 1:
            //   _showHasilPembelajaranOptions(context);
            //   break;
            // case 2:
            //   Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(builder: (context) => smtrapot()),
            //   );
            //   break;
              
            // case 3:
            //   Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(builder: (context) => Penyerahanortu()),
            //   );
            //   break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileOrtuPage()),
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
                    MaterialPageRoute(builder: (context) => AssesmentOrtuPage()),
                  );
                },
              ),
              ListTile(
                title: Text('Tugas'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HasilTugasPageortu()),
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
