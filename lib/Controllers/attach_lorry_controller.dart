import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../models/vehicle_model.dart';

class AttachLorryController extends GetxController implements GetxService {
  List selectStateIdList = [];
  List selectStateList = [];
  String? editeTitle;
  bool isLorryNumber = false;
  bool isNumTonnes = false;
  bool isLoading = true;
  bool passport = false;

  List galleryListOfImages = [];
  setRemoveImage(int index) {
    galleryListOfImages.removeAt(index);
    update();
    if (galleryListOfImages.length < 2) {
      setPassport(false);
    }
  }

  setPassport(value) {
    passport = value;
    update();
  }

  setAddGallery(value) {
    if (value != null) {
      galleryListOfImages.add(value);
    }
    update();
  }

  int selectVehicle = -1;
  String vehicleID = "-1";

  setSelectVehicle(int value) {
    selectVehicle = value;
    update();
  }

  late VehicleListModel vehicleList;

  TextEditingController lorrynumber = TextEditingController();
  TextEditingController numberTonnes = TextEditingController();
  setIsLorryNumber(bool value) {
    isLorryNumber = value;
    update();
  }

  setIsNumTonnes(bool value) {
    isNumTonnes = value;
    update();
  }

  setIsLoading(bool value) {
    isLoading = value;
    update();
  }

  getDataFromApi({required var value}) {
    vehicleList = VehicleListModel.fromJson(value);
    update();
    setIsLoading(false);
  }
}
