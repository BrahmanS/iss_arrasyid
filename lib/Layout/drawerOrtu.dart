// import 'package:flutter/material.dart';
// import 'package:iss/Ortu/ProfileOrtu.dart';
// import 'package:iss/Auth/login.dart';
// import 'package:iss/Services/auth_service.dart';
// import 'package:provider/provider.dart';
// import 'package:iss/Provider/user_data_provider.dart';
// import 'package:iss/Ortu/donasiortu.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class CustomDrawerortu extends StatelessWidget {
//   final AuthService apiService = AuthService();

//   void _logout(BuildContext context) async {
//     final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
//     final sessionIdCookie = userDataProvider.userData?['session_id'];
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('session_id'); 
//     print("Session ID Cookie:");
//     print(sessionIdCookie);

//     try {
//       if (sessionIdCookie != null) {
//         final sessionId = _extractSessionId(sessionIdCookie);
//         print("Session ID:");
//         print(sessionId);

//         if (sessionId != null) {
//           await apiService.logout(sessionId);
//           userDataProvider.clearUserData();

//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (context) => LoginScreen()),
//             (Route<dynamic> route) => false,
//           );
//         } else {
//           throw Exception('Session ID tidak ditemukan dalam hasil login');
//         }
//       }
//     } catch (error) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Error'),
//           content: Text(error.toString()),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   String? _extractSessionId(String sessionIdCookie) {
//     try {
//       final parts = sessionIdCookie.split(';');
//       for (final part in parts) {
//         final trimmedPart = part.trim();
//         if (trimmedPart.startsWith('session_id=')) {
//           return trimmedPart.split('=')[1];
//         }
//       }
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     final userData = Provider.of<UserDataProvider>(context).userData;

//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: <Widget>[
//           UserAccountsDrawerHeader(
//             accountName: Text(userData?['name'] ?? 'No Name'),
//             accountEmail: Text(userData?['username'] ?? 'No Email'),
//             currentAccountPicture: CircleAvatar(
//               backgroundColor: Colors.white,
//               child: Text(userData?['name']?.substring(0, 1) ?? ''),
//             ),
//             decoration: BoxDecoration(
//               color: Color(0xFF2162B6),
//             ),
//           ),
//           ListTile(
//             leading: Icon(Icons.account_circle),
//             title: Text('Profile'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => ProfileOrtuPage()),
//               );
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.exit_to_app),
//             title: Text('Logout'),
//             onTap: () {
//               _logout(context);
//             },
//           ),
//            ListTile(
//             leading: Icon(Icons.volunteer_activism),
//             title: Text('Donasi'),
//             onTap: () {
//                 Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => DonationsPage()),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:iss/Siswa/Profile.dart';
import 'package:iss/Auth/login.dart';
import 'package:iss/Services/auth_service.dart';
import 'package:iss/Services/shared_prefs.dart'; // Import SharedPrefs class
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iss/Ortu/ProfileOrtu.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Ortu/donasiortu.dart';

class CustomDrawerortu extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawerortu> {
  final AuthService apiService = AuthService();
  final SharedPrefs sharedPrefs = SharedPrefs(); // Create an instance of SharedPrefs
  String userName = 'No Name';
  String userEmail = 'No Email';
  String? sessionId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Function to load user data from SharedPreferences using SharedPrefs class
  void _loadUserData() async {
    userName = await sharedPrefs.getUserName() ?? 'No Name';
    userEmail = await sharedPrefs.getUserEmail() ?? 'No Email';
    sessionId = await sharedPrefs.getSessionId(); // Get session ID
    setState(() {}); // Update UI
  }

  // Logout function that uses the session ID from SharedPreferences
  void _logout(BuildContext context) async {
    try {
      if (sessionId != null) {
        print("Session ID:");
        print(sessionId);

        // Process logout using session ID
        await apiService.logout(sessionId!);

        // Clear all data from SharedPreferences
        await sharedPrefs.clear(); // Clear all user data from SharedPrefs

        // Navigate to login screen and remove the previous route
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        throw Exception('Session ID tidak ditemukan dalam SharedPreferences');
      }
    } catch (error) {
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(userName.isNotEmpty ? userName[0] : ''),
            ),
            decoration: BoxDecoration(
              color: Color(0xFF2162B6),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileOrtuPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}
