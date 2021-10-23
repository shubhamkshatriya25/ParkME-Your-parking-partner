import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkme/pages/add_vehicles.dart';
import '../constant.dart';



class GroupViewPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Container(
        width: width,
        height: height,
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('vehicles').where("uid", isEqualTo: FirebaseAuth.instance.currentUser.uid).snapshots(),
          builder: (context, snapshot) {
            if(!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          "My Vehicles",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kprimaryColor,
                              fontSize: 20),
                        ),
                        padding: EdgeInsets.only(top: 15),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: width,
                      height: 60,
                      child: OutlineButton.icon(
                        borderSide: BorderSide(width: 2.0, color: kprimaryColor),
                           onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddVehicle()),
                                );
                              },
                        label: Text(
                          "Add new vehicle",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kprimaryColor,
                            fontSize: 18,
                          ),
                        ),
                        icon: Icon(
                          Icons.add,
                          color: kprimaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int i) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  child: Icon(
                                    Icons.directions_car_rounded,
                                    color: Colors.black38,
                                    size: 60,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  padding: EdgeInsets.only(bottom: 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 10, right: 10),
                                        child: Text(
                                          snapshot.data.docs[i]['title'],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: kprimaryColor
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10, top: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child:
                                                  Text('${ snapshot.data.docs[i]['owner']}'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
