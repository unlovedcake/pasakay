import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:pasakay/app/modules/login/controllers/login_controller.dart';
import 'package:pasakay/app/modules/signup_driver/controllers/signup_driver_controller.dart';
import 'package:pasakay/app/modules/signup_user/controllers/signup_user_controller.dart';

class SignUpDriverForm extends GetWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupDriverController());
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
        SizedBox(
          height: 10.0,
        ),
        Obx(() => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: [
                    Radio<String>(
                      value: 'MotorCycle',
                      groupValue: controller.vehicleType.value,
                      onChanged: (String? value) {
                        controller.vehicleType.value = value!;
                      },
                    ),
                    Text('MotorCycle')
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Car',
                      groupValue: controller.vehicleType.value,
                      onChanged: (String? value) {
                        controller.vehicleType.value = value!;
                      },
                    ),
                    Text('Car')
                  ],
                ),
              ],
            )),
        SizedBox(height: 20.0),
        SizedBox(
          height: 60,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              controller.signUp();
            },
            child: Text('Sign Up'),
          ),
        ),
      ],
    );
  }
}
