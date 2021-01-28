
import 'package:flutter/material.dart';

class Room {
  AssetImage image;
  String description;
  String channelId;
  bool isLive;

  Room(this.image, this.description, this.channelId, this.isLive);
}