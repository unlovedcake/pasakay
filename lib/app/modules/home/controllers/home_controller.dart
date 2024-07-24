import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pasakay/app/global/assets_path.dart';
import 'package:pasakay/app/global/instance_firebase.dart';
import 'package:pasakay/app/models/predicted_places_model.dart';
import 'package:pasakay/app/models/user_model.dart';
import 'package:pasakay/app/repositories/search_place_repository.dart';
import 'package:pasakay/app/utils/custom_snackbar.dart';
import 'package:pasakay/app/utils/helper.dart';
import 'package:pasakay/app/utils/loading_indicator.dart';
import 'package:pasakay/app/utils/notification.dart';

enum CurrentLocationStatus { initial, loading, succeeded, failed }

class HomeController extends GetxController {
  final geo = GeoFlutterFire();
  final currentLocationStatus = CurrentLocationStatus.initial.obs;
  bool get isCurrentLocationStatus =>
      currentLocationStatus.value == CurrentLocationStatus.loading;
  LatLng startLocation = LatLng(
    10.2548959,
    123.8458525,
  );

  final distanceKm = 0.0.obs;

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
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
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
    String address = '';
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

      if (placemarks.isNotEmpty) {
        // Placemark address = placemarks[0]; // get only first and closest address
        // _address =
        //     "${address.street}, ${address.locality}, ${address.administrativeArea}, ${address.country}";

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

      String addresss =
          await getPlacemarks(originLatitude.value, originLongitude.value);

      searchTextFieldFrom.text = addresss;

      startLocation = LatLng(
        originLatitude.value,
        originLongitude.value,
      );

      kGooglePlex = CameraPosition(
        target: startLocation,
        zoom: 14.4746,
      );

      final Uint8List markerIconDriver =
          await Helper.getBytesFromAsset(AssetsPath.carMarker, 120, 120);
      final Uint8List markerIconDriverMotor =
          await Helper.getBytesFromAsset(AssetsPath.motorBikeMarker, 120, 120);
      final Uint8List markerIconUser =
          await Helper.getBytesFromAsset(AssetsPath.userMarker, 140, 140);

      GeoFirePoint center = geo.point(
          latitude: originLatitude.value, longitude: originLongitude.value);
// get the collection reference or query
      var collectionReference = firestore.collection('driver_locations');
      double radius = 20;
      String field = 'position';

      Stream<List<DocumentSnapshot>> streamOfNearby = geo
          .collection(collectionRef: collectionReference)
          .within(
              center: center, radius: radius, field: field, strictMode: true);

      streamOfNearby.listen((List<DocumentSnapshot> snapshots) {
        // Alternatively, using a traditional for loop
        for (int i = 0; i < snapshots.length; i++) {
          DocumentSnapshot snapshot = snapshots[i];
          // Accessing data from snapshot
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          // Do something with the data

          GeoPoint documentLocation = data['position']['geopoint'];

          print('Nearby Driver: $documentLocation ${snapshots.length}');

          String driverId = data['id'];
          String vehicleType = data['vehicleType'];

          listMarkers.add(Marker(
              markerId: MarkerId(driverId),
              infoWindow: InfoWindow(
                  title: 'Driver Current Location',
                  snippet: "Available Driver"),
              position: startLocation = LatLng(
                documentLocation.latitude,
                documentLocation.longitude,
              ),
              icon: BitmapDescriptor.fromBytes(vehicleType == 'Car'
                  ? markerIconDriver
                  : markerIconDriverMotor)
              // icon: BitmapDescriptor.defaultMarkerWithHue(
              //     BitmapDescriptor.hueViolet),
              ));
        }
      });

      listMarkers.add(Marker(
          markerId: const MarkerId("originID"),
          infoWindow:
              InfoWindow(title: 'Your Current Location', snippet: "Origin"),
          position: startLocation,
          icon: BitmapDescriptor.fromBytes(markerIconUser)
          //icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
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

  String getTravelDurationMotor() {
    double fare = distanceKm.value;

    // km * time / speed
    var result = fare * 60 / 30;

    return '${result.toInt()} mins';
  }

  String getTravelDurationCar() {
    double fare = distanceKm.value;

    var result = fare * 60 / 20;

    return '${result.toInt()} mins';
  }

  String fareMotorBike() {
    int fare = distanceKm.value.toInt();

    switch (fare) {
      case 0:
        return '50';
      case 1:
        return '50';
      case 2:
        return '100';
      case 3:
        return '150';
      case 4:
        return '200';
      default:
        return '300';
    }
  }

  String fareCar() {
    int fare = distanceKm.value.toInt();

    switch (fare) {
      case 0:
        return '100';
      case 1:
        return '100';
      case 2:
        return '150';
      case 3:
        return '250';
      case 4:
        return '300';
      default:
        return '400';
    }
  }

  void requestRide() async {
    LoadingIndicator.showLoadingIndicator('Requesting Ride...');

    try {
      GeoFirePoint myLocation = geo.point(
          latitude: originLatitude.value, longitude: originLongitude.value);
      await firestore
          .collection('request_ride')
          .doc(auth.currentUser?.uid)
          .set({
        'id': auth.currentUser?.uid ?? '',
        'name': userInfo.value.user.name,
        'contact': userInfo.value.user.contact,
        'vehicyleType': selectedVehicle.value,
        'isRequestAccept': false,
        'from': searchTextFieldFrom.text,
        'to': searchTextFieldTo.text,
        'fcmToken': userInfo.value.user.fcmToken,
        'position': myLocation.data
      });

      const String chars =
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
      Random random = Random();

      var requestId = String.fromCharCodes(Iterable.generate(
        16,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ));

      await firestore.collection('user_request_ride').add({
        'id': auth.currentUser?.uid ?? '',
        'requestId': requestId,
        'name': userInfo.value.user.name,
        'contact': userInfo.value.user.contact,
        'vehicyleType': selectedVehicle.value,
        'isRequestAccept': 'Pending',
        'from': searchTextFieldFrom.text,
        'to': searchTextFieldTo.text,
        'fcmToken': userInfo.value.user.fcmToken,
        'distance': '${distanceKm.value.toStringAsFixed(1)}',
        'position': myLocation.data,
        'createdAt': DateTime.now(),
        'driver': {
          'id': '',
          'name': '',
          'contact': '',
        }
      });
      LoadingIndicator.closeLoadingIndicator();

      CustomSnackBar.showCustomSuccessSnackBar(
          title: 'Success',
          message: 'Request Successfully Sent.',
          duration: const Duration(seconds: 4));
    } catch (e) {
      print('Error: $e');
      LoadingIndicator.closeLoadingIndicator();
    }
  }

  double getDistanceKilometers() {
    var distanceInMeters = Geolocator.distanceBetween(
        originLatitude.value,
        originLongitude.value,
        destinationLatitude.value,
        destinationLongitude.value);

    return distanceInMeters;
  }

  Future<void> getInfoCurrentUser() async {
    try {
      DocumentSnapshot userDataSnapshot =
          await firestore.collection('users').doc(auth.currentUser!.uid).get();

      final userData = userDataSnapshot.data() as Map<String, dynamic>;

      userInfo.value = UserModel.fromJson(userData);

      print("User Name:" +
          userInfo.value.user.name +
          userInfo.value.createdAt.toString());
    } catch (e) {
      print('Error: $e');
    }
  }
}
