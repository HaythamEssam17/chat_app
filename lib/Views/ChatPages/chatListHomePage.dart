import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'chatPage.dart';

class ChatListHomePage extends StatefulWidget {
  final bool isToGroup;
  ChatListHomePage(this.isToGroup);
  @override
  State<StatefulWidget> createState() => _ChatListHomePageState();
}

class _ChatListHomePageState extends State<ChatListHomePage>
    with SingleTickerProviderStateMixin {
  FirebaseFirestore firebaseInstance = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: Container(
            height: size.height,
            width: size.width,
            color: Colors.white,
            child: Stack(children: [
              chatList(),
            ])));
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
                              builder: (_) => ChatPage(
                                  chatRoomID: text,
                                  isGroup: widget.isToGroup)));
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
