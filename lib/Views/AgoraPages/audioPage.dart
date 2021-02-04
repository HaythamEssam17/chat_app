import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:chat_app/Helpers/sharedTexts.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AudioPageState();
}

class AudioPageState extends State<AudioPage> {
  bool _joined = false;
  int _remoteUid = null;
  bool _switch = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    await [Permission.microphone].request();

    var engine = await RtcEngine.create(SharedTexts.appID);
    engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
      print('joinChannelSuccess $channel---$uid');
      setState(() {
        _joined = true;
      });
    }, userJoined: (int uid, int elapsed) {
      print('userJoined $uid');
      setState(() {
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      print('userOffline $uid');
      setState(() {
        _remoteUid = null;
      });
    }));
    // Join channel 123
    await engine.joinChannel(
        SharedTexts.token, SharedTexts.channedName, null, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agora Audio quickstart'),
      ),
      body: Center(
        child: Text('Please chat!'),
      ),
    );
  }
}
