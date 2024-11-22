import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class PatientDetails extends StatefulWidget {
  final Map<String, dynamic> appointment;

  PatientDetails({required this.appointment});

  @override
  State<PatientDetails> createState() => _PatientDetailsState();
}
  class _PatientDetailsState extends State<PatientDetails> {
  late final Map<String, dynamic> appointment;

  @override
  void initState() {
  appointment = widget.appointment;
  super.initState();
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          child: Container(
            height: MediaQuery.of(context).size.height * .4,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                image: DecorationImage(
              fit: BoxFit.cover,
                image: AssetImage("assets/img.png"),
            )),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: MediaQuery.of(context).size.height * .82,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Text(
                    appointment['patientName'],
                    style: const TextStyle(
                        fontFamily: "Itim", fontSize: 25, color: Colors.black),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Man, ${appointment['patientAge']}",
                            style: TextStyle(
                                fontFamily: "Itim",
                                fontSize: 15,
                                color: Colors.black),
                          ),
                          Text(
                            "Phone:${appointment['patientContact']}",
                            style: const TextStyle(
                                fontFamily: "Itim",
                                fontSize: 15,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Blood type: IV+",
                            style: TextStyle(
                                fontFamily: "Itim",
                                fontSize: 15,
                                color: Colors.black),
                          ),
                          Text(
                            "Allergies-None",
                            style: TextStyle(
                                fontFamily: "Itim",
                                fontSize: 15,
                                color: Colors.black),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                const Text(
                  "Appointment Details",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      fontFamily: "Itim"),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurple, width: 2),
                      borderRadius: BorderRadius.circular(40)),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                const TextSpan(
                                  text: 'Date: ',
                                  style: TextStyle(
                                      fontFamily: "itim",
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: appointment['date'],
                                  style: const TextStyle(
                                    fontFamily: "itim",
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                const TextSpan(
                                  text: 'Time: ',
                                  style: TextStyle(
                                      fontFamily: "itim",
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: appointment['time'],
                                  style: const TextStyle(
                                    fontFamily: "itim",
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .005,
                      ),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Problem: ',
                              style: TextStyle(
                                fontFamily: "itim",
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "problem",
                              style: TextStyle(
                                  fontFamily: "itim",
                                  fontSize: 16,
                                  wordSpacing: 3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.width * 0.1,
          left: MediaQuery.of(context).size.width * 0.05,
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                size: 30,
              )),
        ),
        Positioned(
            top: MediaQuery.of(context).size.width * 0.2,
            left: MediaQuery.of(context).size.width * 0.35,
            child: CircleAvatar(
              foregroundImage: NetworkImage(appointment['patientProfile']),
              backgroundColor: Colors.purple[100],
              maxRadius: 50,
            ))
      ],
    ));
  }
}
