import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constant.dart';
import 'BookingSuccessful.dart';

class MyBooking extends StatefulWidget {
  @override
  _MyBookingState createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kprimaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Bookings',
          style: TextStyle(color: kBtnTextColor),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('reservations')
                .where("uid", isEqualTo: FirebaseAuth.instance.currentUser.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return new ListView(
                children: snapshot.data.docs.map((DocumentSnapshot document) {
                  return new Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(document.data()['centre']),
                          subtitle: Text('Date: ${document.data()['date']}'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) {
                                  return BookingSuccessful(data: {
                                    'ticketID': document.id,
                                    'centre': document.data()['centre'],
                                    'date': document.data()['date'],
                                    'checkin': document.data()['checkin'],
                                    'checkout': document.data()["checkout"],
                                    'cost': document.data()["cost"],
                                    'vehicleNumber':
                                        document.data()["vehicleNumber"],
                                    'transactionID':
                                        document.data()["transactionID"] != null
                                            ? document.data()["transactionID"]
                                            : '',
                                  });
                                },
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
      ),
    );
  }
}
