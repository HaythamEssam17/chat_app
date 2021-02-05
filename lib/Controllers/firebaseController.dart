import 'package:chat_app/Controllers/sharedPrefs.dart';
import 'package:chat_app/Helpers/sharedTexts.dart';
import 'package:chat_app/Views/ChatPages/chatListHomePage.dart';
import 'package:chat_app/Views/ChatPages/chatTabBarPage.dart';
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
              context, MaterialPageRoute(builder: (_) => ChatTabBarPage()));
          // context, MaterialPageRoute(builder: (_) => ChatListHomePage()));
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
