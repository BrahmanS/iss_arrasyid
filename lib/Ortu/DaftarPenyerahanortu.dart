import 'package:flutter/material.dart';
import 'package:iss/Layout/AppbarOrtu.dart';
import 'package:iss/Layout/bottombarOrtu.dart';
import 'package:iss/Layout/drawerOrtu.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Services/parent_service.dart';
import 'package:intl/intl.dart';
import 'package:iss/Services/shared_prefs.dart';
import 'package:url_launcher/url_launcher.dart';
class Penyerahanortu extends StatefulWidget {
  @override
  _PenyerahanortuState createState() => _PenyerahanortuState();
}

class _PenyerahanortuState extends State<Penyerahanortu> with SingleTickerProviderStateMixin {
  // late Future<List<dynamic>> _submittedAssignments;
  Future<List<dynamic>>? _submittedAssignments;
  late AnimationController _animationController;
  late Animation<double> _animation;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _initializeAssignments();
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    // if (sessionId != null) {
    //   _submittedAssignments = ParentService().fetchSubmittedAssignmentsChildren(sessionId);
    // } else {
    //   print('Error: session_id is null');
    // }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _initializeAssignments() async {
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
    if (sessionId2 != null) {
      setState(() {
        _submittedAssignments = ParentService().fetchSubmittedAssignmentsChildren(sessionId2);
      });
      // _submittedAssignments = ParentService().fetchSubmittedAssignmentsChildren(sessionId2);
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

  bool _isWithinSelectedMonth(String dueDate) {
    if (_selectedMonth == null) return true;
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dueDate);
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
              'Daftar Penyerahan Tugas',
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
                future: _submittedAssignments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Tidak ada tugas'));
                  } else {
                    final assignments = snapshot.data!
                        .where((assignment) => _isWithinSelectedMonth(assignment['submission_date']))
                        .toList();
                    _animationController.forward(); // Start the animation

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
                        return ScaleTransition(
                          scale: _animation,
                          child: TaskCard(
                            subject: assignment['assignment_name'],
                            description: assignment['student_name'],
                            dueDate: assignment['submission_date'],
                            attachmentUrl: assignment['attachment'],
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
      ),
      bottomNavigationBar: CustomBottomBarortu(),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String subject;
  final String description;
  final String dueDate;
  final String? attachmentUrl;

  TaskCard({
    required this.subject,
    required this.description,
    required this.dueDate,
    this.attachmentUrl,
  });

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
                  description,
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'Batas pengumpulan: $dueDate',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: attachmentUrl != null
                        ? () async {
                            final Uri url = Uri.parse(attachmentUrl!);
                            try {
                              if (!await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not launch $attachmentUrl')),
                                );
                              }
                            } catch (e) {
                              print('Error launching URL: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error launching URL: $e')),
                              );
                            }
                          }
                        : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text('Review', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
                Divider(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text('Accept', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
