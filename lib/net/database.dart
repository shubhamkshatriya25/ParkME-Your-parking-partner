import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{

  final String uid;
  DatabaseService({this.uid});
  final CollectionReference vehiclesCollection = Firestore.instance.collection('vehicles');

  Future updateUserData(String title, String owner, String vehicleNumber) async{
   return await vehiclesCollection.doc().setData({
     'title': title,
     'owner': owner,
     'vehicleNumber' : vehicleNumber,
     'uid' : uid,
   });
  }
}