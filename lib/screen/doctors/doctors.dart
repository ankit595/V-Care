import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:major_vcare/screen/firstscreen.dart';
import 'package:major_vcare/screen/modules/doc_userprofile.dart';

import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:major_vcare/screen/doctors/doc_appointments.dart';
import 'package:major_vcare/screen/doctors/patientdetails.dart';
import 'package:major_vcare/screen/doctors/statistics.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  String formattedDate = DateFormat('dd MMM, E').format(DateTime.now());
  String formattedTime = DateFormat('h:mm a').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? ''; // Get the user ID
    print(userId);
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          DoctorPage(),
          StatisticsPage(),
          Doc_AppointmentPage()
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.deepPurpleAccent,
        color: Color(0xff7700e5),
        height: 65,
        items: const <Widget>[
          Icon(
            Icons.home,
            size: 35,
            color: Colors.white,
          ),
          Icon(
            Icons.stacked_bar_chart,
            size: 35,
            color: Colors.white,
          ),
          Icon(
            Icons.person_search,
            size: 35,
            color: Colors.white,
          )
        ],
        onTap: (index) {
          _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        },
      ),
        drawer: Drawer(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('doctors')
                .doc(userId)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (!snapshot.hasData || snapshot.data!.data() == null) {
                return Text("User not found");
              }

              Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;
              String userName = userData['name'] ?? '';
              String eduction = userData['eduction']??'';
              userData['age'] != null ? userData['age'].toString() : '';
              String _profilePictureUrl = userData['doctors_profile_picture'] ?? '';

              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(userName, style: TextStyle(fontFamily: "Itim",),),
                    accountEmail: Text(user!.email ?? '', style: TextStyle(fontFamily: "Itim",),),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(_profilePictureUrl),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.edit),
                    title: const Text('Edit Profile', style: TextStyle(fontFamily: "Itim",),),
                    onTap: () {
                      // Navigate to edit profile screen
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditUserProfile())); // Close the drawer
                      // Add navigation logic here
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(fontFamily: "Itim", color: Colors.red),
                    ),
                    onTap: () async {
                      try {
                        // Perform logout action
                        await FirebaseAuth.instance.signOut();

                        // Navigate to the first screen after logout
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => FirstScreen(),
                          ),
                        );

                        // Delay for 1 second before exiting the app
                        await Future.delayed(Duration(seconds: 1));

                        // Exit the app
                        SystemNavigator.pop();
                      } catch (e) {
                        print("Error logging out: $e");
                        // Handle any logout errors here
                      }
                    },
                  ),

                ],
              );
            },
          ),
        )
    );
  }
}

class DoctorPage extends StatefulWidget {
  final String doctorName = 'Dr. Emily Garcia';
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  String formattedDate = DateFormat('dd MMM, E').format(DateTime.now());
  String formattedTime = DateFormat('h:mm a').format(DateTime.now());
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
      });
    } catch (e) {
      print('Error loading appointments: $e');
      // Handle error loading appointments
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? ''; // Get the user ID

    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('doctors').doc(userId).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return Center(child: Text("User not found"));
            }

            Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
            String userName = userData['name'] ?? '';
            String usereduction = userData['education'] ??'';
            String userspeciality = userData['specialty'] ??'';
            String profilePictureUrl = userData['doctors_profile_picture'] ?? '';

            return Column(
              children: [
                Expanded(
                  flex: 9,
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(25),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getGreetingMessage(),
                            style: TextStyle(
                              fontFamily: "itim",
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.calendar_today),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontFamily: "itim",
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(top: 20, left: 5, right: 5, bottom: 10),
                        height: MediaQuery.of(context).size.height * .15,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff7700e5), Color(0xffc591fd)],
                            stops: [0, 1],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(70),
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        userName,
                                        style: TextStyle(
                                          fontFamily: "itim",
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "$usereduction, $userspeciality ",
                                      style: TextStyle(
                                        fontFamily: "itim",
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  backgroundImage: NetworkImage(
                                      profilePictureUrl),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * .01),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => StatisticsPage()),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Material(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                              elevation: 1,
                              child: Container(
                                margin: EdgeInsets.all(10),
                                height: MediaQuery.of(context).size.height * .1,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * .2,
                                  padding: EdgeInsets.all(10),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Column(
                                      children: [
                                        Text(
                                          "Appointment Statistics",
                                          style: TextStyle(
                                            color: Color(0xff7e70fd),
                                            fontFamily: "itim",
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          "Know your statistics here!",
                                          style: TextStyle(
                                            color: Colors.black26,
                                            fontFamily: "itim",
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.only(bottom: 20),
                                child: Image(
                                  image: AssetImage("assets/stats.png"),
                                  height: MediaQuery.of(context).size.height * .15,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * .01),
                      Text(
                        "Today's Appointments",
                        style: TextStyle(
                          fontFamily: "itim",
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: appointments.isEmpty
                      ? Container(
                    height: MediaQuery.of(context).size.height * .2,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            "assets/empty.json",
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.height * .15,
                          ),
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
                      : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      childAspectRatio: 1,
                    ),
                    itemCount: appointments.where((appointment) => appointment['userId'] == userId).toList().length,
                    itemBuilder: (context, index) {
                      final filteredAppointments =
                      appointments.where((appointment) => appointment['userId'] == userId).toList();
                      if (filteredAppointments.isEmpty) {
                        return SizedBox.shrink(); // Hide if no appointments for the doctor
                      }
                      filteredAppointments.sort((a, b) {
                        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
                        final aDateTime = dateFormat.parse('${a['date']} ${a['time']}');
                        final bDateTime = dateFormat.parse('${b['date']} ${b['time']}');
                        return aDateTime.compareTo(bDateTime);
                      });
                      final appointment = filteredAppointments[index];
                      return Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [Color(0xff7700e5), Color(0xffc591fd)],
                            stops: [0, 1],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(appointment['patientProfile']),
                                backgroundColor: Colors.white,
                                radius: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      child: Text(
                                        appointment['patientName'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "Itim",
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${appointment['date']}, ${appointment['time']}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontFamily: "Itim",
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        backgroundColor: Color(0xffc086f8),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => PatientDetails(appointment: appointment)),
                                        );
                                      },
                                      child: Text(
                                        "See Details",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontFamily: "Itim",
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  String _getGreetingMessage() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning!";
    } else if (hour < 17) {
      return "Good Afternoon!";
    } else {
      return "Good Evening!";
    }
  }
}