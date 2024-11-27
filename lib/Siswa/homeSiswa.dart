import 'package:flutter/material.dart';
import 'package:iss/Layout/appbar.dart';
import 'package:iss/Layout/bottombar.dart';
import 'package:iss/Siswa/HasilPembelajaranTugas.dart';
import 'package:iss/Siswa/HasilAssesment.dart';
import 'package:iss/Siswa/DaftarTugas.dart';
import 'package:iss/Siswa/DaftarBuku.dart';
import 'package:iss/Siswa/DaftarPeminjaman.dart';
import 'package:iss/Siswa/Penyerahantugas.dart';
import 'package:iss/Siswa/Profile.dart';
import 'package:iss/Siswa/jadwal.dart';
import 'package:iss/auth/login.dart';
import 'package:iss/Siswa/Notifikasi.dart';
import 'package:iss/Layout/drawer.dart';
import 'package:iss/Siswa/ProgressPembelajaran.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Services/assignment_service.dart';
import 'package:iss/Services/perpustakaan_service.dart';
import 'package:iss/Siswa/JadwalAkademik.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iss/Services/shared_prefs.dart';

class HomeSiswa extends StatefulWidget {
  static const String routeName = '/home';

  @override
  _HomeSiswaState createState() => _HomeSiswaState();
}

class _HomeSiswaState extends State<HomeSiswa> {
  int totalAssignments = 0;
  int submittedAssignments = 0;
  int totalBookLoans = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    
    final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
    print('Session ID 2 from SharedPreferences: $sessionId2');
    if (sessionId2 != null) {
      try {
        final assignmentService = AssignmentService();
        final perpustakaanService = PerpustakaanService();

        final assignments = await assignmentService.fetchAssignments(sessionId2);
        final submittedAssignmentsData = await assignmentService.fetchSubmittedAssignments(sessionId2);
        final bookLoans = await perpustakaanService.fetchQueueRequests(sessionId2);

        setState(() {
          totalAssignments = assignments.length;
          submittedAssignments = submittedAssignmentsData.length;
          totalBookLoans = bookLoans.length;
          isLoading = false;
        });
      } catch (e) {
        print('Error fetching data: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  // String? _extractSessionId(String sessionIdCookie) {
  //   try {
  //     final parts = sessionIdCookie.split(';');
  //     for (final part in parts) {
  //       final trimmedPart = part.trim();
  //       if (trimmedPart.startsWith('session_id=')) {
  //         return trimmedPart.split('=')[1];
  //       }
  //     }
  //     return null;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMenuItem(Icons.assignment, 'Tugas', context, () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Tugas'),
                                      actions: [
                                        TextButton(
                                          child: Text('Penyerahan Tugas'),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => PenyerahanTugasPage()),
                                            );
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Lihat Tugas'),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => TaskListPage()),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }),
                              _buildMenuItem(Icons.library_books, 'Perpustakaan', context, () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Perpustakaan'),
                                      actions: [
                                        TextButton(
                                          child: Text('Daftar Pengajuan Peminjaman'),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => DaftarPengajuanPeminjamanPage()),
                                            );
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Daftar Buku'),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => PerpustakaanPage()),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }),
                              _buildMenuItem(Icons.schedule, 'Jadwal Pelajaran', context, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ScheduleScreen()),
                                );
                              }),
                              _buildMenuItem(Icons.bar_chart, 'Progress Pembelajaran', context, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ProgressPage()),
                                );
                              }),
                              _buildMenuItem(FontAwesomeIcons.chartLine, 'Hasil Pembelajaran', context, () {
                                showDialog( 
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Hasil Pembelajaran'),
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
                              }),
                            ],
                          ),
                        ),
                        SizedBox(height: 18),
                        _buildTaskSummaryCard(),
                        SizedBox(height: 18),
                        _buildLibrarySummaryCard(),
                        SizedBox(height: 18),
                        _buildAcademicCalendarCard(context),
                        SizedBox(height: 18),
                        _buildElearningCard(context),
                        
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, BuildContext context, VoidCallback onTap) {
    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFF2162B6),
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            SizedBox(height: 10),
            Container(
              width: 80,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

 Widget _buildAcademicCalendarCard(BuildContext context) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 50, color: Colors.blue),
              SizedBox(width: 12),
              Text('Kalender akademik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          ElevatedButton(
            child: Text('Lihat'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildElearningCard(BuildContext context) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.computer, size: 50, color: Colors.blue),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kelas E-learning', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Masuk kelas online'),
                ],
              ),
            ],
          ),
          ElevatedButton(
            child: Text('Masuk'),
            onPressed: () async {
              final Uri url = Uri.parse('https://arrasyid-bsd.id/slides/all');
              if (!await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not launch the E-learning link')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Replaces `primary`
              foregroundColor: Colors.white, // Replaces `onPrimary`
            ),

          ),
        ],
      ),
    ),
  );
}

  Widget _buildTaskSummaryCard() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, size: 50, color: Colors.blue),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tugas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Total: $totalAssignments, Dikumpulkan: $submittedAssignments'),
                ],
              ),
            ],
          ),
          
        ],
      ),
    ),
  );
}

 Widget _buildLibrarySummaryCard() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.library_books, size: 50, color: Colors.blue),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Perpustakaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Total Peminjaman: $totalBookLoans'),
                ],
              ),
            ],
          ),
          
        ],
      ),
    ),
  );
}
}
