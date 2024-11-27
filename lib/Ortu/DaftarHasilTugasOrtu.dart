import 'package:flutter/material.dart';
import 'package:iss/Layout/AppbarOrtu.dart';
import 'package:iss/Layout/drawerOrtu.dart';
import 'package:iss/Layout/BottombarOrtu.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Services/parent_service.dart';
import 'package:intl/intl.dart';
import 'package:iss/Services/shared_prefs.dart';
class HasilTugasPageortu extends StatefulWidget {
  @override
  _HasilTugasPageortuState createState() => _HasilTugasPageortuState();
}

class _HasilTugasPageortuState extends State<HasilTugasPageortu> with TickerProviderStateMixin {
  // late Future<List<dynamic>> _hasilTugasFuture;
  Future<List<dynamic>>? _hasilTugasFuture;
  late AnimationController _controller;
  String? _selectedMonth;

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
    //   _hasilTugasFuture = ParentService().fetchSubmittedAssignmentsChildren(sessionId);
    // } else {
    //   print('Error: session_id is null');
    // }
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
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
        _hasilTugasFuture = ParentService().fetchSubmittedAssignmentsChildren(sessionId2);
      });
      // _hasilTugasFuture = ParentService().fetchSubmittedAssignmentsChildren(sessionId2);
    } else {
      print('Error: session_id is null');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      final date = DateFormat('yyyy-MM-dd').parse(submissionDate);
      final formattedMonth = DateFormat('MMMM').format(date);
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

                  final assignments = snapshot.data!.where((assignment) => _isWithinSelectedMonth(assignment['submission_date'])).toList();
                  _controller.forward(); // Start the animation when data is loaded
                  
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
                      return FadeTransition(
                        opacity: Tween(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Interval((1 / assignments.length) * index, 1.0, curve: Curves.easeOut),
                          ),
                        ),
                        child: TaskCard(
                          subject: assignment['assignment_name'] ?? 'No name',
                          submissionDate: assignment['submission_date'] ?? 'No date',
                          score: assignment['marks'] ?? 0.0,
                          studentName: assignment['student_name'] ?? 'Unknown',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBarortu(),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String subject;
  final String studentName;
  final String submissionDate;
  final double score;

  const TaskCard({
    Key? key,
    required this.subject,
    required this.studentName,
    required this.submissionDate,
    required this.score,
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
          Image.asset(
            'assets/images/e learning.jpg',
            fit: BoxFit.cover,
            height: 50,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 50,
              color: Colors.grey[200],
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
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
                  studentName,
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
                        // Action on button press
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
