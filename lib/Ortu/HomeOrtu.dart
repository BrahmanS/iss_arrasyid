import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iss/Layout/AppbarOrtu.dart';
import 'package:iss/Layout/BottomBarOrtu.dart';
import 'package:iss/Ortu/ProgressPembelajaranOrtu.dart';
import 'package:iss/Layout/DrawerOrtu.dart';
import 'package:iss/Ortu/DaftarTagihan.dart';
import 'package:iss/Ortu/CatatanSiswa.dart';
import 'package:iss/Ortu/HasilAsesmentortu.dart';
import 'package:iss/Ortu/jadwalortu.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Services/parent_service.dart';
import 'package:iss/Services/invoice_service.dart'; // Import the InvoiceService
import 'package:iss/Ortu/JadwalAkademikOrtu.dart';
import 'package:iss/Ortu/DaftarPenyerahanortu.dart'; // Import the new page
import 'package:iss/Ortu/pilih_semester.raport.dart';
import 'package:iss/Ortu/DaftarHasilTugasOrtu.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iss/Services/shared_prefs.dart';
class StudentInfo {
  final String studentName;

  StudentInfo({
    required this.studentName,
  });
}

class HomeOrtuPage extends StatefulWidget {
  @override
  _HomeOrtuPageState createState() => _HomeOrtuPageState();
}

class _HomeOrtuPageState extends State<HomeOrtuPage> {
  // Initialize with a default future value
  Future<List<StudentInfo>> futureStudents = Future.value([]);
  Future<int> futureSubmittedAssignmentCount = Future.value(0);
  Future<Map<String, dynamic>> futureInvoiceData = Future.value({'totalAmount': 0.0, 'totalUnpaid': 0.0});

  @override
  void initState() {
    super.initState();
    _fetchData();
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    // if (sessionId != null) {
    //   futureStudents = fetchStudents(sessionId);
    //   futureSubmittedAssignmentCount = fetchSubmittedAssignmentCount(sessionId);
    //   futureInvoiceData = fetchInvoiceData(sessionId); // Fetch invoice data
    // } else {
    //   // Handle the null session ID case
    //   print('Session ID is null');
    // }
  }

  Future<void> _fetchData() async {
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
    if (sessionId2 != null) {
      setState(() {
        futureStudents = fetchStudents(sessionId2);
        futureSubmittedAssignmentCount = fetchSubmittedAssignmentCount(sessionId2);
        futureInvoiceData = fetchInvoiceData(sessionId2); // Fetch invoice data
      });
      
      
    } else {
      // Handle the null session ID case
      print('Session ID is null');
    }
  }

  Future<List<StudentInfo>> fetchStudents(String sessionId) async {
    final apiService = ParentService();
    final result = await apiService.getChildrenData(sessionId);

    final students = (result['children'] as List)
        .map((data) => StudentInfo(studentName: data['name']))
        .toList();

    return students;
  }

  Future<int> fetchSubmittedAssignmentCount(String sessionId) async {
    final apiService = ParentService();
    final submittedAssignments = await apiService.fetchSubmittedAssignmentsChildren(sessionId);
    return submittedAssignments.length;
  }

  Future<Map<String, dynamic>> fetchInvoiceData(String sessionId) async {
    final invoiceService = InvoiceService();
    final invoiceData = await invoiceService.fetchInvoices(sessionId);

    // Calculate the totals
    double totalAmount = 0;
    double totalUnpaid = 0;

    for (var invoice in invoiceData['data']) {
      totalAmount += invoice['amount_total'] ?? 0;
      totalUnpaid += invoice['amount_residual'] ?? 0;
    }

    return {
      'totalAmount': totalAmount,
      'totalUnpaid': totalUnpaid,
    };
  }

  String? _extractSessionId(String sessionIdCookie) {
    try {
      final parts = sessionIdCookie.split(';');
      for (final part in parts) {
        final trimmedPart = part.trim();
        if (trimmedPart.startsWith('session_id=')) {
          return trimmedPart.split('=')[1];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: CustomAppBarortu(),
    drawer: CustomDrawerortu(),
    body: LayoutBuilder(
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildMenuItem(Icons.assignment, 'Catatan Siswa', context, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => StudentReportPage()),
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildMenuItem(Icons.payment, 'Tagihan dan Pembayaran', context, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TagihanPage()),
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildMenuItem(Icons.access_time_filled, 'Jadwal Pelajaran', context, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ScheduleScreenortu()),
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildMenuItem(Icons.bar_chart, 'Progress Pembelajaran', context, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProgressOrtuPage()),
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildMenuItem(FontAwesomeIcons.chartLine, 'Hasil Pembelajaran', context, () {
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
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildMenuItem(FontAwesomeIcons.listCheck, 'Raport', context, () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => smtrapot()),
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildMenuItem(FontAwesomeIcons.clipboardList, 'Daftar Tugas Siswa', context, () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Penyerahanortu()),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _buildSectionTitle('Nama Siswa'),
                FutureBuilder<List<StudentInfo>>(
                  future: futureStudents,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No students found');
                    } else {
                      return Column(
                        children: snapshot.data!
                            .map((student) => _buildStudentInfoCard(student))
                            .toList(),
                      );
                    }
                  },
                ),
                SizedBox(height: 20),
                _buildSectionTitle('Tugas'),
                FutureBuilder<int>(
                  future: futureSubmittedAssignmentCount,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      int assignmentCount = snapshot.data ?? 0;
                      return _buildDaftarTugasCard(assignmentCount);
                    }
                  },
                ),
                SizedBox(height: 20),
                _buildSectionTitle('Tagihan dan Pembayaran'),
                FutureBuilder<Map<String, dynamic>>(
                  future: futureInvoiceData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      double totalAmount = snapshot.data?['totalAmount'] ?? 0.0;
                      double totalUnpaid = snapshot.data?['totalUnpaid'] ?? 0.0;
                      return _buildTagihanCard(totalAmount, totalUnpaid);
                    }
                  },
                ),
                SizedBox(height: 20),
                _buildSectionTitle('Kalender akademik'),
                _buildAcademicCalendarCard(),
              ],
            ),
          ),
        );
      },
    ),
    bottomNavigationBar: CustomBottomBarortu(),
  );
}

  Widget _buildStudentInfoCard(StudentInfo student) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    elevation: 4.0,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(
            Icons.person,
            size: 40.0,
            color: Color(0xFF2162B6),
          ),
          SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nama siswa',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                student.studentName,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    ),
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

  Widget _buildAcademicCalendarCard() {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    elevation: 4.0,
    child: ListTile(
      leading: Icon(
        Icons.calendar_today,
        color: Color(0xFF2162B6),
        size: 40.0,
      ),
      title: Text(
        'Kalender Akademik',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text('Lihat kalender akademik.'),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalendarOrtuScreen()),
        );
      },
    ),
  );
}

  Widget _buildTagihanCard(double totalAmount, double totalUnpaid) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    elevation: 4.0,
    child: ListTile(
      leading: Icon(
        Icons.payment,
        color: Color(0xFF2162B6),
        size: 40.0,
      ),
      title: Text(
        'Tagihan dan Pembayaran',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Tagihan: Rp ${totalAmount.toStringAsFixed(2)}'),
          Text('Belum Dibayar: Rp ${totalUnpaid.toStringAsFixed(2)}'),
        ],
      ),
    ),
  );
}

  Widget _buildDaftarTugasCard(int assignmentCount) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    elevation: 4.0,
    child: ListTile(
      leading: Icon(
        Icons.assignment_turned_in,
        color: Color(0xFF2162B6),
        size: 40.0,
      ),
      title: Text(
        'Tugas',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text('$assignmentCount tugas telah dikumpulkan.'),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Penyerahanortu()),
        );
      },
    ),
  );
}
}
