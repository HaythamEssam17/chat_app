import 'dart:typed_data';

import 'package:chat_app/Helpers/sharedTexts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:permission_handler/permission_handler.dart';

import 'chatPage.dart';

class ContactsHomePage extends StatefulWidget {
  final bool isToAddGroup;
  ContactsHomePage({this.isToAddGroup});

  @override
  State<StatefulWidget> createState() => ContactsHomePageState();
}

class ContactsHomePageState extends State<ContactsHomePage> {
  TextEditingController groupIDController;
  final firebaseInstance = FirebaseFirestore.instance;
  bool isContactsLoaded = false;
  // List<String> groupList = [];

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
    setState(() {
      isContactsLoaded = false;
      // groupList.clear();
      SharedTexts.groupList.clear();
    });

    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      setState(() {
        Contacts.streamContacts().forEach((Contact contact) {
          print("${contact.displayName}");
          SharedTexts.listContacts.add(contact);
        }).whenComplete(() {
          print('Contacts Done!!!');
          setState(() {
            isContactsLoaded = true;
          });
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    groupIDController = new TextEditingController();

    readContacts();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: height,
        width: width,
        child: isContactsLoaded
            ? customContactsListView()
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget customContactsListView() {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        if (SharedTexts.groupList.length != 0)
          Container(
            height: 60.0,
            width: width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: TextField(
                  controller: groupIDController,
                  decoration: InputDecoration(hintText: 'Group Subject'),
                )),
                FlatButton(
                  onPressed: () {
                    if (SharedTexts.groupList.length != 0) {
                      addNewGroup().whenComplete(() {
                        // SharedTexts.groupList.clear();
                        // groupIDController.clear();
                      });
                    }
                  },
                  child: Text('create'),
                  minWidth: 30.0,
                ),
              ],
            ),
          ),
        if (SharedTexts.groupList.length != 0)
          Container(
            height: 80.0,
            width: width,
            color: Colors.grey[300],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => customListItem(index),
              itemCount: SharedTexts.groupList.length,
              shrinkWrap: true,
            ),
          ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              bool haveAvatar = SharedTexts.listContacts[index].hasAvatar;
              String avatar = '';
              var outputAsUint8List;

              if (haveAvatar) {
                avatar = String.fromCharCodes(
                    SharedTexts.listContacts[index].avatar);
                outputAsUint8List = new Uint8List.fromList(avatar.codeUnits);
              }

              return Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: Row(
                      children: [
                        haveAvatar
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(outputAsUint8List),
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.blue[300],
                                child: Text('${index + 1}',
                                    style: TextStyle(color: Colors.black))),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                                SharedTexts.listContacts[index].displayName,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        widget.isToAddGroup
                            ? customChatButton('add', () {
                                setState(() {
                                  if (!SharedTexts.groupList.contains(
                                      SharedTexts
                                          .listContacts[index].displayName))
                                    SharedTexts.groupList.add(SharedTexts
                                        .listContacts[index].displayName);
                                });
                              })
                            : customChatButton('chat', () {
                                addChatRoom(SharedTexts
                                    .listContacts[index].displayName);
                              }),
                      ],
                    ),
                  ),
                  Divider(),
                ],
              );
            },
            itemCount: SharedTexts.listContacts.length,
          ),
        ),
      ],
    );
  }

  Widget customChatButton(String text, Function onPressed) {
    return FlatButton(
        onPressed: onPressed,
        child: Text(text),
        color: Colors.green,
        textColor: Colors.white);
  }

  Widget customListItem(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            children: [
              Container(height: 0.0),
              Expanded(
                child: CircleAvatar(
                  child: Text((index + 1).toString()),
                ),
              ),
            ],
          ),
          Positioned(
            child: InkWell(
                onTap: () {
                  setState(() {
                    SharedTexts.groupList.removeAt(index);
                  });
                },
                child: Icon(Icons.cancel)),
            top: 5.0,
          )
        ],
      ),
    );
  }

  addChatRoom(String chatRoomID) {
    setState(() {
      List<String> users = [SharedTexts.userName, chatRoomID];
      Map<String, dynamic> chatRoom = {
        "ChatUsers": users,
        "chatRoomID": chatRoomID,
        "chatTime": DateTime.now()
      };

      firebaseInstance
          .collection("ChatRooms")
          .doc(chatRoomID)
          .set(chatRoom)
          .catchError((e) {
        print(e);
      });

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ChatPage(chatRoomID, false)));
    });
  }

  Future addNewGroup() async {
    setState(() {
      Map<String, dynamic> groupRoom = {
        "groupUsers": SharedTexts.groupList,
        "groupID": groupIDController.text,
        "groupTime": DateTime.now()
      };

      firebaseInstance
          .collection("GroupRooms")
          .doc(groupIDController.text)
          .set(groupRoom)
          .catchError((e) {
        print(e);
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatPage(groupIDController.text, true)));
    });
  }
}
