import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';

class CustomBottomNavigationBar extends StatelessWidget with STWidget {
  CustomBottomNavigationBar({Key? key, required this.selectedIndexCallback}) : super(key: key);
  final void Function(int) selectedIndexCallback;

  void invokeCallback(int index) {
    selectedIndexCallback(index);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colors.background,
      elevation: 3,
      shape: RoundedRectangleBorder(
        // borderRadius: BorderRadius.all(25),
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(width: 2, color: colors.foreground),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: IconButton(
              icon: Icon(Icons.ac_unit, color: colors.foreground),
              onPressed: () => invokeCallback(0),
            ),
          ),
          Expanded(
            child: IconButton(
              icon: Icon(Icons.access_alarm, color: colors.foreground),
              onPressed: () => invokeCallback(1),
            ),
          ),
          Expanded(
            child: IconButton(
              icon: Icon(Icons.ac_unit, color: colors.foreground),
              onPressed: () => invokeCallback(2),
            ),
          ),
          Expanded(
            child: IconButton(
              icon: Icon(Icons.access_alarm, color: colors.foreground),
              onPressed: () => invokeCallback(3),
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:solidtrade/components/base/st_widget.dart';

// class CustomBottomNavigationBar extends StatelessWidget with STWidget {
//   CustomBottomNavigationBar({Key? key, required this.selectedIndexCallback}) : super(key: key);
//   final void Function(int) selectedIndexCallback;

//   void invokeCallback(int index) {
//     selectedIndexCallback(index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         // border: Border.(
//         //   color: Colors.black,
//         // ),
//         // border: RoundedRectangleBorder(
//         //     borderRadius: BorderRadius.only(
//         //       bottomRight: Radius.circular(10),
//         //       topRight: Radius.circular(10),
//         //     ),),
//         color: colors.background,
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Container(
//           // color: colors.background,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: IconButton(
//                   icon: Icon(Icons.ac_unit, color: colors.foreground),
//                   onPressed: () => invokeCallback(0),
//                 ),
//               ),
//               Expanded(
//                 child: IconButton(
//                   icon: Icon(Icons.access_alarm, color: colors.foreground),
//                   onPressed: () => invokeCallback(1),
//                 ),
//               ),
//               Expanded(
//                 child: IconButton(
//                   icon: Icon(Icons.ac_unit, color: colors.foreground),
//                   onPressed: () => invokeCallback(2),
//                 ),
//               ),
//               Expanded(
//                 child: IconButton(
//                   icon: Icon(Icons.access_alarm, color: colors.foreground),
//                   onPressed: () => invokeCallback(3),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
