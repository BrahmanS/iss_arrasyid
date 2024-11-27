import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iss/Layout/AppbarOrtu.dart';
import 'package:iss/Layout/BottomBarOrtu.dart';
import 'package:iss/Layout/DrawerOrtu.dart';
import 'package:iss/Services/invoice_service.dart'; 
import 'package:iss/Provider/user_data_provider.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:iss/Services/shared_prefs.dart';
class TagihanPage extends StatefulWidget {
  @override
  _TagihanPageState createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
  late InvoiceService _invoiceService;
  Future<Map<String, dynamic>>? _invoicesFuture;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _initializeInvoice();
    _invoiceService = InvoiceService();

    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);

    // if (sessionId != null) {
    //   _invoicesFuture = _invoiceService.fetchInvoices(sessionId);
    // }
  }

  Future<void> _initializeInvoice() async {
    // final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // final sessionIdCookie = userDataProvider.userData?['session_id'];
    // final sessionId = _extractSessionId(sessionIdCookie);
    final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();

    if (sessionId2 != null) {
      setState(() {
        _invoicesFuture = InvoiceService().fetchInvoices(sessionId2);
      });
      // _invoicesFuture = _invoiceService.fetchInvoices(sessionId2);
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

  bool _isWithinSelectedMonth(String dateDue) {
    if (_selectedMonth == null) return true;
    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(dateDue);
      final formattedMonth = DateFormat('MMMM').format(parsedDate);
      return formattedMonth == _selectedMonth;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarortu(),
      drawer: CustomDrawerortu(),
      bottomNavigationBar: CustomBottomBarortu(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: Text('Pilih Bulan'),
              value: _selectedMonth,
              items: DateFormat('MMMM').dateSymbols.MONTHS.map((month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(month),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _invoicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!['data'].isEmpty) {
                  return Center(child: Text('Tidak ada tagihan'));
                } else {
                  final invoices = snapshot.data!['data']
                      .where((invoice) => _isWithinSelectedMonth(invoice['date_due']))
                      .toList();
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = invoices[index];
                      return _buildInvoiceCard(
                        context,
                        invoice['name'],
                        'Batas Pembayaran: ${invoice['date_due']}',
                        'Total Tagihan: Rp ${invoice['amount_total']}',
                        'Tagihan Belum Dibayar: Rp ${invoice['amount_residual']}',
                        invoice['payment_state'],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(
    BuildContext context,
    String invoiceNumber,
    String dueDate,
    String totalAmount,
    String outstandingAmount,
    String paymentState,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invoiceNumber,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(dueDate),
            Text(totalAmount),
            Text(outstandingAmount),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: paymentState == 'paid' ? Colors.green : Colors.red,
              ),
              onPressed: () {},
              child: Text(
                paymentState == 'paid' ? 'Dibayar' : 'Belum Dibayar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
