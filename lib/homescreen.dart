import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Column(
//       children: [
//         Expanded(
//           child: Image(
//             image: AssetImage("assets/spl.png"),
//             height: MediaQuery.of(context).size.height * 0.3,
//           ),
//         ),
//
//         Expanded(
//           child: Container(
//             margin: EdgeInsets.all(50),
//             child: Row(
//               children: [
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * .2,
//                   width: MediaQuery.of(context).size.width * .3,
//                   child: Card(
//                     child: Column(children: [
//                       SizedBox(
//                           child: RiveAnimation.asset(
//                               "assets/cute-interactive-robot.riv")),
//                       Text("Patient")
//                     ]),
//                   ),
//                 ),
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * .2,
//                   width: MediaQuery.of(context).size.width * .3,
//                   child: Card(
//                     child: Column(children: [
//                       Image(image: AssetImage("")),
//                       Text("Doctor")
//                     ]),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         )
//         // Row(
//         //   children: [
//         //     SizedBox(
//         //       height: MediaQuery.of(context).size.height * .2,
//         //       width: MediaQuery.of(context).size.width * .3,
//         //       child: Card(
//         //         elevation: 4.0,
//         //         child: ListTile(
//         //           leading: Icon(Icons.star),
//         //           title: Text("Card"),
//         //           subtitle: Text("hey"),
//         //           onTap: () {},
//         //         ),
//         //       ),
//         //     ),
//         //     Card(
//         //       elevation: 4.0,
//         //       child: ListTile(
//         //         leading: Icon(Icons.star),
//         //         title: Text("Card"),
//         //         subtitle: Text("hey"),
//         //         onTap: () {},
//         //       ),
//         //     ),
//         //   ],
//         // )
//       ],
//     ));
//   }
// }

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
          child: RiveAnimation.network(
              "")),
    );
  }
}
