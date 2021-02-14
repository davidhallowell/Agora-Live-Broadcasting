import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'room.dart';
import 'event.dart';
import 'dart:convert';


TextStyle textStyle = new TextStyle(fontFamily: 'Gotham',color: Colors.white);
TextStyle textStyleBold = new TextStyle(fontFamily: 'Gotham', fontWeight: FontWeight.bold, color: Colors.white);
TextStyle textStyleLigthGrey = new TextStyle(fontFamily: 'Gotham', color: Colors.grey);

Future<List<Room>> fetchRooms() async {
  final response = await http.get('https://dashboard.dapp.events/clubsapi/venue/13/rooms');

  List<Room> rooms = new List();

  if (response.statusCode == 200) {
    List<dynamic> roomlist = json.decode(response.body);

    roomlist.forEach((value) {
      rooms.add(Room.fromJson(value));
    });
    return rooms;

  } else {
    log("FAIL HTTP");
    return defaultRooms;
  }
}

Future<Event> fetchEvent() async {
  final response = await http.get('https://dashboard.dapp.events/clubsapi/venue/13/nextevent');
  Event event;

  if (response.statusCode == 200)  {
    List<dynamic> eventjson = json.decode(response.body);
    event = Event.fromJson(eventjson[0]);
    return event;
  } else {
    log("FAIL HTTP");
  }
  return null;
}

List<Room> defaultRooms = [
  new Room(new AssetImage('assets/images/room-1.png'), 'COMMERCIALE', '16da33854b2036f4d0327c4f72f23b97', true),
  new Room(new AssetImage('assets/images/room-2.png'), 'TECHNO', 'f084ebd4001d20a008095c2bafbebe73', true),
  new Room(new AssetImage('assets/images/room-3.png'), 'HOUSE', 'c1de1fe0e47135f3aff9e7fcdc81944a', true),
  new Room(new AssetImage('assets/images/room-4.png'), 'TRAP GOA', '1124a6b887d236ad4e1a6b7022370e1b', false),
  new Room(new AssetImage('assets/images/room-5.jpeg'), 'DEV+TEST', '424dee2d01fe71fe9a76c97910d6c75c', true),
  new Room(new AssetImage('assets/images/room-6.png'), 'VIP', '424dee2d01fe71fe9a76c97910d6c7ae', false),];

 String title = "DAPP";