import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iss/ortu/payment_method_screen.dart';
import 'package:iss/Services/parent_service.dart';
import 'package:iss/Ortu/donasiortu.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Services/donasi_service.dart';
import 'package:iss/Services/shared_prefs.dart';
class PemdonasiPage extends StatefulWidget {
  final int donasiId;

  PemdonasiPage({required this.donasiId});

  @override
  _PemdonasiPageState createState() => _PemdonasiPageState();
}

class _PemdonasiPageState extends State<PemdonasiPage> {
  TextEditingController _amountController = TextEditingController();
  Map<String, dynamic>? parentData;

  @override
  void initState() {
    super.initState();
    _fetchParentData();
    print('Donasi ID: ${widget.donasiId}');
  }

  void _fetchParentData() async {
    try {
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      final sessionIdCookie = userDataProvider.userData?['session_id'];
      final sessionId = _extractSessionId(sessionIdCookie);
      if (sessionId != null) {
        ParentService parentService = ParentService();
        Map<String, dynamic>? data = await parentService.getParentData(sessionId);
        setState(() {
          parentData = data;
        });
        print('User Data: $parentData');
      } else {
        print('Session ID not found');
      }
    } catch (e) {
      print('Failed to fetch parent data: $e');
    }
  }

  String? _extractSessionId(String? sessionIdCookie) {
    if (sessionIdCookie == null) return null;

    try {
      final parts = sessionIdCookie.split(';');
      for (final part in parts) {
        final trimmedPart = part.trim();
        if (trimmedPart.startsWith('session_id=')) {
          return trimmedPart.split('=')[1];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Donasi()),
            );
          },
        ),
        title: Text('Donasi'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Mau donasi berapa?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text('Rp', style: TextStyle(fontSize: 18)),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Harapan atau Doa',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Tulis Harapan atau doa Anda di sini...',
                      ),
                    ),
                    SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildAmountButton('10.000'),
                        _buildAmountButton('50.000'),
                        _buildAmountButton('100.000'),
                        _buildAmountButton('150.000'),
                        _buildAmountButton('200.000'),
                        _buildAmountButton('250.000'),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (parentData != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentMethodScreen(
                                // donasiId: widget.donasiId, // Pass the donasiId to the payment screen
                                // userData: parentData!,
                              ),
                            ),
                          );
                        } else {
                          // Handle case when parent data is not loaded
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to load user data')),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pilih Metode Pembayaran lainnya'),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey),
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: ElevatedButton(
                onPressed: () async {
                  if (parentData != null) {
                    try {
                      DonationService donationService = DonationService();
                      
                      // Assuming the parentData contains the required fields
                      String namaDonatur = parentData!['name'] ?? '';
                      String email = parentData!['email'] ?? '';
                      String phone = parentData!['mobile'] ?? '';
                      String note = ''; // You can get this from a text field if available
                      int donasiId = widget.donasiId;
                      int nilaiDonasi = int.parse(_amountController.text);

                      print('Submitting donation with Donasi ID: $donasiId');
                      
                      // Call the submitDonation method
                      Map<String, dynamic> response = await donationService.submitDonation(
                        namaDonatur: namaDonatur,
                        email: email,
                        phone: phone,
                        note: note,
                        donasiId: donasiId,
                        nilaiDonasi: nilaiDonasi,
                      );

                      // Handle successful response
                      print('Donation submission successful: $response');
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Donasi Berhasil'),
                            content: Text('Terima kasih atas donasi Anda!'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Navigate to another page or reset the form as needed
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } catch (e) {
                      print('Failed to submit donation: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal mengirimkan donasi: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to load user data')),
                    );
                  }
                },

                child: Text('Bayar sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountButton(String amount) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _amountController.text = amount.replaceAll('.', '');
        });
      },
      child: Text('Rp $amount'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        side: BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
