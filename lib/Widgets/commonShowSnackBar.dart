import 'package:flutter/material.dart';

class CommonShowSnackBar {
  static void showInSnackBar(
      String value, GlobalKey<ScaffoldState> scaffoldKey) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(value, style: TextStyle(color: Colors.white)),
        duration: Duration(milliseconds: 2000),
        backgroundColor: Colors.red));
  }
}
