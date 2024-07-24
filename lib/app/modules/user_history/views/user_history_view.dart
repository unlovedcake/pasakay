import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';

import '../controllers/user_history_controller.dart';

class UserHistoryView extends GetView<UserHistoryController> {
  const UserHistoryView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserHistoryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.userRequestRides.isEmpty) {
          return Center(child: Text('No request rides found.'));
        }

        return ListView.builder(
          itemCount: controller.userRequestRides.length,
          itemBuilder: (context, index) {
            final ride = controller.userRequestRides[index];
            return ListTile(
              title: Text(ride.driver.name),
              subtitle: Text(ride.createdAt.toString()),
            );
          },
        );
      }),
      // body: StreamBuilder<QuerySnapshot>(
      //   stream: controller.getRequestRidesStream(),
      //   builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      //     if (snapshot.hasError) {
      //       return Text('Error: ${snapshot.error}');
      //     }

      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Center(child: CircularProgressIndicator());
      //     }

      //     if (snapshot.data!.docs.length == 0) {
      //       return Center(
      //           child: Container(
      //               child: Text(
      //         'Empty Request Yet...',
      //         style: TextStyle(fontSize: 15, color: Colors.black),
      //       )));
      //     }

      //     return ListView.builder(
      //         itemCount: snapshot.data!.docs.length,
      //         itemBuilder: (context, index) {
      //           final data = snapshot.data!.docs[index];

      //           final driverName = data['driver'];

      //           print('driver name : $driverName');

      //           return Padding(
      //             padding: const EdgeInsets.all(10.0),
      //             child: Card(
      //                 child: Padding(
      //               padding: const EdgeInsets.all(8.0),
      //               child: Column(
      //                 children: [
      //                   Row(
      //                     children: [
      //                       Text(
      //                         'From: ',
      //                         style: TextStyle(
      //                             fontSize: 14, fontWeight: FontWeight.bold),
      //                       ),
      //                       Flexible(
      //                           child: Text('${data['from']}',
      //                               overflow: TextOverflow.ellipsis)),
      //                     ],
      //                   ),
      //                   SizedBox(
      //                     height: 10,
      //                   ),
      //                   Row(
      //                     children: [
      //                       Text(
      //                         'To: ',
      //                         style: TextStyle(
      //                             fontSize: 14, fontWeight: FontWeight.bold),
      //                       ),
      //                       Flexible(
      //                           child: Text(
      //                         '${data['to']}',
      //                         overflow: TextOverflow.ellipsis,
      //                       )),
      //                     ],
      //                   ),
      //                   SizedBox(
      //                     height: 10,
      //                   ),
      //                   Row(
      //                     children: [
      //                       Text(
      //                         'Distance: ',
      //                         style: TextStyle(
      //                             fontSize: 14, fontWeight: FontWeight.bold),
      //                       ),
      //                       Text('${data['distance']} km '),
      //                     ],
      //                   ),
      //                   SizedBox(
      //                     height: 10,
      //                   ),
      //                   Row(
      //                     children: [
      //                       Text(
      //                         'Status: ',
      //                         style: TextStyle(
      //                             fontSize: 14, fontWeight: FontWeight.bold),
      //                       ),
      //                       Text(
      //                           '${data['isRequestAccept'].toString().toUpperCase()} '),
      //                     ],
      //                   ),
      //                   SizedBox(
      //                     height: 10,
      //                   ),
      //                   Row(
      //                     children: [
      //                       Text(
      //                         'Driver: ',
      //                         style: TextStyle(
      //                             fontSize: 14, fontWeight: FontWeight.bold),
      //                       ),
      //                       Text(
      //                           '${data['isRequestAccept'] == 'Pending' ? '---' : driverName['name']} '),
      //                     ],
      //                   ),
      //                   SizedBox(
      //                     height: 20,
      //                   ),
      //                   OutlinedButton(
      //                       onPressed: () {}, child: Text('Send Message'))
      //                 ],
      //               ),
      //             )),
      //           );
      //         });

      //     // return ListView(
      //     //   children: snapshot.data!.docs.map((DocumentSnapshot document) {
      //     //     Map<String, dynamic> data =
      //     //         document.data() as Map<String, dynamic>;

      //     //     return Card(
      //     //         child: Padding(
      //     //       padding: const EdgeInsets.all(8.0),
      //     //       child: Column(
      //     //         children: [
      //     //           Row(
      //     //             children: [
      //     //               Text(
      //     //                 'From: ',
      //     //                 style: TextStyle(
      //     //                     fontSize: 14, fontWeight: FontWeight.bold),
      //     //               ),
      //     //               Text('${data['from'].substring(0, 35) + "..."}'),
      //     //             ],
      //     //           ),
      //     //           SizedBox(
      //     //             height: 10,
      //     //           ),
      //     //           Row(
      //     //             children: [
      //     //               Text(
      //     //                 'To: ',
      //     //                 style: TextStyle(
      //     //                     fontSize: 14, fontWeight: FontWeight.bold),
      //     //               ),
      //     //               Text('${data['to'].substring(0, 35) + "..."}'),
      //     //             ],
      //     //           ),
      //     //           SizedBox(
      //     //             height: 10,
      //     //           ),
      //     //           Row(
      //     //             children: [
      //     //               Text(
      //     //                 'Distance: ',
      //     //                 style: TextStyle(
      //     //                     fontSize: 14, fontWeight: FontWeight.bold),
      //     //               ),
      //     //               Text('${data['distance']} km '),
      //     //             ],
      //     //           ),
      //     //           SizedBox(
      //     //             height: 10,
      //     //           ),
      //     //           Row(
      //     //             children: [
      //     //               Text(
      //     //                 'Status: ',
      //     //                 style: TextStyle(
      //     //                     fontSize: 14, fontWeight: FontWeight.bold),
      //     //               ),
      //     //               Text(
      //     //                   '${data['isRequestAccept'].toString().toUpperCase()} '),
      //     //             ],
      //     //           ),
      //     //           SizedBox(
      //     //             height: 10,
      //     //           ),
      //     //           Row(
      //     //             children: [
      //     //               Text(
      //     //                 'Driver: ',
      //     //                 style: TextStyle(
      //     //                     fontSize: 14, fontWeight: FontWeight.bold),
      //     //               ),
      //     //               Text('${data['driver'].toString()} '),
      //     //             ],
      //     //           ),
      //     //           OutlinedButton(
      //     //               onPressed: () {}, child: Text('Cancel request'))
      //     //         ],
      //     //       ),
      //     //     ));
      //     //   }).toList(),
      //     // );
      //   },
      // ),
    );
  }
}
