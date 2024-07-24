import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:get/get.dart';
import 'package:pasakay/app/models/user_model.dart';

final firestore = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance;
FirebaseAuth auth = FirebaseAuth.instance;
final geo = GeoFlutterFire();

final mapKey = dotenv.env['APP_API_KEY_MAP'];

final userInfo = UserModel(
        user: UserData(
            id: '',
            name: '',
            contact: '',
            email: '',
            fcmToken: '',
            image:
                'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'),
        driver: DriverData(
            id: '',
            name: '',
            contact: '',
            email: '',
            image:
                'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg',
            vehicleType: ''),
        role: '',
        createdAt: DateTime.now())
    .obs;
