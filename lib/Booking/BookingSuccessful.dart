import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:parkme/constant.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingSuccessful extends StatefulWidget {
  final QueryDocumentSnapshot spot;
  final Map data;
  const BookingSuccessful({Key key, this.spot, this.data}) : super(key: key);
  @override
  _BookingSuccessfulState createState() => _BookingSuccessfulState();
}

class _BookingSuccessfulState extends State<BookingSuccessful> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kprimaryBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Container(
                height: height * 0.2,
                width: width,
                child: Center(
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                        color: kprimaryColor,
                        borderRadius: BorderRadius.circular(100)),
                    child: Center(
                      child: Icon(
                        Icons.thumb_up,
                        color: Colors.white,
                        size: 70,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Your parking is reserved!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: ksecondaryColor),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '${widget.data['transactionID'] != '' ? 'Transaction ID: ${widget.data['transactionID']}' : ''}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 10,
              ),
              QrImage(
                data: widget.data['ticketID'],
                version: QrVersions.auto,
                size: 150.0,
              ),
              Text('Ticket ID:', style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text('${ widget.data['ticketID']}', style: TextStyle(fontSize: 20, color: ksecondaryColor)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SuccessTokens(
                    label: 'Location',
                    value: widget.data['centre'],
                  ),
                  Spacer(),
                  SuccessTokens(
                    label: 'Date',
                    value: widget.data['date'],
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SuccessTokens(
                    label: 'From',
                    value: widget.data['checkin'],
                  ),
                  Spacer(),
                  SuccessTokens(
                    label: 'To',
                    value: widget.data['checkout'],
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SuccessTokens(
                    label: 'Bill',
                    value: widget.data['cost'],
                  ),
                  Spacer(),
                  SuccessTokens(
                    label: 'Vehicle Number',
                    value: widget.data['vehicleNumber'],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SuccessTokens extends StatelessWidget {
  const SuccessTokens({
    Key key,
    this.label,
    this.value,
  }) : super(key: key);
  final String label, value;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: ksecondaryColor),
          ),
        ],
      ),
    );
  }
}
