import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<User?> signInWithGoogle(String role) async {
    try {
      print("Starting Google Sign-In...");
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      print("Google User Result: $googleUser");

      if (googleUser == null) {
        print("User cancelled sign-in");
        return null;
      }

      print("Google User Type: ${googleUser.runtimeType}");
      final googleAuth = await googleUser.authentication;
      print("Google Auth: accessToken=${googleAuth.accessToken}, idToken=${googleAuth.idToken}");

      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase.UserCredential userCredential = await _auth.signInWithCredential(credential);
      final firebase.User? firebaseUser = userCredential.user;
      print("Firebase User: $firebaseUser");

      if (firebaseUser != null) {
        return User(
          email: firebaseUser.email ?? '',
          role: role.toLowerCase(),
          address: '0x51E1bCb40463C49eDD3426d0C2cF58785d8003fE', // Default test address
        );
      }
      return null;
    } catch (e) {
      print("Sign-in error: $e");
      rethrow;
    }
  }
}

class User {
  final String email;
  final String role;
  final String address;

  User({
    required this.email,
    required this.role,
    required this.address,
  });
}