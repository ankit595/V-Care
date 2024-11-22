import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicalRecords extends StatefulWidget {
  const MedicalRecords({Key? key}) : super(key: key);

  @override
  _MedicalRecordsState createState() => _MedicalRecordsState();
}

class _MedicalRecordsState extends State<MedicalRecords> {
  final List<PlatformFile> _files = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  // Load files from SharedPreferences
  Future<void> _loadFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? filesJson = prefs.getStringList('files');
    if (filesJson != null) {
      List<PlatformFile> loadedFiles = filesJson
          .map((e) => jsonDecode(e))
          .map((e) => PlatformFile(
        name: e['name'],
        path: e['path'],
        size: e['size'],
      ))
          .toList();
      setState(() {
        _files.clear(); // Clear existing files before adding loaded files
        _files.addAll(loadedFiles);
      });
    }
  }


  // Save files to SharedPreferences
  Future<void> _saveFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> filesJson = _files.map((file) {
      return jsonEncode({
        'name': file.name,
        'path': file.path,
        'size': file.size,
      });
    }).toList();
    prefs.setStringList('files', filesJson);
  }

  // Function to pick PDF files
  Future<void> _pickFiles() async {
    try {
      // Allow the user to pick multiple PDF files
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _files.addAll(result.files);
        });
        _saveFiles(); // Save files after picking
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }
  void _deleteFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
    _saveFiles(); // Save files after deletion
  }

  // Convert bytes to megabytes
  double _bytesToMB(int bytes) {
    return bytes / (1024 * 1024);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Records',
          style: TextStyle(fontFamily: 'itim'),
        ),
      ),
      body: _files.isEmpty
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
                'No records found.',
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
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index];

          // Display a list tile for each PDF file
          return ListTile(
            leading: const Icon(Icons.picture_as_pdf_rounded , color: Colors.red,),
            title: Text(file.name),
            subtitle: Text('${_bytesToMB(file.size).toStringAsFixed(2)} MB'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteFile(index);
              },
            ),
            onTap: () {
              // Display the PDF in a new screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PDFViewScreen(filePath: file.path!),
                ),
              ).then((_) {
                // Reload files when returning from PDFViewScreen
                _loadFiles();
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFiles,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PDFViewScreen extends StatelessWidget {
  final String filePath;

  const PDFViewScreen({Key? key, required this.filePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View PDF'),
      ),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}
