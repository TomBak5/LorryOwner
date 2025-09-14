import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:movers_lorry_owner/widgets/widgets.dart';

import '../Screens/main_pages/booked_lorries.dart';
import '../Screens/main_pages/home_page.dart';
import '../Screens/main_pages/my_loads.dart';
import '../Screens/main_pages/profile_page.dart';

class LandingPageController extends GetxController implements GetxService {
  int selectPageIndex = 0;

  DateTime? lastBackPressed;

  Future popScopeBack() async{
    DateTime now = DateTime.now();
    if (lastBackPressed == null ||
      now.difference(lastBackPressed!) > Duration(seconds: 2)) {
      lastBackPressed = now;
      showCommonToast("Press back again to exit");
      return false;
    }
    return true;
  }

  setSelectPage(int value) {
    selectPageIndex = value;
    update();
  }

  List bottomItems = [
    "Home",
    "Tasks",
    "Messages",
    "Profile",
  ];

  List bottomItemsIcons = [
    "assets/icons/ic_home_bottom.svg",
    "assets/icons/tasks.png",
    "assets/icons/ic_bookedlorries_bottom.svg",
    "assets/icons/ic_user_bottom.svg",
  ];

  List pages = [
    const HomePage(),
    const MyLoads(),
    const BookedLorries(),
    const ProfilePage(),
  ];
}
