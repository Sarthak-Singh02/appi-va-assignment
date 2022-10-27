import 'package:appi_va/CONFIG.dart';
import 'package:appi_va/activity/LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../SharedPrefrence.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String photo = "";
  String location = "";
  String dateTime = "";
  String phone = "";
  String currentLocation = "";
  String? _currentAddress;
  Position? _currentPosition;
  _getData() async {
    var collection = FirebaseFirestore.instance.collection('user_details');
    var docName = await collection
        .doc(await SharePreference.getStringValue(CONFIG.PHONE_NUMBER))
        .get();
    if (docName.exists) {
      Map<String, dynamic>? data = docName.data();
      photo = data?['photo'];
      location = data?['location'];
      phone = data?["phone"];
    }
    if (mounted) setState(() {});
  }

  _updateData(String updateData) async {
    final _fireStore = FirebaseFirestore.instance;
    await _fireStore
        .collection("user_details")
        .doc(await SharePreference.getStringValue(CONFIG.PHONE_NUMBER))
        .update(
            {'location': updateData, 'DateTime': DateTime.now().toString()});
    await _getData();
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

  _getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng(_currentPosition!);
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(52.2165157, 6.9437819);
    await placemarkFromCoordinates(_currentPosition!.latitude.toDouble(),
            _currentPosition!.longitude.toDouble())
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street.toString()}, ${place.subLocality.toString()}, ${place.subAdministrativeArea.toString()}, ${place.postalCode.toString()}';
        currentLocation = _currentAddress.toString();
      });
    }).catchError((e) {
      debugPrint(e);
    });
    await _updateData(currentLocation.toString());
  }

  @override
  void initState() {
    _handleLocationPermission();
    _getCurrentPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(currentLocation.toString());
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text("Homescreen"),
      ),
      body: (photo.isNotEmpty)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 3,
                          child: Image.network(photo),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Phone: $phone"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Location: $currentLocation"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Log in time: ${DateTime.now()}"),
                      )
                    ],
                  ),
                )
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.popUntil(context, (route) => route.isFirst);
          Future<void> _signOut() async {
            await FirebaseAuth.instance.signOut();
          }

          await SharePreference.clearSharePrefrence();
          Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const LoginScreen(),
            ),
          );
        },
        child: Icon(Icons.exit_to_app),
      ),
    );
  }
}
