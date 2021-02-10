import 'dart:async';

import 'package:chat_app/Helpers/sharedTexts.dart';
import 'package:chat_app/Views/ChatPages/chatTabBarPage.dart';
import 'package:chat_app/Views/SignPages/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashHomePageState();
}

class SplashHomePageState extends State<SplashHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogged = prefs.getBool('isLogged') ?? false;

    if (isLogged) {
      SharedTexts.userName = prefs.getString('userName');
      SharedTexts.email = prefs.getString('email');
      SharedTexts.phoneNumber = prefs.getString('phoneNumber');
      SharedTexts.password = prefs.getString('password');

      Timer(Duration(milliseconds: 2500), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ChatTabBarPage()));
        // context, MaterialPageRoute(builder: (_) => ChatListHomePage()));
      });
    } else
      Timer(Duration(milliseconds: 2500), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage()));
      });
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.linear);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.white,
        child: Center(
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Center(
              child: Hero(
                tag: '${size.height}_ABC',
                child: Image.asset('images/logo.png',
                    fit: BoxFit.fill,
                    height: size.height * 0.35,
                    width: size.height * 0.35),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
