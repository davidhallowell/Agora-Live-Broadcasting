import 'dart:async';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:dapp_virtual/models/message.dart';
import 'package:dapp_virtual/screen/Loading.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/settings.dart';
import 'package:wakelock/wakelock.dart';
import 'dart:math' as math;
import 'package:dapp_virtual/screen/HeartAnim.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class JoinPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;
  final String channelId;
  final String username;
  final String hostImage;
  final String userImage;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  /// Creates a call page with given channel name.
  const JoinPage({Key key, this.channelName, this.channelId, this.username,this.hostImage,this.userImage,this.analytics,this.observer}) : super(key: key);
  @override
  _JoinPageState createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  static const String IOHOST = "https://dashboard.dapp.events:3456";
  IO.Socket socket;
  bool loading = true;
  bool completed = false;
  bool joined = false;
  static final _users = <int>[];
  bool muted = true;
  int userNo = 2;
  String promoteText;
  String promoteLink;
  var userMap ;
  bool heart = false;
  bool requested = false;
  String id_user = ""; // for socketio

  bool _isLogin = true;
  bool _isInChannel = true;

  final _channelMessageController = TextEditingController();

  final _infoStrings = <Message>[];

  AgoraRtmClient _client;
  AgoraRtmChannel _channel;

  //Love animation
  final _random = math.Random();
  Timer _timer;
  double height = 0.0;
  int _numConfetti = 10;
  var len;
  bool accepted = false;
  bool stop = false;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
    userMap = {widget.username: widget.userImage};
    _createClient();
  }

  Future<void> initialize() async {
    // socket = IO.io(IOHOST, {'transports': ['websocket'] });
    // debugPrint("A");
    // socket.connect();
    // debugPrint(socket.connected.toString());
    // socket.onConnect((_) {
    //   debugPrint('connect');
    //   setState(() {
    //     id_user=socket.id;
    //   });
    //   socket.emit('roomJoin', {
    //     'room': widget.channelId,
    //     'new_join': widget.username,
    //     'image': widget.userImage,
    //     'id_user': id_user,
    //   });
    // });
    // socket.on('receiveMessage', (message) {
    //   //TODO
    //   int count;
    //   if (message.users != null) {
    //     count = message.users.toInt();
    //     setState(() {
    //       userNo=count;
    //     });
    //     message.users = null;
    //   }
    //   if (message.promote_link != null && message.promote_text != null) {
    //     setState(() {
    //       promoteText = message.promote_text;
    //       promoteLink = message.promote_link;
    //     });
    //     message.promote_text = null;
    //   } else if (message.hide_promote != null) {
    //     setState(() {
    //       promoteText = null;
    //       promoteLink = null;
    //     });
    //     message.hide_promote = null;
    //   }
    //   if (message.reaction != null) {
    //
    //   }
    //   if (message.new_join != null) {
    //     if(message.new_join == widget.username || message.new__join.toString().length < 3) {
    //       //return;
    //     }
    //
    //   }
    // });
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    AgoraRtcEngine.setClientRole(ClientRole.Audience);
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    // await AgoraRtcEngine.setParameters(
    //     '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await AgoraRtcEngine.joinChannel(null, widget.channelId, null, 0);

  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
    AgoraRtcEngine.setLogFilter(5);
    await AgoraRtcEngine.enableVideo();
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {


    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      debugPrint("onJoinChannelSuccess $channel");
      Wakelock.enable();
      setState(() {
        joined = true;
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      debugPrint('onUserJoined $uid');
      setState(() {
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        _users.remove(uid);
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget>  list = [];
    //user.add(widget.channelId);
    _users.forEach((int uid) {

     // Limit to DJ only TODO add vocalist
     if(uid == 1) {
       list.add(AgoraRenderWidget(uid));
     }
      //}
    });
    if(list.isEmpty) {

      setState(() {
        loading=true;
      });
    }
    else{
      setState(() {
        loading=false;
      });
    }

    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: AspectRatio(aspectRatio: 16/9, child: ClipRRect(child: view)));
  }


  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();

    return Expanded(
      child: OrientationBuilder(
          builder: (context, orientation) {
            double padding = orientation == Orientation.portrait ? 50.0 : 0;
            return Padding(
                padding: EdgeInsets.only(top: padding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: wrappedViews,
                )
            );
          }
      )
    );
  }


  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();

    switch (views.length) {
      case 0:
        return (!joined)?
        LoadingPage() : Container(
               child: Container(
                 alignment: Alignment.center,
                 padding: EdgeInsets.all(10),
                 //color: Color(0xFF003399),
                 child: Text("Attualmente non ci sono artisti qui, seguici su instagram su @dapp.events per rimanere aggiornato!",
                   style: TextStyle(
                     fontFamily: "Helvetica",
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                )
          );
      case 1:
        return (loading==true)&&(completed==false)?
        //LoadingPage()
        LoadingPage()
            :Container(
            child: Column(
              children: <Widget>[_expandedVideoRow([views[0]])],
            ));
      case 2:
        return (loading==true)&&(completed==false)?
        //LoadingPage()
        LoadingPage()
            :Container(
            child: Column(
              children: <Widget>[
                _expandedVideoRow([views[0]]),
                _expandedVideoRow([views[1]])
              ],
            ));
    }
    return Container();

  }

  void popUp() async{
    setState(() {
      heart=true;
    });
    Timer(Duration(seconds: 4), () =>
    {
      _timer.cancel(),
      setState(() {
        heart=false;
      })
    });
    _timer = Timer.periodic(Duration(milliseconds: 125), (Timer t) {
      setState(() {
        height += _random.nextInt(20);
      });
    });
  }

  Widget heartPop(){
    final size = MediaQuery.of(context).size;
    final confetti = <Widget>[];
    for (var i = 0; i < _numConfetti; i++) {
      final height = _random.nextInt(size.height.floor());
      final width = 20;
      confetti.add(HeartAnim(height.toDouble(),
          width.toDouble(),1));
    }


    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom:20),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            height: 400,
            width: 200,
            child: Stack(
              children: confetti,
            ),
          ),
        ),
      ),
    );
  }


  /// Info panel to show logs
  Widget _messageList() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: (_infoStrings[index].type=='join')? Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: _infoStrings[index].image,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const  EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        child: Text(
                          '${_infoStrings[index].user} joined',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ):
                (_infoStrings[index].type=='message')?
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: _infoStrings[index].image,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const  EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            child: Text(
                              _infoStrings[index].user,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          SizedBox(height: 5,),
                          Padding(
                            padding: const  EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            child: Text(
                              _infoStrings[index].message,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
                    :null,
              );
            },
          ),
        ),
      ),
    );
  }


  Future<bool> _willPopCallback() async {
    await Wakelock.disable();
    _leaveChannel();
    _logout();
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    return true;
    // return true if the route to be popped
  }

  Widget _ending(){
    return Container(
      color: Colors.black.withOpacity(.7),
      child: Center(
        child: Container(
          width: double.infinity,
          color: Colors.grey[700],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text('The live event has ended',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ),
        )
      ),
    );
  }

  Widget _liveText(){
    return Container(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.indigo, Colors.blue
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(4.0))
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 8.0),
                  child: Text('LIVE',style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:5),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.6),
                        borderRadius: BorderRadius.all(Radius.circular(4.0))
                    ),
                    height: 28,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(FontAwesomeIcons.eye,color: Colors.white,size: 13,),
                          SizedBox(width: 5,),
                          Text('$userNo',style: TextStyle(color: Colors.white,fontSize: 11),),
                        ],
                      ),
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _username(){
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                child: Row(
                  children: <Widget>[
                    FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
                    Image.asset(
                      'assets/images/icon.png',
                      width: 32.0,
                      height: 32.0,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 8.0),
              child: Text(
                '${widget.channelName}',
                style: TextStyle(
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(0, 1.3),
                      ),
                    ],
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void stopFunction() async{
    await AgoraRtcEngine.enableLocalVideo(!muted);
    await AgoraRtcEngine.enableLocalAudio(!muted);
    setState(() {
      accepted= false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child:SafeArea(
          child: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/dj.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: (completed==true)?_ending():Stack(
                children: <Widget>[
                  _viewRows(),
                  if(completed==false)_bottomBar(),
                  _username(),
                  _liveText(),
                  if(completed==false)_messageList(),
                  if(heart == true && completed==false) heartPop(),

                  //_ending()
                ],
              ),
            ),
          ),
        ),
        onWillPop: _willPopCallback
    );
  }
  // Agora RTM


  Widget _bottomBar() {
    if (!_isLogin || !_isInChannel) {
      return Container();
    }
    return Container(
      alignment: Alignment.bottomRight,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(left:8,top:5,right: 8,bottom: 5),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0,0,0,0),
                      child: new TextField(
                          cursorColor: Colors.blue,
                          textInputAction: TextInputAction.go,
                          onSubmitted: _sendMessage,
                          style: TextStyle(color: Colors.white,),
                          controller: _channelMessageController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Comment',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide: BorderSide(color: Colors.white)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide: BorderSide(color: Colors.white)
                            ),
                          )
                      ),
                    )
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                  child: MaterialButton(
                    minWidth: 0,
                    onPressed: _toggleSendChannelMessage,
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    color: Colors.blue[400],
                    padding: const EdgeInsets.all(12.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: MaterialButton(
                    minWidth: 0,
                    onPressed: ()
                    async{
                      popUp();
                    await _channel.sendMessage(AgoraRtmMessage.fromText('m1x2y3z4p5t6l7k8'));
                    },
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    padding: const EdgeInsets.all(12.0),
                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }

  void _logout() async {
    try {
      await _client.logout();
     // _log('Logout success.');
    } catch (errorCode) {
      //_log('Logout error: ' + errorCode.toString());
    }
  }


  void _leaveChannel() async {
    try {
      await _channel.leave();
      //_log('Leave channel success.');
      _client.releaseChannel(_channel.channelId);
      _channelMessageController.text = null;

    } catch (errorCode) {
      //_log('Leave channel error: ' + errorCode.toString());
    }
  }

  void _toggleSendChannelMessage() async {
    String text = _channelMessageController.text;
    if (text.isEmpty) {
      return;
    }
    try {
      _channelMessageController.clear();
      await _channel.sendMessage(AgoraRtmMessage.fromText(text));
      _log(user: widget.username, info: text,type: 'message');
    } catch (errorCode) {
      //_log('Send channel message error: ' + errorCode.toString());
    }
  }

  void _sendMessage(text) async {
    if (text.isEmpty) {
      return;
    }
    try {
      _channelMessageController.clear();
      socket.emit('messageRoomSend', {
        'room': widget.channelId,
        'username_user': widget.username,
        'image': widget.userImage,
        'message': text,
        'id_user': id_user
      });
      _log(user: widget.channelName, info:text,type: 'message');
    } catch (errorCode) {
      //_log('Send channel message error: ' + errorCode.toString());
    }
  }

  void _createClient() async {
    _client =
    await AgoraRtmClient.createInstance('b42ce8d86225475c9558e478f1ed4e8e');
    _client.onMessageReceived = (AgoraRtmMessage message, String peerId)  async{
      var img = Image.asset('assets/images/icon.png', width: 32.0, height: 32.0);
      userMap.putIfAbsent(peerId, () => img);
      _log(user: peerId, info: message.text, type: 'message');
    };
    _client.onConnectionStateChanged = (int state, int reason) {
      if (state == 5) {
        _client.logout();
       // _log('Logout.');
        setState(() {
          _isLogin = false;
        });
      }
    };
    await _client.login(null, widget.username );
    _channel = await _createChannel(widget.channelName);
    await _channel.join();
    var len;
    _channel.getMembers().then((value) {
      len = value.length;
      setState(() {
        //userNo= len ;
      });
    });


  }

  Future<AgoraRtmChannel> _createChannel(String name) async {
    AgoraRtmChannel channel = await _client.createChannel(name);
    channel.onMemberJoined = (AgoraRtmMember member) async{
      var img = Image.asset('assets/images/icon.png', width: 32.0, height: 32.0);
      userMap.putIfAbsent(member.userId, () => img);

      _channel.getMembers().then((value) {
        len = value.length;
        setState(() {
          //userNo= len ;
        });
      });

      _log(info: 'Member joined: ',  user: member.userId,type: 'join');
    };
    channel.onMemberLeft = (AgoraRtmMember member) {
      var len;
      _channel.getMembers().then((value) {
        len = value.length;
        setState(() {
          //userNo= len ;
        });
      });

    };
    channel.onMessageReceived =
        (AgoraRtmMessage message, AgoraRtmMember member) async {
          var img = Image.asset('assets/images/icon.png', width: 32.0, height: 32.0);
          userMap.putIfAbsent(member.userId, () => img);
          _log(user: member.userId, info: message.text, type: 'message');
    };
    return channel;
  }

  void _log({String info,String type,String user}) {
    if(type=='message' && info.contains('m1x2y3z4p5t6l7k8')){
      popUp();
    }
    else if(type=='message' && info.contains('E1m2I3l4i5E6')){
      stopFunction();
    }
    else {
      Message m;
      var image = userMap[user];
      if(info.contains('d1a2v3i4s5h6')){
        var mess = info.split(' ');
        if(mess[1]==widget.username){
          /*m = new Message(
              message: 'working', type: type, user: user, image: image);*/
          setState(() {
            //_infoStrings.insert(0, m);
            requested = true;
          });
        }
      }
      else {
        m = new Message(
            message: info, type: type, user: user, image: image);
        setState(() {
          _infoStrings.insert(0, m);
        });
      }
    }
  }
  void _msg({String message,String type,String user,String image}) {
    if(type=='new_join'){
      // show join
    } else if(type=='react') {
      // heart
    } else if(type=='promo') {
      // set promo banner
    }
    else {
      Message m;
      var image = userMap[user];
      if(user==widget.username){
        /*m = new Message(
            message: 'working', type: type, user: user, image: image);*/
        setState(() {
          //_infoStrings.insert(0, m);
          requested = true;
        });
      }
      else {
        m = new Message(
            message: message, type: type, user: user, image: image);
        setState(() {
          _infoStrings.insert(0, m);
        });
      }
    }
  }
}

