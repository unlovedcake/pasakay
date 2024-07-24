import 'package:get/get.dart';

import '../modules/driver/bindings/driver_binding.dart';
import '../modules/driver/views/driver_view.dart';
import '../modules/driver_history/bindings/driver_history_binding.dart';
import '../modules/driver_history/views/driver_history_view.dart';
import '../modules/driver_profile/bindings/driver_profile_binding.dart';
import '../modules/driver_profile/views/driver_profile_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/sample/bindings/sample_binding.dart';
import '../modules/sample/views/sample_view.dart';
import '../modules/signup_driver/bindings/signup_driver_binding.dart';
import '../modules/signup_driver/views/signup_driver_view.dart';
import '../modules/signup_user/bindings/signup_user_binding.dart';
import '../modules/signup_user/views/signup_user_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/user_history/bindings/user_history_binding.dart';
import '../modules/user_history/views/user_history_view.dart';
import '../modules/user_profile/bindings/user_profile_binding.dart';
import '../modules/user_profile/views/user_profile_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static const LOGIN = Routes.LOGIN;

  static const SIGNUP_DRIVER = Routes.SIGNUP_DRIVER;
  static const SIGNUP_USER = Routes.SIGNUP_USER;
  static const SPLASH = Routes.SPLASH;
  static const SAMPLE = Routes.SAMPLE;
  static const DRIVER = Routes.DRIVER;
  static const USER_HISTORY = Routes.USER_HISTORY;
  static const USER_PROFILE = Routes.USER_PROFILE;
  static const DRIVER_PROFILE = Routes.DRIVER_PROFILE;
  static const DRIVER_HISTORY = Routes.DRIVER_HISTORY;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP_DRIVER,
      page: () => const SignupDriverView(),
      binding: SignupDriverBinding(),
    ),
    GetPage(
      name: _Paths.SIGNUP_USER,
      page: () => const SignupUserView(),
      binding: SignupUserBinding(),
    ),
    GetPage(
      name: _Paths.SAMPLE,
      page: () => SampleView(),
      binding: SampleBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
      children: [
        GetPage(
          name: _Paths.SPLASH,
          page: () => const SplashView(),
          binding: SplashBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.DRIVER,
      page: () => const DriverView(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: _Paths.USER_HISTORY,
      page: () => const UserHistoryView(),
      binding: UserHistoryBinding(),
    ),
    GetPage(
      name: _Paths.USER_PROFILE,
      page: () => const UserProfileView(),
      binding: UserProfileBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_PROFILE,
      page: () => const DriverProfileView(),
      binding: DriverProfileBinding(),
    ),
    GetPage(
      name: _Paths.DRIVER_HISTORY,
      page: () => const DriverHistoryView(),
      binding: DriverHistoryBinding(),
    ),
  ];
}
