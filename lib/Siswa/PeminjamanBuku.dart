import 'package:flutter/material.dart';
import 'package:iss/Layout/appbar.dart';
import 'package:iss/Siswa/DaftarPeminjaman.dart';
import 'package:iss/Layout/bottombar.dart';
import 'package:iss/Layout/drawer.dart';
import 'package:iss/Services/perpustakaan_service.dart';
import 'package:provider/provider.dart';
import 'package:iss/Siswa/DaftarBuku.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:intl/intl.dart';
import 'package:iss/Services/shared_prefs.dart';

class PeminjamanBukuPage extends StatefulWidget {
  final String user;
  final String bookTitle;
  final int bookId;
  final String borrowingDate;

  PeminjamanBukuPage({
    required this.user,
    required this.bookTitle,
    required this.bookId,
    required this.borrowingDate,
  });

  @override
  _PeminjamanBukuPageState createState() => _PeminjamanBukuPageState();
}

class _PeminjamanBukuPageState extends State<PeminjamanBukuPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _bukuController = TextEditingController();
  final TextEditingController _tanggalPeminjamanController = TextEditingController();
  final TextEditingController _tanggalPengembalianController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userController.text = widget.user;
    _bukuController.text = widget.bookTitle;
    _tanggalPeminjamanController.text = widget.borrowingDate;
  }

  Future<void> _selectDateTime(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          controller.text = selectedDateTime.toString();
        });
      }
    }
  }

  String? _validateReturnDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter return date';
    }
    final DateTime borrowingDate = DateTime.parse(_tanggalPeminjamanController.text);
    final DateTime returnDate = DateTime.parse(value);
    if (borrowingDate.isAtSameMomentAs(returnDate)) {
      return 'Return date and time cannot be the same as borrowing date and time';
    }
    return null;
  }

  Future<void> _createMediaQueue(BuildContext context) async {
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
    if (sessionId2 != null) {
      final result = await PerpustakaanService().createMediaQueue(
        sessionId2,
        widget.bookId,
        _tanggalPeminjamanController.text,
        _tanggalPengembalianController.text,
      );

      if (result) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DaftarPengajuanPeminjamanPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create media queue')),
        );
      }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Peminjaman Buku',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _userController,
                 readOnly: true,
                decoration: InputDecoration(
                  labelText: 'User',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter user';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _bukuController,
                 readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Buku',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter book';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _tanggalPeminjamanController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal Peminjaman',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDateTime(context, _tanggalPeminjamanController),
                  ),
                ),
                onTap: () => _selectDateTime(context, _tanggalPeminjamanController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter borrowing date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _tanggalPengembalianController,
                
                decoration: InputDecoration(
                  labelText: 'Tanggal Pengembalian',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDateTime(context, _tanggalPengembalianController),
                  ),
                ),
                onTap: () => _selectDateTime(context, _tanggalPengembalianController),
                validator: _validateReturnDate,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _createMediaQueue(context);
                      }
                    },
                    child: Text('Simpan'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                       Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => PerpustakaanPage()),
                                      );
                    },
                    child: Text('Batal'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }
}
