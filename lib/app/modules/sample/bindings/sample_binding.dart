import 'package:get/get.dart';

import '../controllers/sample_controller.dart';

class SampleBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SampleController());
  }
}
