import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  final String email;
  final String role;

  DashboardScreen({required this.email, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, $email!'),
            SizedBox(height: 20),
            Text('Role: $role'),
          ],
        ),
      ),
    );
  }
}