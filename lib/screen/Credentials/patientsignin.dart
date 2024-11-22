import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:major_vcare/screen/modules/patients_userprofile.dart';
import 'package:major_vcare/screen/patients/patients.dart';


class Patients_Signin extends StatefulWidget {
  final bool isPatient;
  const Patients_Signin({Key? key, this.isPatient = false}) : super(key: key);

  @override
  State<Patients_Signin> createState() => _Patients_SigninState();
}

  class _Patients_SigninState extends State<Patients_Signin> with SingleTickerProviderStateMixin {
    final _formKey = GlobalKey<FormState>();
    bool isLoading = true;
    late TabController tabController;

    @override
    void initState() {
      super.initState();
      tabController = TabController(length: 2, vsync: this);
    }
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color.fromRGBO(129, 71, 255, 0.7)],
                stops: [0.3, 1.0],
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image(image: const AssetImage("assets/spl.png"),
                    width: MediaQuery.of(context).size.width*.8,
                    height: MediaQuery.of(context).size.height*.3,
                  ),
                  const SizedBox(height: 50),
                  TabBar(
                    labelStyle: const TextStyle(fontFamily: "Itim"),
                    controller: tabController,
                    tabs: const [
                      Tab(
                        text: 'Sign-in',
                      ),
                      Tab(
                        text: 'Sign-up',
                      ),
                    ],
                    labelColor: Colors.black,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(129, 71, 255, 1.0),
                                        blurRadius: 25,
                                        offset: Offset(0, 10)
                                    )
                                  ]
                              ),
                              margin: const EdgeInsets.all(20.0),
                              padding: const EdgeInsets.all(5.0),
                              child: TextField(
                               controller: emailController,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: const Icon(Icons.email_outlined,
                                        color: Color.fromRGBO(129, 71, 255, 1.0)),
                                    hintText: "User name or Email",
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.white,
                                            width: 2
                                        ),
                                        borderRadius: BorderRadius.circular(20))),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(129, 71, 255, 1.0),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ]
                              ),
                              margin: const EdgeInsets.only(left: 20,
                                  right: 20,
                                  bottom: 20),
                              padding: const EdgeInsets.all(5.0),
                              child: TextField(
                                obscureText: true,
                                controller: passwordController,
                                decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.fingerprint,
                                        color: Color.fromRGBO(129, 71, 255, 1.0)),
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: "Password",
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 2,
                                            color: Colors.white
                                        ),
                                        borderRadius: BorderRadius.circular(20))),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height*.07,
                              width: MediaQuery.of(context).size.width*.83,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(15))
                                      ), backgroundColor: const Color.fromRGBO(129, 71, 255, 1.0)),
                                  onPressed: () {
                                    signIn(emailController.text, passwordController.text, context);

                                  },
                                  child: const Text(
                                    "Sign-in",
                                    style: TextStyle(fontSize: 22, fontFamily: "Itim", color: Colors.white),
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(onPressed: () {
                                resetPassword(emailController.text);
                              }, child: const Text("Forgot Password ?",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20
                                ),
                              )),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height*.05,
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(129, 71, 255, 1.0),
                                        blurRadius: 25,
                                        offset: Offset(0, 10)
                                    )
                                  ]
                              ),
                              margin: const EdgeInsets.all(20.0),
                              padding: const EdgeInsets.all(5.0),
                              child: TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: const Icon(Icons.email_outlined,
                                        color: Color.fromRGBO(129, 71, 255, 1.0)),
                                    hintText: "Email",
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.white,
                                            width: 2
                                        ),
                                        borderRadius: BorderRadius.circular(20))),
                              ),
                            ),
                           Container(
                              decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(129, 71, 255, 1.0),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ]
                              ),
                              margin: const EdgeInsets.only(left: 20,
                                  right: 20,
                                  bottom: 20),
                              padding: const EdgeInsets.all(5.0),
                              child: TextField(
                                // obscureText: true,
                                controller: passwordController,
                                decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.fingerprint,
                                        color: Color.fromRGBO(129, 71, 255, 1.0)),
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: "Password",
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 2,
                                            color: Colors.white
                                        ),
                                        borderRadius: BorderRadius.circular(20))),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height*.07,
                              width: MediaQuery.of(context).size.width*.83,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(15))
                                      ), backgroundColor: const Color.fromRGBO(129, 71, 255, 1.0)),
                                  onPressed: () {
                                    signUp(emailController.text, passwordController.text);
                                  },
                                  child: const Text(
                                    "Sign-up",
                                    style: TextStyle(color: Colors.white,fontSize: 22, fontFamily: "Itim"),
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
    Future<void> signIn(String email, String password, BuildContext context) async {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          // Get the current user
          User? user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            // Access user metadata
            UserMetadata userMetadata = user.metadata;

            // Check if user profile data exists in Firestore
            DocumentSnapshot userData = await FirebaseFirestore.instance.collection('patients').doc(user.uid).get();
            if (userData.exists) {
              // User profile data exists, navigate to home screen
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PatientScreen()));
            } else {
              // Check if the user is signing in for the first time
              if (userMetadata.creationTime == userMetadata.lastSignInTime) {
                // User is signing in for the first time, navigate to user profile screen
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Patients_UserProfile()));
              } else {
                // User is signing in again, navigate to home screen
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PatientScreen()));
              }
            }
          }
        } else {
          throw FirebaseAuthException(message: 'Error signing in. Please try again.', code: '');
        }
      } catch (e) {
        String errorMessage = 'Error signing in. Please try again.';
        if (e is FirebaseAuthException) {
          errorMessage = e.code == 'user-not-found' || e.code == 'wrong-password'
              ? 'Incorrect email or password. Please try again.'
              : errorMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }


    Future<void> signUp(String email, String password) async {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Navigate to home screen or do something else upon successful sign up
      } catch (e) {
        print(e.toString());
        // Handle sign up errors
      }
    }
    Future<void> resetPassword(String email) async {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        // Show a confirmation dialog or navigate to a screen confirming password reset request
      } catch (e) {
        print(e.toString());
        // Handle reset password errors
      }
    }
}




