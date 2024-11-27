import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:iss/Layout/AppbarOrtu.dart';
import 'package:iss/Layout/drawerOrtu.dart';
import 'package:iss/Layout/BottombarOrtu.dart';
import 'package:iss/services/parent_service.dart';
import 'package:iss/services/elearning_service.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Services/shared_prefs.dart';
class ProgressOrtuPage extends StatefulWidget {
  @override
  _ProgressOrtuPageState createState() => _ProgressOrtuPageState();
}

class _ProgressOrtuPageState extends State<ProgressOrtuPage> {
  Future<List<ProgressData>> futureAssignmentData = Future.value([]);
  Future<List<ProgressData>> futureQuizData = Future.value([]);

  @override
  void initState() {
    super.initState();
    futureAssignmentData = fetchProgressData();
    futureQuizData = fetchQuizData();
  }

  Future<List<ProgressData>> fetchProgressData() async {
    try {
      // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      // final sessionIdCookie = userDataProvider.userData?['session_id'];
      // print("Session ID:");
      // print(sessionIdCookie);
      // final sessionId = _extractSessionId(sessionIdCookie);
      final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
      if (sessionId2 == null) {
        throw Exception('Session ID is null');
      }

      final parentService = ParentService();
      final submittedAssignments = await parentService.fetchSubmittedAssignmentsChildren(sessionId2);

      List<ProgressData> progressData = [];
      for (var assignment in submittedAssignments) {
        progressData.add(ProgressData(
          assignment['student_name'] ?? 'Unknown Student', // Default value
          assignment['assignment_name'] ?? 'Unknown Assignment', // Default value
          (assignment['marks'] ?? 0).toDouble(), // Default to 0 if null
        ));
      }
      return progressData;
    } catch (e) {
      print('Error fetching progress data: $e');
      return [];
    }
  }

  Future<List<ProgressData>> fetchQuizData() async {
    try {
      // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      // final sessionIdCookie = userDataProvider.userData?['session_id'];
      // final sessionId = _extractSessionId(sessionIdCookie);
      final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
      if (sessionId2 == null) {
        throw Exception('Session ID is null');
      }

      final eLearningService = ELearningService();
      final quizData = await eLearningService.fetchChildQuizzes(sessionId2);

      List<ProgressData> progressData = [];
      // Iterate over children_quizzes and their respective quizzes
      if (quizData != null && quizData['children_quizzes'] is List) {
        for (var child in quizData['children_quizzes']) {
          String childName = child['child_name'] ?? 'Unknown Child';
          if (child['quizzes'] is List) {
            for (var quiz in child['quizzes']) {
              int score = _getScore(quiz);
              progressData.add(ProgressData(
                childName, // Use child's name for identification
                quiz['slide_name'] ?? 'Unknown Quiz', // Default value
                score.toDouble(),
            ));
          }
        } else {
          print('No quizzes found for child: $childName');
        }
      }
    } else {
      print('children_quizzes key is missing or not a list.');
    }
    return progressData;
  } catch (e) {
    print('Error fetching quiz data: $e');
    return [];
  }
}


  int _getScore(Map<String, dynamic> quiz) {
    final attemptsCount = quiz['quiz_attempts_count'] ?? 0; // Default to 0 if null
    int score;
    switch (attemptsCount) {
      case 1:
        score = quiz['slide_first'] ?? 0; // Default to 0 if null
        break;
      case 2:
        score = quiz['slide_second'] ?? 0; // Default to 0 if null
        break;
      case 3:
        score = quiz['slide_third'] ?? 0; // Default to 0 if null
        break;
      default:
        score = quiz['slide_fourth'] ?? 0; // Default to 0 if null
    }
    return score * 10;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarortu(),
      drawer: CustomDrawerortu(),
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
            FutureBuilder<List<ProgressData>>(
              future: futureAssignmentData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Tidak ada progress tugas'));
                } else {
                  return Container(
                    height: 200,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: snapshot.data!.length * 100.0,
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
                            enable: true,
                            header: '',
                            canShowMarker: false,
                          ),
                          series: <ColumnSeries<ProgressData, String>>[
                            ColumnSeries<ProgressData, String>(
                              dataSource: snapshot.data!,
                              xValueMapper: (ProgressData data, _) => data.title,
                              yValueMapper: (ProgressData data, _) => data.score,
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                textStyle: TextStyle(fontSize: 10),
                              ),
                              spacing: 0.2,
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Hasil Pembelajaran (Evaluasi Belajar)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            FutureBuilder<List<ProgressData>>(
              future: futureQuizData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Tidak ada progress evaluasi belajar'));
                } else {
                  return Container(
                    height: 200,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: snapshot.data!.length * 100.0,
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
                            enable: true,
                            header: '',
                            canShowMarker: false,
                          ),
                          series: <ColumnSeries<ProgressData, String>>[
                            ColumnSeries<ProgressData, String>(
                              dataSource: snapshot.data!,
                              xValueMapper: (ProgressData data, _) => data.title,
                              yValueMapper: (ProgressData data, _) => data.score,
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                textStyle: TextStyle(fontSize: 10),
                              ),
                              spacing: 0.2,
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBarortu(),
    );
  }
}

class ProgressData {
  ProgressData(this.studentName, this.title, this.score);
  final String studentName;
  final String title;
  final double score;
}
