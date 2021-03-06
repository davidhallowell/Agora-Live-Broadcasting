
import 'package:dapp_virtual/screen/SplashScreen.dart';
import 'package:dapp_virtual/screen/foyer.dart';
import 'package:dapp_virtual/screen/help.dart';
import 'package:dapp_virtual/screen/about.dart';
import 'package:dapp_virtual/screen/home.dart';
import 'package:dapp_virtual/screen/shop.dart';
import 'package:dapp_virtual/screen/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dapp_virtual/screen/loginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'models/event.dart';
import 'models/global.dart';
//import 'dart:io';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Admob.initialize();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DAPP',
      color: Color(0xFF003399),
      navigatorObservers: <NavigatorObserver>[observer],
      home: SplashScreen(analytics: analytics, observer: observer),
      routes: <String, WidgetBuilder>{
        '/HomePage': (BuildContext context) => new HomePage(analytics: analytics, observer: observer),
        '/HomeScreen': (BuildContext context) => new MainScreen(analytics: analytics, observer: observer),
        '/Foyer': (BuildContext context) => new Foyer(analytics: analytics, observer: observer),
        '/Profile': (BuildContext context) => new Profile(analytics: analytics, observer: observer),
        '/Shop': (BuildContext context) => new Shop(analytics: analytics, observer: observer),
        '/About': (BuildContext context) => new About(analytics: analytics, observer: observer),
        '/Help': (BuildContext context) => new Help(analytics: analytics, observer: observer),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  MainScreen({Key key, this.analytics,this.observer}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Event event;
  bool loggedIn = false, live = false;

  @override
  void initState() {
    super.initState();
    loadSharedPref();
  }

  @override
  void dispose() {
    super.dispose();

  }

  void loadSharedPref() async{
    final prefs = await SharedPreferences.getInstance();
    event = await fetchEvent();
    live = liveEvent(event);
    setState(()  {
      loggedIn = prefs.getBool('login') ?? false;
    });
  }

  bool liveEvent(Event evt) {
    var datetime = DateTime.parse(evt.datetime);
    var now = new DateTime.now();
    if (datetime.isBefore(now)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    loadSharedPref();
    return loggedIn?
      (live?
        Foyer(analytics: widget.analytics, observer: widget.observer):
        HomePage(analytics: widget.analytics, observer: widget.observer)
      ):
        LoginScreen(analytics: widget.analytics, observer: widget.observer);
  }


}

