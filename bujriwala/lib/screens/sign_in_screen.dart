import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  final List<String> _roles = ['customer', 'collector', 'recycler'];
  String? _selectedRole;

  Future<void> _signInWithGoogle() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Configure Google Sign-In to always show account chooser
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'], // Add any additional scopes if needed
        // Force account selection by clearing previous account and setting prompt
      );

      // Sign out from Google to ensure fresh selection (optional, see notes)
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null && mounted) {
        String? existingRole = user.displayName?.contains('role:') == true
            ? user.displayName!.split('role:')[1]
            : null;

        if (existingRole == null) {
          await user.updateDisplayName('${user.displayName ?? ''} role:$_selectedRole');
          await user.reload();
          existingRole = _selectedRole;
        }

        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/dashboard',
            arguments: {'role': existingRole},
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-In failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade700, Colors.green.shade200],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.recycling, size: 80, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to Bujriwala',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Join the recycling revolution',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            hint: const Text('Select your role'),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: _roles.map((role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(role.capitalize()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedRole = value);
                            },
                          ),
                          const SizedBox(height: 20),
                          _isLoading
                              ? const CircularProgressIndicator(color: Colors.green)
                              : ElevatedButton.icon(
                                  icon: const Icon(Icons.login),
                                  label: const Text('Sign in with Google'),
                                  onPressed: _signInWithGoogle,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'By signing in, you agree to our terms',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}