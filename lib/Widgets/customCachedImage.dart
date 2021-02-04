import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomCachedImage {
  static Widget cachedImage(
      {BuildContext context,
      String imageUrl,
      double size,
      double topLeft,
      double topRight,
      double bottomLeft,
      double bottomRight}) {
    String image = imageUrl ??
        'https://d.newsweek.com/en/full/1611676/senior-couple-cuddling.jpg';

    return CachedNetworkImage(
      imageUrl: image,
      imageBuilder: (context, imageProvider) => ClipOval(
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(topLeft),
              topRight: Radius.circular(topRight),
              bottomLeft: Radius.circular(bottomLeft),
              bottomRight: Radius.circular(bottomRight),
            ),
            image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
          ),
        ),
      ),
      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => ClipOval(
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/loginbg.jpg'), fit: BoxFit.fill),
          ),
        ),
      ),
    );
  }
}
