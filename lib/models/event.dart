
import 'package:flutter/material.dart';

class Event {
  final ImageProvider image;
  final String datetime;
  final String headlines;
  final String description;

  Event(this.image, this.description, this.datetime, this.headlines);

  factory Event.fromJson(Map<String, dynamic> json) {
    ImageProvider image;
    if (json['image'].toString().startsWith("https")) {
      image = NetworkImage(json['image']);
    } else if (json['image'].toString().startsWith("assets")) {
      image = AssetImage(json['image']);
    } else {
      image = AssetImage("assets/images/header.png");
    }

    return Event(
      image,
      json['description'],
      json['datetime'],
      json['headlines']
    );
  }
}
