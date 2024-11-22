import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('patients').doc(user.uid).get();

      // Update text controllers with user data
      setState(() {
        _nameController.text = snapshot['name'] ?? '';
        _contactController.text = snapshot['contact'] ?? '';
        _ageController.text = snapshot['age'] ?? '';
        _emailController.text = snapshot['email'] ?? '';

        // Fetch and store profile picture URL
        _profilePictureUrl = snapshot['profile_picture'] ?? '';
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
          final Reference storageReference = FirebaseStorage.instance.ref().child('profile_pictures/${user.uid}.jpg');
          await storageReference.putFile(_image!);
          imageUrl = await storageReference.getDownloadURL();
        }

        // Update user profile data in Firestore
        await FirebaseFirestore.instance.collection('patients').doc(user.uid).update({
          'name': _nameController.text,
          'contact': _contactController.text,
          'age': _ageController.text,
          'email': _emailController.text,
          'profile_picture': imageUrl, // Update profile picture URL
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
