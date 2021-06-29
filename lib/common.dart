import 'dart:io';

import 'package:flutter/material.dart';

Widget gradientBorderButton(String text, void Function()? onTap) {
  return GestureDetector(
    onTap: onTap,
    child: ShaderMask(
      shaderCallback: (Rect rect) =>
          LinearGradient(colors: [Colors.orange, Colors.pinkAccent])
              .createShader(rect),
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Text(
            text,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
          )),
    ),
  );
}

Widget gradientBorder(Widget child) {
  return ShaderMask(
      shaderCallback: (Rect rect) =>
          LinearGradient(colors: [Colors.orange, Colors.pinkAccent])
              .createShader(rect),
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: child));
}

Widget gradientButton(String text, void Function()? onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [Colors.orange, Colors.pinkAccent]),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        )),
  );
}

getPadding() {
  return EdgeInsets.symmetric(vertical: 20, horizontal: 30);
}

Future show(context, String msg) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Text(msg),
        actions: [
          SizedBox(
              height: 30,
              width: 80,
              child: gradientBorderButton('Ok', () => Navigator.pop(context)))
        ],
      );
    },
  );
}

Widget loadingWidget() {
  return Container(
    height: 20,
    width: 20,
    alignment: Alignment.center,
    child: CircularProgressIndicator(),
  );
}

Future<bool> checkConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  } on SocketException catch (_) {
    return false;
  }
}

Widget beautifulCard(Widget child, margin) {
  return Container(
    alignment: Alignment.center,
    margin: margin,
    //margin: EdgeInsets.only(right: 20),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset.fromDirection(1.5, 5))
        ]),
    child: child,
  );
}
