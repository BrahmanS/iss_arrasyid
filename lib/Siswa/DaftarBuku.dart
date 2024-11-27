import 'package:flutter/material.dart';
import 'package:iss/Layout/appbar.dart';
import 'package:iss/Siswa/PeminjamanBuku.dart';
import 'package:iss/Layout/bottombar.dart';
import 'package:iss/Layout/drawer.dart';
import 'package:iss/Services/perpustakaan_service.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Services/shared_prefs.dart';

class PerpustakaanPage extends StatefulWidget {
  @override
  _PerpustakaanPageState createState() => _PerpustakaanPageState();
}

class _PerpustakaanPageState extends State<PerpustakaanPage> {
  // late Future<List<dynamic>> _mediaStatusFuture;
  Future<List<dynamic>>? _mediaStatusFuture;

  @override
  void initState() {
    super.initState();
    _initializeMediaStatus();
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    // // final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
    // if (sessionId != null) {
    //   _mediaStatusFuture = PerpustakaanService().fetchMediaStatus(sessionId);
    // } else {
    //   print('Error: session_id is null');
    // }
    
  }

  Future<void> _initializeMediaStatus() async {
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
    if (sessionId2 != null) {
      setState(() {
        _mediaStatusFuture = PerpustakaanService().fetchMediaStatus(sessionId2);
      });
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
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final studentName = userDataProvider.userData?['name'] ?? 'Unknown';
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: FutureBuilder<List<dynamic>>(
        future: _mediaStatusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No media found.'));
          }

          final mediaList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: mediaList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Daftar Buku',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              final media = mediaList[index - 1];
              print('Media: $media'); // Debug print statement

              
              final availability = media['status'] is bool ? media['status'].toString() : media['status'].toString();

              return BookCard(
               
                title: media['name'].toString(),
                bookId: media['id'],
                availability: availability,
                userName: studentName,
                bookCode: media['isbn'].toString(),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}

class BookCard extends StatefulWidget {
  final String title;
  final int bookId;
  final String availability;
  final String userName;
  final String bookCode;

  BookCard({
    required this.title,
    required this.bookId,
    required this.availability,
    required this.userName,
    required this.bookCode,
  });

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(widget.bookCode),
                        Text(
                          widget.availability,
                          style: TextStyle(
                            color: widget.availability == 'Available'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PeminjamanBukuPage(
                            user: widget.userName,
                            bookTitle: widget.title,
                            bookId: widget.bookId,
                            borrowingDate: DateTime.now().toString(),
                          ),
                        ),
                      );
                    },
                    child: Text('Pinjam Buku'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
