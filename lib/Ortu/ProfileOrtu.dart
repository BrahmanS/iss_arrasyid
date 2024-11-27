import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iss/Services/parent_service.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Services/shared_prefs.dart';
class ProfileOrtuPage extends StatefulWidget {
  @override
  _ProfileOrtuPageState createState() => _ProfileOrtuPageState();
}

class _ProfileOrtuPageState extends State<ProfileOrtuPage> {
  bool isLoading = true;
  Map<String, dynamic>? parentData;

  @override
  void initState() {
    super.initState();
    _fetchParentData();
  }

  Future<void> _fetchParentData() async {
    try {
      // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      // final sessionIdCookie = userDataProvider.userData?['session_id'];
      // final sessionId = _extractSessionId(sessionIdCookie);
      final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
      if (sessionId2 != null) {
        final apiService = ParentService();
        final data = await apiService.getParentData(sessionId2);
        setState(() {
          parentData = data;
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
        title: Text('Profile Ortu'),
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
                      parentData?['name'] ?? '',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Orang tua',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        buildProfileCard('Email', parentData?['email'] ?? 'kosong'),
                        buildProfileCard('Telfon', parentData?['mobile'] ?? 'kosong'),
                        // buildProfileCard(
                        //   'Alamat',
                        //   '${_formatAddress(parentData?['address']['street'])}, '
                        //   '${_formatAddress(parentData?['address']['city'])}, '
                        //   '${_formatAddress(parentData?['address']['state'])}, '
                        //   '${_formatAddress(parentData?['address']['zip'])}, '
                        //   '${_formatAddress(parentData?['address']['country'])}',
                        // ),
                        buildProfileCard(
                          'Alamat',
                          _buildFormattedAddress(parentData?['address']),
                        ),
                        buildProfileCard('Hubungan dengan Siswa', parentData?['relationship'] ?? 'kosong'),
                        buildProfileCard(
                          'Nama Siswa',
                          parentData?['student_ids']
                              ?.map((student) => student['name'])
                              ?.join(', ') ?? 'kosong',
                        ),
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
              value.isEmpty ? '' : value, // Display 'kosong' if value is empty
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  String _buildFormattedAddress(Map<String, dynamic>? address) {
    if (address == null) return 'kosong'; // Return 'kosong' if the address is null

    // List of address components
    List<String> addressParts = [
      _formatAddress(address['street']),
      _formatAddress(address['city']),
      _formatAddress(address['state']),
      _formatAddress(address['zip']),
      _formatAddress(address['country']),
    ];

    // Filter out empty or null values
    addressParts.removeWhere((part) => part.isEmpty);

    // Join the non-empty parts with a comma and return
    return addressParts.isNotEmpty ? addressParts.join(', ') : '';
  }


  String _formatAddress(dynamic value) {
    if (value == null || value == false) {
      return '';
    }
    return value.toString();
  }
}
