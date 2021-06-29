import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:metanoia_flutter_test/user/usermodel.dart';

class AuthenticationService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  PhoneAuthCredential? _phoneAuthCredential;
  String? verificationId, status = '', authPage = '', error = '';

  //user's sign-in state notifier.
  Stream<MyUser?> get authStateChanges => _firebaseAuth
      .authStateChanges()
      .map((user) => _userFromFirebaseUser(user));

  AuthenticationService(this._firebaseAuth);

  MyUser? _userFromFirebaseUser(User? user) {
    if (user != null) return MyUser(uid: user.uid);
    return null;
  }

  //Email SignIn
  Future<void> signInWithEmail(
      {required String email, required String password}) async {
    _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      if (value.user!.emailVerified == false)
        value.user!.sendEmailVerification();
      error = '';
      notifyListeners();
    }).onError((FirebaseAuthException e, stackTrace) {
      error = e.message;
      notifyListeners();
    });
  }

  Future<void> signUpWithEmail({String? email, String? password}) async {
    _firebaseAuth
        .createUserWithEmailAndPassword(email: email!, password: password!)
        .then((value) {
      value.user!.sendEmailVerification();
      error = '';
      notifyListeners();
      //Create New user in Firestore
      UserDatabaseService(uid: _firebaseAuth.currentUser!.uid)
          .updateUserData('', '');
    }).onError((FirebaseAuthException e, stackTrace) {
      error = e.message;
      notifyListeners();
    });
  }

  //Phone Number SignIn
  Future<void> submitPhoneNumber(String phoneNumber) async {
    error = '';
    Future<void> verificationCompleted(
        PhoneAuthCredential phoneAuthCredential) async {
      this._phoneAuthCredential = phoneAuthCredential;
      await _firebaseAuth
          .signInWithCredential(_phoneAuthCredential!)
          .then((value) {
        //Create New user in Firestore
        UserDatabaseService(uid: _firebaseAuth.currentUser!.uid).updateUserData('','');
        error = '';
        notifyListeners();
      }).onError((FirebaseAuthException e, stackTrace) {
        error = e.message;
        notifyListeners();
      });
    }

    void verificationFailed(FirebaseAuthException e) {
      error = e.message;
      notifyListeners();
    }

    void codeSent(String verificationId, [int? code]) {
      this.verificationId = verificationId;
      status = 'codesent';
      notifyListeners();
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      //print('codeAutoRetrievalTimeout');
    }

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 30),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<void> submitOTP(String smsCode) async {
    this._phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId!, smsCode: smsCode);
    _firebaseAuth.signInWithCredential(_phoneAuthCredential!).then((value) {
      status = 'Login';
      error = '';
      notifyListeners();

      //Create New user in Firestore
      UserDatabaseService(uid: _firebaseAuth.currentUser!.uid).updateUserData('','');
    }).onError((FirebaseAuthException e, stackTrace) {
      error = e.message;
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  changePage(String title) {
    authPage = title;
    notifyListeners();
  }

  //GoogleSignIn
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? gUser;
  Future googleLogin() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      _firebaseAuth.signInWithCredential(credential).then((value) {
        error = '';
        notifyListeners();
        //Create New user in Firestore
        UserDatabaseService(uid: _firebaseAuth.currentUser!.uid).updateUserData(_firebaseAuth.currentUser!.displayName!,'');

        if (value.user!.emailVerified != true)
          value.user!.sendEmailVerification();
      }).onError(
        (FirebaseAuthException e, stackTrace) {
          error = e.message;
          notifyListeners();
        },
      );
    }
  }
}
