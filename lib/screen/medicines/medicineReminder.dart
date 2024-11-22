import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:major_vcare/screen/medicines/medicineTrack.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'addReminder.dart';
import 'viewall_Reminder.dart';

class Medicines extends StatefulWidget {
  const Medicines({Key? key});

  @override
  State<Medicines> createState() => _MedicinesState();
}

class _TakenData {
  DateTime? date;

  _TakenData({
    this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date != null ? DateFormat('yyyy-MM-dd').format(date!) : null,
    };
  }

  _TakenData.fromJson(Map<String, dynamic> json)
      : date = json['date'] != null ? DateTime.parse(json['date']) : null;
}

class _SkippedData {
  DateTime? date;

  _SkippedData({
    this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date != null ? DateFormat('yyyy-MM-dd').format(date!) : null,
    };
  }

  _SkippedData.fromJson(Map<String, dynamic> json)
      : date = json['date'] != null ? DateTime.parse(json['date']) : null;
}

class _MedicinesState extends State<Medicines> {
  List<bool> isExpandedList = [];
  DateTime selectedDate = DateTime.now();
  String formattedDate = DateFormat('dd MMM, E').format(DateTime.now());
  String formattedTime = DateFormat('h:mm a').format(DateTime.now());

  List<Map<String, dynamic>> medicine_reminderData = [];

  @override
  void initState() {
    super.initState();
    _loadReminderData();
    isExpandedList =
        List.generate(medicine_reminderData.length, (index) => false);
  }

  Future<void> _loadReminderData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reminder_data.json');
      final jsonString = await file.readAsString();
      final List<dynamic> decodedData = jsonDecode(jsonString);
      setState(() {
        medicine_reminderData = decodedData.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print('Error loading reminder data: $e');
      // Handle error loading appointments
    }
  }

  Future<void> _saveReminderData(
      List<Map<String, dynamic>> medicine_reminderData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reminder_data.json');
      await file.writeAsString(jsonEncode(medicine_reminderData));
    } catch (e) {
      print('Error saving appointments: $e');
      // Handle error saving appointments
    }
  }

  void _addTakenDates(DateTime date, Map<String, dynamic> reminder) async {
    setState(() {
      medicine_reminderData.remove(reminder);
    });
    final medTakenDate = _TakenData(date: date);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/medicineTakenDates.json');

    List<_TakenData> existingTakenDates = [];
    if (await file.exists()) {
      try {
        final jsonString = await file.readAsString();
        final jsonData = json.decode(jsonString);

        if (jsonData is List<dynamic>) {
          existingTakenDates =
              jsonData.map((date) => _TakenData.fromJson(date)).toList();
        } else if (jsonData is Map<String, dynamic>) {
          // Handle the case where the JSON data is a single object (not a list)
          existingTakenDates.add(_TakenData.fromJson(jsonData));
        }
      } catch (e) {
        print('Error decoding JSON data: $e');
        // Handle error decoding JSON data
      }
    }
    // Add the new taken date
    existingTakenDates.add(medTakenDate);

    final takenMedsJson = jsonEncode(
        existingTakenDates.map((takenDate) => takenDate.toJson()).toList());

    await file.writeAsString(takenMedsJson);
    print("Taken Dates: $takenMedsJson");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Bravo! Another step towards wellness with your medication routine.",
        ),
      ),
    );
  }

  void _addSkippedDates(DateTime date, Map<String, dynamic> reminder) async {
    setState(() {
      medicine_reminderData.remove(reminder);
    });
    final medSkippedDate = _SkippedData(date: date);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/medicineSkippedDates.json');

    List<_SkippedData> existingSkippedDates = [];
    if (await file.exists()) {
      try {
        final jsonString = await file.readAsString();
        final jsonData = json.decode(jsonString);

        if (jsonData is List<dynamic>) {
          existingSkippedDates =
              jsonData.map((date) => _SkippedData.fromJson(date)).toList();
        } else if (jsonData is Map<String, dynamic>) {
          // Handle the case where the JSON data is a single object (not a list)
          existingSkippedDates.add(_SkippedData.fromJson(jsonData));
        }
      } catch (e) {
        print('Error decoding JSON data: $e');
        // Handle error decoding JSON data
      }
    }
    // Add the new skipped date
    existingSkippedDates.add(medSkippedDate);

    final skippedMedsJson = jsonEncode(existingSkippedDates
        .map((skippedDate) => skippedDate.toJson())
        .toList());

    await file.writeAsString(skippedMedsJson);
    print("Skipped Dates: $skippedMedsJson");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Let's try again tomorrow. Remember, your health comes first.",
        ),
      ),
    );
  }

  Future<void> _showCancelConfirmationDialog(int index) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black38,
          title: const Text(
            'Cancel Reminder',
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Itim",
            ),
          ),
          content: const Text(
            'Are you sure you want to cancel this reminder?',
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Itim",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
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
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Itim",
                ),
              ),
              onPressed: () {
                setState(() {
                  medicine_reminderData.removeAt(index);
                  _saveReminderData(medicine_reminderData);
                });
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
      body: Stack(
        children: [
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              height: MediaQuery.of(context).size.height * 0.45,
              width: MediaQuery.of(context).size.width,
              color: Colors.purple[100],
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your Drug\n Cabinet",
                            style: TextStyle(fontFamily: "Itim", fontSize: 30),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white70),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const AddReminder()));
                              },
                              child: const Icon(Icons.add))
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              8, // Set the number of days to show in the future
                          itemBuilder: (context, index) {
                            final currentDate =
                                DateTime.now().add(Duration(days: index));
                            final isSelected =
                                currentDate.year == selectedDate.year &&
                                    currentDate.month == selectedDate.month &&
                                    currentDate.day == selectedDate.day;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedDate = DateTime.now()
                                        .add(Duration(days: index));
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isSelected
                                        ? Colors.purple[400]
                                        : Colors.transparent,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Text(
                                        DateFormat.E('en_US')
                                            .format(currentDate),
                                        // Day of the week (e.g., Mon)
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        DateFormat.d('en_US')
                                            .format(currentDate),
                                        // Day of the month (e.g., 1)
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )),
                    Expanded(
                      flex: 2,
                      child: Container(),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Today's Reminder",
                            style: TextStyle(fontFamily: "Itim", fontSize: 20),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Viewall_Reminder()));
                              },
                              child: const Text(
                                "View all",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 17,
                                    fontFamily: "Itim"),
                              ))
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                    thickness: 2,
                    indent: 20,
                    endIndent: 20,
                  ),
                  Expanded(
                    flex: 10,
                    child: Container(
                      child: medicine_reminderData.isEmpty ||
                              !medicine_reminderData.any((reminder) {
                                final reminderDate = reminder['date'] != null &&
                                        reminder['date'].isNotEmpty
                                    ? DateFormat('yyyy-MM-dd')
                                        .parse(reminder['date']!)
                                    : DateTime.now();
                                return reminderDate.year == selectedDate.year &&
                                    reminderDate.month == selectedDate.month &&
                                    reminderDate.day == selectedDate.day;
                              })
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * .75,
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                      "assets/empty.json",
                                      fit: BoxFit.cover,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .2,
                                    ),
                                    const Text(
                                      'No reminders set.',
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
                              itemCount: medicine_reminderData.length,
                              itemBuilder: (context, index) {
                                final reminder = medicine_reminderData[index];
                                final reminderDate = reminder['date'] != null &&
                                        reminder['date'].isNotEmpty
                                    ? DateFormat('yyyy-MM-dd')
                                        .parse(reminder['date']!)
                                    : DateTime.now();

                                if (reminderDate.year == selectedDate.year &&
                                    reminderDate.month == selectedDate.month &&
                                    reminderDate.day == selectedDate.day) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        // Toggle the expansion state of the tapped item
                                        reminder['isExpanded'] =
                                            !(reminder['isExpanded'] ?? false);
                                      });
                                    },
                                    child: reminder['isExpanded'] ?? false
                                        ? SingleChildScrollView(
                                            child: Container(
                                            margin: const EdgeInsets.all(10),
                                            padding: const EdgeInsets.all(12),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.23,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.deepPurple[900],
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.12,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.25,
                                                      child: const Image(
                                                        fit: BoxFit.cover,
                                                        image: AssetImage(
                                                            "assets/med.png"),
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          reminder[
                                                                  'medicine'] ??
                                                              '',
                                                          style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily: "Itim",
                                                            fontSize: 20,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          reminder['dose'] ??
                                                              '',
                                                          style: const TextStyle(
                                                            fontFamily: "Itim",
                                                            fontSize: 15,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        Text(
                                                          DateFormat(
                                                                  'dd-MMM-yyyy')
                                                              .format(DateTime.parse(reminder[
                                                                      'date'] ??
                                                                  DateTime.now()
                                                                      .toString())),
                                                          style: const TextStyle(
                                                            fontFamily: "Itim",
                                                            fontSize: 15,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.005,
                                                        ),
                                                        Text(
                                                          reminder['intake'] ??
                                                              '',
                                                          style: const TextStyle(
                                                            fontFamily: "Itim",
                                                            fontSize: 18,
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    PopupMenuButton(
                                                      icon: const Icon(
                                                        Icons.more_vert,
                                                        color: Colors.white,
                                                        size: 30,
                                                      ),
                                                      itemBuilder: (BuildContext
                                                              context) =>
                                                          [
                                                        const PopupMenuItem(
                                                          value: 'cancel',
                                                          child: Text('Cancel'),
                                                        ),
                                                      ],
                                                      onSelected: (value) {
                                                        // Handle the selected action here
                                                        switch (value) {
                                                          case 'cancel':
                                                            _showCancelConfirmationDialog(
                                                                index);
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01,
                                                ),
                                                const Divider(
                                                  color: Colors.white70,
                                                  thickness: 1,
                                                  indent: 20,
                                                  endIndent: 20,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        _addSkippedDates(DateTime
                                                            .parse(reminder[
                                                                    'date'] ??
                                                                DateTime.now()
                                                                    .toString()), reminder);
                                                      },
                                                      child: const Text(
                                                        "X  Skip",
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontFamily: "Itim",
                                                          color: Colors.orange,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        _addTakenDates(DateTime
                                                            .parse(reminder[
                                                                    'date'] ??
                                                                DateTime.now()
                                                                    .toString()), reminder);
                                                      },
                                                      child: const Text(
                                                        "Y  Done",
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontFamily: "Itim",
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ))
                                        : Container(
                                            margin: const EdgeInsets.all(10),
                                            padding: const EdgeInsets.all(12),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.deepPurple),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: Row(
                                              // add image here
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Image(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.08,
                                                  image: const AssetImage(
                                                      "assets/med.png"),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      reminder['medicine'] ??
                                                          '',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: "Itim",
                                                        fontSize: 20,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          reminder['dose'] ??
                                                              '',
                                                          style: const TextStyle(
                                                            fontFamily: "Itim",
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .05,
                                                        ),
                                                        Text(
                                                          DateFormat(
                                                                  'dd-MMM-yyyy')
                                                              .format(DateTime.parse(reminder[
                                                                      'date'] ??
                                                                  DateTime.now()
                                                                      .toString())),
                                                          style: const TextStyle(
                                                            fontFamily: "Itim",
                                                            fontSize: 15,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                PopupMenuButton(
                                                  icon: const Icon(
                                                    Icons.more_vert,
                                                    color: Colors.black,
                                                    size: 30,
                                                  ),
                                                  itemBuilder:
                                                      (BuildContext context) =>
                                                          [
                                                    const PopupMenuItem(
                                                      value: 'cancel',
                                                      child: Text('Cancel'),
                                                    ),
                                                  ],
                                                  onSelected: (value) {
                                                    // Handle the selected action here
                                                    switch (value) {
                                                      case 'cancel':
                                                        _showCancelConfirmationDialog(
                                                            index);
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              right: 10,
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MedicineCalendar()));
                  },
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * .14,
                    width: MediaQuery.of(context).size.width * .35,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height * .08,
                            width: MediaQuery.of(context).size.width * .25,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        AssetImage("assets/drugcabinet.png")))),
                        const Text(
                          "Medicine Tracker",
                          style: TextStyle(
                            fontFamily: "Itim",
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                  )))
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)!.isActive) {
      _loadReminderData();
    }
  }

// Other methods remain unchanged...
}
