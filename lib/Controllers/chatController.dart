import 'package:chat_app/Helpers/sharedTexts.dart';
import 'package:chat_app/Views/ChatPages/chatPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatController extends ChangeNotifier {
  final firebaseInstance = FirebaseFirestore.instance;

  bool isLoading = false;
  bool get getIsLoading => isLoading;

  bool isRoomFounded = false;
  bool get getIsRoomFounded => isRoomFounded;

  addChatRoom({BuildContext context, String chatRoomID}) {
    List<String> users = [SharedTexts.userName, chatRoomID];
    Map<String, dynamic> chatRoom = {
      "chatUsers": users,
      "creatorPhone": SharedTexts.phoneNumber,
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

    notifyListeners();

    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) =>
    //             ChatPage(chatRoomID: chatRoomID, isGroup: false)));
  }

  bool checkIfRoomCreatedBefore(String chatRoomID) {
    firebaseInstance.collection("ChatRooms").get().then((QuerySnapshot value) {
      value.docs.forEach((QueryDocumentSnapshot document) {
        print('document.data();: ${document.data()}');
        if (document.data()['chatRoomID'] == chatRoomID) {
          isRoomFounded = true;
          notifyListeners();
          // return true;
        }
      });
    });

    isRoomFounded = false;
    notifyListeners();
    return isRoomFounded;
  }
}
