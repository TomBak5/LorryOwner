import 'package:get/get.dart';

class OnBoardingScreensController extends GetxController
    implements GetxService {
  int pageSelecter = 0;

  setPageSelecter(int value) {
    pageSelecter = value;
    update();
  }

  List onBoardingTitle = [
    "Delivering your cargo with care",
    "Moving you forward, one load at a time",
    "Order directly the ingredients",
  ];

  List subTitle = [
    "Valuable cargo, so you take great care in handling",
    "Reach new markets, or simply meet their customers",
    "Order the ingredients you need quickly with a fast process",
  ];

  List images = [
    "assets/image/onbordingimage1.png",
    "assets/image/onbordingimage2.png",
    "assets/image/onbordingimage3.png",
  ];
}
