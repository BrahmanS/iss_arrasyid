import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iss/Layout/AppbarOrtu.dart';
import 'package:iss/Layout/BottomBarOrtu.dart';
import 'package:iss/Layout/DrawerOrtu.dart';
import 'package:iss/Services/activity_service.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:intl/intl.dart';
import 'package:iss/Services/shared_prefs.dart';

class StudentReportPage extends StatefulWidget {
  @override
  _StudentReportPageState createState() => _StudentReportPageState();
}

class _StudentReportPageState extends State<StudentReportPage> {
  late ActivityService _activityService;
  Future<Map<String, dynamic>>? _activitiesFuture;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _initializeActivity();
    _activityService = ActivityService();

    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);

    // if (sessionId != null) {
    //   _activitiesFuture = _activityService.fetchActivities(sessionId);
    // }
  }

  Future<void> _initializeActivity() async {
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
    if (sessionId2 != null) {
      setState(() {
        _activitiesFuture = ActivityService().fetchActivities(sessionId2);
      });
      // _activitiesFuture = ActivityService().fetchActivities(sessionId2);
    } else {
      print('Error: session_id is null');
    }
  }

  // String? _extractSessionId(String? sessionIdCookie) {
  //   if (sessionIdCookie == null) return null;

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

  bool _isWithinSelectedMonth(String date) {
    if (_selectedMonth == null) return true;
    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      final formattedMonth = DateFormat('MMMM').format(parsedDate);
      return formattedMonth == _selectedMonth;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarortu(),
      drawer: CustomDrawerortu(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: Text('Pilih Bulan'),
              value: _selectedMonth,
              items: DateFormat('MMMM').dateSymbols.MONTHS.map((month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(month),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _activitiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  final error = snapshot.error.toString();
                  if (error.contains("No students found for this parent")) {
                    return Center(child: Text('Tidak ada siswa'));
                  } else {
                    return Center(child: Text('Error: $error'));
                  }
                } else if (!snapshot.hasData || snapshot.data!['submitted_assignments'].isEmpty) {
                  return Center(child: Text('Tidak ada catatan siswa'));
                } else {
                  final activities = snapshot.data!['submitted_assignments']
                      .where((activity) => _isWithinSelectedMonth(activity['date']))
                      .toList();
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return _buildReportCard(
                        context,
                        activity['student_id']['name'],
                        activity['faculty_id']['name'] ?? 'Guru tidak tersedia',
                        activity['date'],
                        activity['type_id']['name'] ?? 'Laporan tidak tersedia',
                        activity['description'],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBarortu(),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String studentName,
    String teacherName,
    String date,
    String reportType,
    String reportDetails,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$studentName dari guru $teacherName',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.topRight,
              child: Text(
                'Tanggal : $date',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(reportType),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Isi Catatan'),
                        content: Text(reportDetails),
                        actions: [
                          TextButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Lihat Catatan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
