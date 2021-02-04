import 'package:flutter/material.dart';

class CommonButton {
  static Widget signButton(
      {Function onPressed, String text, double height, double minWidth}) {
    return MaterialButton(
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 20.0)),
      color: Colors.red,
      height: height,
      minWidth: minWidth,
    );
  }
}
