import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // SMTP Credentials (Use an App Password for Gmail)
  // IMPORTANT: You must provide a valid Gmail and App Password for this to work.
  final String _myEmail = 'your-email@gmail.com'; 
  final String _myAppPassword = 'your-app-password'; 

  // Stream for Auth State Changes
  Stream<User?> get user => _auth.authStateChanges();

  // Function to send a Custom Greeting Email via SMTP
  Future<void> sendGreetingEmail(String recipientEmail, String name) async {
    final smtpServer = gmail(_myEmail, _myAppPassword);

    final message = Message()
      ..from = Address(_myEmail, 'Kaarigar Haat')
      ..recipients.add(recipientEmail)
      ..subject = 'Namaste $name! Welcome to Kaarigar Haat 🏺'
      ..html = """
        <div style="font-family: 'Poppins', sans-serif; padding: 20px; color: #3B2F2F;">
          <h1 style="color: #8B4513;">Namaste $name!</h1>
          <p>We are delighted to have you at <b>Kaarigar Haat</b>.</p>
          <p>Thank you for joining our community to support local artisans. Explore the latest handmade masterpieces added to our collection today!</p>
          <br>
          <p>Happy Shopping,<br>The Kaarigar Haat Team</p>
        </div>
      """;

    try {
      await send(message, smtpServer);
      debugPrint('Greeting email sent to $recipientEmail');
    } catch (e) {
      debugPrint('SMTP Email error: $e');
    }
  }

  // Sign Up
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String userType,
    Map<String, dynamic>? artisanDetails,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        await user.sendEmailVerification();

        Map<String, dynamic> userData = {
          'uid': user.uid,
          'name': name,
          'email': email,
          'userType': userType,
          'createdAt': FieldValue.serverTimestamp(),
        };

        if (userType == 'Artisan' && artisanDetails != null) {
          userData.addAll(artisanDetails);
        }

        await _firestore.collection('users').doc(user.uid).set(userData);

        try {
          await _firestoreService.sendNotification(
            userId: user.uid,
            title: "Verification Link Sent! 📧",
            body: "Namaste $name! We've sent a verification link to your email. Please verify to secure your account.",
          );
        } catch (e) {
          debugPrint("Notification Error: $e");
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Login
  Future<String?> login({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      if (result.user != null) {
        Map<String, dynamic>? userData = await getUserData(result.user!.uid);
        String name = userData?['name'] ?? "Member";
        sendGreetingEmail(email, name);

        try {
          await _firestoreService.sendNotification(
            userId: result.user!.uid,
            title: "Welcome Back! 👋",
            body: "Great to see you again! Check your email for a special greeting.",
          );
        } catch (e) {
          debugPrint("Login Notification Error: $e");
        }
      }
      return null; 
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign in with Google
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Sign-in aborted by user';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null && result.additionalUserInfo!.isNewUser) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName,
          'email': user.email,
          'profileImageUrl': user.photoURL,
          'userType': 'Buyer', 
          'createdAt': FieldValue.serverTimestamp(),
        });
        sendGreetingEmail(user.email!, user.displayName!);
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign in with Facebook
  Future<String?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        return 'Facebook login failed: ${result.message}';
      }

      final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null && userCredential.additionalUserInfo!.isNewUser) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName,
          'email': user.email,
          'profileImageUrl': user.photoURL,
          'userType': 'Buyer', 
          'createdAt': FieldValue.serverTimestamp(),
        });
        sendGreetingEmail(user.email!, user.displayName!);
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Forgot Password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Get User Data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
