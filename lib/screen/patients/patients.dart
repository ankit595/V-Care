import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:major_vcare/screen/doctors/specialitylist/cardiologists.dart';
import 'package:major_vcare/screen/doctors/specialitylist/doctorspeciality.dart';
import 'package:major_vcare/screen/doctors/specialitylist/practitioners.dart';
import 'package:major_vcare/screen/appointment/appointment.dart';
import 'package:major_vcare/screen/firstscreen.dart';
import 'package:major_vcare/screen/medicines/medicineSplash.dart';
import 'package:major_vcare/screen/modules/health_tip.dart';
import 'package:major_vcare/screen/modules/patients_userprofile.dart';



import 'package:path_provider/path_provider.dart';
import '../appointment/appointment_list.dart';
import 'med-records.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
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
      // Handle error loading appointments
    }
  }
  //
  // Future<void> _signOut() async {
  //   await FirebaseAuth.instance.signOut();
  //   // Redirect to sign-in page after sign-out
  //   Navigator.of(context).pushReplacement(
  //     MaterialPageRoute(
  //       builder: (context) =>
  //           SelectionScreen(), // Replace with your sign-in screen widget
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? ''; // Get the user ID
    print(userId);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      image: const DecorationImage(
                          image: AssetImage("assets/p.jpeg"),
                          fit: BoxFit.fill)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('patients')
                              .doc(userId)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.data() == null) {
                              return Text("User not found");
                            }

                            Map<String, dynamic> userData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            String userName = userData['name'] ?? '';
                            String userAge = userData['age'] != null
                                ? userData['age'].toString()
                                : '';
                            String profilePictureUrl = userData[
                                    'patients_profile_picture'] ??
                                ''; // Get profile picture URL from Firestore

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Hi $userName!",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "Itim",
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "Age: $userAge", // Display user's age
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontFamily: "Itim"),
                                          ),
                                          Text(
                                            "How do you feel today?",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontFamily: "Itim"),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      profilePictureUrl), // Fallback to default image if profile picture URL is empty
                                  backgroundColor: Colors.white,
                                  radius: 38,
                                ),
                              ],
                            );
                          },
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * .17,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(3),
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          fixedSize: const Size(70, 70),
                                          backgroundColor:
                                              Colors.white.withOpacity(0.6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/icons/reminder.svg",
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MedicineSplash()));
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .18,
                                          child: const Text(
                                            "Medication\n  Reminder",
                                            style: TextStyle(
                                                fontSize: 13.5,
                                                color: Colors.white,
                                                fontFamily: "Itim"),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(3),
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          fixedSize: const Size(70, 70),
                                          backgroundColor:
                                              Colors.white.withOpacity(0.6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/icons/med-records.svg",
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MedicalRecords()));
                                        },
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          "Med-Records",
                                          style: TextStyle(
                                              fontSize: 13.5,
                                              color: Colors.white,
                                              fontFamily: "Itim"),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(3),
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          fixedSize: const Size(70, 70),
                                          backgroundColor:
                                              Colors.white.withOpacity(0.6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/icons/appointment.svg",
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                       Appointment()));
                                        },
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          "Appointment",
                                          style: TextStyle(
                                              fontSize: 13.5,
                                              color: Colors.white,
                                              fontFamily: "Itim"),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(3),
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          fixedSize: const Size(70, 70),
                                          backgroundColor:
                                              Colors.white.withOpacity(0.6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                        ),
                                        child: SvgPicture.asset(
                                          "assets/icons/health-tips.svg",
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const Healthtip()));
                                        },
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          "Health-Tips",
                                          style: TextStyle(
                                              fontSize: 13.5,
                                              color: Colors.white,
                                              fontFamily: "Itim"),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "Upcoming Schedule",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: "Itim"),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AppointmentListPage()));
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
                Container(
                  child: appointments.isEmpty
                      ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width * 0.98,
                    child: Center(
                      child: Column(
                        children: [
                          Lottie.asset("assets/empty.json",
                              fit: BoxFit.cover,
                              height:
                              MediaQuery.of(context).size.height * .15),
                          const Text(
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
                      : Container(
                    height: MediaQuery.of(context).size.height * 0.23,
                    width: MediaQuery.of(context).size.width * 0.98,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: const DecorationImage(
                            image: AssetImage("assets/p.jpeg"),
                            fit: BoxFit.fill)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                    appointments[0]['doctorPicture'] ?? ''),
                                backgroundColor: Colors.white,
                                radius: 38,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.4,
                                      child: Text(
                                        appointments[0]['doctorName'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Itim",
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      appointments[0]['doctorSpecialty'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: "Itim"),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.width *
                                    .15,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Colors.white.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(15.0),
                                    ),
                                  ),
                                  child: const Icon(Icons.video_call,
                                      size: 30),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height *
                                .07,
                            child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(15.0),
                                  ),
                                  backgroundColor:
                                  Colors.white.withOpacity(0.5),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Icon(Icons.calendar_month),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(appointments[0]['date'] ?? ''),
                                    ),
                                    const Icon(Icons.access_time_filled),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(appointments[0]['time'] ?? ''),
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "Doctor Speciality",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: "Itim"),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const DoctorSpeciality()));
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
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.deepPurple,
                                  backgroundColor: Colors.white,
                                  elevation: 5,
                                  fixedSize: const Size(80, 80),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/practitioner.svg",
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Practitioners()));
                                },
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "  Practitioner",
                                  style: TextStyle(
                                      fontFamily: "Itim",
                                      color: Color.fromRGBO(119, 0, 229, 1)),
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.deepPurple,
                                  backgroundColor: Colors.white,
                                  elevation: 5,
                                  fixedSize: const Size(80, 80),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/cardiology.svg",
                                  color: Colors.deepOrange,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Cardiologists()));
                                },
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Cardiology",
                                  style: TextStyle(
                                      fontFamily: "Itim",
                                      color: Color.fromRGBO(119, 0, 229, 1)),
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.deepPurple,
                                  backgroundColor: Colors.white,
                                  elevation: 5,
                                  fixedSize: const Size(80, 80),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/pediatrics.svg",
                                  color: Colors.blue,
                                ),
                                onPressed: () {},
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Pediatrician",
                                  style: TextStyle(
                                      fontFamily: "Itim",
                                      color: Color.fromRGBO(119, 0, 229, 1)),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.deepPurple,
                                  backgroundColor: Colors.white,
                                  elevation: 5,
                                  fixedSize: const Size(80, 80),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/psychology.svg",
                                  color: Colors.brown,
                                ),
                                onPressed: () {},
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Psychiatrist",
                                  style: TextStyle(
                                      fontFamily: "Itim",
                                      color: Color.fromRGBO(119, 0, 229, 1)),
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.deepPurple,
                                  backgroundColor: Colors.white,
                                  elevation: 5,
                                  fixedSize: const Size(80, 80),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/neurology.svg",
                                  color: const Color.fromRGBO(119, 40, 165, 1),
                                ),
                                onPressed: () {},
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Neurologist",
                                  style: TextStyle(
                                      fontFamily: "Itim",
                                      color: Color.fromRGBO(119, 0, 229, 1)),
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.deepPurple,
                                  backgroundColor: Colors.white,
                                  elevation: 5,
                                  fixedSize: const Size(80, 80),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/dermatology.svg",
                                  color: const Color.fromRGBO(245, 172, 38, 1),
                                ),
                                onPressed: () {},
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Dermatologist",
                                  style: TextStyle(
                                      fontFamily: "Itim",
                                      color: Color.fromRGBO(119, 0, 229, 1)),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.deepPurple,
                                  backgroundColor: Colors.white,
                                  elevation: 5,
                                  fixedSize: const Size(80, 80),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/radiology.svg",
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {},
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Radiologist",
                                  style: TextStyle(
                                      fontFamily: "Itim",
                                      color: Color.fromRGBO(119, 0, 229, 1)),
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.deepPurple,
                                  backgroundColor: Colors.white,
                                  elevation: 5,
                                  fixedSize: const Size(80, 80),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/gynecology.svg",
                                  color: const Color.fromRGBO(196, 104, 222, 1),
                                ),
                                onPressed: () {},
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Gynecologist",
                                  style: TextStyle(
                                      fontFamily: "Itim",
                                      color: Color.fromRGBO(119, 0, 229, 1)),
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.deepPurple,
                                  backgroundColor: Colors.white,
                                  elevation: 5,
                                  fixedSize: const Size(80, 80),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/dentistry.svg",
                                  color: Colors.pink,
                                ),
                                onPressed: () {},
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Dentist",
                                  style: TextStyle(
                                      fontFamily: "Itim",
                                      color: Color.fromRGBO(119, 0, 229, 1)),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    // LAST THREE
                  ],
                )
              ],
            ),
          ),
          drawer: Drawer(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('patients')
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
                String userAge =
                    userData['age'] != null ? userData['age'].toString() : '';
                String _profilePictureUrl = userData['patients_profile_picture'] ?? '';

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
                      leading: SvgPicture.asset(
                        "assets/icons/reminder.svg",
                        color: Colors.black,
                        width: 24, // Add width and height for the SVG image
                        height: 24,
                      ),
                      title: const Text('Medication Reminder', style: TextStyle(fontFamily: "Itim",),),
                      onTap: () {
                        // Navigate to edit profile screen
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MedicineSplash())); // Close the drawer
                        // Add navigation logic here
                      },
                    ),
                    ListTile(
                      leading:SvgPicture.asset(
                        "assets/icons/med-records.svg",
                        color: Colors.black,
                        width: 24, // Add width and height for the SVG image
                        height: 24,
                      ),
                      title: const Text('Med-Records', style: TextStyle(fontFamily: "Itim",),),
                      onTap: () {
                        // Navigate to edit profile screen
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MedicalRecords())); // Close the drawer
                        // Add navigation logic here
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset(
                        "assets/icons/appointment.svg",
                        color: Colors.black,
                        width: 24, // Add width and height for the SVG image
                        height: 24,
                      ),
                      title: const Text('Appointments',style: TextStyle(fontFamily: "Itim",),),
                      onTap: () {
                        // Navigate to edit profile screen
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Appointment())); // Close the drawer
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
          )),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)!.isActive) {
      _loadAppointments();
    }
  }
}
