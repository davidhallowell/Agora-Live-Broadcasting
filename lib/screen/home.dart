import 'dart:async';

import 'package:agorartm/models/live.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/global.dart';
import '../models/room.dart';
import 'agora/join.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final FlareControls flareControls = FlareControls();
  List<Live> list =[];
  bool ready =false;
  Live liveUser;
  var name = "Dave H";
  var image ='assets/images/icon.png';
  var username = 'daveh';
  var postUsername = 'posted';

  @override
  Widget build(BuildContext context) {
    return getMain();
  }

  @override
  void initState() {
    super.initState();
    loadSharedPref();
    list = [];
    liveUser = new Live(username: username,me: true,image:image );
    setState(() {
      list.add(liveUser);
      list.add(new Live(username: '424dee2d01fe71fe9a76c97910d6c75c',image: image,channelId: '424dee2d01fe71fe9a76c97910d6c75c',me: false));
    });
    /*var date = DateTime.now();
    var newDate = '${DateFormat("dd-MM-yyyy hh:mm:ss").format(date)}';
    */
  }


  Future<void> loadSharedPref() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Jon Doe';
      username = prefs.getString('username') ?? 'jon';
      image = prefs.getString('image') ?? 'https://nichemodels.co/wp-content/uploads/2019/03/user-dummy-pic.png';
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

        backgroundColor: Colors.black87,
      ),
      body: Container(
        color: Colors.black,
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget> [
                Column(
                  children: getRooms(context),
                ),
                SizedBox(height: 10,)
              ],
            )
          ],
        )
      ),
    );
  }



  List<Widget> getRooms(BuildContext context) {
    List<Widget> rooms = [];
    int index = 0;
    for (Room room in defaultRooms) {
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
              onJoin(channelName: room.description,channelId: room.channelId,username: username, hostImage: image,userImage: image);
            },
            child: Container(
            constraints: BoxConstraints(
              maxHeight: 280
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: room.image
              )
            ),
                ),
          ),

          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 15, right: 10),
                child: Text(
                  post.description,
                  style: textStyleBold,
                ),
              )
            ],
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
