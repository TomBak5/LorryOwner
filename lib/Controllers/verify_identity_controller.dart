import 'package:get/get.dart';

class VerifyIdentityController extends GetxController implements GetxService {
  List docx = [];
  bool passport = false;
  bool camera = false;
  bool isLoading = false;
  String statsCode = "";

  setIsLoading(bool value) {
    isLoading = value;
    update();
  }

  String status = "";

  setStatus(String value) {
    status = value;
    update();
  }

  setPassport(value) {
    passport = value;
    update();
  }

  setCamera(value) {
    camera = value;
    update();
  }

  List listOfImages = [
    {
      "gallery": [],
      "camera": [],
    }
  ];

  setAddImage(value) {
    docx.add(value);
    update();
  }

  setAddGallery(value) {
    if (value != null) {
      listOfImages[0]["gallery"].add(value);
    }
    update();
  }

  setAddCamera(value) {
    if (value != null) {
      listOfImages[0]["camera"].add(value);
    }
    update();
  }

  setRemoveImage(int index) {
    listOfImages[0]["gallery"].removeAt(index);
    update();
    if (listOfImages[0]["gallery"].length < 2) {
      setPassport(false);
    }
  }

  setRemoveCamera(int index) {
    listOfImages[0]["camera"].removeAt(index);
    update();
    if (listOfImages[0]["camera"].length == 0) {
      setCamera(false);
    }
  }
}
