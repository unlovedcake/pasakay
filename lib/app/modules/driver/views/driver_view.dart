import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pasakay/app/global/instance_firebase.dart';
import 'package:pasakay/app/models/predicted_places_model.dart';
import 'package:pasakay/app/modules/driver/controllers/driver_controller.dart';
import 'package:pasakay/app/repositories/auth_repository.dart';
import 'package:pasakay/app/repositories/search_place_repository.dart';
import 'package:pasakay/app/routes/app_pages.dart';
import 'package:pasakay/app/utils/custom_snackbar.dart';
import 'package:pasakay/app/utils/loading_indicator.dart';

import '../controllers/driver_controller.dart';

class DriverView extends StatefulWidget {
  const DriverView({super.key});

  @override
  State<DriverView> createState() => _DriverViewState();
}

class _DriverViewState extends State<DriverView> {
  final controller = Get.put(DriverController());

  List<PredictedPlacesModel> placesPredictedList = [];

  Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];

  void _addPolyline(double originLat, double originLong, double destinationLat,
      double destinationLong) {
    setState(() {
      // Clear previous polylines if any
      _polylines.clear();

      // Add origin and destination coordinates
      LatLng origin = LatLng(originLat, originLong);
      LatLng destination = LatLng(destinationLat, destinationLong);

      // Add polyline coordinates
      _polylineCoordinates.clear();
      _polylineCoordinates.add(origin);
      _polylineCoordinates.add(destination);

      // Add polyline to the map
      _polylines.add(Polyline(
        polylineId: PolylineId("poly"),
        color: Colors.blue,
        width: 3,
        points: _polylineCoordinates,
      ));

      // Zoom the map to fit the polyline
      controller.newGoogleMapController!
          .animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            min(origin.latitude, destination.latitude),
            min(origin.longitude, destination.longitude),
          ),
          northeast: LatLng(
            max(origin.latitude, destination.latitude),
            max(origin.longitude, destination.longitude),
          ),
        ),
        70.0, // Padding
      ));
    });
  }

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

        _addPolyline(controller.originLatitude.value,
            controller.originLongitude.value, lat, long);

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
          _addPolyline(
            controller.originLatitude.value,
            controller.originLongitude.value,
            controller.destinationLatitude.value,
            controller.destinationLongitude.value,
          );
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
                                userInfo.value.driver.image,
                                width: 50,
                                height: 50,
                              )),
                          Text(
                            userInfo.value.driver.name,
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
                Get.toNamed(AppPages.DRIVER_PROFILE);
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
                Get.toNamed(AppPages.DRIVER_HISTORY);
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
                        polylines: _polylines,
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
      bottomSheet: DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        expand: false,
        builder: (BuildContext context, scrollController) {
          return Container(
            height: 250,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Request Ride',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                    child: RequestRideLocation(
                  scrollController: scrollController,
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RequestRideLocation extends StatefulWidget {
  RequestRideLocation({required this.scrollController, Key? key})
      : super(key: key);

  final ScrollController scrollController;

  @override
  State<RequestRideLocation> createState() => _RequestRideLocationState();
}

class _RequestRideLocationState extends State<RequestRideLocation> {
  final geo = GeoFlutterFire();

  final _firestore = FirebaseFirestore.instance;

  final controller = Get.put(DriverController());

  GeoFirePoint? center;

  Stream<QuerySnapshot> getRequestRidesStreams() {
    return FirebaseFirestore.instance
        .collection('user_request_ride')
        // .where('isRequestAccept', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Stream<List<DocumentSnapshot>> getRequestRidesStream() {
  //   var collectionReference = _firestore.collection('request_ride');
  //   double radius = 20;
  //   String field = 'position';

  //   center = geo.point(
  //       latitude: controller.originLatitude.value,
  //       longitude: controller.originLongitude.value);
  //   Stream<List<DocumentSnapshot>> streamOfNearby = geo
  //       .collection(collectionRef: collectionReference)
  //       .within(center: center!, radius: radius, field: field);

  //   return streamOfNearby;
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: getRequestRidesStreams(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          }
          if (snapshot.data!.docs.length == 0) {
            return Center(
                child: Container(
                    child: Text(
              'Empty Request Yet...',
              style: TextStyle(fontSize: 15, color: Colors.black),
            )));
          }

          return ListView(
            controller: widget.scrollController,
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Card(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'From: ',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Flexible(
                          child: Text('${data['from']}',
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'To: ',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Flexible(
                          child: Text('${data['to']}',
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Distance: ',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text('${data['distance']} km '),
                      ],
                    ),
                    OutlinedButton(
                        onPressed: data['isRequestAccept'] == 'Request Accepted'
                            ? null
                            : () async {
                                QuerySnapshot querySnapshot =
                                    await FirebaseFirestore.instance
                                        .collection('user_request_ride')
                                        .where('requestId',
                                            isEqualTo: data['requestId'])
                                        .get();

                                // Update data for each matching document
                                querySnapshot.docs.forEach((doc) async {
                                  LoadingIndicator.showLoadingIndicator(
                                      'Requesting...');
                                  try {
                                    DocumentReference userRef =
                                        FirebaseFirestore.instance
                                            .collection('user_request_ride')
                                            .doc(doc.id);

                                    await userRef.update({
                                      'isRequestAccept': 'Request Accepted',
                                      'driver': {
                                        'id': userInfo.value.driver.id,
                                        'name': userInfo.value.driver.name,
                                        'contact':
                                            userInfo.value.driver.contact,
                                      }
                                    }).whenComplete(() async {
                                      LoadingIndicator.closeLoadingIndicator();
                                      // NotificationRepository.sendFcmMessage(
                                      //     'Request Ride Accepted',
                                      //     userInfo.value.driver.name +
                                      //         ' is on the way your location',
                                      //     data['fcmToken']);
                                      QuerySnapshot querySnapshots =
                                          await FirebaseFirestore.instance
                                              .collection('request_ride')
                                              .where('id',
                                                  isEqualTo: data['id'])
                                              .get();

                                      querySnapshots.docs.forEach((doc) async {
                                        try {
                                          DocumentReference userRef =
                                              FirebaseFirestore.instance
                                                  .collection('request_ride')
                                                  .doc(doc.id);

                                          await userRef
                                              .delete()
                                              .then((value) {});
                                        } catch (e) {
                                          print(
                                              'Error deleting request ride data: $e');
                                          LoadingIndicator
                                              .closeLoadingIndicator();
                                        }
                                      });
                                    });
                                  } catch (e) {
                                    LoadingIndicator.closeLoadingIndicator();
                                    print('Error: $e');
                                  }
                                });
                              },
                        child: Text(data['isRequestAccept'] == 'Pending'
                            ? 'Accept request'
                            : 'Request Accepted'))
                  ],
                ),
              ));
            }).toList(),
          );
        },
      ),
      // child: StreamBuilder<List<DocumentSnapshot>>(
      //     stream: getRequestRidesStream(),
      //     builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
      //       if (!snapshot.hasData) {
      //         return Container(
      //           child: Text('No data'),
      //         );
      //       }
      //       return Container(
      //         child: ListView.builder(
      //             shrinkWrap: true,
      //             itemCount: snapshot.data!.length,
      //             itemBuilder: ((context, index) {
      //               DocumentSnapshot data = snapshot.data![index];
      //               GeoPoint documentLocation =
      //                   data.get('position')['geopoint'];
      //               var distanceInMeters = Geolocator.distanceBetween(
      //                   center!.latitude,
      //                   center!.longitude,
      //                   documentLocation.latitude,
      //                   documentLocation.longitude);

      //               double distanceKm = distanceInMeters / 1000;
      //               return Card(
      //                   child: Padding(
      //                 padding: const EdgeInsets.all(8.0),
      //                 child: Column(
      //                   children: [
      //                     Row(
      //                       children: [
      //                         Text(
      //                           'From: ',
      //                           style: TextStyle(
      //                               fontSize: 14, fontWeight: FontWeight.bold),
      //                         ),
      //                         Text(
      //                             '${data.get('from').substring(0, 35) + "..."}'),
      //                       ],
      //                     ),
      //                     Row(
      //                       children: [
      //                         Text(
      //                           'To: ',
      //                           style: TextStyle(
      //                               fontSize: 14, fontWeight: FontWeight.bold),
      //                         ),
      //                         Text(
      //                             '${data.get('to').substring(0, 35) + "..."}'),
      //                       ],
      //                     ),
      //                     Row(
      //                       children: [
      //                         Text(
      //                           'Distance: ',
      //                           style: TextStyle(
      //                               fontSize: 14, fontWeight: FontWeight.bold),
      //                         ),
      //                         Text('${distanceKm.toStringAsFixed(1)} km '),
      //                       ],
      //                     ),
      //                     OutlinedButton(
      //                         onPressed: () {}, child: Text('Accept request'))
      //                   ],
      //                 ),
      //               )
      //                   // ListTile(
      //                   //   title: Text(
      //                   //       '${data.get('from').substring(0, 40) + "..."}'),
      //                   //   subtitle: Column(
      //                   //     children: [
      //                   //       Text('${data.get('to').substring(0, 40) + "..."}'),
      //                   //       Text('${distanceKm.toStringAsFixed(1)} km '),
      //                   //     ],
      //                   //   ),
      //                   // ),
      //                   );
      //             })),
      //       );
      //     }),
    );
  }
}
