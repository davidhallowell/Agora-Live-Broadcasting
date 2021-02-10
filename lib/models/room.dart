
import 'package:flutter/material.dart';

class Room {
  final ImageProvider image;
  final String description;
  final String channelId;
  final bool isLive;

  Room(this.image, this.description, this.channelId, this.isLive);

  factory Room.fromJson(Map<String, dynamic> json) {
    ImageProvider image_tile;
    if (json['image_tile'].toString().startsWith("https")) {
      image_tile = NetworkImage(json['image_tile']);
    } else if (json['image_tile'].toString().startsWith("assets")) {
      image_tile = AssetImage(json['image_tile']);
    } else {
      image_tile = AssetImage("assets/images/room-1-def.png");
    }

    return Room(
      image_tile,
      json['room_name'],
      json['uuid'],
      true
    );
  }
}
