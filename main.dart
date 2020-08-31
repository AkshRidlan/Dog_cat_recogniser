import 'dart:ffi';
import 'dart:io';
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import 'package:tflite/tflite.dart';

Void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading;

  File _image;
  List _output;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    loadModel().then((value) {
      setState() {
        _isLoading = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dog & Cat Recogniser"),
      ),
      body: _isLoading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _image == null ? Container() : Image.file(_image),
                  SizedBox(
                    height: 16,
                  ),
                  _output == null ? Text("") : Text("${_output[0]["label"]}")
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getImage();
        },
        child: Icon(Icons.image),
      ),
    );
  }

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;
    File image;
    setState(() {
      _isLoading = true;
      image = File(pickedFile.path);
    });

    runModelOnImage(image);
  }

  runModelOnImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.5);
    setState(() {
      _isLoading = false;
      _image = image;
      _output = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
  }
}
