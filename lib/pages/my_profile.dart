import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkme/authentication/signIn.dart';
import 'package:parkme/UserDashboard/ChangePassword.dart';
import 'package:parkme/booking/mybooking.dart';
import 'package:parkme/constant.dart';
import 'package:parkme/pages/faq.dart';

class MyProfile extends StatefulWidget {
  final User user;
  const MyProfile({Key key, this.user}) : super(key: key);
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 250,
                decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Profile(),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        widget.user.displayName,
                        style: TextStyle(
                          wordSpacing: 2,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: kprimaryColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        widget.user.email,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text('Account Settings'),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    children: [
                      GestureDetector(
                        child: ProfileOptions(
                            icon: Icons.settings,
                            Option_title: 'Change Password'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) {
                                return ChangePassword(
                                  user: _auth.currentUser,
                                );
                              },
                            ),
                          );
                        },
                      ),
                     GestureDetector(
                       child:  ProfileOptions(
                          icon: Icons.question_answer,
                          Option_title: 'Frequently Asked Questions'),
                              onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) {
                                return FAQPage();
                              },
                            ),
                          );
                        },
                     ),
                      GestureDetector(
                        child: ProfileOptions(
                            icon: Icons.store, Option_title: 'My Bookings'),
                                 onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) {
                                return MyBooking();
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                // sign out logic
                padding: const EdgeInsets.only(top: 30, bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    _signOut().whenComplete(() {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => SignIn()));
                    });
                  },
                  child: Text(
                    'Sign out',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kprimaryColor,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Text('ParkMe v1.0.0')
            ],
          ),
        ),
      ),
    );
  }

  Future _signOut() async {
    await _auth.signOut();
  }

  Profile() {
    if (widget.user.photoURL != null) {
      String photoUrl = widget.user.photoURL.replaceFirst("s96", "s400"); //
      print(photoUrl);
      return CircleAvatar(
        radius: 65,
        backgroundImage: NetworkImage(photoUrl),
      );
    }
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
          color: kprimaryColor,
          borderRadius: BorderRadius.all(Radius.circular(100))),
      child: Center(
          child: Text(
        widget.user.displayName[0],
        style: TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      )),
    );
  }
}

class ProfileOptions extends StatelessWidget {
  const ProfileOptions({
    Key key,
    this.icon,
    this.Option_title,
  }) : super(key: key);

  final IconData icon;
  final String Option_title;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(Option_title),
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
}
