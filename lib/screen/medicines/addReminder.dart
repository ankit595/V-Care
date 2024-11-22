import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class AddReminder extends StatefulWidget {
  const AddReminder({Key? key}) : super(key: key);

  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _ReminderData {
  DateTime? date;
  TimeOfDay? time;
  String? medicine;
  String? dose;
  String? intake;
  String? note;

  _ReminderData({
    this.date,
    this.time,
    this.medicine,
    this.dose,
    this.intake,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date != null ? DateFormat('yyyy-MM-dd').format(date!) : null,
      'time': time != null ? '${time!.hour}:${time!.minute}' : null,
      'medicine': medicine,
      'dose': dose,
      'intake': intake,
      'note': note,
    };
  }

  _ReminderData.fromJson(Map<String, dynamic> json)
      : date = json['date'] != null ? DateTime.parse(json['date']) : null,
        time = json['time'] != null
            ? TimeOfDay(
                hour: int.parse(json['time'].split(':')[0]),
                minute: int.parse(json['time'].split(':')[1]),
              )
            : null,
        medicine = json['medicine'],
        dose = json['dose'],
        intake = json['intake'],
        note = json['note'];
}

class _AddReminderState extends State<AddReminder> {
  final _medicineController = TextEditingController();
  final _doseController = TextEditingController();
  final _intakeController = TextEditingController();
  final _noteController = TextEditingController();

  List<Map<String, dynamic>> contentList = [
    {
      'image': AssetImage("assets/3d/1.png"),
      'text': "Your health is your wealth. Remember your medicine."
    },
    {
      'image': AssetImage("assets/3d/2.png"),
      'text': "Stay strong, stay healthy. Don't forget your pills."
    },
    {
      'image': AssetImage("assets/3d/3.png"),
      'text':
          "Wellness starts with consistency. Take your medication as prescribed."
    },
    {
      'image': AssetImage("assets/3d/4.png"),
      'text':
          "A dose a day keeps the illness away. Stay on track with your meds."
    },
    {
      'image': AssetImage("assets/3d/5.png"),
      'text': "Every pill counts. Don't skip, stay healthy."
    },
    {
      'image': AssetImage("assets/3d/6.png"),
      'text':
          "Health is a journey, not a destination. Keep up with your medication routine."
    },
    // Add more images and texts as needed
  ];
  int currentIndex = 0;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _saveReminder() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    final reminderData = _ReminderData(
      date: _selectedDate,
      time: _selectedTime,
      medicine: _medicineController.text,
      dose: _doseController.text,
      intake: _intakeController.text,
      note: _noteController.text,
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/reminder_data.json');

    List<_ReminderData> existingReminders = [];

    // Read existing reminders from file if it exists
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final dynamic jsonData = json.decode(jsonString);

      if (jsonData is List<dynamic>) {
        existingReminders =
            jsonData.map((item) => _ReminderData.fromJson(item)).toList();
      } else if (jsonData is Map<String, dynamic>) {
        // Handle the case where the JSON data is a single object (not a list)
        existingReminders.add(_ReminderData.fromJson(jsonData));
      }
    }
    // Add the new reminder
    existingReminders.add(reminderData);

    // Convert reminders to JSON and write to file
    final remindersJson = jsonEncode(
      existingReminders.map((reminder) => reminder.toJson()).toList(),
    );

    await file.writeAsString(remindersJson);
    print("Reminder: $remindersJson");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black26,
          title: Text(
            "Reminder Scheduled",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Itim",
            ),
          ),
          content: Text(
            "Your reminder has been scheduled successfully.",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Itim",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pop(); // Pop twice to go back to previous screen
              },
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Itim",
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _medicineController.dispose();
    _doseController.dispose();
    _intakeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Timer? _timer;

  void _startTimer() {
    const duration = Duration(seconds: 5);
    _timer = Timer.periodic(duration, (Timer timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % contentList.length;
      });
    });
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    ).then((selectedDate) {
      if (selectedDate != null) {
        setState(() {
          _selectedDate = selectedDate;
        });
      }
    });
  }

  void _showTimePicker() {
    showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    ).then((selectedTime) {
      if (selectedTime != null) {
        setState(() {
          _selectedTime = selectedTime;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[100],
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.purple[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Add Medicine",
                  style: TextStyle(fontFamily: "Itim", fontSize: 25),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _saveReminder,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Save",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Itim",
                            fontSize: 20),
                      ),
                      Icon(
                        Icons.check,
                        color: Colors.white70,
                        size: 25,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            color: Colors.purple[100],
            height: MediaQuery.of(context).size.height * .3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Image(image: contentList[currentIndex]['image']),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Text(
                    contentList[currentIndex]['text'],
                    style: TextStyle(fontFamily: "Itim", fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * .7,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: MaterialButton(
                        onPressed: _showDatePicker,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(Icons.calendar_today),
                              Text(
                                _selectedDate != null
                                    ? DateFormat('dd-MM-yyyy')
                                        .format(_selectedDate!)
                                    : "Select Date",
                                style:
                                    TextStyle(fontSize: 18, fontFamily: "Itim"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: MaterialButton(
                        onPressed: _showTimePicker,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(Icons.access_time_filled),
                              Text(
                                _selectedTime != null
                                    ? _selectedTime!.format(context)
                                    : "Select Time",
                                style:
                                    TextStyle(fontSize: 18, fontFamily: "Itim"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                TextField(
                  controller: _medicineController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    labelText: "Medicine ",
                    labelStyle: TextStyle(
                      fontFamily: "Itim",
                      fontSize: 17,
                    ),
                    hintText: "Enter the Medicine Name",
                    hintStyle: TextStyle(
                      fontFamily: "Itim",
                      fontSize: 15,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                TextField(
                  controller: _doseController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    labelText: "Dose ",
                    labelStyle: TextStyle(
                      fontFamily: "Itim",
                      fontSize: 17,
                    ),
                    hintText: "Number of Pills or Quantity in ml",
                    hintStyle: TextStyle(
                      fontFamily: "Itim",
                      fontSize: 15,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                TextField(
                  controller: _intakeController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    labelText: "Intake",
                    labelStyle: TextStyle(
                      fontFamily: "Itim",
                      fontSize: 17,
                    ),
                    hintText: "e.g,. Morning/After after breakfast!!!",
                    hintStyle: TextStyle(
                      fontFamily: "Itim",
                      fontSize: 15,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: TextField(
                    controller: _noteController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      labelText: "Note",
                      labelStyle: TextStyle(
                        fontFamily: "Itim",
                        fontSize: 17,
                      ),
                      hintText: "Add a note regarding the medicine",
                      hintStyle: TextStyle(
                        fontFamily: "Itim",
                        fontSize: 15,
                      ),
                      alignLabelWithHint: true, // Align label with hint text
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
