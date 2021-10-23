import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkme/constant.dart';
import 'package:parkme/pages/vehicles.dart';
import '../pages/map_view.dart';
import '../pages/my_profile.dart';

class Dashboard extends StatefulWidget {
  final User user;
  const Dashboard({Key key, this.user}) : super(key: key);
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  final tabs = [
    MapView(),
    GroupViewPage(),
    MyProfile(
      user: FirebaseAuth.instance.currentUser,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      color: Colors.white,
      child: Scaffold(
        body: tabs[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              title: Text('Find'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              title: Text('My Vehicles'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('My Profile'),
            ),
          ],
          selectedItemColor: kprimaryColor,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),

    );
  }
}
