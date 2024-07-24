import 'package:flutter/material.dart';

import 'package:get/get.dart';

class LoadingIndicator {
  static void showLoadingIndicator(String title) {
    Get.dialog(
        barrierDismissible: false,
        Dialog(
          backgroundColor: Colors.transparent,
          child: WillPopScope(
            onWillPop: () async => true,
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 8,
                  ),
                  Text(title),
                  const CircularProgressIndicator(
                    strokeWidth: 1,
                    color: Colors.black,
                  )
                ],
              ),
            ),
          ),
        ));
  }

  static void closeLoadingIndicator() {
    Get.back();
  }
}
