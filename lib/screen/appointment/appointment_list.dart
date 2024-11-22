import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';

class AppointmentListPage extends StatefulWidget {
  @override
  _AppointmentListPageState createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  List<Map<String, dynamic>> appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/appointment_list.json');
      final jsonString = await file.readAsString();
      final List<dynamic> decodedData = jsonDecode(jsonString);
      setState(() {
        appointments = decodedData.cast<Map<String, dynamic>>();
        print("Apoointments: $appointments");
      });
    } catch (e) {
      print('Error loading appointments: $e');
      // Handle error loading appointments
    }
  }

  Future<void> _saveAppointments(List<Map<String, dynamic>> appointments) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/appointment_list.json');

      // Convert DateTime objects to String representations
      final List<Map<String, dynamic>> encodedAppointments = appointments.map((appointment) {
        final DateTime dateTime = appointment['dateTime'];
        final String formattedDateTime = dateTime.toIso8601String();
        return {...appointment, 'dateTime': formattedDateTime};
      }).toList();

      await file.writeAsString(jsonEncode(encodedAppointments));
    } catch (e) {
      print('Error saving appointments: $e');
    }
  }


  Future<void> _showCancelConfirmationDialog(int index) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black26,
          title: Text(
            'Cancel Appointment',
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Itim",
            ),
          ),
          content: Text(
            'Are you sure you want to cancel this appointment?',
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Itim",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Itim",
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Itim",
                ),
              ),
              onPressed: () {
                setState(() {
                  appointments.removeAt(index);

                });
                _saveAppointments(appointments);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment List',
          style: TextStyle(
            fontFamily: "Itim",
            fontSize: 20,
          ),
        )
      ),
      body: appointments.isEmpty
          ? Container(
              height: MediaQuery.of(context).size.height * .75,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset("assets/empty.json",
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height * .2),
                    Text(
                      'No appointments booked.',
                      style: TextStyle(
                        fontFamily: "Itim",
                        fontSize: 17,
                      ),
                    )
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                // Parse date and time strings into DateTime objects
                final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
                for (var appointment in appointments) {
                  final dateTime = dateFormat
                      .parse('${appointment['date']} ${appointment['time']}');
                  appointment['dateTime'] = dateTime;
                }

// Sort appointments by date and time
                appointments
                    .sort((a, b) => a['dateTime'].compareTo(b['dateTime']));
                final appointment = appointments[index];
                return Container(
                  margin: EdgeInsets.all(5),
                  height: MediaQuery.of(context).size.height * 0.23,
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    image: DecorationImage(
                      image: AssetImage("assets/p.jpeg"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(appointment['doctorPicture']??''),
                              backgroundColor: Colors.white,
                              radius: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Text(
                                      appointment['doctorName']??'',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Itim",
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    appointment['doctorSpecialty']??'',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: "Itim",
                                    ),
                                  ) 
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .1,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .07,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(.7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                child: Icon(
                                  Icons.video_call,
                                  size: 30,
                                  color: Colors.green,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .67,
                              height: MediaQuery.of(context).size.height * .07,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  backgroundColor:
                                      Colors.white.withOpacity(0.5),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${appointment['date']}'?? '',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: "Itim",
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.access_time_filled,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${appointment['time']}'??'',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: "Itim",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .07,
                              child: ElevatedButton(
                                  onPressed: () =>
                                      _showCancelConfirmationDialog(index),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    backgroundColor: Colors.white.withOpacity(.7),
                                  ),
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 30,
                                  )),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
