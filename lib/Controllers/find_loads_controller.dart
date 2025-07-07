import 'package:get/get.dart';
import '../models/find_load_model.dart';

class FindLoadController extends GetxController implements GetxService {
  late FindLoadModel loadData;
  int selectVehicle = 0;

  setSelectVehicle(int value) {
    selectVehicle = value;
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
  bool isLoading = false;

  late List<bool> isBidNowLoder;
  late List<bool> isBidLoder;

  setIsBidNowLoder({required int index, required bool value}) {
    isBidNowLoder[index] = value;
    update();
  }

  setIsBidLoder({required int index, required bool value}) {
    isBidLoder[index] = value;
    update();
  }

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

  String picUpState = "";
  String dropPoint = "";

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
