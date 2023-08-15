import 'package:flutter/material.dart';

class Constants {
  final footerBlue = const Color(0xFF1f4c73);
  final colorBlue = const Color(0xFF0f2940);
  final colorGreen = const Color(0xFF03a751);
  final angelenoAccountButtonStyle =  ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
      shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
      surfaceTintColor: MaterialStateProperty.all<Color>(Colors.transparent),
      overlayColor: MaterialStateProperty.all<Color>(const Color(0xff0daa58)),
      alignment: Alignment.center,
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder()
      )
  );
  final actionButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      disabledBackgroundColor: Colors.transparent,
      alignment: Alignment.center,
      textStyle: const TextStyle(
          color: Colors.black
      ),
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.black,
      shadowColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
          side: BorderSide()
      )
  );

}