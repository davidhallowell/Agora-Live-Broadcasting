import 'dart:io';
import 'package:dapp_virtual/widgets/drawer.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class About extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  About({Key key, this.analytics,this.observer}) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {

  final FlareControls flareControls = FlareControls();
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return getMain();
  }

  Widget getMain() {
    return Scaffold(
      appBar: AppBar(
        title:
          Container(
            child: Image.asset(
              'assets/images/logo512.png',
            ),
          ),
        backgroundColor: Color(0xFF003399),
      ),
      body: WebView(
        initialUrl: "https://dapp.events/about_app",
        javascriptMode: JavascriptMode.unrestricted,
      ),
      drawer: AppDrawer(),
    );
  }
}
