import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:major_vcare/screen/Credentials/doctorsignin.dart';
import 'package:major_vcare/screen/Credentials/patientsignin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:major_vcare/screen/doctors/doctors.dart';
import 'package:major_vcare/screen/patients/patients.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({Key? key}) : super(key: key);

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  @override
  void initState() {
    super.initState();
    checkUserExistenceAndRedirect();
  }

  Future<void> checkUserExistenceAndRedirect() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final isPatient = await checkUserExistence('patients', userId);
      final isDoctor = await checkUserExistence('doctors', userId);
      if (isPatient) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PatientScreen()));
      } else if (isDoctor) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DoctorScreen()));
      }
    }
  }

  Future<bool> checkUserExistence(String collection, String userId) async {
    final snapshot = await FirebaseFirestore.instance.collection(collection).doc(userId).get();
    return snapshot.exists;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Positioned(
                left: -15,
                top: -50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(500),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width * 0.4,
                    color: Colors.deepPurple,
                  ),
                )),
            Positioned(
              right: -100,
              top: -150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(500),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 1,
                  color: Color.fromRGBO(129, 71, 255, 1.0),
                ),
              ),
            ),
            Positioned(
                bottom: -20,
                left: -40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(500),
                  child: Container(
                    height: MediaQuery.of(context).size.height * .15,
                    width: MediaQuery.of(context).size.width * 0.3,
                    color: Colors.deepPurple,
                  ),
                )),
            Positioned(
                bottom: -20,
                left: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(500),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.09,
                    width: MediaQuery.of(context).size.width * 0.18,
                    color: Color.fromRGBO(129, 71, 255, 1.0),
                  ),
                )),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: 100,
              child: Container(
                clipBehavior: Clip.none,
                margin: EdgeInsets.all(5),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // await saveUserSelection('patient');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Patients_Signin(isPatient: true)));
                      },
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * .4,
                        width: MediaQuery.of(context).size.width * .7,
                        child: Card(
                          shadowColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 10,
                          margin: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * .3,
                                width: MediaQuery.of(context).size.width * .5,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image(
                                    fit: BoxFit.cover,
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                    image: AssetImage("assets/patient.jpg"),
                                  ),
                                ),
                              ),
                              Text(
                                "Patient",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        // await saveUserSelection('doctor');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return Doc_Signin(
                                  isPatient:
                                      false); // Replace 'SecondScreen' with your next screen.
                            },
                          ),
                        );
                      },
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * .4,
                        width: MediaQuery.of(context).size.width * .7,
                        child: Card(
                          shadowColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 10,
                          margin: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * .3,
                                width: MediaQuery.of(context).size.width * .5,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                        "assets/doctor.png"), // Replace with the doctor image path
                                  ),
                                ),
                              ),
                              Text(
                                "Doctor",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: -20,
                left: -40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(500),
                  child: Container(
                    height: MediaQuery.of(context).size.height * .15,
                    width: MediaQuery.of(context).size.width * 0.3,
                    color: Colors.deepPurple,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
