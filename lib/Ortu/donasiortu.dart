import 'package:flutter/material.dart';
import 'package:iss/Layout/BottomBarOrtu.dart';
import 'package:iss/ortu/HomeOrtu.dart';
import 'package:iss/Services/donasi_service.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'detail_donasi.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import this for initializing locale data
import 'package:iss/Services/shared_prefs.dart';
class Donasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donations App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DonationsPage(),
    );
  }
}

class DonationsPage extends StatefulWidget {
  @override
  _DonationsPageState createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  final DonationService _donationService = DonationService();
  Future<List<dynamic>>? _donasiData;

  @override
  void initState() {
    super.initState();

    // Initialize the locale data
    initializeDateFormatting('id_ID', null).then((_) {
      _donasiData = _donationService.fetchDonasi();
      setState(() {}); // Refresh the state once the initialization is complete
    });
  }

  String _formatDate(String dateEnd) {
  try {
    // Parse the date string assuming it's in yyyy-MM-dd format
    DateTime endDate = DateTime.parse(dateEnd.trim());
    DateTime today = DateTime.now();

    // Calculate the difference in days
    int daysRemaining = endDate.difference(today).inDays;

    // Handle past dates
    if (daysRemaining < 0) {
      return "Sudah berakhir";
    }

    return "$daysRemaining hari lagi";
  } catch (e) {
    print('Date parsing error: $e');
    return "Invalid date"; // Return this if parsing fails
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Donations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeOrtuPage()));
          },
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          Icon(Icons.filter_list, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'Program Donasi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _donasiData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load data'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No donations available'));
                } else {
                  final donasiData = snapshot.data as List<dynamic>;
                  final filteredData = donasiData.where((donasi) => donasi['state'] == 'publish').toList();

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final data = filteredData[index];
                      return DonationCard(
                        donasiId: data['id'], // Pass the donasi ID
                        category: data['yayasan'] ?? 'Uncategorized',
                        title: data['nama_program'] ?? 'No Title',
                        subtitle: _formatDate(data['date_end'] ?? ''),
                        target: 'Rp ${data['target_terkumpul'] ?? '0'}',
                        progress: (data['progres_saldo_terkumpul'] ?? 0) / 100,
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBarortu(),
    );
  }
}

class DonationCard extends StatelessWidget {
  final int donasiId; // Add the donasiId parameter
  final String category;
  final String title;
  final String subtitle;
  final String target;
  final double progress;

  const DonationCard({
    Key? key,
    required this.donasiId, // Add this parameter
    required this.category,
    required this.title,
    required this.subtitle,
    required this.target,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonationDetailsPage(donasiId: donasiId), // Pass donasiId
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Target: $target',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                color: progress > 0 ? Colors.blue : Colors.grey,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terkumpul: Rp ${(double.tryParse(target.replaceAll('Rp ', '').replaceAll(',', '')) ?? 0) * progress}',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
