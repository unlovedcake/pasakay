import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pasakay/app/global/assets_path.dart';
import 'package:pasakay/app/global/instance_firebase.dart';
import 'package:pasakay/app/models/predicted_places_model.dart';
import 'package:pasakay/app/repositories/auth_repository.dart';
import 'package:pasakay/app/repositories/search_place_repository.dart';
import 'package:pasakay/app/routes/app_pages.dart';
import 'package:pasakay/app/utils/custom_snackbar.dart';

import '../controllers/home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final controller = Get.put(HomeController());

  List<PredictedPlacesModel> placesPredictedList = [];

  Set<Polyline> _polylines = {};

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> _polylineCoordinates = [];

  Future<List<LatLng>> fetchPolylinePoints() async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      mapKey!,
      PointLatLng(
          controller.originLatitude.value, controller.originLongitude.value),
      PointLatLng(controller.destinationLatitude.value,
          controller.destinationLongitude.value),
    );

    if (result.points.isNotEmpty) {
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      debugPrint(result.errorMessage);
      return [];
    }
  }

  Future<void> generatePolyLineFromPoints(
      List<LatLng> polylineCoordinates) async {
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 5,
    );

    setState(() => polylines[id] = polyline);
  }

  Future<void> addPolyLine() async {
    polylines.clear();
    List<LatLng> coordinates = [];
    coordinates = await fetchPolylinePoints();
    generatePolyLineFromPoints(coordinates);
    // Zoom the map to fit the polyline
    controller.newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(
          min(controller.originLatitude.value,
              controller.destinationLatitude.value),
          min(controller.originLongitude.value,
              controller.destinationLongitude.value),
        ),
        northeast: LatLng(
          max(controller.originLatitude.value,
              controller.destinationLatitude.value),
          max(controller.originLongitude.value,
              controller.destinationLongitude.value),
        ),
      ),
      80.0, // Padding
    ));
  }

  // void _addPolyline(double originLat, double originLong, double destinationLat,
  //     double destinationLong) {
  //   setState(() {
  //     // Clear previous polylines if any
  //     _polylines.clear();

  //     // Add origin and destination coordinates
  //     LatLng origin = LatLng(originLat, originLong);
  //     LatLng destination = LatLng(destinationLat, destinationLong);

  //     // Add polyline coordinates
  //     _polylineCoordinates.clear();
  //     _polylineCoordinates.add(origin);
  //     _polylineCoordinates.add(destination);

  //     // Add polyline to the map
  //     _polylines.add(Polyline(
  //       polylineId: PolylineId("poly"),
  //       color: Colors.blue,
  //       startCap: Cap.squareCap,
  //       endCap: Cap.roundCap,
  //       width: 3,
  //       patterns: [
  //         PatternItem.dash(8),
  //         PatternItem.gap(15),
  //       ],
  //       points: _polylineCoordinates,
  //     ));

  //     // Zoom the map to fit the polyline
  //     controller.newGoogleMapController!
  //         .animateCamera(CameraUpdate.newLatLngBounds(
  //       LatLngBounds(
  //         southwest: LatLng(
  //           min(origin.latitude, destination.latitude),
  //           min(origin.longitude, destination.longitude),
  //         ),
  //         northeast: LatLng(
  //           max(origin.latitude, destination.latitude),
  //           max(origin.longitude, destination.longitude),
  //         ),
  //       ),
  //       70.0, // Padding
  //     ));
  //   });
  // }

  findPlaceAutoCompleteSearchId(String id) async {
    try {
      String url =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=$id&key=$mapKey";

      final response = await SearchPlacerepository.searchPlaceId(url);

      if (response == "Error Occured. Failed. No Response.") {
        return;
      }

      if (response["status"] == "OK") {
        var lat = response["result"]["geometry"]["location"]["lat"];
        var long = response["result"]["geometry"]["location"]["lng"];
        var northeast = response["result"]["geometry"]["viewport"]['northeast'];
        var southwest = response["result"]["geometry"]["viewport"]['southwest'];

        print("Lat: $lat long: $long");

        controller.destinationLatitude.value = lat;
        controller.destinationLongitude.value = long;

        controller.endLocation = LatLng(lat, long);

        controller.listMarkers.add(Marker(
          markerId: const MarkerId("destinationID"),
          infoWindow:
              InfoWindow(title: 'Your Destination', snippet: "Destination"),
          position: controller.endLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));

        // _addPolyline(controller.originLatitude.value,
        //     controller.originLongitude.value, lat, long);

        addPolyLine();

        setState(() {
          placesPredictedList.clear();
        });
      }
    } catch (e) {
      setState(() {
        placesPredictedList.clear();
      });
      print(e.toString());
    }
  }

  findPlaceAutoCompleteSearchIdFrom(String id) async {
    try {
      String url =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=$id&key=$mapKey";

      final response = await SearchPlacerepository.searchPlaceId(url);

      if (response == "Error Occured. Failed. No Response.") {
        return;
      }

      if (response["status"] == "OK") {
        var lat = response["result"]["geometry"]["location"]["lat"];
        var long = response["result"]["geometry"]["location"]["lng"];

        controller.originLatitude.value = lat;
        controller.originLongitude.value = long;

        print(
            "Lats: ${controller.originLatitude.value} long: ${controller.originLongitude.value}");
        print(
            "Lats: ${controller.destinationLatitude.value} long: ${controller.destinationLongitude.value}");
        print("Latz: $lat long: $long");

        controller.startLocation = LatLng(
            controller.originLatitude.value, controller.originLongitude.value);

        controller.listMarkers.add(Marker(
          markerId: const MarkerId("originID"),
          infoWindow: InfoWindow(title: 'Origin Location', snippet: "Origin"),
          position: controller.startLocation,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));

        if (controller.searchTextFieldFrom.text.isNotEmpty) {
          addPolyLine();
          // _addPolyline(
          //   controller.originLatitude.value,
          //   controller.originLongitude.value,
          //   controller.destinationLatitude.value,
          //   controller.destinationLongitude.value,
          // );
        }

        setState(() {
          placesPredictedList.clear();
        });
      }
    } catch (e) {
      setState(() {
        placesPredictedList.clear();
      });
      print(e.toString());
    }
  }

  findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      String url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:PH";

      final response = await SearchPlacerepository.searchPlace(url);

      if (response == "Error Occured. Failed. No Response.") {
        return;
      }

      if (response["status"] == "OK") {
        var placePredictions = response["predictions"];

        var placePredictionsList = (placePredictions as List)
            .map((jsonData) => PredictedPlacesModel.fromJson(jsonData))
            .toList();

        setState(() {
          placesPredictedList = placePredictionsList;
        });
      }
    } else {
      setState(() {
        placesPredictedList.clear();
      });
    }
  }

  @override
  void initState() {
    controller.getInfoCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasakay'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Obx(() => DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.network(
                                userInfo.value.user.image,
                                width: 50,
                                height: 50,
                              )),
                          Text(
                            userInfo.value.user.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Get.toNamed(AppPages.USER_PROFILE);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('History'),
              onTap: () {
                Get.toNamed(AppPages.USER_HISTORY);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                AuthRepository.signout();
              },
            ),
          ],
        ),
      ),
      body: Obx(
        () => Stack(
          children: [
            controller.isCurrentLocationStatus
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      GoogleMap(
                        // onTap: (coLoc) async {
                        //   try {
                        //     FirebaseAuth _auth = FirebaseAuth.instance;
                        //     GeoFirePoint myLocation = geo.point(
                        //         latitude: 10.3321, longitude: 123.9357);
                        //     await firestore
                        //         .collection('locations')
                        //         .doc(_auth.currentUser!.uid)
                        //         .update({'position': myLocation.data});
                        //     // await firestore.collection('locations').add({
                        //     //   'name': '${Random().nextInt(9)}',
                        //     //   'position': myLocation.data
                        //     // });
                        //   } catch (e) {
                        //     print(e);
                        //   }
                        // },
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        zoomGesturesEnabled: true,
                        zoomControlsEnabled: true,
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.55),

                        initialCameraPosition: controller.kGooglePlex,
                        markers: Set<Marker>.of(controller.listMarkers.value),
                        //polylines: _polylines,
                        polylines: Set<Polyline>.of(polylines.values),
                        // circles: {
                        //   Circle(
                        //       circleId: CircleId('1'),
                        //       center: controller.startLocation,
                        //       radius: 4000,
                        //       strokeWidth: 2,
                        //       fillColor: Colors.black12.withOpacity(0.2))
                        // },

                        onMapCreated: (GoogleMapController controllers) {
                          //controller.controllerGoogleMap.complete(controllers);
                          controller.newGoogleMapController = controllers;
                        },
                      ),
                      if (placesPredictedList.length > 0)
                        Positioned.fill(
                            top: 50,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 18),
                              height: 100,
                              child: ListView.builder(
                                padding: EdgeInsets.all(10),
                                itemCount: 10,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    color: Colors.white,
                                    height: 400,
                                    child: ListView.separated(
                                      itemCount: placesPredictedList.length,
                                      physics: ClampingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final data = placesPredictedList[index];
                                        return ListTile(
                                          onTap: () {
                                            if (controller
                                                .searchInputTo.value) {
                                              controller
                                                      .searchTextFieldTo.text =
                                                  data.description ?? '';
                                              findPlaceAutoCompleteSearchId(
                                                  data.placeId ?? '');
                                            } else {
                                              controller.searchTextFieldFrom
                                                      .text =
                                                  data.description ?? '';
                                              findPlaceAutoCompleteSearchIdFrom(
                                                  data.placeId ?? '');
                                            }
                                          },
                                          leading: Icon(Icons.location_on),
                                          title: Text(data.description ?? ''),
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return Divider(
                                          height: 0,
                                          color: Colors.blue,
                                          thickness: 0,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            )),
                    ],
                  ),
          ],
        ),
      ),
      bottomSheet: Container(
        height: 250,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: controller.searchTextFieldFrom,
                      onChanged: (val) {
                        controller.searchInputTo.value = false;
                        if (val != '') {
                          controller.searchInput.value = val;
                          findPlaceAutoCompleteSearch(val);
                        }
                      },
                      decoration: InputDecoration(
                        helperStyle: TextStyle(fontSize: 12),
                        labelText: 'From',
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.location_on),
                        suffixIcon: IconButton(
                          onPressed: () {
                            controller.searchInput.value =
                                controller.searchTextFieldFrom.text = '';
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: controller.searchTextFieldTo,
                      onChanged: (val) {
                        controller.searchInputTo.value = true;
                        if (val != '') {
                          controller.searchInput.value = val;
                          findPlaceAutoCompleteSearch(val);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'To',
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.location_on),
                        suffixIcon: IconButton(
                          onPressed: () {
                            controller.searchInput.value =
                                controller.searchTextFieldTo.text = '';
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                )),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                    onPressed: () {
                      if (controller.searchTextFieldTo.text.isEmpty) {
                        CustomSnackBar.showCustomErrorSnackBar(
                            title: "Error",
                            message: 'Please select your destination',
                            duration: Duration(seconds: 2));
                        return;
                      }
                      controller.distanceKm.value =
                          controller.getDistanceKilometers() / 1000;
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return BottomSheetContent();
                        },
                      );
                    },
                    child: Text('Show Fare')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BottomSheetContent extends StatefulWidget {
  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  String selectedVehicle = '';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      height: 350,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            elevation: 5,
            padding: EdgeInsets.all(8),
            backgroundColor: Colors.grey.shade300,
            shadowColor: Colors.black,
            avatar: Icon(
              Icons.star,
              color: Colors.blue,
            ),
            label: Flexible(
              child: Text(
                controller.searchTextFieldFrom.text,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Chip(
            elevation: 5,
            padding: EdgeInsets.all(8),
            backgroundColor: Colors.grey.shade300,
            shadowColor: Colors.black,
            avatar: Icon(
              Icons.star,
              color: Colors.red,
            ),
            label: Flexible(
              child: Text(
                controller.searchTextFieldTo.text,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Chip(
            elevation: 5,
            padding: EdgeInsets.all(8),
            backgroundColor: Colors.grey.shade300,
            shadowColor: Colors.black,

            label: Text(
              '${controller.distanceKm.value.toStringAsFixed(1)} KM - ${selectedVehicle == 'car' ? controller.getTravelDurationCar() : controller.getTravelDurationMotor()}',
              style: TextStyle(fontSize: 10),
            ), //Text
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedVehicle = 'car';
                    controller.selectedVehicle.value = selectedVehicle;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      color: selectedVehicle == 'car'
                          ? Colors.grey.shade300
                          : Colors.transparent,
                      padding: EdgeInsets.all(8),
                      child: Image.asset(
                        AssetsPath.car,
                        width: 100,
                        height: 100,
                      ),
                    ),
                    Text('₱ ${controller.fareCar()}')
                  ],
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedVehicle = 'motorbike';
                    controller.selectedVehicle.value = selectedVehicle;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      color: selectedVehicle == 'motorbike'
                          ? Colors.grey.shade300
                          : Colors.transparent,
                      padding: EdgeInsets.all(8),
                      child: Image.asset(
                        AssetsPath.motorBike,
                        width: 100,
                        height: 100,
                      ),
                    ),
                    Text('₱ ${controller.fareMotorBike()}')
                  ],
                ),
              ),
            ],
          ),
          Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
                onPressed: () {
                  if (selectedVehicle == '') {
                    CustomSnackBar.showCustomErrorToast(
                        duration: Duration(seconds: 2),
                        message: 'Please, select type of ride');
                    return;
                  }
                  controller.requestRide();
                },
                child: Text('Request Ride')),
          )
        ],
      ),
    );
  }
}
