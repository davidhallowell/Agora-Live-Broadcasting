//import 'package:flutter/cupertino.dart';

class RemoteMessage {

  String message;
  String type;
  String username;
  int users;
  String image;
  String promote_link;
  String promote_text;
  bool hide_promote;
  String reaction;
  String role;


  RemoteMessage({this.type,this.message,this.username,this.users,this.image,this.promote_link,this.promote_text,this.hide_promote,this.reaction,this.role});

  factory RemoteMessage.fromJson(dynamic json) {
    String type = 'message';
    bool hide_promote = false;
    String role = 'viewer';

    if (json['new_join'] != null && json['new_join'].toString().isNotEmpty)
      type = 'new_join';
    else if (json['reaction'] != null && json['reaction'].toString().isNotEmpty)
      type = 'reaction';

    if (json['hide_promote'] != null && json['hide_promote'].toString().isNotEmpty && json['hide_promote'].toString() != 'false')
      hide_promote = true;

    if (json['dj'] != null && json['dj'].toString().isNotEmpty)
      role = 'dj';
    else if (json['voco'] != null && json['voco'].toString().isNotEmpty)
      role = 'vocalist';
    else if (json['director'] != null && json['director'].toString().isNotEmpty)
      role = 'director';

    return RemoteMessage(message: json['message'] as String,
        users: json['users'] as int,
        type: type,
        username: json['username_user'] as String,
        image: json['image'] as String,
        promote_link: json['promote_link'] as String,
        promote_text: json['promote_text'] as String,
        hide_promote: hide_promote,
        reaction: json['reaction'] as String,
        role: role
    );
  }
}