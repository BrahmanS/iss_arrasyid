import 'package:flutter/material.dart';
import 'package:iss/Layout/appbar.dart';
import 'package:iss/Siswa/form_Penyerahan Tugas.dart';
import 'package:iss/Layout/bottombar.dart';
import 'package:iss/Layout/drawer.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Services/assignment_service.dart';
import 'package:iss/Services/shared_prefs.dart';

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> with SingleTickerProviderStateMixin {
  // late Future<List<dynamic>> _assignmentsFuture;
  Future<List<dynamic>>? _assignmentsFuture;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeAssignments();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1300),
    );

    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // print("Session ID:");
    // print(sessionIdCookie);
    // final sessionId = _extractSessionId(sessionIdCookie);
    
    // if (sessionId != null) {
    //   _assignmentsFuture = AssignmentService().fetchAssignments(sessionId);
    // } else {
    //   print('Error: session_id is null');
    // }

    _animationController.forward();
  }

  Future<void> _initializeAssignments() async {
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // print("Session ID:");
    // print(sessionIdCookie);
    // final sessionId = _extractSessionId(sessionIdCookie);
    final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
    if (sessionId2 != null) {
      setState(() {
        _assignmentsFuture = AssignmentService().fetchAssignments(sessionId2);
      });
      
    } else {
      print('Error: session_id is null');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final studentName = userDataProvider.userData?['name'] ?? 'Unknown';
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Tugas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _assignmentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No assignments found.'));
                  }

                  final assignments = snapshot.data!;
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
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: Tween<double>(begin: 0, end: 1).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(
                                  (index / assignments.length) * 0.5,
                                  1.0,
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: Offset(0, 0.5),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(
                                    (index / assignments.length) * 0.5,
                                    1.0,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                              child: TaskCard(
                                subject: assignment['assignment_name'] ?? 'No name',
                                description: assignment['description'] ?? 'No description',
                                dueDate: assignment['submission_date'] ?? 'No due date',
                                taskId: assignment['assignment_id'] ?? 'No status',
                                studentName: studentName,
                              ),
                            ),
                          );
                        },
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
  final String description;
  final String dueDate;
  final String studentName;
  final int taskId;

  const TaskCard({
    Key? key,
    required this.subject,
    required this.description,
    required this.dueDate,
    required this.studentName,
    required this.taskId,
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
          _buildHeaderImage(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubjectText(),
                const SizedBox(height: 4),
                _buildDescriptionText(context),
                const SizedBox(height: 4),
                _buildDueDateText(),
                const SizedBox(height: 10),
                _buildSubmitButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Image.asset(
      'assets/images/e learning.jpg',
      fit: BoxFit.cover,
      height: 50,
      width: double.infinity,
    );
  }

  Widget _buildSubjectText() {
    return Text(
      subject,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDescriptionText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        GestureDetector(
          onTap: () => _showFullDescription(context),
          child: Text(
            'Read more',
            style: TextStyle(color: Colors.blue, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDueDateText() {
    return Text(
      'Batas pengumpulan: $dueDate',
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToPenyerahanTugas(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
        ),
        child: const Text(
          'Submit Tugas',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }

  void _navigateToPenyerahanTugas(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PenyerahanTugas(
          studentName: studentName,
          taskId: taskId,
        ),
      ),
    );
  }

  void _showFullDescription(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Full Description'),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
