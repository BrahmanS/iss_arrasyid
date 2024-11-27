import 'package:flutter/material.dart';
import 'package:iss/Layout/BottomBarOrtu.dart';
import 'package:iss/ortu/donasiortu.dart';
import 'package:iss/ortu/pemdonasiortu.dart';
import 'package:iss/Services/donasi_service.dart';
import 'package:iss/Services/shared_prefs.dart';
class DonationDetailsPage extends StatefulWidget {
  final int donasiId; // Receive donasiId from the previous page

  const DonationDetailsPage({Key? key, required this.donasiId}) : super(key: key);

  @override
  _DonationDetailsPageState createState() => _DonationDetailsPageState();
}

class _DonationDetailsPageState extends State<DonationDetailsPage> {
  final DonationService _donationService = DonationService();
  Future<Map<String, dynamic>>? _donasiDetails;

  @override
  void initState() {
    super.initState();
    _donasiDetails = _donationService.fetchDonasiById(widget.donasiId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Detail Donasi'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _donasiDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load donation details'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No details available'));
          } else {
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Text(
                      data['nama_program'] ?? 'No Title',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(Icons.business, data['yayasan'] ?? 'Yayasan Tidak Diketahui'),
                        SizedBox(width: 8),
                        _buildInfoChip(Icons.calendar_today, 'Sampai: ${data['date_end']}'),
                      ],
                    ),
                    SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (data['progres_saldo_terkumpul'] ?? 0) / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Terkumpul: Rp ${data['saldo'] ?? '0'}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Target: Rp ${data['target_terkumpul'] ?? '0'}',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Dana Tersalurkan: Rp ${data['tersalurkan'] ?? '0'}',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Keterangan:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      data['keterangan'] ?? 'Tidak ada keterangan',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 64),
                    ElevatedButton(
                      child: Text('Donate Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PemdonasiPage(
                              donasiId: widget.donasiId, // Pass the donasiId to the next page
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: CustomBottomBarortu(),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// class DonationsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Donations'),
//       ),
//       body: Center(
//         child: Text('List of donations will be shown here'),
//       ),
//     );
//   }
// }

// Commented out PemdonasiPage class
// class PemdonasiPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Donation Page'),
//       ),
//       body: Center(
//         child: Text('Donation form will be shown here'),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:iss/Services/donasi_service.dart';

// class DonationDetailsPage extends StatefulWidget {
//   final int donasiId; // Receive donasiId from the previous page

//   const DonationDetailsPage({Key? key, required this.donasiId}) : super(key: key);

//   @override
//   _DonationDetailsPageState createState() => _DonationDetailsPageState();
// }

// class _DonationDetailsPageState extends State<DonationDetailsPage> {
//   final DonationService _donationService = DonationService();
//   Future<Map<String, dynamic>>? _donasiDetails;

//   @override
//   void initState() {
//     super.initState();
//     _donasiDetails = _donationService.fetchDonasiById(widget.donasiId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Donation Details'),
//         backgroundColor: Colors.blue,
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _donasiDetails,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Failed to load donation details'));
//           } else if (!snapshot.hasData) {
//             return Center(child: Text('No details available'));
//           } else {
//             final data = snapshot.data!;
//             return SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       data['nama_program'],
//                       style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Yayasan: ${data['yayasan']}',
//                       style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Keterangan: ${data['keterangan']}',
//                       style: TextStyle(fontSize: 14, color: Colors.black),
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       'Detail RAB Donasi:',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 8),
//                     ...data['rab_donasi'].map<Widget>((rab) {
//                       return Card(
//                         elevation: 2,
//                         margin: EdgeInsets.symmetric(vertical: 4),
//                         child: ListTile(
//                           title: Text(rab['product_name']),
//                           subtitle: Text('Qty: ${rab['qty']} ${rab['uom_name']}'),
//                           trailing: Text('Rp ${rab['total_paket']}'),
//                         ),
//                       );
//                     }).toList(),
//                     SizedBox(height: 16),
//                     Text(
//                       'Donatur Details:',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 8),
//                     ...data['donatur_donasi'].map<Widget>((donatur) {
//                       return Card(
//                         elevation: 2,
//                         margin: EdgeInsets.symmetric(vertical: 4),
//                         child: ListTile(
//                           title: Text(donatur['donatur_name']),
//                           subtitle: Text('Donasi: Rp ${donatur['nilai_donasi']}'),
//                           trailing: Text(donatur['infaq_date']),
//                         ),
//                       );
//                     }).toList(),
//                   ],
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
