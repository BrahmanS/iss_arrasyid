import 'package:flutter/material.dart';
import 'package:iss/Layout/appbar.dart';
import 'package:iss/Layout/drawer.dart';
import 'package:iss/Layout/bottombar.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Services/assignment_service.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:iss/Services/shared_prefs.dart';

class HasilTugasPage extends StatefulWidget {
  @override
  _HasilTugasPageState createState() => _HasilTugasPageState();
}

class _HasilTugasPageState extends State<HasilTugasPage> {
  // late Future<List<dynamic>> _hasilTugasFuture;
  Future<List<dynamic>>? _hasilTugasFuture;
  String? _selectedMonth; // State to hold the selected month

  @override
  void initState() {
    super.initState();
    _initializeHasilTugas();
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    // print("Session ID:");
    // print(sessionId);
    // if (sessionId != null) {
    //   _hasilTugasFuture = AssignmentService().fetchSubmittedAssignments(sessionId);
    // } else {
    //   print('Error: session_id is null');
    // }
  }

  Future<void> _initializeHasilTugas() async {
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
    print("Session ID:");
    print(sessionId2);
    if (sessionId2 != null) {
      setState(() {
        _hasilTugasFuture = AssignmentService().fetchSubmittedAssignments(sessionId2);
      });
      // _hasilTugasFuture = AssignmentService().fetchSubmittedAssignments(sessionId2);
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

  bool _isWithinSelectedMonth(String submissionDate) {
    if (_selectedMonth == null) return true;
    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(submissionDate);
      final formattedMonth = DateFormat('MMMM').format(parsedDate);
      return formattedMonth == _selectedMonth;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hasil Tugas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
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
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _hasilTugasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Tidak ada tugas'));
                  }

                  final assignments = snapshot.data!
                      .where((assignment) => _isWithinSelectedMonth(assignment['submission_date']))
                      .toList();
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = assignments[index];
                      return TaskCard(
                        subject: assignment['subject_name'] ?? 'No name',
                        submissionDate: assignment['submission_date'] ?? 'No description',
                        score: assignment['marks'],
                        assignment_name: assignment['assignment_name'],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String subject;
  final String submissionDate;
  final double score;
  final String assignment_name;

  const TaskCard({
    Key? key,
    required this.subject,
    required this.submissionDate,
    required this.score,
    required this.assignment_name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/images/e learning.jpg', fit: BoxFit.cover, height: 50, width: double.infinity),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  assignment_name,
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'Tanggal pengumpulan: $submissionDate',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        //
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        'Skor: $score',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
