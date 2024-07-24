import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pasakay/app/repositories/auth_repository.dart';
import 'package:pasakay/app/routes/app_pages.dart';
import 'package:pasakay/app/utils/loading_indicator.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final obscureText = true.obs;

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  login() async {
    LoadingIndicator.showLoadingIndicator('Authenticating...');
    try {
      final user = await AuthRepository.loginUserWithEmailAndPassword(
          emailController.text, passwordController.text);
      if (user != null) {
        String role = user.displayName!;
        if (role == 'driver') {
          LoadingIndicator.closeLoadingIndicator();
          Get.offAllNamed(AppPages.DRIVER);
        } else {
          LoadingIndicator.closeLoadingIndicator();
          Get.offAllNamed(AppPages.INITIAL);
        }
        //checkUserRole(user.uid);
      }
    } catch (e) {
      print("Error: ${e.toString()}");
      LoadingIndicator.closeLoadingIndicator();
    }
  }

  Future<void> checkUserRole(String userId) async {
    try {
      // Retrieve user data from Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        var userData = snapshot.data() as Map<String, dynamic>;
        var role = userData['role'];

        // Check user role and return the appropriate page
        if (role == 'driver') {
          Get.offAllNamed(AppPages.DRIVER);
        } else {
          Get.offAllNamed(AppPages.INITIAL);
        }
      } else {
        print('Error');
      }
    } catch (e) {
      print('Error');
    }
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
