import 'package:flutter/material.dart';

import 'commonSpinKit.dart';

class CommonWaitingDiaog {
  static showLoadWaitingDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          contentPadding: EdgeInsets.all(0.0),
          content: CommonSpinKit.customSpinKitRing(),
        );
      },
    );
  }
}
