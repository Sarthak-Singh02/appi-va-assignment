import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SharePreference {
  static setStringValue(String keyword, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(keyword, value);
  }

  static getStringValue(String keyword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? value = prefs.getString(keyword) ?? "";
    return value;
  }

  static setBooleanValue(String keyword, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(keyword, value);
  }

  static getBooleanValue(String keyword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyword) ?? false;
  }

  static clearSharePrefrence() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
   await preference.clear();
  }
}
