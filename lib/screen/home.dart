import 'dart:io';
import 'package:dapp_virtual/widgets/drawer.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../models/global.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dapp_virtual/utils/adextensions.dart';

class HomePage extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  HomePage({Key key, this.analytics,this.observer}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final FlareControls flareControls = FlareControls();
  Future<Event> event;

  @override
  void initState() {
    super.initState();
    event = fetchEvent();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }
  @override
  Widget build(BuildContext context) {
    return getMain(context);
  }
  Widget _header() {
    TextStyle style = TextStyle(fontSize: 28.0, fontWeight: FontWeight.w800, color: Color(0xFF023399));
    return Text("VIRTUAL.DAPP.EVENTS", style: style);
  }

  bool notLive(Event evt) {
    var datetime = DateTime.parse(evt.datetime);
    var now = new DateTime.now();
    if (datetime.isBefore(now)) {
      return false;
    }
    return true;
  }
  Widget _topSection(Event evt) {
      var datetime = DateTime.parse(evt.datetime);

      DateFormat dateformat = DateFormat('dd/MM/yyyy');
      String formatDate = dateformat.format(datetime);
      DateFormat timeformat = DateFormat('HH:mm');
      String formatTime = timeformat.format(datetime);
      TextStyle style = TextStyle(fontSize: 72.0, fontWeight: FontWeight.w100, color: Colors.white);
      TextStyle countdown = TextStyle(fontSize: 28.0, fontWeight: FontWeight.w800, color: Colors.white);
      return Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Column(
              children: <Widget>[
                _header(),
                Text(formatDate, style: style),
                Text(formatTime, style: style),
                Text("PROSSIMO EVENTO TRA", style: countdown),
                CountdownTimer(
                  endTime: datetime.millisecondsSinceEpoch,
                  textStyle: countdown,
                  onEnd: liveShow,
                ),
              Text(evt.headlines, style: style),
              ]
          )
      );
  }

  Widget _image(Event evt) {
      return Image(image: evt.image);

  }

  Widget _description(Event evt) {
    var style = {
      "body": Style(
        backgroundColor: Color(0xffffffd9),
        padding: EdgeInsets.all(15.0),
      )
    };
    return Html(
      data: evt.description,
      style: style,
      onLinkTap: (url) {
        launch(url);
      },
    );

  }

  void liveShow() {
    Navigator.pushReplacementNamed(context, '/Foyer');
  }

  Widget getMain(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Container(
          child: Image.asset(
            'assets/images/logo512.png',
          ),
        ),
        backgroundColor: Color(0xFF003399),
      ).withBottomAdmobBanner(context),
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/dj.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: FutureBuilder<Event>(
            future: event,
            builder: (context, snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                if (notLive(snapshot.data)) {
                  children = <Widget>[
                    _topSection(snapshot.data),
                    _image(snapshot.data),
                    _description(snapshot.data),
                  ];
                } else {
                  Navigator.pushReplacementNamed(context, '/Foyer');
                }
              } else if (snapshot.hasError) {
                children = <Widget>[
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  )
                ];            } else {
                children = <Widget>[
                  SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Awaiting result...'),
                  )
                ];
              }
              return ListView(
                children: children,
              );
            },
          ),
          // child: ListView(
          //   children: <Widget>[
          //     _header(),
          //     _dateTime(),
          //     _headlines(),
          //     _image(),
          //     _description(),
          //   ]
          // )
      ),
      drawer: AppDrawer(),
    );
  }
}
