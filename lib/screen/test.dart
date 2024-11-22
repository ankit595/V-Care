import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class Test_MedicalRecords extends StatefulWidget {
  const Test_MedicalRecords({super.key});

  @override
  _Test_MedicalRecordsState createState() => _Test_MedicalRecordsState();
}

class _Test_MedicalRecordsState extends State<Test_MedicalRecords> {
  final List<PlatformFile> _files = [];

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
      }
    } catch (e) {
      print('Error picking files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records', style: TextStyle(fontFamily: 'itim'),),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];

                // Display a list tile for each PDF file
                return ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(file.name),
                  subtitle: Text('${file.size} bytes'),
                  onTap: () {
                    // Display the PDF in a new screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PDFViewScreen(filePath: file.path!),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _pickFiles,
          child: const Text('Select PDF Files'),
      ),
    );
  }
}

class PDFViewScreen extends StatelessWidget {
  final String filePath;

  const PDFViewScreen({super.key, required this.filePath});

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


