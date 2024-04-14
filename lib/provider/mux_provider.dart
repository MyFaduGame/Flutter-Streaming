//Third Party Imports
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_streaming/models/mux_model.dart';
import 'package:flutter_streaming/repository/mux_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MuxProvider extends ChangeNotifier {
  final repo = MuxRepo();
  MuxLiveData? liveData;
  List<MuxLiveData>? liveStreams;
  bool isLoading = false;

  Future<dynamic> getStreamkey() async {
    try {
      isLoading = true;
      Map<String, dynamic> responseData = await repo.streamKey();
      if (responseData['status_code'] == 200) {
        liveData = MuxLiveData.fromJson(responseData['data']);
        SharedPreferences myPrefs = await SharedPreferences.getInstance();
        myPrefs.setString("Stream Key", liveData?.streamKey??"");
        isLoading = false;
        notifyListeners();
        return liveData;
      } else {
        log(responseData.toString(), name: 'logging');
      }
    } catch (e) {
      log("$e", name: "Error in User Profile Get");
    }
  }

  Future<dynamic> getListStreams() async {
    try {
      isLoading = true;
      Map<String, dynamic> responseData = await repo.getListStreams();
      if (responseData['status_code'] == 200) {
        liveStreams = List<MuxLiveData>.from(
            responseData["data"]!.map((x) => MuxLiveData.fromJson(x)));
        // SharedPreferences myPrefs = await SharedPreferences.getInstance();
        // myPrefs.setString("Stream Key", liveData?.streamKey??"");
        isLoading = false;
        notifyListeners();
        return liveData;
      } else {
        log(responseData.toString(), name: 'logging');
      }
    } catch (e) {
      log("$e", name: "Error in User Profile Get");
    }
  }

}
