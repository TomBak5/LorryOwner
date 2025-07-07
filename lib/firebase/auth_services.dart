import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class AuthServices with ChangeNotifier {

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  setSubdriverData({required String ownerId, required String lat, required String long, required String lorryId, required String subdriverId}) async {
    try {
      await  firestore.collection("Lorryownersubdriver").doc(lorryId).set({
        "lorryid" : lorryId,
        "ownerid" : ownerId,
        "late" : lat,
        "long" : long,
        "subdriverid" : subdriverId,
        "ispicked" : "0"
      });
    } catch (e) {
      print("+++++++ FirebaseAuthException +++++ $e");
    }
  }
}