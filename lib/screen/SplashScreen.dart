import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:admob_flutter/admob_flutter.dart';

class SplashScreen extends StatefulWidget{
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  SplashScreen({Key key, this.analytics,this.observer}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  var image = Image.asset('assets/images/lightLogo.png');
  @override
  void initState() {
    super.initState();
    startTime();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(image.image, context);
  }

  startTime() async {
    var _duration = new Duration(seconds: 3);
    await Admob.requestTrackingAuthorization();
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/HomeScreen');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Color(0xFF003399),
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height-100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal:35),
                    width: double.maxFinite,
                    child: Center(
                      child: image,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}