// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

String basUrl = "https://moverspro.cscodetech.cloud/";
// String basUrl = "https://movers.cscodetech.cloud/";
// String basUrl = "http://15.207.11.52/lorriz/";

class ImageUploadApi extends GetConnect {
  Map<String, String> header = {'Content-Type': 'application/json'};
  String basUrlApi = "${basUrl}lorry_api/";

  Future upLoadDox(
      {XFile? image,
      XFile? image1,
      XFile? imageSelfie,
      required String uid,
      required String status}) async {
    final body = {
      "image0": image.isNull
          ? ""
          : MultipartFile(await image!.readAsBytes(), filename: image.name),
      "image1": image1.isNull
          ? ""
          : MultipartFile(await image1!.readAsBytes(), filename: image1.name),
      "images0": imageSelfie.isNull
          ? ""
          : MultipartFile(await imageSelfie!.readAsBytes(), filename: imageSelfie.name),
      "size": "2",
      "sizes": "1",
      "status": status,
      "owner_id": uid,
    };

    FormData formData = FormData(body);

    log("++++++++++++++++++$body");
    var respons = await post("${basUrlApi}personal_document.php", formData,
        contentType: "multipart/form-data");

    log("+++++++++++++++++${respons.body}");
    return respons.body;
  }

  Future editeLorry({
    XFile? image,
    XFile? image1,
    required String recodeId,
    required String ownerId,
    required String lorryNo,
    required String widght,
    required String des,
    required String vehicleId,
    required String currentlocation,
    required String routes,
  }) async{
    var request = http.MultipartRequest('POST', Uri.parse("${basUrlApi}edit_lorry.php"));
    request.fields.addAll({
      "record_id": recodeId,
      "owner_id": ownerId,
      "lorry_no": lorryNo,
      "weight": widght,
      "description": des,
      "vehicle_id": vehicleId,
      "status": "1",
      "curr_location": currentlocation,
      "curr_state_id": "1",
      "routes": routes,
      "size": "2",
    });
    if (image != null && image.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image0', image.path));
    } else {
      // request.files.add(await http.MultipartFile.fromPath('image0', ""));
    }

    if (image1 != null && image1.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image1', image1.path));
    }


    http.StreamedResponse response = await request.send();
      print("+++++++++++++++++++ body ++++++++++++++++++ ${request.fields}");

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = jsonDecode(responseBody);
      print("++++++++++++url++++++++++++++++++++++ ${basUrlApi}edit_lorry.php}");
      print("++++++++++++body+++++++++++++++++++++ ${data}");
      print("++++++++++++respons++++++++++++++++++ ${responseBody}");

      if(data["Result"] == "true"){
        return data;
      }
    }
    else {
      print(response.reasonPhrase);
    }
  }
}
