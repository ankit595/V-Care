import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../modules/health_tip.dart';
import 'dart:math';

class DoctorSpeciality extends StatefulWidget {
  const DoctorSpeciality({super.key});

  @override
  State<DoctorSpeciality> createState() => _DoctorSpecialityState();
}

class _DoctorSpecialityState extends State<DoctorSpeciality> {
  @override
  // List of SVG picture strings
  final List<String> svgList = [
   """assets/icons/practitioner.svg""",
   """assets/icons/cardiology.svg""",
   """assets/icons/pediatrics.svg""",
   """assets/icons/psychology.svg""",
   """assets/icons/neurology.svg""",
   """assets/icons/dermatology.svg""",
   """assets/icons/radiology.svg""",
   """assets/icons/gynecology.svg""",
   """assets/icons/dentistry.svg""",
   """assets/icons/nephrology.svg""",
   """assets/icons/urology.svg""",
   """assets/icons/orthopedics.svg""",
  ];

  // List of names corresponding to the SVGs
  final List<String> names = [
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
    'Oncologist',
    'Pulmonologist',
    'ophthalmologist',
    // Add more names here
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text("Doctor Speciality",
        style: TextStyle(
          fontFamily: "Itim"
        ),),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage("assets/doc_back.jpg")
          )
        ),
        child: Container(
          margin: EdgeInsets.only(top: 80,bottom: 80),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Number of columns
              crossAxisSpacing: 10.0, // Spacing between columns
              mainAxisSpacing: 10.0, // Spacing between rows
            ),
            itemCount: 12, // Number of items in the grid
            itemBuilder: (context, index) {
              return Container(
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.deepPurple, backgroundColor: Colors.white,
                        elevation: 5,
                        fixedSize: const Size(80, 80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: SvgPicture.asset(
                        svgList[index],
                        color: Color(Random().nextInt(0xFFFFFFFF) | 0xFF000000),
                      ),
                      onPressed: () {},
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        names[index],
                        style: TextStyle(
                          fontSize: 15,
                            fontFamily: "Itim",
                            color: Colors.black),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}