import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pasakay/app/routes/app_pages.dart';

class AuthRepository {
  static final _auth = FirebaseAuth.instance;

  static Future<void> sendEmailVerificationLink() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Error: $e");
      rethrow;
    }
  }

  static Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Error: $e");
      rethrow;
    }
  }

  static Future<void> signout() async {
    try {
      await _auth.signOut();

      Get.offAllNamed(AppPages.LOGIN);
    } catch (e) {
      log("Error: $e");
      rethrow;
    }
  }
}
