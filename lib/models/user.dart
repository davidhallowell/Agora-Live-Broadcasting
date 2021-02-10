
import 'package:flutter/material.dart';

class User {
  String username;
  String image;
  String name;

  User.fromJson(Map<String, dynamic> json) :
      name = json['name'],
      username = json['email'],
      image = json['picture']['data']['url'];

  User({this.username, this.name, this.image});
}