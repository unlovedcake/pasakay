import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:pasakay/app/modules/login/controllers/login_controller.dart';
import 'package:pasakay/app/modules/signup_user/controllers/signup_user_controller.dart';

class SignUpUserForm extends GetWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupUserController());
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: controller.nameController,
          decoration: InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20.0),
        TextField(
          controller: controller.mobileNumberController,
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20.0),
        TextField(
          controller: controller.emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20.0),
        Obx(() => TextField(
              controller: controller.passwordController,
              obscureText: controller.obscureText.value,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureText.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: controller.toggleObscureText,
                ),
              ),
            )),
        SizedBox(height: 40.0),
        SizedBox(
          height: 60,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              controller.signUp();

              // Add your authentication logic here
            },
            child: Text('Sign in'),
          ),
        ),
      ],
    );
  }
}
