import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';

String version;
String appName;

Future<Void> getInfo() async{
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  appName = packageInfo.appName;
  version = packageInfo.version;
}



class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    getInfo();
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo512.png',
                ),
                Text("$appName - v$version", style: TextStyle(color: Colors.white),),
              ],
            ),
            decoration: BoxDecoration(
              color: Color(0xFF003399),
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              // Update the state of the app
              Navigator.pushReplacementNamed(context, '/HomePage');
              // Then close the drawer
            },
          ),
          ListTile(
            title: Text('Eventi live'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/Foyer');
            },
          ),
          ListTile(
            title: Text('Profile'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/Profile');
            },
          ),
          ListTile(
            title: Text('Log out'),
            onTap: () async {
              // Update the state of the app
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('login', false);
              Navigator.pushReplacementNamed(context, '/HomeScreen');
            },
          ),
          ListTile(
            title: Text('About $appName'),
            onTap: () {
              // Update the state of the app
              Navigator.pushReplacementNamed(context, '/About');
            },
          ),
          ListTile(
            title: Text('Help'),
            onTap: () {
              // Update the state of the app
              Navigator.pushReplacementNamed(context, '/Help');
            },
          ),
        ],
      ),
    );
  }
}