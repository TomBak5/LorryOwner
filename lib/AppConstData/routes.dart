import 'package:get/get.dart';
import 'package:movers_lorry_owner/Screens/login_screen.dart';
import 'package:movers_lorry_owner/Screens/onboarding_screens.dart';
import 'package:movers_lorry_owner/Screens/splash_screen.dart';

import '../Screens/main_pages/notification.dart';
import '../Screens/profile_Sub_page/contactus.dart';
import '../Screens/profile_Sub_page/faq.dart';
import '../Screens/profile_Sub_page/privacy_policy.dart';
import '../Screens/profile_Sub_page/review_screen.dart';
import '../Screens/profile_Sub_page/terms_conditions.dart';
import '../Screens/profile_Sub_page/wallet_screen.dart';
import '../Screens/creatnew_pass_screen.dart';
import '../Screens/forgotpassword_screen.dart';
import '../Screens/main_pages/landing_page.dart';
import '../Screens/singup_screen.dart';
import '../Screens/sub_pages/attach_lorry.dart';
import '../Screens/sub_pages/findload.dart';
import '../Screens/sub_pages/nearload.dart';
import '../Screens/sub_pages/verify_indentity.dart';
import '../Screens/sub_pages/truck_info_screen.dart';
import '../Screens/congratulations_screen.dart';
import '../Screens/sub_pages/assign_order_screen.dart';
import '../Screens/sub_pages/assigned_orders_screen.dart';
import '../Screens/test_map_screen.dart';

class Routes {
  static String splashScreen = '/';
  static String onBoardingScreens = '/OnBoardingScreens';
  static String loginScreen = "/LoginScreen";
  static String singUp = "/SingUp";
  static String forgotPassword = "/ForgotPassword";
  static String createNewPassword = "/CreateNewPassword";
  static String landingPage = "/LandingPage";
  static String reviewScreen = "/ReviewScreen";
  static String walletScreen = "/WalletScreen";
  static String privacyPolicy = "/ReferFriend";
  static String termsConditions = "/TermsConditions";
  static String contactus = "/Contactus";
  static String faq = "/Faq";
  static String verifyIdentity = "/VerifyIdentity";
  static String findLorry = "/FindLorry";
  static String nearLoad = "/NearLoad";
  static String attachLorry = "/AttachLorry";
  static String notification = "/Notification";
  static const String truckInfo = '/truckInfo';
  static const String assignOrder = '/assignOrder';
  static const String assignedOrders = '/assignedOrders';
  static const String testMap = '/testMap';

}

final getpage = [
  GetPage(
    name: Routes.splashScreen,
    page: () => const SplashScreen(),
  ),
  GetPage(
    name: Routes.onBoardingScreens,
    page: () => const OnBoardingScreens(),
  ),
  GetPage(
    name: Routes.loginScreen,
    page: () => const LoginScreen(),
  ),
  GetPage(
    name: Routes.singUp,
    page: () => const SingUp(),
  ),
  GetPage(
    name: Routes.forgotPassword,
    page: () => const ForgotPassword(),
  ),
  GetPage(
    name: Routes.createNewPassword,
    page: () => const CreateNewPassword(),
  ),
  GetPage(
    name: Routes.landingPage,
    page: () => const LandingPage(),
  ),
  GetPage(
    name: Routes.reviewScreen,
    page: () => const ReviewScreen(),
  ),
  GetPage(
    name: Routes.walletScreen,
    page: () => const EarningScreen(),
  ),
  GetPage(
    name: Routes.privacyPolicy,
    page: () => const PrivacyPolicy(),
  ),
  GetPage(
    name: Routes.termsConditions,
    page: () => const TermsConditions(),
  ),
  GetPage(
    name: Routes.contactus,
    page: () => const ContactUs(),
  ),
  GetPage(
    name: Routes.faq,
    page: () => const Faq(),
  ),
  GetPage(
    name: Routes.verifyIdentity,
    page: () => const VerifyIdentity(),
  ),
  GetPage(
    name: Routes.findLorry,
    page: () => const FindLoad(),
  ),
  GetPage(
    name: Routes.nearLoad,
    page: () => const NearLoad(),
  ),
  GetPage(
    name: Routes.attachLorry,
    page: () => const AttachLorry(),
  ),
  GetPage(
    name: Routes.notification,
    page: () => const Notification(),
  ),
  GetPage(
    name: Routes.truckInfo,
    page: () => const TruckInfoScreen(),
  ),
  GetPage(
    name: Routes.assignOrder,
    page: () => const AssignOrderScreen(),
  ),
  GetPage(
    name: Routes.assignedOrders,
    page: () => const AssignedOrdersScreen(),
  ),
  GetPage(
    name: Routes.testMap,
    page: () => const TestMapScreen(),
  ),

  GetPage(
    name: '/CongratulationsScreen',
    page: () => CongratulationsScreen(userRole: 'driver'),
  ),
];
