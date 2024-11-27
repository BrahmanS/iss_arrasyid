import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for rootBundle
import 'package:iss/Layout/AppbarOrtu.dart'; // Assumed custom app bar
import 'package:iss/Layout/BottombarOrtu.dart'; // Assumed custom bottom bar
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:iss/Services/shared_prefs.dart';
class ReportCardSATPage extends StatelessWidget {
  final Map<String, dynamic> reportData;

  ReportCardSATPage({required this.reportData});

  @override
  Widget build(BuildContext context) {
    // Extracting necessary data
    final List<dynamic> raportData = reportData['result']['data'];
    final Map<String, dynamic> raport = raportData.isNotEmpty ? raportData[0] : {};

    final Map<String, dynamic> studentInfo = raport['student_id'] ?? {};
    final List<dynamic> grades = raport['raport_siswa_ids'] ?? [];
    final List<dynamic> mulok = raport['mulok_siswa_ids'] ?? [];
    final List<dynamic> physicalDevelopment = [
      {
        'tinggi_badan': raport['tinggi_bdn'] ?? 0,
        'berat_badan': raport['berat_bdn'] ?? 0,
        'lingkar_kepala': raport['lingkar_kpl'] ?? 0,
        'pendengaran': raport['pendengaran'],
        'penglihatan': raport['penglihatan'],
        'gigi': raport['gigi'],
      }
    ];
    final int sakit = raport['sakit'] ?? 0;
    final int izin = raport['izin'] ?? 0;
    final int tanpaKeterangan = raport['tanpa_keterangan'] ?? 0;
    final String kesimpulan = raport['ksmpln_saran'] ?? '';
    final String keputusan = raport['keputusan_siswa'] ?? '';

    return Scaffold(
      appBar: CustomAppBarortu(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Image.asset('assets/images/logo arrasyid.png', height: 120),
                  Text('SEKOLAH BERBASIS AKHLAK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('SEKOLAH ISLAM ARRASYID', style: TextStyle(fontSize: 16)),
                  Text('Jl. Rama Buana No 37 Serpong - Tangerang Selatan'),
                  SizedBox(height: 20),
                  Text('LAPORAN HASIL BELAJAR PESERTA DIDIK', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Report Card
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // General Student Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama: ${studentInfo['name'] ?? 'Nama tidak tersedia'}'),
                      Text('NIS: ${studentInfo['nis_nisn'] ?? 'NIS/NISN tidak tersedia'}'),
                      SizedBox(height: 10),
                      Text('Kelas: ${raport['kelas_id']['name'] ?? 'Kelas tidak tersedia'}'),
                      Text('Rombel: ${raport['grade_id']['name'] ?? 'Rombel tidak tersedia'}'),
                      Text('Semester: ${raport['semester_id'] ?? 'Semester tidak tersedia'}'),
                      Text('Tahun Ajaran: ${raport['tahun_pelajaran']['name'] ?? 'Tahun ajaran tidak tersedia'}'),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Grades Table
                  Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FixedColumnWidth(40),
                      2: FlexColumnWidth(3),
                      3: FlexColumnWidth(3),
                    },
                    children: [
                      TableRow(children: [
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Mata Pelajaran', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(5), child: Text('Nilai', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Capaian Kompetensi', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Catatan Kompetensi', style: TextStyle(fontWeight: FontWeight.bold)))),
                      ]),
                      // Populate rows with dynamic data
                      ...grades.map<TableRow>((grade) {
                        return TableRow(children: [
                          TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(grade['subject_name'] ?? 'Mata pelajaran tidak tersedia'))),
                          TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(grade['nilai_akhir'].toString() ?? 'Nilai tidak tersedia'))),
                          TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(grade['note'] ?? 'Capaian kompetensi tidak tersedia'))),
                          TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(grade['note2'] ?? 'Catatan kompetensi tidak tersedia'))),
                        ]);
                      }).toList(),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Additional Subject Table (mulok_siswa_ids)
                  Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FixedColumnWidth(40),
                      2: FlexColumnWidth(3),
                      3: FlexColumnWidth(3),
                    },
                    children: [
                      TableRow(children: [
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Mata Pelajaran', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(5), child: Text('Nilai', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Capaian Kompetensi', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Catatan Kompetensi', style: TextStyle(fontWeight: FontWeight.bold)))),
                      ]),
                      // Populate rows with dynamic data for mulok_siswa_ids
                      ...mulok.map<TableRow>((subject) {
                        return TableRow(children: [
                          TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(subject['subject_name'] ?? 'Mata pelajaran tidak tersedia'))),
                          TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(subject['nilai_akhir'].toString() ?? 'Nilai tidak tersedia'))),
                          TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(subject['note'] ?? 'Capaian kompetensi tidak tersedia'))),
                          TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(subject['note2'] ?? 'Catatan kompetensi tidak tersedia'))),
                        ]);
                      }).toList(),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Physical Development Table
                  Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                      4: FlexColumnWidth(2),
                      5: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(children: [
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Tinggi Badan', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Berat Badan', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Lingkar Kepala', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Pendengaran', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Penglihatan', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Gigi', style: TextStyle(fontWeight: FontWeight.bold)))),
                      ]),
                      // Populate rows with dynamic data for perkembangan fisik
                      ...physicalDevelopment.map<TableRow>((item) {
                        return TableRow(children: [
                          TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(item['tinggi_badan'].toString() ?? 'Data tidak tersedia'))),
                          TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(item['berat_badan'].toString() ?? 'Data tidak tersedia'))),
                          TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(item['lingkar_kepala'].toString() ?? 'Data tidak tersedia'))),
                          TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(item['pendengaran'] ?? 'Data tidak tersedia'))),
                          TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(item['penglihatan'] ?? 'Data tidak tersedia'))),
                          TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(item['gigi'] ?? 'Data tidak tersedia'))),
                        ]);
                      }).toList(),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Attendance Table
                  Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(children: [
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Sakit', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(sakit.toString()))),
                      ]),
                      TableRow(children: [
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Izin', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(izin.toString()))),
                      ]),
                      TableRow(children: [
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Tanpa Keterangan', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(tanpaKeterangan.toString()))),
                      ]),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Kesimpulan dan Saran Table
                  Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(3),
                    },
                    children: [
                      TableRow(children: [
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Kesimpulan Saran', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(kesimpulan))),
                      ]),
                      TableRow(children: [
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Keputusan', style: TextStyle(fontWeight: FontWeight.bold)))),
                        TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text(keputusan))),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _printReportCard(context),
        child: Icon(Icons.print),
      ),
      bottomNavigationBar: CustomBottomBarortu(), // Use custom bottom bar
    );
  }

  Future<void> _printReportCard(BuildContext context) async {
    final pdf = pw.Document();

    // Load the image outside of the build method
    final logoImage = pw.MemoryImage((await rootBundle.load('assets/images/logo arrasyid.png')).buffer.asUint8List());

    // Extracting necessary data
    final List<dynamic> raportData = reportData['result']['data'];
    final Map<String, dynamic> raport = raportData.isNotEmpty ? raportData[0] : {};

    final Map<String, dynamic> studentInfo = raport['student_id'] ?? {};
    final List<dynamic> grades = raport['raport_siswa_ids'] ?? [];
    final List<dynamic> mulok = raport['mulok_siswa_ids'] ?? [];
    final List<dynamic> physicalDevelopment = [
      {
        'tinggi_badan': raport['tinggi_bdn'] ?? 0,
        'berat_badan': raport['berat_bdn'] ?? 0,
        'lingkar_kepala': raport['lingkar_kpl'] ?? 0,
        'pendengaran': raport['pendengaran'],
        'penglihatan': raport['penglihatan'],
        'gigi': raport['gigi'],
      }
    ];
    final int sakit = raport['sakit'] ?? 0;
    final int izin = raport['izin'] ?? 0;
    final int tanpaKeterangan = raport['tanpa_keterangan'] ?? 0;
    final String kesimpulan = raport['ksmpln_saran'] ?? '';
    final String keputusan = raport['keputusan_siswa'] ?? '';

    // Add content to the PDF document
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Image(
                logoImage,
                height: 120,
              ),
              pw.Text('SEKOLAH BERBASIS AKHLAK', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('SEKOLAH ISLAM ARRASYID', style: pw.TextStyle(fontSize: 16)),
              pw.Text('Jl. Rama Buana No 37 Serpong - Tangerang Selatan'),
              pw.SizedBox(height: 20),
              pw.Text('LAPORAN HASIL BELAJAR PESERTA DIDIK', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              // General Student Info
              pw.Text('Nama: ${studentInfo['name'] ?? 'Nama tidak tersedia'}'),
              pw.Text('NIS: ${studentInfo['nis_nisn'] ?? 'NIS/NISN tidak tersedia'}'),
              pw.SizedBox(height: 10),
              pw.Text('Kelas: ${raport['kelas_id']['name'] ?? 'Kelas tidak tersedia'}'),
              pw.Text('Rombel: ${raport['grade_id']['name'] ?? 'Rombel tidak tersedia'}'),
              pw.Text('Semester: ${raport['semester_id'] ?? 'Semester tidak tersedia'}'),
              pw.Text('Tahun Ajaran: ${raport['tahun_pelajaran']['name'] ?? 'Tahun ajaran tidak tersedia'}'),
              pw.SizedBox(height: 20),
              // Grades Table
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.centerLeft,
                headers: ['Mata Pelajaran', 'Nilai', 'Capaian Kompetensi', 'Catatan Kompetensi'],
                data: grades.map((grade) {
                  return [
                    grade['subject_name'] ?? 'Mata pelajaran tidak tersedia',
                    grade['nilai_akhir'].toString() ?? 'Nilai tidak tersedia',
                    grade['note'] ?? 'Capaian kompetensi tidak tersedia',
                    grade['note2'] ?? 'Catatan kompetensi tidak tersedia'
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              // Additional Subject Table (mulok_siswa_ids)
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.centerLeft,
                headers: ['Mata Pelajaran', 'Nilai', 'Capaian Kompetensi', 'Catatan Kompetensi'],
                data: mulok.map((subject) {
                  return [
                    subject['subject_name'] ?? 'Mata pelajaran tidak tersedia',
                    subject['nilai_akhir'].toString() ?? 'Nilai tidak tersedia',
                    subject['note'] ?? 'Capaian kompetensi tidak tersedia',
                    subject['note2'] ?? 'Catatan kompetensi tidak tersedia'
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              // Physical Development Table
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.centerLeft,
                headers: ['Tinggi Badan', 'Berat Badan', 'Lingkar Kepala', 'Pendengaran', 'Penglihatan', 'Gigi'],
                data: physicalDevelopment.map((item) {
                  return [
                    item['tinggi_badan'].toString() ?? 'Data tidak tersedia',
                    item['berat_badan'].toString() ?? 'Data tidak tersedia',
                    item['lingkar_kepala'].toString() ?? 'Data tidak tersedia',
                    item['pendengaran'] ?? 'Data tidak tersedia',
                    item['penglihatan'] ?? 'Data tidak tersedia',
                    item['gigi'] ?? 'Data tidak tersedia'
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              // Attendance Table
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.centerLeft,
                headers: ['Keterangan', 'Jumlah'],
                data: [
                  ['Sakit', sakit.toString()],
                  ['Izin', izin.toString()],
                  ['Tanpa Keterangan', tanpaKeterangan.toString()]
                ],
              ),
              pw.SizedBox(height: 20),
              // Kesimpulan dan Saran Table
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.centerLeft,
                headers: ['Kesimpulan Saran', 'Keputusan'],
                data: [
                  [kesimpulan, keputusan]
                ],
              ),
            ],
          );
        },
      ),
    );

    // Print the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
