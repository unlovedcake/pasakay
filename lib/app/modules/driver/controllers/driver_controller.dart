import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pasakay/app/global/instance_firebase.dart';
import 'package:pasakay/app/models/predicted_places_model.dart';
import 'package:pasakay/app/models/user_model.dart';
import 'package:pasakay/app/repositories/search_place_repository.dart';
import 'package:pasakay/app/utils/custom_snackbar.dart';
import 'package:pasakay/app/utils/notification.dart';

enum CurrentLocationStatus { initial, loading, succeeded, failed }

class DriverController extends GetxController {
  final geo = GeoFlutterFire();
  final currentLocationStatus = CurrentLocationStatus.initial.obs;
  bool get isCurrentLocationStatus =>
      currentLocationStatus.value == CurrentLocationStatus.loading;
  LatLng startLocation = LatLng(
    10.2548959,
    123.8458525,
  );

  late LatLng endLocation;
  Position? currentUserPosition;

  final originLatitude = 0.0.obs;
  final originLongitude = 0.0.obs;

  final destinationLatitude = 0.0.obs;
  final destinationLongitude = 0.0.obs;

  final searchTextFieldFrom = TextEditingController();

  final searchTextFieldTo = TextEditingController();
  final searchInput = ''.obs;

  final searchInputTo = false.obs;

  final Completer<GoogleMapController> controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  late CameraPosition kGooglePlex;

  late Marker originMarker;
  late Marker destinationMarker;
  late Marker driversNearByMarker;

  //List<Marker> listMarkers = [];

  String address = '';

  final selectedVehicle = ''.obs;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polylineSet = {};

  Set<Circle> circlesSet = {};

  final listMarkers = <Marker>[].obs;
  final NotificationSetUp _noti = NotificationSetUp();

  final ctx = Get.context as BuildContext;

  void onInit() {
    currentLocation();
    _noti.configurePushNotifications(ctx);
    _noti.eventListenerCallback(ctx);
    AwesomeNotifications().setListeners(
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
    );

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

  Future<void> updateDriverLocationWhenAppIsOpen() async {
    GeoFirePoint myLocation = geo.point(
        latitude: originLatitude.value, longitude: originLongitude.value);
    await firestore
        .collection('driver_locations')
        .doc(auth.currentUser!.uid)
        .update({'position': myLocation.data});
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      CustomSnackBar.showCustomErrorSnackBar(
          title: 'Error',
          message: 'Location services are disabled. Please enable the services',
          duration: const Duration(seconds: 4));

      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        CustomSnackBar.showCustomErrorSnackBar(
            title: 'Error',
            message: 'Location permissions are denied',
            duration: const Duration(seconds: 4));

        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      CustomSnackBar.showCustomErrorSnackBar(
          title: 'Error',
          message:
              'Location permissions are permanently denied, we cannot request permissions.',
          duration: const Duration(seconds: 4));

      return false;
    }
    return true;
  }

  Future<String> getPlacemarks(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

      if (placemarks.isNotEmpty) {
        // Concatenate non-null components of the address
        var streets = placemarks.reversed
            .map((placemark) => placemark.street)
            .where((street) => street != null);

        // Filter out unwanted parts
        streets = streets.where((street) =>
            street!.toLowerCase() !=
            placemarks.reversed.last.locality!
                .toLowerCase()); // Remove city names
        streets = streets
            .where((street) => !street!.contains('+')); // Remove street codes

        address += streets.join(', ');

        address += ', ${placemarks.reversed.last.subLocality ?? ''}';
        address += ', ${placemarks.reversed.last.locality ?? ''}';
        address += ', ${placemarks.reversed.last.subAdministrativeArea ?? ''}';
        address += ', ${placemarks.reversed.last.administrativeArea ?? ''}';
        address += ', ${placemarks.reversed.last.postalCode ?? ''}';
        address += ', ${placemarks.reversed.last.country ?? ''}';
      }

      print("Your Address for ($lat, $long) is: $address");

      return address;
    } catch (e) {
      print("Error getting placemarks: $e");
      return "No Address";
    }
  }

  Future<void> currentLocation() async {
    currentLocationStatus.value = CurrentLocationStatus.loading;
    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return;
      currentUserPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      originLatitude.value = currentUserPosition!.latitude;
      originLongitude.value = currentUserPosition!.longitude;

      await updateDriverLocationWhenAppIsOpen();
      startLocation = LatLng(
        originLatitude.value,
        originLongitude.value,
      );

      kGooglePlex = CameraPosition(
        target: startLocation,
        zoom: 14.4746,
      );

      String addresss =
          await getPlacemarks(originLatitude.value, originLongitude.value);

      searchTextFieldFrom.text = addresss;

      GeoFirePoint center = geo.point(
          latitude: originLatitude.value, longitude: originLongitude.value);
// get the collection reference or query
      var collectionReference = firestore.collection('request_ride');
      double radius = 20;
      String field = 'position';

      Stream<List<DocumentSnapshot>> streamOfNearby = geo
          .collection(collectionRef: collectionReference)
          .within(
              center: center, radius: radius, field: field, strictMode: true);

      streamOfNearby.listen((List<DocumentSnapshot> snapshots) {
        for (int i = 0; i < snapshots.length; i++) {
          DocumentSnapshot snapshot = snapshots[i];

          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          GeoPoint documentLocation = data['position']['geopoint'];

          print('Request Ride: $documentLocation ${snapshots.length}');

          String requestRideId = data['id'];

          listMarkers.add(Marker(
            markerId: MarkerId(requestRideId),
            infoWindow: InfoWindow(
                title: 'Passenger Location', snippet: "Request Ride"),
            position: startLocation = LatLng(
              documentLocation.latitude,
              documentLocation.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet),
          ));
        }
      });

      listMarkers.add(Marker(
        markerId: const MarkerId("originID"),
        infoWindow:
            InfoWindow(title: 'Your Current Location', snippet: "Origin"),
        position: startLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));

      CameraPosition cameraPosition =
          CameraPosition(target: startLocation, zoom: 15);

      newGoogleMapController!
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      currentLocationStatus.value = CurrentLocationStatus.succeeded;
    } catch (e) {
      print('Error : $e ');
      currentLocationStatus.value = CurrentLocationStatus.failed;
    }
  }

  Future<void> getInfoCurrentUser() async {
    try {
      DocumentSnapshot userDataSnapshot =
          await firestore.collection('users').doc(auth.currentUser!.uid).get();

      final userData = userDataSnapshot.data() as Map<String, dynamic>;

      userInfo.value = UserModel.fromJson(userData);

      print("User Name:" +
          userInfo.value.driver.name +
          userInfo.value.createdAt.toString());
    } catch (e) {
      print('Error: $e');
    }
  }
}
