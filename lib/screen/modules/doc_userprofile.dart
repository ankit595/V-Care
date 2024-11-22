import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:major_vcare/screen/doctors/doctors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class Doc_UserProfile extends StatefulWidget {
  const Doc_UserProfile({Key? key}) : super(key: key);

  @override
  _Doc_UserProfileState createState() => _Doc_UserProfileState();
}

class _Doc_UserProfileState extends State<Doc_UserProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  File? _image;
  String? _selectedSpecialty;
  List<String> specialties = [
    'Practitioner',
    'Cardiology',
    'Pediatrician',
    'Psychiatrist',
    'Neurologist',
    'Dermatologist',
    'Radiologist',
    'Gynecologist',
    'Dentist',
    'Nephrologist',
    'Urologist',
    'Orthopedist',
  ];

  Map<String, List<String>> doctorNamesBySpecialty = {
    'Practitioner': [],
    'Cardiology': [],
    'Pediatrician': [],
    'Psychiatrist': [],
    'Neurologist': [],
    'Dermatologist': [],
    'Radiologist': [],
    'Gynecologist': [],
    'Dentist': [],
    'Nephrologist': [],
    'Urologist': [],
    'Orthopedist': [],
  };

  Map<String, List<Map<String, String>>> doctorDetails = {
    'Practitioner': [],
    'Cardiology': [],
    'Pediatrician': [],
    'Psychiatrist': [],
    'Neurologist': [],
    'Dermatologist': [],
    'Radiologist': [],
    'Gynecologist': [],
    'Dentist': [],
    'Nephrologist': [],
    'Urologist': [],
    'Orthopedist': [],
  };

  Future<void> _saveUserProfile() async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String imageUrl = '';
        if (_image != null) {
          // Upload profile picture to Firebase Storage
          final Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('doctors_profile_picture/${user.uid}.jpg');
          await storageReference.putFile(_image!);
          imageUrl = await storageReference.getDownloadURL();
        }

        // Update user profile data in Firestore
        await FirebaseFirestore.instance.collection('doctors').doc(user.uid).set({
          'userId': user.uid,
          'name': _nameController.text,
          'contact': _contactController.text,
          'age': _ageController.text,
          'email': _emailController.text,
          'education': _educationController.text,
          'doctors_profile_picture': imageUrl, // Add profile picture URL
          'specialty': _selectedSpecialty,
          'doctor_details': doctorDetails[_selectedSpecialty],
        });

        // Add doctor's name to specialty list
        doctorNamesBySpecialty[_selectedSpecialty!]?.add(_nameController.text);

        // Navigate to the home screen or any other screen
        Navigator.push(context, MaterialPageRoute(builder: (context)=> DoctorScreen()));
      }
    } catch (e) {
      print('Error saving user profile: $e');
      // Handle errors
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _image != null ? FileImage(_image!) : null,
              ),
              ElevatedButton(
                onPressed: _getImage,
                child: Text('Select Image'),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.person,
                        color: Color.fromRGBO(129, 71, 255, 1.0)),
                    hintText: "Name",
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1
                        ),
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _contactController,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.contact_phone_outlined,
                        color: Color.fromRGBO(129, 71, 255, 1.0)),
                    hintText: "Contact",
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1
                        ),
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.date_range_outlined,
                        color: Color.fromRGBO(129, 71, 255, 1.0)),
                    hintText: "Age",
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1
                        ),
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: Color.fromRGBO(129, 71, 255, 1.0)),
                    hintText: "Email",
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1
                        ),
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _educationController,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.school_outlined,
                        color: Color.fromRGBO(129, 71, 255, 1.0)),
                    hintText: "Education",
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1
                        ),
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedSpecialty,
                onChanged: (newValue) {
                  setState(() {
                    _selectedSpecialty = newValue;
                  });
                },
                items: specialties.map((specialty) {
                  return DropdownMenuItem<String>(
                    value: specialty,
                    child: Text(specialty),
                  );
                }).toList(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Select Specialty',
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUserProfile,
                child: Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class EditUserProfile extends StatefulWidget {
  const EditUserProfile({Key? key}) : super(key: key);

  @override
  _EditUserProfileState createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _image;
  String _profilePictureUrl = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // Get current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch user data from Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('doctors').doc(user.uid).get();

      // Update text controllers with user data
      setState(() {
        _nameController.text = snapshot['name'] ?? '';
        _contactController.text = snapshot['contact'] ?? '';
        _ageController.text = snapshot['age'] ?? '';
        _emailController.text = snapshot['email'] ?? '';

        // Fetch and store profile picture URL
        _profilePictureUrl = snapshot['doctors_profile_picture'] ?? '';
      });
    }
  }

  Future<void> saveUserProfile() async {
    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String imageUrl = _profilePictureUrl; // Initialize with existing URL

        if (_image != null) {
          // Upload new profile picture to Firebase Storage
          final Reference storageReference = FirebaseStorage.instance.ref().child('doctors_profile_picture/${user.uid}.jpg');
          await storageReference.putFile(_image!);
          imageUrl = await storageReference.getDownloadURL();
        }

        // Update user profile data in Firestore
        await FirebaseFirestore.instance.collection('doctors').doc(user.uid).update({
          'name': _nameController.text,
          'contact': _contactController.text,
          'age': _ageController.text,
          'email': _emailController.text,
          'doctors_profile_picture': imageUrl, // Update profile picture URL
        });

        // Navigate back to previous screen
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error saving user profile: $e');
      // Handle errors
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(fontFamily: "Itim"),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _getImage,
              child: _image != null
                  ? CircleAvatar(
                radius: 50,
                backgroundImage: FileImage(_image!),
              )
                  : _profilePictureUrl.isNotEmpty
                  ? CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_profilePictureUrl),
                child: Icon(Icons.add_a_photo, color: Colors.white,),
              )
                  : CircleAvatar(
                radius: 50,
                child: Icon(Icons.add_a_photo),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name', labelStyle: TextStyle(fontFamily: "Itim")),
              style: TextStyle(fontFamily: "Itim"),
            ),
            TextField(
              controller: _contactController,
              style: TextStyle(fontFamily: "Itim"),
              decoration: InputDecoration(labelText: 'Contact', labelStyle: TextStyle(fontFamily: "Itim")),
            ),
            TextField(
              controller: _ageController,
              style: TextStyle(fontFamily: "Itim"),
              decoration: InputDecoration(labelText: 'Age', labelStyle: TextStyle(fontFamily: "Itim")),
            ),
            TextField(
              controller: _emailController,
              style: TextStyle(fontFamily: "Itim"),
              decoration: InputDecoration(labelText: 'Email', labelStyle: TextStyle(fontFamily: "Itim")),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveUserProfile,
              child: Text(
                'Save Profile',
                style: TextStyle(fontFamily: "Itim"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
