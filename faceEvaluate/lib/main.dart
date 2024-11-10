import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(FaceEvaluatorApp());
}

class FaceEvaluatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FaceEvaluatorScreen(),
    );
  }
}

class FaceEvaluatorScreen extends StatefulWidget {
  @override
  _FaceEvaluatorScreenState createState() => _FaceEvaluatorScreenState();
}

class _FaceEvaluatorScreenState extends State<FaceEvaluatorScreen> {
  File? _image;
  final picker = ImagePicker();
  String result = "평가 결과가 여기에 표시됩니다.";

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://binary96.store/api/evaluate'), // 서버 주소 입력
    );

    request.files.add(await http.MultipartFile.fromPath('images', _image!.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);

        setState(() {
          result = responseData['results'][0]; // 평가 결과를 표시
        });
      } else {
        setState(() {
          result = 'Error: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('재미로 보는 얼굴 평가 ^^')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null) Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('사진 선택하기'),
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('평가받기'),
            ),
            SizedBox(height: 20),
            Text(result), // 평가 결과 표시
          ],
        ),
      ),
    );
  }
}
