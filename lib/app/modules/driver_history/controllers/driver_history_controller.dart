import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pasakay/app/global/instance_firebase.dart';

class DriverHistoryController extends GetxController {
  Stream<QuerySnapshot> getRequestRidesStream() {
    return FirebaseFirestore.instance
        .collection('user_request_ride')
        .where('driver.id', isEqualTo: auth.currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
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
