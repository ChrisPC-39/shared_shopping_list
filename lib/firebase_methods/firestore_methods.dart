import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void addItem(
      {required String uid,
      required String user,
      required int userColor,
      required String item,
      required int itemCount,
      required DateTime date,
      required bool isChecked,
      required List<dynamic> votedToDeleteBy}) {
    _firestore.collection("items").doc(uid).set({
      "uid": uid,
      "user": user,
      "userColor": userColor,
      "item": item,
      "itemCount": itemCount,
      "date": date,
      "isChecked": isChecked,
      "votedToDeleteBy": votedToDeleteBy,
    });
  }

  void updateItem(
      {required String uid,
      required String user,
      required int userColor,
      required String item,
      required int itemCount,
      required DateTime date,
      required bool isChecked,
      required List<dynamic> votedToDeleteBy}) {
    _firestore.collection("items").doc(uid).update({
      "uid": uid,
      "user": user,
      "userColor": userColor,
      "item": item,
      "itemCount": itemCount,
      "date": date,
      "isChecked": isChecked,
      "votedToDeleteBy": votedToDeleteBy,
    });
  }

  void deleteItem({required String uid}) {
    _firestore
        .collection("items")
        .doc(uid)
        .delete();
  }
}
