import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  Future<User?> loginWithEmail(String email, String senha) async {
    final userCred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha.trim(),
    );
    return userCred.user;
  }

  Future<User?> registerWithEmail({
    required String nome,
    required int idade,
    required String email,
    required String senha,
  }) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha.trim(),
    );

    await _firestore.collection('users').doc(userCred.user!.uid).set({
      'nome': nome.trim(),
      'email': email.trim(),
      'idade': idade,
      'criadoEm': DateTime.now(),
    });

    return userCred.user;
  }

  Future<User?> loginWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    return userCred.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
