// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:iss/Layout/BottombarOrtu.dart';
// import 'package:iss/Layout/AppbarOrtu.dart';
// import 'package:iss/Layout/drawerOrtu.dart';
// import 'package:iss/Services/shared_prefs.dart';
// void main() {
//   runApp(MaterialApp(
//     home: PenyerahanTugas(),
//   ));
// }

// class PenyerahanTugas extends StatefulWidget {
//   @override
//   _PenyerahanTugasState createState() => _PenyerahanTugasState();
// }

// class _PenyerahanTugasState extends State<PenyerahanTugas> {
//   final _formKey = GlobalKey<FormState>();
//   String? selectedFileName;
//   DateTime? selectedDateTime;
//   final TextEditingController _studentController = TextEditingController();

//   Future<void> pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();

//     if (result != null) {
//       setState(() {
//         selectedFileName = result.files.single.name;
//       });
//       print('File selected: ${result.files.single.path}');
//     } else {
//       print('File selection cancelled');
//     }
//   }

//   Future<void> pickDateTime() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(DateTime.now().year + 5),
//     );
//     if (picked != null) {
//       final TimeOfDay? timePicked = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );
//       if (timePicked != null) {
//         setState(() {
//           selectedDateTime = DateTime(
//               picked.year, picked.month, picked.day, timePicked.hour, timePicked.minute);
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBarortu(),
//       drawer: CustomDrawerortu(),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Text(
//                 'Penyerahan Tugas',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 16.0),
//               TextFormField(
//                 controller: _studentController,
//                 decoration: InputDecoration(
//                   labelText: 'Siswa',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Nama siswa tidak boleh kosong';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16.0),
//               GestureDetector(
//                 onTap: pickDateTime,
//                 child: AbsorbPointer(
//                   child: TextFormField(
//                     decoration: InputDecoration(
//                       labelText: selectedDateTime != null
//                           ? selectedDateTime.toString()
//                           : 'Pilih Tanggal dan Waktu',
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (value) {
//                       if (selectedDateTime == null) {
//                         return 'Tanggal dan waktu tidak boleh kosong';
//                       }
//                       return null;
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.0),
//               TextFormField(
//                 readOnly: true,
//                 decoration: InputDecoration(
//                   labelText: selectedFileName != null ? selectedFileName : 'Pilih File Tugas',
//                   border: OutlineInputBorder(),
//                   suffixIcon: IconButton(
//                     icon: Icon(Icons.attach_file),
//                     onPressed: pickFile,
//                   ),
//                 ),
//                 validator: (value) {
//                   if (selectedFileName == null) {
//                     return 'File tugas harus dipilih';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 32.0),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (_formKey.currentState!.validate()) {
//                           print('Simpan button pressed');
//                           // Implementasi logika penyimpanan disini
//                         }
//                       },
//                       child: Text('Simpan'),
//                       style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//                     ),
//                   ),
//                   SizedBox(width: 16.0),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: Text('Batal'),
//                       style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: CustomBottomBarortu(),
//     );
//   }
// }
