import 'package:get/get.dart';
import 'package:movers_lorry_owner/models/myloads_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api_Provider/api_provider.dart';

class MyLoadsController extends GetxController implements GetxService {
  late MyLoadsModel currentData;
  late MyLoadsModel complete;

  bool isLoading = true;
  String uid = '';
  String currency = "\$";
  setIsLoading(bool value) {
    isLoading = value;
    update();
  }

  setDataInCurrentList(value) {
    currentData = value;
    update();
  }

  setDataInCompletList(value) {
    complete = value;
    update();
  }

  fetchDataFromApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("uid")!;
    currency = prefs.getString("currencyIcon")!;

    ApiProvider()
        .myLoadsApi(ownerId: uid, status: "Current")
        .then((value) async {
      setDataInCurrentList(value);
      ApiProvider().myLoadsApi(ownerId: uid, status: "complet").then((value) {
        setDataInCompletList(value);
        setIsLoading(false);
      });
    });
  }
}
