import 'package:flutter/material.dart';
import 'package:iss/Layout/appbar.dart';
import 'package:iss/Layout/bottombar.dart';
import 'package:iss/Layout/drawer.dart';
import 'package:iss/Services/perpustakaan_service.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Services/shared_prefs.dart';

class DaftarPengajuanPeminjamanPage extends StatefulWidget {
  @override
  _DaftarPengajuanPeminjamanPageState createState() => _DaftarPengajuanPeminjamanPageState();
}

class _DaftarPengajuanPeminjamanPageState extends State<DaftarPengajuanPeminjamanPage> {
  // late Future<List<dynamic>> _loanRequestsFuture;
  Future<List<dynamic>>? _loanRequestsFuture;
  @override
  void initState() {
    super.initState();
    _initializeQueueRequests();
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    // if (sessionId != null) {
    //   _loanRequestsFuture = PerpustakaanService().fetchQueueRequests(sessionId);
    // } else {
    //   print('Error: session_id is null');
    // }
  }

  Future<void> _initializeQueueRequests() async {
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
    if (sessionId2 != null) {
      setState(() {
        _loanRequestsFuture = PerpustakaanService().fetchQueueRequests(sessionId2);
      });
      // _loanRequestsFuture = PerpustakaanService().fetchQueueRequests(sessionId2);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: FutureBuilder<List<dynamic>>(
        future: _loanRequestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada antrian peminjaman'));
          }

          final loanRequests = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: loanRequests.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Daftar Pengajuan Peminjaman',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              final loanRequest = loanRequests[index - 1];
              return PinjamRequestCard(
                imageUrl: 'https://via.placeholder.com/100',
                title: loanRequest['media_name'] ?? 'No title',
                borrowerName: loanRequest['partner_name'] ?? 'No name',
                returnDate: loanRequest['date_to'] ?? 'No date',
                queueId: loanRequest['sequence_no'].toString(),
                state: loanRequest['state'],
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}


class PinjamRequestCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String borrowerName;
  final String returnDate;
  final String queueId;
  final String state;

  PinjamRequestCard({
    required this.imageUrl,
    required this.title,
    required this.borrowerName,
    required this.returnDate,
    required this.queueId,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text('Nama peminjam: $borrowerName'),
                  SizedBox(height: 5),
                  Text('Tanggal Pengembalian: $returnDate'),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Kode: $queueId'),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                  },
                  child: Text('$state'),
                  // style: ElevatedButton.styleFrom(
                  //   primary: Colors.green,
                  // ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
