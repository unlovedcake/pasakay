import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pasakay/app/models/user_model.dart';
import 'package:pasakay/app/repositories/auth_repository.dart';
import 'package:pasakay/app/routes/app_pages.dart';
import 'package:pasakay/app/utils/loading_indicator.dart';
import 'package:toastification/toastification.dart';

import '../../../global/instance_firebase.dart';

class SignupUserController extends GetxController {
  final nameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final ctx = Get.context as BuildContext;

  final obscureText = true.obs;

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  signUp() async {
    LoadingIndicator.showLoadingIndicator('Authenticating...');
    try {
      final user = await AuthRepository.createUserWithEmailAndPassword(
          emailController.text, passwordController.text);
      if (user != null) {
        final String? currentFcmToken =
            await FirebaseMessaging.instance.getToken();
        await user.updateDisplayName('user');
        UserModel userMap = UserModel(
          user: UserData(
            id: user.uid,
            name: nameController.text.trim(),
            contact: mobileNumberController.text.trim(),
            email: emailController.text.trim(),
            fcmToken: currentFcmToken ?? '',
            image:
                "https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg",
          ),
          driver: DriverData(
            id: '',
            name: '',
            contact: '',
            email: '',
            image: '',
            vehicleType: '',
          ),
          role: auth.currentUser!.displayName!,
          createdAt: DateTime.now(),
        );

        // Map<String, dynamic> userMap = {
        //   "user": {
        //     "id": user.uid,
        //     "name": nameController.text.trim(),
        //     "contact": mobileNumberController.text.trim(),
        //     "email": emailController.text.trim(),
        //   },
        //   "driver": {
        //     "id": "",
        //     "name": "",
        //     "contact": "",
        //     "email": "",
        //     "vehicleType": "",
        //   },
        //   'role': role.value,
        //   'createdAt': FieldValue.serverTimestamp(),
        // };

        await firestore.collection('users').doc(user.uid).set(userMap.toMap());
        print("User Created Succesfully");
        LoadingIndicator.closeLoadingIndicator();

        Get.offAllNamed(AppPages.INITIAL);
      }
    } catch (e) {
      print("Error: ${e.toString()}");
      LoadingIndicator.closeLoadingIndicator();
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
