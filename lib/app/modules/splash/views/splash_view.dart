import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:pasakay/app/global/assets_path.dart';
import 'package:pasakay/app/global/instance_firebase.dart';
import 'package:pasakay/app/modules/driver/views/driver_view.dart';
import 'package:pasakay/app/modules/home/views/home_view.dart';
import 'package:pasakay/app/modules/login/views/login_view.dart';
import 'package:pasakay/app/modules/sample/views/sample_view.dart';
import 'package:pasakay/app/modules/splash/controllers/splash_controller.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        duration: 3000,
        splashIconSize: 300,
        splash: Column(
          children: [
            Text(
              'Pasakay',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            ClipOval(
              child: Image.asset(
                AssetsPath.appLogo,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        nextScreen: auth.currentUser?.uid == null
            ? LoginView()
            : auth.currentUser!.displayName! == 'user'
                ? HomeView()
                : DriverView(),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.white);
  }
}
