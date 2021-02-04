import 'package:chat_app/Controllers/sharedPrefs.dart';
import 'package:chat_app/Helpers/sharedTexts.dart';
import 'package:chat_app/Views/ChatPages/chatListHomePage.dart';
import 'package:chat_app/Views/SignPages/loginPage.dart';
import 'package:chat_app/Views/SignPages/phoneAuthenticationPage.dart';
import 'package:chat_app/Widgets/commonAlertDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firestoreInstance = FirebaseFirestore.instance;

  bool isLoading = false;
  bool get getIsLoading => isLoading;

  String verifyId;
  String get getVerifyId => verifyId;

  String smsOTP = '254662';
  String get getSmsOTP => smsOTP;

  String authMsg = '';
  String get getAuthMsg => authMsg;

  UserCredential userCredential;
  UserCredential get getUserCredential => userCredential;

  User user;
  User get getUser => user;

  Map formData;
  Map get getFormData => formData;

  // Future signInWithEmailAndPassword(String email, String password) async {
  //   try {
  //     final result = await _auth.signInWithEmailAndPassword(
  //         email: email, password: password);
  //     User user = result.user;
  //     return user != null ? UserModel(uid: user.uid) : null;
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  // Future signUpWithEmailAndPassword(String email, String password) async {
  //   try {
  //     final result = await _auth.createUserWithEmailAndPassword(
  //         email: email, password: password);
  //     User user = result.user;
  //     return user != null ? UserModel(uid: user.uid) : null;
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  // Future signOut() async {
  //   try {
  //     return await _auth.signOut();
  //   } catch (e) {
  //     print(e.toString());
  //     return null;
  //   }
  // }

  Future<void> verifyPhone({
    BuildContext context,
    String phoneNumber,
    Map formData,
  }) async {
    isLoading = true;

    try {
      PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
        verifyId = verId;
        isLoading = false;
        notifyListeners();

        print('Success!');

        // smsOTPDialog(context);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PhoneAuthenticationPage(formData: formData)));
      };

      await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          codeAutoRetrievalTimeout: (String verId) {
            verifyId = verId;
            notifyListeners();
          },
          codeSent: smsOTPSent,
          timeout: Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            isLoading = false;
            notifyListeners();
            print('phoneAuthCredential: $phoneAuthCredential');
            // Navigator.pop(context);
          },
          verificationFailed: (FirebaseAuthException exception) {
            isLoading = false;
            authMsg = exception.message;
            notifyListeners();
            print('exception.message: ${exception.message}');
            // Navigator.pop(context);
          });
    } catch (e) {
      isLoading = false;
      authMsg = e._failedAssertion;
      print('Error Happened: $e');
      notifyListeners();
      // Navigator.pop(context);
    }
  }

  // Future<bool> smsOTPDialog(BuildContext context) {
  //   return showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return new AlertDialog(
  //           title: Text('Enter SMS Code'),
  //           content: Container(
  //             // height: 85,
  //             child: Column(children: [
  //               TextField(
  //                 onChanged: (value) {
  //                   smsOTP = value;
  //                 },
  //               ),
  //               (authMsg != ''
  //                   ? Text(
  //                       authMsg,
  //                       style: TextStyle(color: Colors.red),
  //                     )
  //                   : Container())
  //             ]),
  //           ),
  //           contentPadding: EdgeInsets.all(10),
  //           actions: <Widget>[
  //             FlatButton(
  //               child: Text('Done'),
  //               onPressed: () {
  //                 user = _auth.currentUser;

  //                 if (user != null) {
  //                   Navigator.of(context).pop();
  //                   // Navigator.of(context).pushReplacementNamed('/homepage');
  //                 } else {
  //                   signIn(context);
  //                 }
  //               },
  //             )
  //           ],
  //         );
  //       });
  // }

  checkUser(BuildContext context) async {
    // user = _auth.currentUser;

    // if (user != null) {
    //   // Navigator.of(context).pop();
    //   Navigator.pushReplacement(
    //       context, MaterialPageRoute(builder: (_) => ChatListHomePage()));
    // } else {
    signIn(context);
    // }
  }

  signIn(BuildContext context) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verifyId,
        smsCode: smsOTP,
      );
      userCredential = await _auth.signInWithCredential(credential);
      User currentUser = _auth.currentUser;
      assert(userCredential.user.uid == currentUser.uid);
      registerUser(
        context: context,
        userName: formData['userName'],
        email: formData['email'],
        phoneNumber: formData['phoneNumber'],
        password: formData['password'],
      );
    } catch (e) {
      authMsg = e;
    }
  }

  registerUser(
      {BuildContext context,
      String userName,
      String email,
      String phoneNumber,
      String password}) {
    firestoreInstance.collection("Users").add({
      "userName": userName,
      "email": email,
      "phoneNumber": phoneNumber,
      "password": password,
    }).then((value) {
      if (value.id != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage()));
      } else {
        authMsg = 'Some error happened!';
      }
    }).catchError((e) => print('E: $e'));
  }

  loginUser({BuildContext context, String phoneNumber, String password}) async {
    var result = await firestoreInstance
        .collection("Users")
        .where('phoneNumber', isEqualTo: '+2' + phoneNumber)
        .where('password', isEqualTo: password)
        .get()
        .then((value) {
      if (value.docs.length != 0) {
        value.docs.forEach((res) {
          Navigator.pop(context);
          SharedPrefs.saveIsLogged(true);
          SharedPrefs.saveUserName(res.data()['userName']);
          SharedPrefs.saveEmail(res.data()['email']);
          SharedPrefs.savePhoneNumber(phoneNumber);
          SharedPrefs.savePassword(password);

          SharedTexts.userName = res.data()['userName'];
          SharedTexts.email = res.data()['email'];
          SharedTexts.phoneNumber = phoneNumber;
          SharedTexts.password = password;

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => ChatListHomePage()));
        });
      } else {
        Navigator.pop(context);
        CommonAlertDialog.showAlertDialog(
            context, 'Please confirm your phone number and password');
      }
    });

    return result;
  }
}
