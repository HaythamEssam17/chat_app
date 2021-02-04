import 'dart:typed_data';

import 'package:chat_app/Helpers/sharedTexts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';

import 'chatPage.dart';

class ChatListHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChatListHomePageState();
}

class _ChatListHomePageState extends State<ChatListHomePage> {
  List<Contact> listContacts;
  bool isInstalled = false;
  FirebaseFirestore firebaseInstance = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    listContacts = new List();
    readContacts();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat List'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.white,
        child: StreamBuilder(
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: new CircularProgressIndicator());
                break;
              default:
                // if (snapshot.data.docs.length == 0)
                //   return Center(
                //       child: Text('You Don\'t Have Any ChatRooms Yet!'));
                return ListView.builder(
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ChatPage(snapshot
                                    .data.docs[index]
                                    .data()['chatRoomID'])));
                      },
                      title:
                          Text(snapshot.data.docs[index].data()['chatRoomID']),
                      trailing: Icon(Icons.arrow_forward_ios),
                      leading: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Text((index + 1).toString()),
                      ),
                    ),
                  ),
                  itemCount: snapshot.data.docs.length,
                );
            }
          },
          stream: firebaseInstance
              .collection('ChatRooms')
              .orderBy('chatTime')
              .snapshots(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalSheet();
        },
        child: Icon(Icons.contacts),
      ),
    );
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.undetermined;
    } else {
      return permission;
    }
  }

  Future readContacts() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      listContacts.clear();
      setState(() {
        Contacts.streamContacts().forEach((Contact contact) {
          print("${contact.displayName}");
          // setState(() {
          listContacts.add(contact);
          // });
        }).whenComplete(() {
          getIsAppInstalled();
        });
      });
    }
  }

  Future<bool> getIsAppInstalled() async {
    isInstalled = await DeviceApps.isAppInstalled('com.codeforegypt.chat_app');
    return isInstalled;
  }

  showModalSheet() {
    Size size = MediaQuery.of(context).size;
    showMaterialModalBottomSheet(
      context: context,
      expand: false,
      bounce: true,
      builder: (context) => Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: size.height * 0.1,
              width: size.width,
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Contacts List',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'))
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  bool haveAvatar = listContacts[index].hasAvatar;
                  String avatar = '';
                  var outputAsUint8List;

                  if (haveAvatar) {
                    avatar = String.fromCharCodes(listContacts[index].avatar);
                    outputAsUint8List =
                        new Uint8List.fromList(avatar.codeUnits);
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Row(
                          children: [
                            haveAvatar
                                // ? Text('Done')
                                ? CircleAvatar(
                                    backgroundImage:
                                        MemoryImage(outputAsUint8List),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.blue[300],
                                    child: Text('${index + 1}',
                                        style: TextStyle(color: Colors.black)),
                                  ),
                            Expanded(
                                child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(listContacts[index].displayName,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            )),
                            FlatButton(
                                onPressed: () {
                                  String chatRoomID = SharedTexts.userName +
                                      '_' +
                                      listContacts[index].displayName;
                                  List<String> users = [
                                    SharedTexts.userName,
                                    listContacts[index].displayName
                                  ];
                                  Map<String, dynamic> chatRoom = {
                                    "ChatUsers": users,
                                    "chatRoomID": chatRoomID,
                                    "chatTime":
                                        DateTime.now().millisecondsSinceEpoch
                                  };

                                  firebaseInstance
                                      .collection("ChatRooms")
                                      .doc(chatRoomID)
                                      .set(chatRoom)
                                      .catchError((e) {
                                    print(e);
                                  });
                                  Navigator.pop(context);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ChatPage(chatRoomID)));
                                },
                                child: Text('Chat'),
                                color: Colors.green,
                                textColor: Colors.white)
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  );
                },
                itemCount: listContacts.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
