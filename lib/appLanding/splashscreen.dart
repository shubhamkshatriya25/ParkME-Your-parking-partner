import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkme/constant.dart';
import 'package:splashscreen/splashscreen.dart';
import 'landingScreen.dart';
import 'package:parkme/UserDashboard/dashboard.dart';

class Splash extends StatelessWidget {
  BuildContext get context => null;

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 6,
      navigateAfterSeconds: next(),
      image: new Image.asset("assets/images/parkmeLogo.png"),
      loadingText: Text("loading..."),
      photoSize: 100.0,
      backgroundColor: Colors.white,
      loaderColor: kprimaryColor,
    );
  }
  next() {
    // check whether a user already exists
    User user = FirebaseAuth.instance.currentUser;
    if( user != null){
      // if yes redirect to Dashboard
      return new Dashboard(
        user: user,
      );
    }
    else{
      // if no redirect to Landing Screen
      return new LandingScreen();
    }
  }
}


