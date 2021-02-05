import 'package:chat_app/Widgets/commonDraggableBottomSheetwidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chatListHomePage.dart';
import 'contactsHomePage.dart';

class ChatTabBarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatTabBarPageState();
}

class ChatTabBarPageState extends State<ChatTabBarPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Duration _duration = Duration(milliseconds: 500);
  Tween<Offset> _tween = Tween(begin: Offset(0, 1), end: Offset(0, 0));
  FirebaseFirestore firebaseInstance = FirebaseFirestore.instance;

  bool isToGroup = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat List'),
          automaticallyImplyLeading: false,
          actions: [
            FlatButton(
                onPressed: () {
                  setState(() {
                    isToGroup = true;
                    _controller.reverse();
                    _controller.forward();
                  });
                },
                child: Text('Add Group')),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Chats'),
              Tab(text: 'Groups'),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                ChatListHomePage(false),
                ChatListHomePage(true),
              ],
            ),
            SizedBox.expand(
              child: SlideTransition(
                position: _tween.animate(_controller),
                child: CommonDraggableBottomSheetwidget
                    .customDraggableBottomSheet([
                  Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Contacts List',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold)),
                        FlatButton(
                            onPressed: () {
                              _controller.reverse();
                            },
                            child: Icon(Icons.cancel))
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: ContactsHomePage(
                      isToAddGroup: isToGroup,
                    ),
                  )
                ]),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              isToGroup = false;
              // _controller.reverse();
              _controller.forward();
            });
          },
          child: Icon(Icons.contacts),
        ),
      ),
    );
  }
}
