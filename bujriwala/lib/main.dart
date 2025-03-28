import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bujriwala/screens/sign_in_screen.dart';
import 'package:bujriwala/screens/customer_dashboard_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BujriwalaApp());
}

class BujriwalaApp extends StatelessWidget {
  const BujriwalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bujriwala',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      initialRoute: '/sign_in',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/sign_in':
            return MaterialPageRoute(builder: (_) => const SignInScreen());
          case '/dashboard':
            final args = settings.arguments as Map<String, dynamic>?;
            final role = args?['role'] as String? ?? 'customer';
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              // If no user is signed in, redirect to sign-in
              return MaterialPageRoute(builder: (_) => const SignInScreen());
            }
            switch (role) {
              case 'customer':
                return MaterialPageRoute(
                  builder: (_) => CustomerDashboard(role: role),
                );
              case 'recycler':
                // Placeholder for recycler role - you can add a RecyclerDashboard later
                return MaterialPageRoute(
                  builder: (_) => CustomerDashboard(role: role), // Temporary fallback
                );
              default:
                return MaterialPageRoute(
                  builder: (_) => CustomerDashboard(role: 'customer'),
                );
            }
          default:
            return MaterialPageRoute(builder: (_) => const SignInScreen());
        }
      },
    );
  }
}