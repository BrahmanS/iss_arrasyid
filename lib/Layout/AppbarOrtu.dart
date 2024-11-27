// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // Import for date formatting
// import 'package:intl/date_symbol_data_local.dart'; // Import for initializing the locale
// import 'package:iss/Ortu/NotifOrtu.dart';
// import 'package:provider/provider.dart';
// import 'package:iss/Provider/user_data_provider.dart';

// class CustomAppBarortu extends StatelessWidget implements PreferredSizeWidget {
//   @override
//   final Size preferredSize;

//   CustomAppBarortu({Key? key})
//       : preferredSize = const Size.fromHeight(120.0),
//         super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final userData = Provider.of<UserDataProvider>(context).userData;

//     // Initialize Indonesian locale
//     initializeDateFormatting('id_ID', null);

//     // Get today's date and format it in Indonesian
//     final DateTime now = DateTime.now();
//     final String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

//     return AppBar(
//       backgroundColor: Color(0xFF2162B6),
//       leading: Builder(
//         builder: (context) => IconButton(
//           icon: Icon(Icons.person, color: Colors.white),
//           onPressed: () {
//             Scaffold.of(context).openDrawer();
//           },
//         ),
//       ),
//       title: Text(
//         'Selamat Datang\n${userData?['name'] ?? 'nama'}',
//         style: TextStyle(color: Colors.white, fontSize: 18),
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//       ),
//       actions: [
//         IconButton(
//           icon: Icon(Icons.notifications, color: Colors.white),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => Notifikasiortu()),
//             );
//           },
//         ),
//         SizedBox(width: 16),
//       ],
//       bottom: PreferredSize(
//         preferredSize: Size.fromHeight(40.0),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             children: [
//               Icon(Icons.calendar_today, color: Colors.white),
//               SizedBox(width: 10),
//               Expanded(
//                 child: Container(
//                   height: 40,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(30),
//                     color: Colors.white,
//                   ),
//                   child: Center(
//                     child: Text(
//                       formattedDate,
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:intl/date_symbol_data_local.dart'; // Import for initializing the locale
import 'package:iss/Ortu/NotifOrtu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBarortu extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  CustomAppBarortu({Key? key})
      : preferredSize = const Size.fromHeight(120.0),
        super(key: key);

  @override
  _CustomAppBarortuState createState() => _CustomAppBarortuState();
}

class _CustomAppBarortuState extends State<CustomAppBarortu> {
  String userName = 'nama'; // Nilai default jika nama tidak ada

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fungsi untuk mengambil data dari SharedPreferences
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'nama'; // Ambil nama dari SharedPreferences
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize Indonesian locale
    initializeDateFormatting('id_ID', null);

    // Get today's date and format it in Indonesian
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    return AppBar(
      backgroundColor: Color(0xFF2162B6),
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.person, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: Text(
        'Selamat Datang\n$userName',
        style: TextStyle(color: Colors.white, fontSize: 18),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Notifikasiortu()),
            );
          },
        ),
        SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
