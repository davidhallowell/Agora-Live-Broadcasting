import 'dart:convert';

import 'package:dapp_virtual/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
  ],
);

class LoginScreen extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  LoginScreen({Key key, this.analytics,this.observer}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final FacebookLogin facebookSignIn = new FacebookLogin();
  var submitted = false;
  GoogleSignInAccount _currentGoogleUser;
  bool isLoggedInFB = false;
  String userEmail = "";
  String userName = "";
  String userImage = "";
  String _message = "Benvenuto in DAPP, effettua l'accesso per entrare nel mondo della notte";

  void _submit() async{

    setState(() {
      submitted = true;
    });
    final name = userName;
    final email = userEmail;
    final image = userImage;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('login', true);
    await prefs.setString('name', name);
    await prefs.setString('username', email);
    await prefs.setString('image', image);

    Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));

  }
  void _fbStatus() async{
    isLoggedInFB = await facebookSignIn.isLoggedIn;
  }
  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentGoogleUser = account;
        if (_currentGoogleUser != null) {
          setEmail(_currentGoogleUser.email);
          setName(_currentGoogleUser.displayName);
          setImage(_currentGoogleUser.photoUrl);
          _submit();
        }
        _fbStatus();
      });
    });
  }

  void setEmail(String email){
    if(email.isNotEmpty){
      setState(() {
        userEmail = email;
      });
    }
    else
      setState(() {
        userEmail = "";
      });
  }

  void setImage(String image){
    if(image.isNotEmpty){
      setState(() {
        userImage = image;
      });
    }
    else
      setState(() {
        userImage = "";
      });
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleFacebookSignIn() async {
    final result = await facebookSignIn.logIn(['email']);
    final token = result.accessToken.token;
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
    Map profileMap = jsonDecode(graphResponse.body);
    User profile = User.fromJson(profileMap);
    setName(profile.name);
    setEmail(profile.username);
    setImage(profile.image);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        _showMessage('''
         Logged in!
         
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');

        _submit();
        break;
      case FacebookLoginStatus.cancelledByUser:
        _showMessage('Login cancelled by the user.');
        break;
      case FacebookLoginStatus.error:
        _showMessage('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
      default:
        debugPrint("WTF");
    }
  }
  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  void setName(String name){
    if(name.isNotEmpty){
      setState(() {
        userName = name;
      });
    }
    else
      setState(() {
        userName = "";
      });

  }

  @override
  Widget build(BuildContext context) {
    // logout existing when loading this screen
    if (_currentGoogleUser != null) {
      _googleSignIn.signOut();
    }

    // if (isLoggedInFB) {
    //   facebookSignIn.logOut();
    // }

    return Scaffold(
      backgroundColor: Color(0xFF003399),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height -45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/lightLogo.png'),
                  SizedBox(height: 13,),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Text(_message, style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(height: 10,),
                      SignInWithAppleButton(
                        style: SignInWithAppleButtonStyle.white,
                        onPressed: () async {
                          final credential = await SignInWithApple.getAppleIDCredential(
                              scopes: [
                                AppleIDAuthorizationScopes.email,
                                AppleIDAuthorizationScopes.fullName
                              ],
                              webAuthenticationOptions: WebAuthenticationOptions(
                                  clientId: "events.dapp.virtual",
                                  redirectUri: Uri.parse("https://dashboard.dapp.events/auth-api/apple-auth.php"),
                              ),
                          );
                          final signInWithAppleEndpoint = Uri(
                            scheme: 'https',
                            host: 'dashboard.dapp.events',
                            path: '/auth-api/apple-auth.php',
                            queryParameters: <String, String>{
                              'code': credential.authorizationCode,
                              'firstName': credential.givenName,
                              'lastName': credential.familyName,
                            },
                          );

                          final session = await http.Client().post(
                            signInWithAppleEndpoint,
                          );

                          //_showMessage(session.toString());
                          _submit();
                        }
                      ),
                      SizedBox(height: 5,),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                        onPressed: _handleGoogleSignIn,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          height: 44,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: (28 / 44) * 44,
                                  height: (28 / 44) * 44 + 2,
                                  padding: EdgeInsets.only(
                                    // Properly aligns the icon with the text of the button
                                    bottom: (4 / 44) * 44,
                                    right: 15,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: (44 * 0.43) * (25 / 31),
                                      height: (44 * 0.43),
                                      child: FaIcon(FontAwesomeIcons.google, color: Colors.black,),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    'Sign In with Google',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      inherit: false,
                                      fontSize: 44 * 0.43, // 44 is height
                                      color: Colors.black,
                                      fontFamily: '.SF Pro Text',
                                      letterSpacing: -0.41,
                                    ),
                                  ),
                                ),
                              ]
                          ),
                        ),
                      ),
                      SizedBox(height: 5,),
                      CupertinoButton(
                          padding: EdgeInsets.zero,
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                          onPressed: _handleFacebookSignIn,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            height: 44,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: (28 / 44) * 44,
                                  height: (28 / 44) * 44 + 2,
                                  padding: EdgeInsets.only(
                                    // Properly aligns the icon with the text of the button
                                    bottom: (4 / 44) * 44,
                                    right: 15,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: (44 * 0.43) * (25 / 31),
                                      height: (44 * 0.43),
                                      child: FaIcon(FontAwesomeIcons.facebook, color: Colors.black,),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    'Sign In with Facebook',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      inherit: false,
                                      fontSize: 44 * 0.43, // 44 is height
                                      color: Colors.black,
                                      fontFamily: '.SF Pro Text',
                                      letterSpacing: -0.41,
                                    ),
                                  ),
                                ),
                              ]
                            ),
                          ),
                      ),
                      SizedBox(height: 20.0),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
