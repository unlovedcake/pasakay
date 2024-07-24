import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:pasakay/app/global/instance_firebase.dart';
import 'package:pasakay/app/models/user_model.dart';
import 'package:pasakay/app/utils/custom_snackbar.dart';
import 'package:pasakay/app/utils/loading_indicator.dart';

class DriverEditProfilePage extends StatefulWidget {
  @override
  _DriverEditProfilePageState createState() => _DriverEditProfilePageState();
}

class _DriverEditProfilePageState extends State<DriverEditProfilePage> {
  final _nameController =
      TextEditingController(text: userInfo.value.driver.name);
  final _contactController =
      TextEditingController(text: userInfo.value.driver.contact);
  File? _imageFile;

  final picker = ImagePicker();
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadProfile() async {
    try {
      if (_imageFile != null) {
        final storageRef = storage.ref().child(
            'user_profile_images/${DateTime.now().millisecondsSinceEpoch}.png');
        await storageRef.putFile(_imageFile!);
        final imageUrl = await storageRef.getDownloadURL();

        await firestore.collection('users').doc(auth.currentUser!.uid).update({
          'driver.${'name'}': _nameController.text,
          'driver.${'contact'}': _contactController.text,
          'driver.${'image'}': imageUrl,
          // 'user': {
          //   'id': auth.currentUser!.uid,
          //   'name': _nameController.text,
          //   'contact': _contactController.text,
          //   'email': userInfo.value.user.email,
          //   'image': imageUrl,
          // }
        });
        getInfoCurrentUser();
      } else {
        await firestore
            .collection('users')
            .doc(userInfo.value.driver.id)
            .update({
          'driver.${'name'}': _nameController.text,
          'driver.${'contact'}': _contactController.text,
          // 'user': {
          //   'id': auth.currentUser!.uid,
          //   'name': _nameController.text,
          //   'contact': _contactController.text,
          //   'email': userInfo.value.user.email,
          //   'image': userInfo.value.user.image,
          // },
        });
        getInfoCurrentUser();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getInfoCurrentUser() async {
    LoadingIndicator.showLoadingIndicator('Editing Profile...');
    try {
      DocumentSnapshot userDataSnapshot =
          await firestore.collection('users').doc(auth.currentUser!.uid).get();

      final userData = userDataSnapshot.data() as Map<String, dynamic>;

      userInfo.value = UserModel.fromJson(userData);
      LoadingIndicator.closeLoadingIndicator();

      CustomSnackBar.showCustomSuccessSnackBar(
          title: 'Success',
          message: 'Successfully Edited',
          duration: const Duration(seconds: 3));

      print("Driver Name:" +
          userInfo.value.driver.name +
          userInfo.value.createdAt.toString());
    } catch (e) {
      print('Error: $e');
      LoadingIndicator.closeLoadingIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : NetworkImage(userInfo.value.driver.image)
                        as ImageProvider,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _contactController,
              decoration: InputDecoration(labelText: 'Contact'),
            ),
            Spacer(),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _uploadProfile,
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
