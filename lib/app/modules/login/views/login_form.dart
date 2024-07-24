import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:pasakay/app/modules/login/controllers/login_controller.dart';

class LoginForm extends GetWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Login to your account',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          "Welcome back, you have been missed",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
        ),
        SizedBox(
          height: 40,
        ),
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
        SizedBox(height: 50.0),
        Container(
          height: 60,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              controller.login();
            },
            child: Text('Login'),
          ),
        ),
      ],
    );
  }
}
