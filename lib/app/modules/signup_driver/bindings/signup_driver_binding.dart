import 'package:get/get.dart';

import '../controllers/signup_driver_controller.dart';

class SignupDriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupDriverController>(
      () => SignupDriverController(),
    );
  }
}
