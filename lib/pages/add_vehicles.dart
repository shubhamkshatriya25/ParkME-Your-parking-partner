import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkme/constant.dart';
import 'package:parkme/net/database.dart';

class AddVehicle extends StatefulWidget {
  @override
  _AddVehicleState createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _vehicleName = TextEditingController();
  TextEditingController _vehicleNum = TextEditingController();
  TextEditingController _ownerName = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kprimaryColor,
        title: Text('Add Vehicle'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _vehicleName,
                validator: (value) {
                  return value.isEmpty
                      ? "This field must not be empty"
                      : null;
                },
                decoration: InputDecoration(
                  labelText: "Vehicle Name",
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w600),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: kprimaryColor),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _ownerName,
                validator: (value) {
                  return value.isEmpty
                      ? "This field must not be empty"
                      : null;
                },
                decoration: InputDecoration(
                  labelText: "Owner Name",
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w600),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: kprimaryColor),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _vehicleNum,
                validator: (value) {
                  return value.isEmpty
                      ? "This field must not be empty"
                      : null;
                },
                decoration: InputDecoration(
                  labelText: "Vehicle Number",
                  labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w600),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: kprimaryColor),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 50,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: RaisedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      //do what we have to do
                      addVehicleToDatabase(_vehicleName.text.trim(), _ownerName.text.trim(), _vehicleNum.text.trim());
                    }
                  },
                  padding: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: kprimaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      constraints: BoxConstraints(
                          minHeight: 50, maxWidth: double.infinity),
                      child: Text(
                        "ADD",
                        style:
                        TextStyle(color: kBtnTextColor, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addVehicleToDatabase(vehicle, owner, number) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    final user1 = _auth.currentUser;
    await DatabaseService(uid: user1.uid)
        .updateUserData(vehicle, owner, number).then((value){
          Navigator.pop(context);
        }).catchError((value){
          //Add Error Here
        });
  }
}
