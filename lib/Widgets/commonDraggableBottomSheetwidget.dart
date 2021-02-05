import 'package:flutter/material.dart';

class CommonDraggableBottomSheetwidget {
  static Widget customDraggableBottomSheet(List<Widget> widgetsList) {
    return DraggableScrollableSheet(
        initialChildSize: 1,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0)),
                color: Colors.white,
                border: Border.all(color: Colors.grey)),
            child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                controller: scrollController,
                children: widgetsList),
          );
        });
  }
}
