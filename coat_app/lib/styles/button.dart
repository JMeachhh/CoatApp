// import 'package:flutter/material.dart';

// ButtonStyle buttonPrimary(double buttonSize) {
//   return ElevatedButton.styleFrom(
//     minimumSize: Size(buttonSize, buttonSize),
//     backgroundColor: Colors.transparent,
//     elevation: 0,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.all(
//         Radius.circular(15),
//       ),
//     ),
//   );
// }

import 'package:flutter/material.dart';

Widget gradientButton(double buttonSize, VoidCallback onPressed, String text,
    bool isSelected, int index) {
  Color buttonColor1 = const Color.fromARGB(255, 238, 133, 36);
  Color buttonColor2 = const Color.fromARGB(255, 197, 43, 16);

  Color todayButtonColor1 = const Color.fromARGB(255, 36, 107, 238);
  Color todayButtonColor2 = const Color.fromARGB(255, 49, 16, 197);

  BoxShadow outerShadow = const BoxShadow(
    color: Colors.black26,
    offset: Offset(0, 0),
    blurRadius: 7,
    spreadRadius: 1,
  );

  BoxShadow pressedShadow = const BoxShadow(
      color: Color.fromARGB(255, 255, 255, 255),
      offset: Offset(0, 0),
      blurRadius: 12,
      spreadRadius: 0,
      blurStyle: BlurStyle.inner);
  return Container(
    decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: index > 0
                    ? [
                        buttonColor1.withOpacity(0.7),
                        buttonColor2.withOpacity(0.7),
                      ]
                    : [
                        todayButtonColor1.withOpacity(0.7),
                        todayButtonColor2.withOpacity(0.7),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
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
        boxShadow: [
          if (isSelected) pressedShadow,
          if (!isSelected) outerShadow
        ]),
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
      child: Text(text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          )), // Button text
    ),
  );
}

// child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       // boxShadow: [
//                       //   BoxShadow(
//                       //       color: Color.fromARGB(244, 160, 160, 160),
//                       //       offset: Offset(0, 0),
//                       //       blurRadius: 5,
//                       //       spreadRadius: 0.1)
//                       // ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(15),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [buttonColor1, buttonColor2],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                         ),
//                         width: buttonSize,
//                         height: buttonSize,
//                       ),
//                     ),
//                   ),
