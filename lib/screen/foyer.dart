import 'dart:async';

import 'package:dapp_virtual/models/live.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dapp_virtual/widgets/drawer.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';
import '../models/global.dart';
import '../models/room.dart';
import 'agora/join.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class Foyer extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  Foyer({Key key, this.analytics,this.observer}) : super(key: key);
  @override
  _FoyerState createState() => _FoyerState();
}

class _FoyerState extends State<Foyer> {

  final FlareControls flareControls = FlareControls();
  Future<List<Room>> roomList;
  List<Live> list =[];
  bool ready =false;
  Live liveUser;
  var name = "";
  var image ='';
  var imagelocal = 'assets/images/icon.png';
  var username = '';
  var postUsername = 'posted';

  @override
  Widget build(BuildContext context) {
    return getMain();
  }

  @override
  void initState() {
    super.initState();
    loadSharedPref();
    roomList = fetchRooms();

    /*var date = DateTime.now();
    var newDate = '${DateFormat("dd-MM-yyyy hh:mm:ss").format(date)}';
    */
  }


  Future<void> loadSharedPref() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'DAPP User';
      username = prefs.getString('username') ?? 'dappuser';
      image = prefs.getString('image') ?? 'https://nichemodels.co/wp-content/uploads/2019/03/user-dummy-pic.png';
      imagelocal = prefs.getString('imagelocal') ?? image;
    });
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/dj.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<Room>>(
          future: roomList,
          builder: (context, snapshot) {
            List<Widget> children;
            if (snapshot.hasData) {
              children = getRooms(context, snapshot.data);
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
        )
      ),
      drawer: AppDrawer(),
    );
  }



  List<Widget> getRooms(BuildContext context, List<Room> roomList) {
    List<Widget> rooms = [];
    int index = 0;
    for (Room room in roomList) {
      rooms.add(getRoom(context, room, index));
      index ++;
    }
    return rooms;
  }

  Widget getRoom(BuildContext context, Room room, int index) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[


          GestureDetector(
            onTap: () {
              onJoin(channelName: room.description,channelId: room.channelId,username: name, hostImage: image,userImage: imagelocal);
            },
            child: Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              constraints: BoxConstraints(
                maxHeight: 280,
              ),

              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: room.image
                )
              ),
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                room.description,
                style: textStyleBold
              ),
            ),
          ),

          SizedBox(height: 10,)

        ],
      )
    );
  }

  Future<void> onJoin({channelName,channelId, username, hostImage, userImage}) async {
    // update input validation
    if (channelName.isNotEmpty) {
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinPage(
            channelName: channelName,
            channelId: channelId,
            username: username,
            hostImage: hostImage,
            userImage: userImage,
          ),
        ),
      );
    }
  }

}
