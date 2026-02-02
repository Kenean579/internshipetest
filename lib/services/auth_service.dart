import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String companyName,
    required String licenseNumber,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        await _db.collection('providers').doc(user.uid).set({
          'id': user.uid,
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'companyName': companyName,
          'licenseNumber': licenseNumber,
          'createdAt': DateTime.now().toIso8601String(),
        });
        return user;
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw e.message ?? 'An error occurred during registration.';
      }
      rethrow;
    }
    return null;
  }

  Future<User?> login({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw e.message ?? 'An error occurred during login.';
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<AppUser?> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _db
          .collection('providers')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    }
    return null;
  }
}
