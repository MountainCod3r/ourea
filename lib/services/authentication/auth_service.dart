import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser _firebaseUser;

  FirebaseUser get user => _firebaseUser;

  Future loginWithEmail(
      {@required String email, @required String password}) async {
    try {
      var user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return user != null;
    } catch (e) {
      return e.message;
    }
  }

  Future signUpWithEmail(
      {@required String email, @required String password}) async {
    try {
      var authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _firebaseUser = await _auth.currentUser();
      return authResult.user != null;
    } catch (e) {
      return e.message;
    }
  }

  Future anonymousLogin() async {
    try {
      var authResult = await _auth.signInAnonymously();
      _firebaseUser = await _auth.currentUser();
      return authResult.user != null;
    } catch (e) {
      print(e.toString());
    }
  }
}
