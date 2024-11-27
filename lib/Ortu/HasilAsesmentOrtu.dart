import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iss/Layout/AppbarOrtu.dart';
import 'package:iss/Layout/drawerOrtu.dart';
import 'package:iss/Layout/BottombarOrtu.dart';
import 'package:iss/Services/elearning_service.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:intl/intl.dart';
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
      margin: EdgeInsets.only(bottom: 10.0),
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
                  Text('Siswa: $studentName', style: TextStyle(fontSize: 12)),
                  Text('Tanggal penyerahan: $submissionDate', style: TextStyle(fontSize: 12)),
                  SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Text('Skor: $score', style: TextStyle(fontSize: 12, color: Colors.white)),
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

class AssesmentOrtuPage extends StatefulWidget {
  @override
  _AssesmentOrtuPageState createState() => _AssesmentOrtuPageState();
}

class _AssesmentOrtuPageState extends State<AssesmentOrtuPage> with TickerProviderStateMixin {
  late ELearningService _quizService;
  Future<Map<String, dynamic>>? _quizzesFuture;
  late AnimationController _controller;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _initializeHasilQuiz();
    _quizService = ELearningService();

    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);

    // if (sessionId != null) {
    //   _quizzesFuture = _quizService.fetchChildQuizzes(sessionId);
    // }

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  Future<void> _initializeHasilQuiz() async {
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
    if (sessionId2 != null) {
      setState(() {
        _quizzesFuture = ELearningService().fetchChildQuizzes(sessionId2);
      });
      // _quizzesFuture = _quizService.fetchChildQuizzes(sessionId2);
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

  String _formatTimestamp(double timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).toInt());
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  bool _isWithinSelectedMonth(double timestamp) {
    if (_selectedMonth == null) return true;
    final date = DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).toInt());
    final formattedMonth = DateFormat('MMMM').format(date);
    return formattedMonth == _selectedMonth;
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
              future: _quizzesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!['children_quizzes'] == null || snapshot.data!['children_quizzes'].isEmpty) {
                  return Center(child: Text('Tidak ada assessment'));
                } else {
                  final childrenQuizzes = snapshot.data!['children_quizzes'];
                  _controller.forward();

                  return ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: childrenQuizzes.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            'Hasil Assesment',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      final child = childrenQuizzes[index - 1];
                      final childName = child['child_name'];
                      final quizzes = child['quizzes'].where((quiz) => _isWithinSelectedMonth(quiz['slide_completion_time'])).toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: quizzes.map<Widget>((quiz) {
                          final score = _getScore(quiz);
                          final submissionDate = _formatTimestamp(quiz['slide_completion_time']);
                          return FadeTransition(
                            opacity: Tween(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _controller,
                                curve: Interval((1 / quizzes.length) * index, 1.0, curve: Curves.easeOut),
                              ),
                            ),
                            child: AssignmentCard(
                              subject: quiz['slide_name'],
                              studentName: childName,
                              submissionDate: submissionDate,
                              score: score,
                            ),
                          );
                        }).toList(),
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
