import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:dapp_virtual/widgets/drawer.dart';
import 'package:mime/mime.dart';
import 'package:dapp_virtual/main.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class Profile extends StatefulWidget {
  static final String id = 'login_screen';
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  Profile({Key key, this.analytics,this.observer}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File _imagelocal;
  bool submitted=false;
  String name;
  String image;
  String imagelocal;
  BuildContext context;

  final _nameController = TextEditingController();

  bool changed=false, imgchanged =false;

  void _submit() async{
    setState(() {
      submitted=true;
    });
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;
    final name = _nameController.text.toString().trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    if(_imagelocal != null && _imagelocal.existsSync()) {
      final fileName = basename(_imagelocal.path);
      final File newImage = await _imagelocal.copy('$path/$fileName');
      debugPrint('$path/$fileName');
      await prefs.setString('imagelocal', newImage.path);
    }
    setState(() {
      submitted=false;
      changed = false;
      imgchanged = false;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
  }

  void imageDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: Colors.grey[800],
              ),
              height: 190,
              child: Column(
                children: [
                  Container(
                    height: 140,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 30,right: 30),
                          child: Text('Select Image',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                            textAlign: TextAlign.center,),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30,right: 25,top: 15),
                          child: Text(
                            "Image is not selected for avatar.",
                            style: TextStyle(color: Colors.white60),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey,thickness: 0,height: 0,),
                  SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text('Try Again',style: TextStyle(color: Colors.white),),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    loadSharedPref();
    _nameController.addListener(setName);
  }

  Future<void> loadSharedPref() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      imagelocal = prefs.getString('imagelocal');
      _imagelocal = File(imagelocal);
      name = prefs.getString('name');
      _nameController.text = name;
      image = prefs.getString('image');

    });
  }

  void setName(){
    if(_nameController.text.toString().trim() == name){
      setState(() {
        changed=false;
      });
    }
    else
      setState(() {
        changed=true;
      });

  }

  @override
  Widget build(BuildContext context) {
    Image chosenImage;
    if (_imagelocal != null && _imagelocal.existsSync()) {
      chosenImage = Image.file(_imagelocal);
    } else if (image != null && image.isNotEmpty) {
      chosenImage = Image.network(image);
    } else {
      chosenImage = Image.asset('assets/images/dummy.png');
    }
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
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height -110,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                   GestureDetector(
                    onTap:() {
                      chooseFile();
                    },
                    child:Container(
                      height: 150,
                      width: 150,
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                          backgroundImage:  chosenImage.image,
                      ),
                    ),
                  ),
                  SizedBox(height: 13,),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 5.0,
                        ),
                        child: TextField(
                          controller: _nameController,
                          cursorColor: Colors.white,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            fillColor: Colors.grey[700],
                            filled: true,
                            hintText: 'Nome da visualizzare',
                            hintStyle: TextStyle(color: Colors.white,fontSize: 13),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 30,vertical: 5),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          onPressed: (changed || imgchanged) ?_submit : null,
                          color: Colors.blue,
                          disabledColor: Colors.green,
                          disabledTextColor: Colors.black45,
                          textColor: Colors.white,
                          padding: EdgeInsets.all(15.0),
                          child: submitted ? SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              :Text(
                            'Salva',
                            style: TextStyle(
                              fontSize: 13.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: AppDrawer(),
    );
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 150, maxWidth: 150, imageQuality: 75).then((imagefile) {

      setState(() {
        _imagelocal = imagefile;
        imgchanged = true;
      });
    });
  }

}
