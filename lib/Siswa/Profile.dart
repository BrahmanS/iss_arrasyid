import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iss/Services/student_service.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Services/shared_prefs.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  Map<String, dynamic>? studentData;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      // final sessionIdCookie = userDataProvider.userData?['session_id'];
      // final sessionId = _extractSessionId(sessionIdCookie);
      final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
      if (sessionId2 != null) {
        final apiService = StudentService();
        final data = await apiService.getStudentData(sessionId2);
        setState(() {
          studentData = data;
          isLoading = false;
        });
      } else {
        throw Exception('Session ID not found');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Icon(
                      Icons.person,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      studentData?['name'] ?? '',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Siswa',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        buildProfileCard('NIS', studentData?['nis'] ?? ''),
                        buildProfileCard('NISN', studentData?['nisn'] ?? ''),
                        buildProfileCard('Email', studentData?['email'] ?? ''),
                        buildProfileCard('Telfon', studentData?['mobile'] ?? ''),
                        buildProfileCard('Tempat Lahir', studentData?['birth_place'] ?? ''),
                        buildProfileCard('Tanggal Lahir', studentData?['birth_date'] ?? ''),
                        buildProfileCard('Jenis Kelamin', studentData?['gender'] ?? ''),
                        buildProfileCard('Alamat', studentData?['address'] ?? ''),
                        buildProfileCard('Nama Ayah', studentData?['father_name'] ?? ''),
                        buildProfileCard('Nama Ibu', studentData?['mother_name'] ?? ''),
                        buildProfileCard('Nama Wali', studentData?['wali_name'] ?? ''),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildProfileCard(String label, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
