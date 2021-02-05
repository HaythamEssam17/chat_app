import 'dart:io';

import 'package:chat_app/Helpers/sharedTexts.dart';
import 'package:chat_app/Widgets/commonWaitingAlertDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreviewPage extends StatefulWidget {
  final File image;
  final String chatRoomID;
  ImagePreviewPage({this.image, this.chatRoomID});

  @override
  _ImagePreviewPageState createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  final firestoreInstance = FirebaseFirestore.instance;

  addFileMessage() {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("image" + DateTime.now().toString());
    UploadTask uploadTask = ref.putFile(widget.image);

    uploadTask.then((res) {
      res.ref.getDownloadURL().then((value) {
        setState(() {
          print('imagePath: $value');
        });

        Map<String, dynamic> chatMessageMap = {
          "sendBy": SharedTexts.userName,
          "message": value,
          "messageType": "file",
          'time': DateTime.now().millisecondsSinceEpoch,
        };

        firestoreInstance
            .collection("ChatRooms")
            .doc(widget.chatRoomID)
            .collection("Chats")
            .add(chatMessageMap)
            .then((value) {
          print("--------------- success!");
          Navigator.pop(context);
          Navigator.pop(context);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: size.height * 0.1,
              width: size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(widget.chatRoomID == null ? 'back' : 'cancel',
                          style: TextStyle(color: Colors.red, fontSize: 20.0))),
                  if (widget.chatRoomID != null)
                    FlatButton(
                        onPressed: () {
                          CommonWaitingDiaog.showLoadWaitingDialog(context);
                          addFileMessage();
                        },
                        child: Icon(Icons.done)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                  child: PhotoView(
                imageProvider: FileImage(widget.image),
              )),
              // child: Container(
              // child: Image.file(
              //   widget.image,
              //   fit: BoxFit.contain,
              // ),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
