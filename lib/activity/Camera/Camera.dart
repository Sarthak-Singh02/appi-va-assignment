// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:appi_va/CONFIG.dart';
import 'package:appi_va/SharedPrefrence.dart';
import 'package:appi_va/activity/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class Camera extends StatefulWidget {
  final String ph_num;
  const Camera({
    Key? key,
    required this.ph_num,
  }) : super(key: key);

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  var _image;
  var _imageAsBytes;
  var url;
  final imagePicker = ImagePicker();
  String? _currentAddress;
  Position? _currentPosition;
  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  registerUser() async {
    final _fireStore = FirebaseFirestore.instance;
    await _fireStore
        .collection("user_details")
        .doc(widget.ph_num.toString())
        .set({
      'phone': widget.ph_num.toString(),
      'photo': url,
      'DateTime': DateTime.now().toString(),
      
    });
  }

  Future captureImage() async {
    final image = await imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      try {
        _image = File(image!.path);
        _imageAsBytes = File(image.path).readAsBytesSync();
      } catch (e) {
        print("Image cannot be empty");
      }
    });
  }

  Future getImage() async {
    final image = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      try {
        _image = File(image!.path);
        _imageAsBytes = File(image.path).readAsBytesSync();
      } catch (e) {
        print("Image cannot be empty");
      }
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  uploadPic() async {
    final ref = FirebaseStorage.instance.ref(widget.ph_num);
    await ref.putFile(_image);
    url = await ref.getDownloadURL();
    registerUser();
  }

  @override
  void initState() {
    _handleLocationPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Photo"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: _image == null
                  ? Text("No Image Selected")
                  : Container(
                      height: MediaQuery.of(context).size.height / 2,
                      width: MediaQuery.of(context).size.width,
                      child: Image.file(_image)),
            ),
            SizedBox(
              height: 15,
            ),
            Visibility(
              visible: _image == null ? false : true,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                          Size.fromWidth(MediaQuery.of(context).size.width)),
                    ),
                    onPressed: () async {
                      showLoaderDialog(context);
                      await uploadPic();
                      await SharePreference.setBooleanValue(
                          CONFIG.IS_LOGIN, true);
                      await SharePreference.setStringValue(
                          CONFIG.PHONE_NUMBER, widget.ph_num);
                      Navigator.pop(context);
                      Navigator.pushReplacement<void, void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const HomeScreen(),
                        ),
                      );
                    },
                    child: Text("Next")),
              ),
            )
          ],
        ),
        persistentFooterButtons: [
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.camera),
            onPressed: () {
              captureImage();
            },
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.photo),
            onPressed: () {
              getImage();
            },
          ),
        ]);
  }
}
