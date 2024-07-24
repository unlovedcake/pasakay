import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pasakay/app/global/instance_firebase.dart';
import 'package:pasakay/app/modules/user_profile/views/user_edit_profile.dart';

import '../controllers/user_profile_controller.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UserProfileView'),
        centerTitle: true,
      ),
      body: Center(child: ProfileContentPage()),
    );
  }
}

class ProfileContentPage extends StatefulWidget {
  @override
  State<ProfileContentPage> createState() => _ProfileContentPageState();
}

class _ProfileContentPageState extends State<ProfileContentPage> {
  File? _imageFile;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  //  Future<void> _uploadProfile() async {
  //   if (_imageFile != null) {
  //     final storageRef = storage.ref().child('profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
  //     await storageRef.putFile(_imageFile!);
  //     final imageUrl = await storageRef.getDownloadURL();

  //     await firestore.collection('profiles').doc('userProfile').set({
  //       'name': _nameController.text,
  //       'contact': _contactController.text,
  //       'email': _emailController.text,
  //       'image_url': imageUrl,
  //     });
  //   } else {
  //     await firestore.collection('profiles').doc('userProfile').set({
  //       'name': _nameController.text,
  //       'contact': _contactController.text,
  //       'email': _emailController.text,
  //     });
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    userInfo.value.user.image), // Replace with your image URL
              ),
              SizedBox(height: 16),
              Text(
                userInfo.value.user.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 50),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Text(
                        'Contact: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        userInfo.value.user.contact,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Text(
                        'Email: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        userInfo.value.user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              SizedBox(
                height: 60,
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserEditProfilePage()),
                      );
                    },
                    child: Text('Edit')),
              )
            ],
          ),
        ));
  }
}
