import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:iss/Layout/appbar.dart';
import 'package:iss/Layout/bottombar.dart';
import 'package:iss/Layout/drawer.dart';
import 'package:iss/Services/assignment_service.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:http/http.dart' as http;
import 'package:iss/Services/elearning_service.dart';
import 'dart:convert';
import 'package:iss/Services/shared_prefs.dart';

class ProgressPage extends StatefulWidget {
  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  // late Future<List<dynamic>> _submittedAssignmentsFuture;
  // late Future<Map<String, dynamic>> _userQuizzesFuture;
  Future<List<dynamic>>? _submittedAssignmentsFuture;
  Future<Map<String, dynamic>>? _userQuizzesFuture;

  @override
  void initState() {
    super.initState();
    _initializeProgress();
    // final userDataProvider =
    //     Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    // if (sessionId != null) {
    //   _submittedAssignmentsFuture =
    //       AssignmentService().fetchSubmittedAssignments(sessionId);
    //   _userQuizzesFuture = ELearningService().fetchUserQuizzes(sessionId);
    // } else {
    //   print('Error: session_id is null');
    // }
  }
  Future<void> _initializeProgress() async {
    // final userDataProvider =
    //     Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
    if (sessionId2 != null) {
      setState(() {
        _submittedAssignmentsFuture = AssignmentService().fetchSubmittedAssignments(sessionId2);
        _userQuizzesFuture = ELearningService().fetchUserQuizzes(sessionId2);
      });
      // _submittedAssignmentsFuture = AssignmentService().fetchSubmittedAssignments(sessionId2);
      // _userQuizzesFuture = ELearningService().fetchUserQuizzes(sessionId2);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Progres Pembelajaran',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Hasil Pembelajaran (Tugas)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 200,
              child: FutureBuilder<List<dynamic>>(
                future: _submittedAssignmentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Tidak ada progress tugas'));
                  }

                  final assignments = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: assignments.length * 100.0,
                      // Adjust width based on number of assignments
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          majorGridLines: MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          axisLine: AxisLine(width: 0),
                          majorTickLines: MajorTickLines(size: 0),
                          maximum: 100,
                        ),
                        tooltipBehavior: TooltipBehavior(
                            enable: true, header: '', canShowMarker: false),
                        series: <ColumnSeries<ProgressData, String>>[
                          ColumnSeries<ProgressData, String>(
                            dataSource: assignments.map((assignment) {
                              return ProgressData(
                                assignment['assignment_name'] ?? 'No name',
                                (assignment['marks'] ?? 0).toDouble(),
                              );
                            }).toList(),
                            xValueMapper: (ProgressData data, _) => data.title,
                            yValueMapper: (ProgressData data, _) => data.score,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(fontSize: 10),
                            ),
                            spacing: 0.2, // Add spacing between bars
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Hasil Pembelajaran (Quiz)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              height: 200,
              child: FutureBuilder<Map<String, dynamic>>(
                future: _userQuizzesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!['quizzes'].isEmpty) {
                    return Center(child: Text('Tidak ada progress quiz'));
                  }

                  final quizzes = snapshot.data!['quizzes'] as List<dynamic>;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: quizzes.length * 100.0, // Adjust width based on number of quizzes
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          majorGridLines: MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          axisLine: AxisLine(width: 0),
                          majorTickLines: MajorTickLines(size: 0),
                          maximum: 100,
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true, header: '', canShowMarker: false),
                        series: <ColumnSeries<ProgressData, String>>[
                          ColumnSeries<ProgressData, String>(
                            dataSource: quizzes.map((quiz) {
                              return ProgressData(
                                quiz['slide_name'] ?? 'No name',
                                _getScore(quiz).toDouble(),
                              );
                            }).toList(),
                            xValueMapper: (ProgressData data, _) => data.title,
                            yValueMapper: (ProgressData data, _) => data.score,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(fontSize: 10),
                            ),
                            spacing: 0.2, // Add spacing between bars
                          )
                        ],
                      ),
                    ),
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

class ProgressData {
  ProgressData(this.title, this.score);
  final String title;
  final double score;
}
