import 'package:get/get.dart';
import 'package:truckbuddy/models/near_load_model.dart';

import '../models/find_load_model.dart';

class NearLoadController extends GetxController implements GetxService {
  late NearLoadModel loaddata;
  late FindLoadModel loadData;

  int selectVehicle = 0;

  setSelectVehicle(int value) {
    selectVehicle = value;
    update();
  }

  late List<bool> isbidLoder;

  setIsBidLoder({required int index, required bool value}) {
    isbidLoder[index] = value;
    update();
  }

  String? pickUpStatId;
  String? dropUpStatId;

  setPickUpStatId(String value) {
    pickUpStatId = value;
    update();
  }

  setDropUpStatId(String value) {
    dropUpStatId = value;
    update();
  }

  bool isShowData = false;
  bool isLoading = true;

  setIsShowData(bool value) {
    isShowData = value;
    update();
  }

  setIsLoading(bool value) {
    isLoading = value;
    update();
  }

  setDataInList(value) {
    loadData = value;
    update();
  }

  String? picUpState;
  String? dropPoint;

  String? picUpLat;
  String? picUpLng;

  String? dropUpLat;
  String? dropUpLng;

  bool isPickUp = false;
  bool isDropPoint = false;

  setIsDropPoint(bool value) {
    isDropPoint = value;
    update();
  }

  setIsPickUp(bool value) {
    isPickUp = value;
    update();
  }
}
