import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:metanoia_flutter_test/user/usermodel.dart';

class AuthenticationService with ChangeNotifier {
  final FirebaseAuth firebaseAuth;
  PhoneAuthCredential? _phoneAuthCredential;
  String? verificationId, status = '', authPage = '', error = '';

  //user's sign-in state notifier.
  Stream<MyUser?> get authStateChanges => firebaseAuth
      .authStateChanges()
      .map((user) => _userFromFirebaseUser(user));

  AuthenticationService(this.firebaseAuth);

  MyUser? _userFromFirebaseUser(User? user) {
    if (user != null) return MyUser(uid: user.uid);
    return null;
  }

  //Email SignIn
  Future<void> signInWithEmail(
      {required String email, required String password}) async {
    firebaseAuth
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
    firebaseAuth
        .createUserWithEmailAndPassword(email: email!, password: password!)
        .then((value) {
      value.user!.sendEmailVerification();
      error = '';
      notifyListeners();
      //Create New user in Firestore
      UserDatabaseService(uid: firebaseAuth.currentUser!.uid)
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
      await firebaseAuth
          .signInWithCredential(_phoneAuthCredential!)
          .then((value) {
        //Create New user in Firestore
        UserDatabaseService(uid: value.user!.uid).getUserData.first.then((value) {
          UserDatabaseService(uid: value.uid).updateUserData(value.name ?? '', value.age ?? '');
        }).catchError((e){
          UserDatabaseService(uid: value.user!.uid).updateUserData('','');
        });
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

    await firebaseAuth.verifyPhoneNumber(
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
    firebaseAuth.signInWithCredential(_phoneAuthCredential!).then((value) {
      status = 'Login';
      error = '';
      notifyListeners();

      //Create if new user
      //Create New user in Firestore
      UserDatabaseService(uid: value.user!.uid).getUserData.first.then((value) {
        UserDatabaseService(uid: value.uid).updateUserData(value.name ?? '', value.age ?? '');
      }).catchError((e){
        UserDatabaseService(uid: value.user!.uid).updateUserData('','');
      });
    }).onError((FirebaseAuthException e, stackTrace) {
      error = e.message;
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
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

      firebaseAuth.signInWithCredential(credential).then((value) {
        error = '';
        notifyListeners();

        //Create New user in Firestore
        UserDatabaseService(uid: value.user!.uid).getUserData.first.then((value) {
          UserDatabaseService(uid: value.uid).updateUserData(value.name ?? '', value.age ?? '');
        }).catchError((e){
          UserDatabaseService(uid: value.user!.uid).updateUserData('','');
        });

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
