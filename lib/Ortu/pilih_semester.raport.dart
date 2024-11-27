import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iss/Layout/appbarOrtu.dart';
import 'package:iss/Layout/bottombarOrtu.dart';
import 'package:iss/Layout/drawerOrtu.dart';
import 'package:iss/Ortu/Rapor.dart';
import 'package:iss/Services/parent_service.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Ortu/Rapot_SAS.dart';
import 'package:iss/Ortu/Rapot_SAT.dart';
import 'package:iss/Services/shared_prefs.dart';
class smtrapot extends StatefulWidget {
  @override
  _PenyerahanTugasState createState() => _PenyerahanTugasState();
}

class _PenyerahanTugasState extends State<smtrapot> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedChildId;
  String? _selectedClassId;
  String? _selectedSemester;
  String? _selectedReportType;
  String? _selectedAcademicYearId;
  List<Map<String, String>> _children = [];
  List<Map<String, String>> _classes = [];
  List<Map<String, String>> _academicYears = [];
  List<String> _semesters = ['1', '2'];
  List<String> _reportTypes = ['STS', 'SAS', 'SAT'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      // final sessionIdCookie = userDataProvider.userData?['session_id'];
      // final sessionId = _extractSessionId(sessionIdCookie);
      final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
      if (sessionId2 != null) {
        final parentService = ParentService();
        
        final childrenData = await parentService.getChildrenData(sessionId2);
        setState(() {
          _children = List<Map<String, String>>.from(childrenData['children'].map((child) => {
            'id': child['id'].toString(),
            'name': child['name'].toString()
          }));
        });

        final classYearData = await parentService.fetchClassYearData(sessionId2);
        setState(() {
          _classes = List<Map<String, String>>.from(classYearData['classes'].map((item) => {
            'id': item['class_id'].toString(),
            'name': item['class_name'].toString()
          }));
          _academicYears = List<Map<String, String>>.from(classYearData['academic_years'].map((item) => {
            'id': item['academic_year_id'].toString(),
            'name': item['academic_year_name'].toString()
          }));
        });
      }
    } catch (e) {
      print('Failed to load data: $e');
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
      appBar: CustomAppBarortu(),
      drawer: CustomDrawerortu(),
      bottomNavigationBar: CustomBottomBarortu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'E-Raport',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedChildId,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedChildId = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Pilih Anak',
                  border: OutlineInputBorder(),
                ),
                items: _children.map<DropdownMenuItem<String>>((Map<String, String> value) {
                  return DropdownMenuItem<String>(
                    value: value['id'],
                    child: Text(value['name']!),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama anak tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedClassId,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedClassId = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Pilih Kelas',
                  border: OutlineInputBorder(),
                ),
                items: _classes.map<DropdownMenuItem<String>>((Map<String, String> value) {
                  return DropdownMenuItem<String>(
                    value: value['id'],
                    child: Text(value['name']!),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama kelas tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedSemester,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSemester = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Pilih Semester',
                  border: OutlineInputBorder(),
                ),
                items: _semesters.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Semester tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedReportType,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedReportType = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Pilih Jenis Raport',
                  border: OutlineInputBorder(),
                ),
                items: _reportTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jenis raport tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedAcademicYearId,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAcademicYearId = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Pilih Tahun Ajaran',
                  border: OutlineInputBorder(),
                ),
                items: _academicYears.map<DropdownMenuItem<String>>((Map<String, String> value) {
                  return DropdownMenuItem<String>(
                    value: value['id'],
                    child: Text(value['name']!),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tahun ajaran tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
                    // final sessionIdCookie = userDataProvider.userData?['session_id'];
                    // final sessionId = _extractSessionId(sessionIdCookie);
                    final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
                    if (sessionId2 != null) {
                      try {
                        final studentId = int.parse(_selectedChildId!);
                        final classId = int.parse(_selectedClassId!);
                        final academicYearId = int.parse(_selectedAcademicYearId!);

                        print('Student ID: $studentId, Type: ${studentId.runtimeType}');
                        print('Class ID: $classId, Type: ${classId.runtimeType}');
                        print('Academic Year ID: $academicYearId, Type: ${academicYearId.runtimeType}');
                        
                        final parentService = ParentService();
                        final reportData = await parentService.searchRaport(
                          sessionId: sessionId2,
                          studentId: studentId,
                          kelasId: classId,
                          semesterId: _selectedSemester!,
                          jenisRaport: _selectedReportType!,
                          tahunPelajaran: academicYearId,
                        );

                        if (reportData['result']['data'] == null  || reportData['result']['data'].isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tidak ada data raport'))
                          );
                        } else {
                          if (_selectedReportType == 'SAS') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ReportCardSASPage(reportData: reportData)),
                            );
                          } else if (_selectedReportType == 'SAT') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ReportCardSATPage(reportData: reportData)),
                            );
                          } else if (_selectedReportType == 'STS') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ReportCardPage(reportData: reportData)),
                            );
                          }
                        }
                      } catch (e) {
                        print('Error searching report: $e');
                      }
                    }
                  }
                },
                child: Text('Cari Raport'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
