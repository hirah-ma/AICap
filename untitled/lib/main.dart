import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(AICaptionsApp());
}

class AICaptionsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AICap',
      theme: ThemeData.dark(),
      home: CaptionGeneratorScreen(),
    );
  }
}

class CaptionGeneratorScreen extends StatefulWidget {
  @override
  _CaptionGeneratorScreenState createState() => _CaptionGeneratorScreenState();
}

class _CaptionGeneratorScreenState extends State<CaptionGeneratorScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  String _caption = '';
  late AnimationController _controller;
  late Animation<double> _animation;

  final ImagePicker _picker = ImagePicker();
  final String apiKey = 'API KEY HERE'; // Replace with your Gemini API key

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _caption = '';
        });
        _generateCaption();
      } else {
        print("No image selected.");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }


  Future<void> _generateCaption() async {
    if (_image == null) return;

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    final response = await model.generateContent([
      Content.data('image/jpeg', await _image!.readAsBytes()), // Convert image to bytes
      Content.text('Generate a funny or meaningful caption for this image.just one sentence,do not describe give a funny caption used to send this image for example in a chat to someone.choose and return any one caption only one sentence in your output')
    ]);

    setState(() {
      _caption = response.text ?? 'Failed to generate caption';
    });

    _controller.forward(from: 0.0);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[900],

          title: Center(
        child: Text('AICap',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, fontFamily:'Trebuchet MS' ),

      ),
      ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: Text(
              "Choose any image and get AI captions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: _image == null
                      ? Icon(Icons.add_a_photo, size: 100, color: Colors.grey)
                      : Image.file(_image!, height: 200),
                ),
                SizedBox(height: 20),
                FadeTransition(
                  opacity: _animation,
                  child: Text(
                    _caption,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text("Choose Image", style : TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}

