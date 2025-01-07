import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class FileSharingPage extends StatelessWidget {
  final String roomCode;

  const FileSharingPage({required this.roomCode, super.key});

  Future<void> _uploadFile(File file, BuildContext context) async {
    try {

      const String uploadUrl = 'https://10.0.2.2:3000/upload';

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['roomCode'] = roomCode; 
      request.files.add(
        http.MultipartFile(
          'file',
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: file.path.split('/').last,
        ),
      );


      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _pickAndUploadFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        File file = File(result.files.single.path!);
        await _uploadFile(file, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('File Sharing: $roomCode')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _pickAndUploadFile(context),
          child: const Text('Upload File'),
        ),
      ),
    );
  }
}
