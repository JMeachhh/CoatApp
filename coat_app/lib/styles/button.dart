import 'package:flutter/material.dart';

Widget gradientButton(double buttonSize, VoidCallback onPressed, String text,
    bool isSelected, int index) {
  Color buttonColor1 = const Color.fromARGB(255, 255, 196, 0);
  Color buttonColor2 = const Color.fromARGB(255, 255, 38, 0);

  Color todayButtonColor1 = const Color.fromARGB(255, 0, 153, 255);
  Color todayButtonColor2 = const Color.fromARGB(255, 72, 8, 248);

  BoxShadow outerShadow = const BoxShadow(
    color: Colors.black26,
    offset: Offset(0, 0),
    blurRadius: 3,
    spreadRadius: 1,
  );

  double underlineHeight = 4.0;

  return Column(
    children: [
      Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: index > 0
                  ? [
                      buttonColor1,
                      buttonColor2,
                    ]
                  : [
                      todayButtonColor1,
                      todayButtonColor2,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [if (!isSelected) outerShadow]),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(buttonSize, buttonSize),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
      if (isSelected)
        Container(
          margin: EdgeInsets.only(top: 4),
          height: underlineHeight,
          width: buttonSize * 0.8,
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 119, 119, 119),
              borderRadius: BorderRadius.circular(2)),
        )
    ],
  );
}
