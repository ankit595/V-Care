import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class MedicineCalendar extends StatefulWidget {
  @override
  _MedicineCalendarState createState() => _MedicineCalendarState();
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

class _MedicineCalendarState extends State<MedicineCalendar> {
  late DateTime currentDate;
  late DateTime firstDayOfMonth;
  late int daysInMonth;
  List<bool> isExpandedList = [];
  List<DateTime> medicineTakenDates = [];
  List<DateTime> medicineSkippedDates = [];
  DateTime selectedDate = DateTime.now();

  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  List<Map<String, dynamic>> medicine_reminderData = [];

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
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadMedicineDates();
    _loadReminderData();
    isExpandedList =
        List.generate(medicine_reminderData.length, (index) => false);
  }

  Future<void> _loadMedicineDates() async {
    final directory = await getApplicationDocumentsDirectory();
    final takenFile = File('${directory.path}/medicineTakenDates.json');
    final skippedFile = File('${directory.path}/medicineSkippedDates.json');

    if (await takenFile.exists()) {
      final takenJsonString = await takenFile.readAsString();
      final List<dynamic> takenData = jsonDecode(takenJsonString);
      setState(() {
        medicineTakenDates =
            takenData.map((date) => DateTime.parse(date['date'])).toList();
        print("Taken: $medicineTakenDates");
      });
    }

    if (await skippedFile.exists()) {
      final skippedJsonString = await skippedFile.readAsString();
      final List<dynamic> skippedData = jsonDecode(skippedJsonString);
      setState(() {
        medicineSkippedDates =
            skippedData.map((date) => DateTime.parse(date['date'])).toList();
        print("Skipped: $medicineSkippedDates");
      });
    }
  }

  Future<void> _updateTakenDatesJson(List<DateTime> takenDates) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/medicineTakenDates.json');
    final takenJson =
        takenDates.map((date) => {'date': date.toString()}).toList();
    await file.writeAsString(jsonEncode(takenJson));
  }

  Future<void> _updateSkippedDatesJson(List<DateTime> skippedDates) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/medicineSkippedDates.json');
    final skippedJson =
        skippedDates.map((date) => {'date': date.toString()}).toList();
    await file.writeAsString(jsonEncode(skippedJson));
  }

  @override
  Widget build(BuildContext context) {
    medicine_reminderData.sort((a, b) {
      final DateTime dateTimeA = DateTime.parse(a['date'] ?? DateTime.now().toString());
      final DateTime dateTimeB = DateTime.parse(b['date'] ?? DateTime.now().toString());
      return dateTimeA.compareTo(dateTimeB);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medicine Calendar',
          style: TextStyle(
            fontFamily: "Itim",
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 20,),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime.utc(
                        _focusedDay.year, _focusedDay.month - 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM').format(_focusedDay), // Display month name
                style: TextStyle(fontSize: 20,fontFamily: "Itim",),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 20,),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime.utc(
                        _focusedDay.year, _focusedDay.month + 1);
                  });
                },
              ),
            ],
          ),
          TableCalendar(
            calendarFormat: _calendarFormat,
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(_focusedDay.year, _focusedDay.month - 1),
            lastDay: DateTime.utc(_focusedDay.year, _focusedDay.month + 1, 0),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.black, fontFamily: "Itim"),
              weekendStyle: TextStyle(color: Colors.black, fontFamily: "Itim"),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle:
                  TextStyle(color: Colors.black, fontFamily: "Itim"),
              todayDecoration: BoxDecoration(
                color: Colors.blue[500],
                shape: BoxShape.circle,
              ),
            ),
            headerVisible: false,
            rowHeight: 40,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                Color color = Colors.white;
                if (medicineTakenDates
                    .contains(DateTime(date.year, date.month, date.day))) {
                  color = Colors.green;
                } else if (medicineSkippedDates
                    .contains(DateTime(date.year, date.month, date.day))) {
                  color = Colors.orange;
                }
                return GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.black26,
                          title: Text('Confirmation'),
                          content: Text(
                              'Do you want to remove or switch  the status of this date?'),
                          elevation: 5,
                          titleTextStyle: TextStyle(
                              fontFamily: "Itim", color: Colors.white),
                          contentTextStyle: TextStyle(
                              fontFamily: "Itim", color: Colors.white),
                          actions: [
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      if (medicineTakenDates.contains(DateTime(
                                          date.year, date.month, date.day))) {
                                        medicineTakenDates.remove(DateTime(
                                            date.year, date.month, date.day));
                                        _updateTakenDatesJson(
                                            medicineTakenDates);
                                      } else if (medicineSkippedDates.contains(
                                          DateTime(date.year, date.month,
                                              date.day))) {
                                        medicineSkippedDates.remove(DateTime(
                                            date.year, date.month, date.day));
                                        _updateSkippedDatesJson(
                                            medicineSkippedDates);
                                      }
                                    });
                                  },
                                  child: Text(
                                    'Remove',
                                    style: TextStyle(
                                        fontFamily: "Itim",
                                        color: Colors.white),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      if (medicineTakenDates.contains(DateTime(
                                          date.year, date.month, date.day))) {
                                        medicineTakenDates.remove(DateTime(
                                            date.year, date.month, date.day));
                                        medicineSkippedDates.add(DateTime(
                                            date.year, date.month, date.day));
                                        _updateTakenDatesJson(
                                            medicineTakenDates);
                                        _updateSkippedDatesJson(
                                            medicineSkippedDates);
                                      } else if (medicineSkippedDates.contains(
                                          DateTime(date.year, date.month,
                                              date.day))) {
                                        medicineSkippedDates.remove(DateTime(
                                            date.year, date.month, date.day));
                                        medicineTakenDates.add(DateTime(
                                            date.year, date.month, date.day));
                                        _updateTakenDatesJson(
                                            medicineTakenDates);
                                        _updateSkippedDatesJson(
                                            medicineSkippedDates);
                                      }
                                    });
                                  },
                                  child: Text(
                                    'Switch status',
                                    style: TextStyle(
                                        fontFamily: "Itim",
                                        color: Colors.white),
                                  ),
                                ),
                                
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style:
                            TextStyle(color: Colors.black, fontFamily: "Itim"),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  "Today's Activities",
                  style: TextStyle(
                      color: Colors.black, fontFamily: "Itim", fontSize: 20),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Container(
              child: medicine_reminderData.isEmpty ||
                      !medicine_reminderData.any((reminder) {
                        final reminderDate = reminder['date'] != null &&
                                reminder['date'].isNotEmpty
                            ? DateFormat('yyyy-MM-dd').parse(reminder['date']!)
                            : DateTime.now();
                        return reminderDate.year == selectedDate.year &&
                            reminderDate.month == selectedDate.month &&
                            reminderDate.day == selectedDate.day;
                      })
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
                      itemCount: medicine_reminderData.length,
                      itemBuilder: (context, index) {
                        final reminder = medicine_reminderData[index];
                        final reminderDate = reminder['date'] != null &&
                                reminder['date'].isNotEmpty
                            ? DateFormat('yyyy-MM-dd').parse(reminder['date']!)
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
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(12),
                                    height: MediaQuery.of(context).size.height *
                                        0.23,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple[900],
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.12,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.25,
                                              child: Image(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                    "assets/med.png"),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                                  DateFormat('dd-MMM-yyyy')
                                                      .format(DateTime.parse(
                                                          reminder['date'] ??
                                                              DateTime.now()
                                                                  .toString())),
                                                  style: TextStyle(
                                                    fontFamily: "Itim",
                                                    fontSize: 15,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.005,
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
                                              itemBuilder:
                                                  (BuildContext context) => [
                                                PopupMenuItem(
                                                  child: Text('Cancel'),
                                                  value: 'cancel',
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
                                        Divider(
                                          color: Colors.white70,
                                          thickness: 1,
                                          indent: 20,
                                          endIndent: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _addSkippedDates(DateTime.parse(
                                                    reminder['date'] ??
                                                        DateTime.now()
                                                            .toString()));
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
                                                _addTakenDates(DateTime.parse(
                                                    reminder['date'] ??
                                                        DateTime.now()
                                                            .toString()));
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
                                  ))
                                : Container(
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(12),
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          width: 1, color: Colors.deepPurple),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      // add image here
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.08,
                                          image: AssetImage("assets/med.png"),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .05,
                                                ),
                                                Text(
                                                  DateFormat('dd-MMM-yyyy')
                                                      .format(DateTime.parse(
                                                          reminder['date'] ??
                                                              DateTime.now()
                                                                  .toString())),
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
                                          itemBuilder: (BuildContext context) =>
                                              [
                                            PopupMenuItem(
                                              child: Text('Cancel'),
                                              value: 'cancel',
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
    );
  }
}
