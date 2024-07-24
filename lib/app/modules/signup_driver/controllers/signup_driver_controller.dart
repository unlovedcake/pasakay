import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:get/get.dart';
import 'package:pasakay/app/models/user_model.dart';
import 'package:pasakay/app/repositories/auth_repository.dart';
import 'package:pasakay/app/routes/app_pages.dart';
import 'package:pasakay/app/utils/loading_indicator.dart';

import '../../../global/instance_firebase.dart';

class SignupDriverController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final vehicleType = 'MotorCycle'.obs;

  final obscureText = true.obs;

  final mobileNumberController = TextEditingController();

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  signUp() async {
    LoadingIndicator.showLoadingIndicator('Authenticating...');
    try {
      final user = await AuthRepository.createUserWithEmailAndPassword(
          emailController.text, passwordController.text);

      if (user != null) {
        await user.updateDisplayName('driver');
        UserModel userMap = UserModel(
          user: UserData(
              id: '',
              name: '',
              contact: '',
              email: '',
              fcmToken: '',
              image: ''),
          driver: DriverData(
              id: user.uid,
              name: nameController.text.trim(),
              contact: mobileNumberController.text.trim(),
              email: emailController.text.trim(),
              image:
                  "https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg",
              vehicleType: vehicleType.value),
          role: auth.currentUser!.displayName!,
          createdAt: DateTime.now(),
        );

        await firestore.collection('users').doc(user.uid).set(userMap.toMap());

        GeoFirePoint myLocation =
            geo.point(latitude: 10.3321, longitude: 123.9357);
        await firestore.collection('driver_locations').doc(user.uid).set({
          'id': user.uid,
          'name': nameController.text.trim(),
          'contact': mobileNumberController.text.trim(),
          'vehicleType': vehicleType.value,
          'position': myLocation.data
        });

        print("User Created Succesfully");
        LoadingIndicator.closeLoadingIndicator();

        Get.offAllNamed(AppPages.DRIVER);
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
