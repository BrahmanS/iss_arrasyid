import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iss/Layout/appbar.dart';
import 'package:iss/Layout/drawer.dart';
import 'package:iss/Layout/bottombar.dart';
import 'package:iss/Services/elearning_service.dart'; // import the quiz service
import 'package:iss/Provider/user_data_provider.dart'; // import the user data provider
import 'package:intl/intl.dart'; // import for date formatting
import 'package:iss/Services/shared_prefs.dart';

class AssignmentCard extends StatelessWidget {
  final String subject;
  final String studentName;
  final String submissionDate;
  final int score;

  const AssignmentCard({
    Key? key,
    required this.subject,
    required this.studentName,
    required this.submissionDate,
    required this.score,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 4,
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(8.0)),
              image: DecorationImage(
                image: AssetImage('assets/images/e learning.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('Tanggal penyerahan: $submissionDate', style: TextStyle(fontSize: 12)),
                  SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add your onPressed functionality here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Text(
                          'Skor : $score',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HasilAssesmentPage extends StatefulWidget {
  @override
  _HasilAssesmentPageState createState() => _HasilAssesmentPageState();
}

class _HasilAssesmentPageState extends State<HasilAssesmentPage> {
  late ELearningService _quizService;
  Future<Map<String, dynamic>>? _quizzesFuture;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _initializeQuizzes();
    _quizService = ELearningService();

    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);

    // if (sessionId != null) {
    //   _quizzesFuture = _quizService.fetchUserQuizzes(sessionId);
    // }
  }

  Future<void> _initializeQuizzes() async {
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();

    if (sessionId2 != null) {
      setState(() {
        _quizzesFuture = _quizService.fetchUserQuizzes(sessionId2);
      });
      // _quizzesFuture = _quizService.fetchUserQuizzes(sessionId2);
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

  String _formatTimestamp(double timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).toInt());
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: Text('Pilih Bulan'),
              value: _selectedMonth,
              onChanged: (newValue) {
                setState(() {
                  _selectedMonth = newValue;
                });
              },
              items: List.generate(12, (index) {
                return DropdownMenuItem(
                  value: (index + 1).toString().padLeft(2, '0'),
                  child: Text(DateFormat.MMMM().format(DateTime(0, index + 1))),
                );
              }),
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _quizzesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!['quizzes'].isEmpty) {
                  return Center(child: Text('Tidak ada hasil quiz'));
                } else {
                  final quizzes = snapshot.data!['quizzes']
                      .where((quiz) => _selectedMonth == null ||
                          _formatTimestamp(quiz['slide_completion_time']).substring(5, 7) == _selectedMonth)
                      .toList();

                  if (quizzes.isEmpty) {
                    return Center(child: Text('Tidak ada hasil quiz di bulan yang dipilih'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: quizzes.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            'Hasil Assesment',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      final quiz = quizzes[index - 1];
                      final score = _getScore(quiz);
                      final submissionDate = _formatTimestamp(quiz['slide_completion_time']);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: AssignmentCard(
                          subject: quiz['slide_name'],
                          studentName: '', // Add student name if available in the quiz data
                          submissionDate: submissionDate,
                          score: score,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }

  int _getScore(Map<String, dynamic> quiz) {
    final attemptsCount = quiz['quiz_attempts_count'];
    int score;
    switch (attemptsCount) {
      case 1:
        score = quiz['slide_first'];
        break;
      case 2:
        score = quiz['slide_second'];
        break;
      case 3:
        score = quiz['slide_third'];
        break;
      default:
        score = quiz['slide_fourth'];
    }
    return score * 10;
  }
}
