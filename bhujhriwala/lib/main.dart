import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(BhujriwalaApp());
}

class BhujriwalaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bhujriwala',
      theme: ThemeData(primarySwatch: Colors.green),
      home: PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String status = "";

  Future<void> createOrderAndPay() async {
    final amount = int.tryParse(amountController.text) ?? 0;
    final userAddress = addressController.text.trim();

    if (amount <= 0 || userAddress.isEmpty) {
      setState(() => status = "Enter valid amount and address");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/create-order/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount, 'userAddress': userAddress}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final orderId = data['orderId'];
        final amountInPaise = data['amount'];

        final razorpayKey = 'rzp_test_your_key_id'; // Replace with your key
        final paymentUrl = Uri.parse(
          'http://localhost:8080/pay?orderId=$orderId&amount=$amountInPaise&key=$razorpayKey&address=$userAddress',
        );

        if (await canLaunchUrl(paymentUrl)) {
          await launchUrl(paymentUrl, mode: LaunchMode.externalApplication);
          setState(() => status = "Payment initiated. Complete in browser.");
        } else {
          setState(() => status = "Failed to launch payment URL");
        }
      } else {
        setState(() => status = "Order creation failed: ${response.body}");
      }
    } catch (e) {
      setState(() => status = "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bhujriwala - Pay for Scrap')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount (INR)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Ethereum Address (0x...)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: createOrderAndPay,
              child: Text('Pay with Razorpay'),
            ),
            SizedBox(height: 16),
            Text(status, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}