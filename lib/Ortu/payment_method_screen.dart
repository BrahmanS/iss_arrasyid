import 'package:flutter/material.dart';
import 'package:iss/ortu/pemdonasiortu.dart';
import 'package:iss/Services/shared_prefs.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PaymentMethodScreen(),
    );
  }
}

class PaymentMethodScreen extends StatefulWidget {
  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selectedMethod = 'Dana';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Payment Method'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Silahkan pilih metode pembayaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            PaymentMethodOption(
              title: 'Dana',
              isSelected: _selectedMethod == 'Dana',
              onTap: () {
                setState(() {
                  _selectedMethod = 'Dana';
                });
              },
            ),
            PaymentMethodOption(
              title: 'Virtual Account',
              isSelected: _selectedMethod == 'Virtual Account',
              onTap: () {
                setState(() {
                  _selectedMethod = 'Virtual Account';
                });
              },
            ),
            PaymentMethodOption(
              title: 'Gopay',
              isSelected: _selectedMethod == 'Gopay',
              onTap: () {
                setState(() {
                  _selectedMethod = 'Gopay';
                });
              },
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodOption({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Colors.blue : Colors.grey,
              
            ),
          ],
        ),
      ),
    );
  }
}
