import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pasakay/app/global/instance_firebase.dart';
import 'package:pasakay/app/models/user_request_ride_model.dart';

class UserHistoryController extends GetxController {
  final userRequestRides = <UserRequestRideModel>[].obs;
  Stream<QuerySnapshot> getRequestRidesStream() {
    return FirebaseFirestore.instance
        .collection('user_request_ride')
        .where('id', isEqualTo: auth.currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<List<UserRequestRideModel>> getRequestRidesStreams() {
    return FirebaseFirestore.instance
        .collection('user_request_ride')
        .where('id', isEqualTo: auth.currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot query) {
      List<UserRequestRideModel> rides = [];
      for (var doc in query.docs) {
        rides.add(
            UserRequestRideModel.fromJson(doc.data() as Map<String, dynamic>));
      }

      print('Hello $rides');
      return rides;
    });
  }

  @override
  void onInit() {
    super.onInit();

    userRequestRides.bindStream(getRequestRidesStreams());
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
