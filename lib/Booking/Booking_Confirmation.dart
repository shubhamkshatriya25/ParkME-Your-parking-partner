import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parkme/booking/BookingSuccessful.dart';
import 'package:parkme/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class BookingConfirmation extends StatefulWidget {
  final QueryDocumentSnapshot spot;
  const BookingConfirmation({Key key, this.spot}) : super(key: key);
  @override
  _BookingConfirmationState createState() => _BookingConfirmationState();
}

class _BookingConfirmationState extends State<BookingConfirmation> {
  TimeOfDay _checkInTime, _checkOutTime;
  DateTime _date;
  String dropdownValue = null;
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  int currentOccupiedSpots;
  List _vehicles = [];
  Razorpay _razorpay = Razorpay();
  TwilioFlutter twilioFlutter;
  @override
  void initState() {
    _initUserVehicles();
    _checkInTime = TimeOfDay.now();
    _checkOutTime = TimeOfDay.now();
    _date = DateTime.now();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    twilioFlutter = TwilioFlutter(
        accountSid : '*********************',
        authToken : '****************************',
        twilioNumber : '****************'
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsetsDirectional.only(top: 5),
                  height: height * 0.35,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.spot['imageUrl']),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Positioned(
                  top: 250,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                        color: kprimaryBgColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: kprimaryBgColor,
                    child: Center(
                      child: GestureDetector(
                        child: Icon(Icons.arrow_back, color: kprimaryColor),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: height * 0.60,
              decoration: BoxDecoration(
                color: kprimaryBgColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Hero(
                              tag: 'centerName',
                              child: Text(
                                widget.spot['name'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kprimaryColor,
                                    fontSize: 20),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 18,
                                ),
                                Text(
                                  widget.spot['address'],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 12, bottom: 10),
                          height: 30,
                          width: 150,
                          child: Center(
                            child: Text(
                              '${widget.spot['totalSpots'] - widget.spot['occupiedSpots']} slots available',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      ],
                    ),
                    Text(
                      '\u{20B9} ${widget.spot['costPerHour']} per hour',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 20),
                      child: Divider(color: Colors.grey),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Check-in',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                TimeOfDay time = await showTimePicker(
                                    context: context,
                                    initialTime: _checkInTime);
                                setState(() {
                                  if (time != null) {
                                    _checkInTime = time;
                                  }
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                width: width * 0.3,
                                height: 65,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text(
                                  "${_checkInTime.hour < 10 ? '0${_checkInTime.hour}' : _checkInTime.hour}:${_checkInTime.minute < 10 ? '0${_checkInTime.minute}' : _checkInTime.minute}",
                                  style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            Text(
                              '(Tap to edit)',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Check-out',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                TimeOfDay time = await showTimePicker(
                                    context: context,
                                    initialTime: _checkOutTime);
                                setState(() {
                                  if (time != null) {
                                    _checkOutTime = time;
                                  }
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                width: width * 0.3,
                                height: 65,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text(
                                  "${_checkOutTime.hour < 10 ? '0${_checkOutTime.hour}' : _checkOutTime.hour}:${_checkOutTime.minute < 10 ? '0${_checkOutTime.minute}' : _checkOutTime.minute}",
                                  style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            Text(
                              '(Tap to edit)',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                            )
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: width,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5)),
                          child: Center(
                            child: DropdownButton<String>(
                              hint: dropdownValue == null
                                  ? Text('Choose Vehicle')
                                  : Text(
                                      dropdownValue,
                                    ),
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 30,
                              elevation: 24,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                              underline: Container(
                                height: 2,
                                color: Colors.grey.shade200,
                              ),
                              onChanged: (newValue) {
                                setState(() {
                                  dropdownValue = newValue;
                                });
                              },
                              items: <String>[
                                ..._vehicles
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Column(
                      children: [
                        Text(
                          'Total Charges',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          '\u{20B9} ${((((_checkOutTime.hour * 60 + _checkOutTime.minute) - (_checkInTime.hour * 60 + _checkInTime.minute)) / 60) * widget.spot['costPerHour']).round()}',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  width: width * 0.5,
                  height: 60,
                  child: FlatButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(0.0)),
                    padding: EdgeInsets.all(10),
                    splashColor: Colors.blue,
                    color: Colors.grey.shade200,
                    child: const Text(
                      'PAY AT LOCATION',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      if(dropdownValue == null){
                        Fluttertoast.showToast(msg: "Please Select Vehicle", timeInSecForIos: 4);
                      }else if(((_checkOutTime.hour * 60 + _checkOutTime.minute) - (_checkInTime.hour * 60 + _checkInTime.minute)) <= 0){
                        Fluttertoast.showToast(msg: "Please Select Appropriate Time", timeInSecForIos: 4);
                      }else{
                        addReservationToFirebase(false, null);
                      }
                    },
                  ),
                ),
                Container(
                  width: width * 0.5,
                  height: 60,
                  child: FlatButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(0.0)),
                    padding: EdgeInsets.all(10),
                    splashColor: Colors.blue,
                    color: kprimaryColor,
                    child: const Text(
                      'PAY NOW',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      if(dropdownValue == null){
                        Fluttertoast.showToast(msg: "Please Select Vehicle", timeInSecForIos: 4);
                      }else if(((_checkOutTime.hour * 60 + _checkOutTime.minute) - (_checkInTime.hour * 60 + _checkInTime.minute)) <= 0){
                        Fluttertoast.showToast(msg: "Please Select Appropriate Time", timeInSecForIos: 4);
                      }else{
                        openCheckout();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _initUserVehicles() {
     Firestore.instance
        .collection('vehicles')
        .where("uid", isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((vehicle) {
        _vehicles.add(vehicle['vehicleNumber']);
      });
      setState(() {
        _vehicles = [..._vehicles];
      });
    });
  }

  void openCheckout() async {
    int checkOutAmount = ((((_checkOutTime.hour * 60 + _checkOutTime.minute) - (_checkInTime.hour * 60 + _checkInTime.minute)) / 60) * widget.spot['costPerHour']).round();
    print(checkOutAmount);
    var options = {
      'key': '*********************',
      'amount': checkOutAmount * 100,
      'name': FirebaseAuth.instance.currentUser.displayName,
      'description': 'Payment of Parking Spot',
      'prefill': {'email': FirebaseAuth.instance.currentUser.email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId, timeInSecForIos: 4);
    addReservationToFirebase(true, response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message,
        timeInSecForIos: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName, timeInSecForIos: 4);
  }

  void addReservationToFirebase(paymentDone, transactionID) {
    CollectionReference reservations =
    FirebaseFirestore.instance.collection('reservations');
    CollectionReference parkingCentres =
    FirebaseFirestore.instance.collection('parkingCentres');

    reservations
      .add({
        'centre': widget.spot['name'],
        'vehicleNumber': dropdownValue,
        'date': formatter.format(_date),
        'checkin':
        "${_checkInTime.hour < 10 ? '0${_checkInTime.hour}' : _checkInTime.hour}:${_checkInTime.minute < 10 ? '0${_checkInTime.minute}' : _checkInTime.minute}",
        'checkout':
        "${_checkOutTime.hour < 10 ? '0${_checkOutTime.hour}' : _checkOutTime.hour}:${_checkOutTime.minute < 10 ? '0${_checkOutTime.minute}' : _checkOutTime.minute}",
        'cost':
        '${((((_checkOutTime.hour * 60 + _checkOutTime.minute) - (_checkInTime.hour * 60 + _checkInTime.minute)) / 60) * widget.spot['costPerHour']).round()}',
        'paymentMethod': paymentDone ? 'Online' : 'On Arrival',
        'transactionID': transactionID != null ? transactionID : null,
        'uid': FirebaseAuth.instance.currentUser.uid.toString(),
      })
        .then((value) => {
      currentOccupiedSpots =
      widget.spot['occupiedSpots'],
      parkingCentres
          .doc('${widget.spot['id']}')
          .update({
        'occupiedSpots': ++currentOccupiedSpots
      }),

      twilioFlutter.sendSMS(
        toNumber : '+************************',
        messageBody : 'Parking Spot at ${widget.spot['name']} successful. Thanks for using Park ME.'
      ),

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return BookingSuccessful(
                data: {
                  'ticketID': value.id,
                  'vehicleNumber': dropdownValue,
                  'centre': widget.spot['name'],
                  'date': formatter.format(_date),
                  'transactionID': transactionID != null ? transactionID : '',
                  'checkin':
                  "${_checkInTime.hour < 10 ? '0${_checkInTime.hour}' : _checkInTime.hour}:${_checkInTime.minute < 10 ? '0${_checkInTime.minute}' : _checkInTime.minute}",
                  'checkout':
                  "${_checkOutTime.hour < 10 ? '0${_checkOutTime.hour}' : _checkOutTime.hour}:${_checkOutTime.minute < 10 ? '0${_checkOutTime.minute}' : _checkOutTime.minute}",
                  'cost':
                  '${((((_checkOutTime.hour * 60 + _checkOutTime.minute) - (_checkInTime.hour * 60 + _checkInTime.minute)) / 60) * widget.spot['costPerHour']).round()}'
                });
          },
        ),
      )
    }).catchError((error) => print("Failed to do reservation: $error"));
  }
}
