import 'package:chat_app/Helpers/sharedTexts.dart';
import 'package:chat_app/Views/AgoraPages/audioPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String chatRoomID;
  ChatPage(this.chatRoomID);

  @override
  State<StatefulWidget> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  FirebaseFirestore firebaseInstance = FirebaseFirestore.instance;
  TextEditingController messageController = TextEditingController();

  addNewMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": SharedTexts.userName,
        "message": messageController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      firebaseInstance
          .collection("ChatRooms")
          .doc(widget.chatRoomID)
          .collection("Chats")
          .add(chatMessageMap);

      setState(() {
        messageController.text = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Page'),
        actions: [
          IconButton(
              icon: Icon(Icons.call),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => AudioPage()));
              })
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: chatMessages()),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                    ),
                  ),
                  SizedBox(width: 20.0),
                  IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        addNewMessage();
                      })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: firebaseInstance
          .collection("ChatRooms")
          .doc(widget.chatRoomID)
          .collection("Chats")
          .orderBy('time')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
            break;
          default:
            return ListView.builder(
              itemBuilder: (context, index) {
                bool isMyMessage = snapshot.data.docs[index].data()['sendBy'] ==
                        SharedTexts.userName ??
                    false;
                String message = snapshot.data.docs[index].data()['message'];

                return Padding(
                  padding: EdgeInsets.all(10.0),
                  child: buildMessageRow(message, current: isMyMessage),
                );
              },
              itemCount: snapshot.data.docs.length,
            );
        }
      },
    );
  }

  Widget messageBox(String sendBy, String message) {
    bool isMyMessage = sendBy == SharedTexts.userName ?? false;

    return Container(
      height: 100.0,
      width: 100.0,
      decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.only(
            bottomLeft:
                isMyMessage ? Radius.circular(100.0) : Radius.circular(0.0),
            bottomRight:
                isMyMessage ? Radius.circular(0.0) : Radius.circular(100.0),
          )),
    );
  }

  Row buildMessageRow(String message, {bool current}) {
    Size size = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment:
          current ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment:
          current ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: current ? 30.0 : 20.0),

        ///Chat bubbles
        Container(
          padding: EdgeInsets.only(
            bottom: 5,
            right: 5,
          ),
          child: Column(
            crossAxisAlignment:
                current ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                    minHeight: 40,
                    maxHeight: 250,
                    maxWidth: size.width * 0.5,
                    minWidth: size.width * 0.1),
                decoration: BoxDecoration(
                  color: current ? Colors.blue[100] : Colors.red,
                  borderRadius: current
                      ? BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          topRight: Radius.circular(20))
                      : BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                          topRight: Radius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 15, top: 10, bottom: 5, right: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: current
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Text(message),
                      ),
                      Icon(Icons.done_all, color: Colors.white)
                    ],
                  ),
                ),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
        SizedBox(width: current ? 20.0 : 30.0),
      ],
    );
  }
}
