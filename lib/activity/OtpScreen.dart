import 'package:appi_va/activity/Camera/Camera.dart';
import 'package:appi_va/activity/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import '../CONFIG.dart';
import '../SharedPrefrence.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phoneNumber});
  final String phoneNumber;
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  OtpFieldController otpFieldController = OtpFieldController();
  String otp = "";
  

  GetData() async {
    var collection = FirebaseFirestore.instance.collection('user_details');
    var docSnapshot = await collection.doc(widget.phoneNumber).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var value = data?['phone'];
      await SharePreference.setStringValue(CONFIG.PHONE_NUMBER, value);
      await SharePreference.setBooleanValue(CONFIG.IS_LOGIN, true);
      Navigator.pushReplacement<void, void>(
        context,
        CupertinoPageRoute<void>(
          builder: (BuildContext context) => HomeScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement<void, void>(
        context,
        CupertinoPageRoute<void>(
          builder: (BuildContext context) => Camera(
            ph_num: widget.phoneNumber,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(
            height: 60,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "   OTP Verification   ",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "   OTP has been sent to +91 ${widget.phoneNumber}   ",
              style: TextStyle(
                  fontSize: 30,
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w900),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          OTPTextField(
            controller: otpFieldController,
            length: 6,
            width: MediaQuery.of(context).size.width,
            fieldWidth: 30,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            textFieldAlignment: MainAxisAlignment.spaceEvenly,
            fieldStyle: FieldStyle.underline,
            onChanged: (value) {},
            onCompleted: (value) {
              setState(() {
                otp = value;
              });
            },
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthLoggedInState) {
                  
                  GetData();
      
                } else if (state is AuthErrorState) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.error)));
                }
              },
              builder: (context, state) {
                if (state is AuthLoadingState) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Visibility(
                  visible: (otp.length == 6) ? true : false,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                    ),
                    child: Text(
                      "Verify",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      BlocProvider.of<AuthCubit>(context).verifyOTP(otp);
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
