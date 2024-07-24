import 'package:get/get.dart';

import '../controllers/signup_user_controller.dart';

class SignupUserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupUserController>(
      () => SignupUserController(),
    );
  }
}
