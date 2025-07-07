import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../Api_Provider/api_provider.dart';
import '../models/earning_model.dart';
import '../models/transaction_model.dart';

class EarningScreenController extends GetxController implements GetxService {
  String walletVale = '0';
  String currency = "\$0.00";
  String uid = "";
  int selectMethode = -1;
  bool istrue = true;
  late TransactionModel historyData;
  late EarningModel walletModel;

  bool isLoading = true;

  setIsLoading(value) {
    isLoading = value;
    update();
  }

  fetChDataFromApi() {
    ApiProvider().earning(uid: uid).then((value) {
      walletModel = value;
      update();
      ApiProvider().transactionHistory(ownerId: uid).then((value) {
        historyData = value;
        istrue = false;
        update();
      });
    });
  }

  Future getDataFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("uid")!;
    update();
    currency = prefs.getString("currencyIcon")!;
    setIsLoading(false);
  }
}
