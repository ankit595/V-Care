import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';

class Viewall_Reminder extends StatefulWidget {
  @override
  _Viewall_ReminderState createState() => _Viewall_ReminderState();
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

class _Viewall_ReminderState extends State<Viewall_Reminder> {

  List<bool> isExpandedList = [];
  List<Map<String, dynamic>> reminderData = [];

  @override
  void initState() {
    super.initState();
    _loadReminderData();
    isExpandedList = List.generate(reminderData.length, (index) => false);
  }

  Future<void> _loadReminderData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reminder_data.json');
      final jsonString = await file.readAsString();
      final List<dynamic> decodedData = jsonDecode(jsonString);
      setState(() {
        reminderData = decodedData.cast<Map<String, dynamic>>();
        print("Reminder: $reminderData");
      });
    } catch (e) {
      print('Error loading reminder data: $e');
      // Handle error loading reminder data
    }
  }

  void _addTakenDates(DateTime date) async {
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

    // Check if the date is already in the list
    if (!existingTakenDates.any((element) => element.date == date)) {
      // Add the new taken date
      existingTakenDates.add(medTakenDate);

      final takenMedsJson = jsonEncode(
          existingTakenDates.map((takenDate) => takenDate.toJson()).toList());

      await file.writeAsString(takenMedsJson);
      print("Taken Dates: $takenMedsJson");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.purple[200],
          content: Text(
            "Bravo! Another step towards wellness with your medication routine.",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "This date is already marked as taken.",
          ),
        ),
      );
    }
  }

  void _addSkippedDates(DateTime date) async {
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

    // Check if the date is already in the list
    if (!existingSkippedDates.any((element) => element.date == date)) {
      // Add the new skipped date
      existingSkippedDates.add(medSkippedDate);

      final skippedMedsJson = jsonEncode(existingSkippedDates
          .map((skippedDate) => skippedDate.toJson())
          .toList());

      await file.writeAsString(skippedMedsJson);
      print("Skipped Dates: $skippedMedsJson");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.purple[700],
          content: Text(
            "Let's try again tomorrow. Remember, your health comes first.",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "This date is already marked as skipped.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    reminderData.sort((a, b) {
      final DateTime dateTimeA = DateTime.parse(a['date'] ?? DateTime.now().toString());
      final DateTime dateTimeB = DateTime.parse(b['date'] ?? DateTime.now().toString());
      return dateTimeA.compareTo(dateTimeB);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Activties',
          style: TextStyle(
            fontFamily: "Itim",
            fontSize: 20,
          ),
        ),
      ),
      body: reminderData.isEmpty
          ? Container(
        height: MediaQuery.of(context).size.height * .75,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                "assets/empty.json",
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * .2,
              ),
              Text(
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
        itemCount: reminderData.length,
        itemBuilder: (context, index) {
          final reminder = reminderData[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                // Toggle the expansion state of the tapped item
                reminder['isExpanded'] = !(reminder['isExpanded'] ?? false);
              });
            },
            child: reminder['isExpanded'] ?? false
                ? SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(12),
                  height: MediaQuery.of(context).size.height * 0.23,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[900],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.12,
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: Image(
                              fit: BoxFit.cover,
                              image: AssetImage("assets/med.png"),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reminder['medicine'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Itim",
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                reminder['dose'] ?? '',
                                style: TextStyle(
                                  fontFamily: "Itim",
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                DateFormat('dd-MMM-yyyy').format(DateTime.parse(
                                    reminder['date'] ??
                                        DateTime.now().toString())),
                                style: TextStyle(
                                  fontFamily: "Itim",
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(
                                height:
                                MediaQuery.of(context).size.height * 0.005,
                              ),
                              Text(
                                reminder['intake'] ?? '',
                                style: TextStyle(
                                  fontFamily: "Itim",
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          PopupMenuButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 30,
                            ),
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                child: Text('Cancel'),
                                value: 'cancel',
                              ),
                            ],
                            onSelected: (value) {
                              // Handle the selected action here
                              switch (value) {
                                case 'cancel':
                                  _showCancelConfirmationDialog(index);
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Divider(
                        color: Colors.white70,
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _addSkippedDates(DateTime.parse(
                                  reminder['date'] ??
                                      DateTime.now().toString()));
                            },
                            child: Text(
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
                              _addTakenDates(DateTime.parse(reminder['date'] ??
                                  DateTime.now().toString()));
                            },
                            child: Text(
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
                )
            )
                : Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(12),
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1, color: Colors.deepPurple),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                // add image here
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                    height: MediaQuery.of(context).size.height * 0.08,
                    image: AssetImage("assets/med.png"),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder['medicine'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Itim",
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            reminder['dose'] ?? '',
                            style: TextStyle(
                              fontFamily: "Itim",
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width*.05,
                          ),
                          Text(
                            DateFormat('dd-MMM-yyyy').format(DateTime.parse(
                                reminder['date'] ??
                                    DateTime.now().toString())),
                            style: TextStyle(
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
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.black,
                      size: 30,
                    ),
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        child: Text('Cancel'),
                        value: 'cancel',
                      ),
                    ],
                    onSelected: (value) {
                      // Handle the selected action here
                      switch (value) {
                        case 'cancel':
                          _showCancelConfirmationDialog(index);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),

    );
  }

  Future<void> _showCancelConfirmationDialog(int index) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black26,
          title: Text(
            'Cancel Reminder',
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Itim",
            ),
          ),
          content: Text(
            'Are you sure you want to cancel this reminder?',
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
                  reminderData.removeAt(index);
                  _saveReminderData(reminderData);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveReminderData(
      List<Map<String, dynamic>> reminderData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reminder_data.json');
      await file.writeAsString(jsonEncode(reminderData));
    } catch (e) {
      print('Error saving reminder data: $e');
      // Handle error saving reminder data
    }
  }
}
