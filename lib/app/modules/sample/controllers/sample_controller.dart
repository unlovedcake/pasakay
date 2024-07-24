import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pasakay/app/global/instance_firebase.dart';
import 'package:pasakay/app/modules/driver/views/driver_view.dart';
import 'package:pasakay/app/modules/home/views/home_view.dart';
import 'package:pasakay/app/modules/login/views/login_view.dart';
import 'package:pasakay/app/routes/app_pages.dart';

class SampleController extends GetxController {
  Future<void> checkUserRole() async {
    try {
      if (auth.currentUser!.uid.isEmpty) {
        Get.toNamed(AppPages.LOGIN);
        return;
      }
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser!.uid)
          .get();

      if (snapshot.exists) {
        var userData = snapshot.data() as Map<String, dynamic>;
        var role = userData['role'];

        if (role == 'driver') {
          Get.toNamed(AppPages.DRIVER);
          return;
        } else {
          Get.toNamed(AppPages.INITIAL);
        }
      }
    } catch (e) {
      print('Error');
      return;
    }
  }

  @override
  void onInit() {
    print('Hoy');
    checkUserRole();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    checkUserRole();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
