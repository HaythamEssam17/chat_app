import 'package:chat_app/Widgets/commonDraggableBottomSheetwidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'chatPage.dart';
import 'contactsHomePage.dart';

class ChatListHomePage extends StatefulWidget {
  final bool isToGroup;
  ChatListHomePage(this.isToGroup);
  @override
  State<StatefulWidget> createState() => _ChatListHomePageState();
}

class _ChatListHomePageState extends State<ChatListHomePage>
    with SingleTickerProviderStateMixin {
  // AnimationController _controller;
  // Duration _duration = Duration(milliseconds: 500);
  // Tween<Offset> _tween = Tween(begin: Offset(0, 1), end: Offset(0, 0));
  FirebaseFirestore firebaseInstance = FirebaseFirestore.instance;

  // bool isToGroup = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _controller = AnimationController(vsync: this, duration: _duration);
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Chat List'),
      //   automaticallyImplyLeading: false,
      //   actions: [
      //     FlatButton(
      //         onPressed: () {
      //           setState(() {
      //             isToGroup = true;
      //             _controller.reverse();
      //             _controller.forward();
      //           });
      //         },
      //         child: Text('Add Group')),
      //   ],
      // ),
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.white,
        child: Stack(
          children: [
            chatList(),
            // SizedBox.expand(
            //   child: SlideTransition(
            //     position: _tween.animate(_controller),
            //     child: CommonDraggableBottomSheetwidget
            //         .customDraggableBottomSheet([
            //       Container(
            //         color: Colors.white,
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Text('Contacts List',
            //                 style: TextStyle(
            //                     fontSize: 20.0, fontWeight: FontWeight.bold)),
            //             FlatButton(
            //                 onPressed: () {
            //                   _controller.reverse();
            //                 },
            //                 child: Icon(Icons.cancel))
            //           ],
            //         ),
            //       ),
            //       Divider(),
            //       Container(
            //         height: size.height * 0.8,
            //         child: ContactsHomePage(
            //           isToAddGroup: isToGroup,
            //         ),
            //       )
            //     ]),
            //   ),
            // ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       isToGroup = false;
      //       // _controller.reverse();
      //       _controller.forward();
      //     });
      //   },
      //   child: Icon(Icons.contacts),
      // ),
    );
  }

  Widget chatList() {
    return StreamBuilder(
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center();
            break;
          default:
            if (snapshot.data.docs.length == 0) return Center();
            return ListView.builder(
              itemBuilder: (context, index) {
                String dt = widget.isToGroup
                    ? snapshot.data.docs[index]
                        .data()['groupTime']
                        .toDate()
                        .toString()
                    : snapshot.data.docs[index]
                        .data()['chatTime']
                        .toDate()
                        .toString();
                var formattedDate = DateTime.parse(dt);
                var format = new DateFormat('hh:mm a').format(formattedDate);

                var text = widget.isToGroup
                    ? snapshot.data.docs[index].data()['groupID']
                    : snapshot.data.docs[index].data()['chatRoomID'];

                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ChatPage(text, widget.isToGroup)));
                    },
                    title: Text(text),
                    trailing: Text(format.toString()),
                    leading: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Text((index + 1).toString()),
                    ),
                  ),
                );
              },
              itemCount: snapshot.data.docs.length,
            );
        }
      },
      stream: widget.isToGroup
          ? firebaseInstance
              .collection('GroupRooms')
              .orderBy('groupTime')
              .snapshots()
          : firebaseInstance
              .collection('ChatRooms')
              .orderBy('chatTime')
              .snapshots(),
    );
  }
}
