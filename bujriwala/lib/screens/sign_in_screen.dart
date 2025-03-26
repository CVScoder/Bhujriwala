import 'package:flutter/material.dart';
import 'package:bujriwala/screens/dashboard_screen.dart'; // Updated path
import 'package:bujriwala/services/auth_service.dart'; // Adjust if in services/

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String _selectedRole = 'Customer';
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final List<String> _roles = ['Customer', 'Collector', 'Recycler'];

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle(_selectedRole);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(email: user.email, role: user.role),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in cancelled')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bujriwala Sign In')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: _selectedRole,
              onChanged: (value) {
                setState(() => _selectedRole = value!);
              },
              items: _roles.map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signInWithGoogle,
                    child: Text('Sign in with Google'),
                  ),
          ],
        ),
      ),
    );
  }
}