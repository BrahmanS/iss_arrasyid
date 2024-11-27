import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iss/Siswa/Penyerahantugas.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Services/assignment_service.dart';
import 'package:iss/Layout/appbar.dart';
import 'package:iss/Layout/bottombar.dart';
import 'package:iss/Layout/drawer.dart';
import 'package:iss/Services/shared_prefs.dart';

class PenyerahanTugas extends StatefulWidget {
  final String studentName;
  final int taskId;

  PenyerahanTugas({required this.studentName, required this.taskId});

  @override
  _PenyerahanTugasState createState() => _PenyerahanTugasState();
}

class _PenyerahanTugasState extends State<PenyerahanTugas> {
  final _formKey = GlobalKey<FormState>();
  String? selectedFileName;
  File? selectedFile;
  DateTime? selectedDateTime;
  final TextEditingController _studentController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _studentController.text = widget.studentName;
    _dateController.text = DateTime.now().toString();
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        selectedFileName = result.files.single.name;
        selectedFile = File(result.files.single.path!);
      });
      print('File selected: ${result.files.single.path}');
    } else {
      print('File selection cancelled');
    }
  }

  Future<void> pickDateTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (timePicked != null) {
        setState(() {
          selectedDateTime = DateTime(
              picked.year, picked.month, picked.day, timePicked.hour, timePicked.minute);
          _dateController.text = selectedDateTime.toString();
        });
      }
    }
  }

  Future<void> _submitAssignment() async {
    if (_formKey.currentState!.validate()) {
      try {
        // final userData = Provider.of<UserDataProvider>(context, listen: false).userData;
        // final sessionIdCookie = userData?['session_id'];
        // final sessionId = _extractSessionId(sessionIdCookie);
        final assignmentService = AssignmentService();
        final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
        if (selectedFile != null && sessionId2 != null) {
          await assignmentService.submitAssignment(
            sessionId: sessionId2,
            taskId: widget.taskId,
            studentName: widget.studentName,
            file: selectedFile!,
            submissionDate: selectedDateTime ?? DateTime.now(),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Assignment submitted successfully')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PenyerahanTugasPage()),
          );
        } else {
          throw Exception('Please select a file');
        }
      } catch (e) {
        print('Error submitting assignment: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit assignment: $e')),
        );
      }
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
                'Penyerahan Tugas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                readOnly: true,
                controller: _studentController,
                decoration: InputDecoration(
                  labelText: 'Siswa',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama siswa tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                
               
                child: AbsorbPointer(
                  child: TextFormField(
                    readOnly: true,
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Pilih Tanggal dan Waktu',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tanggal dan waktu tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: selectedFileName != null ? selectedFileName : 'Pilih File Tugas',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: pickFile,
                  ),
                ),
                validator: (value) {
                  if (selectedFileName == null) {
                    return 'File tugas harus dipilih';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitAssignment,
                      child: Text('Simpan', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Batal', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
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
