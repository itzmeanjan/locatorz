import 'package:flutter/services.dart';
import 'dart:async';

class PlatformLevelLocationIssueHandler {
  MethodChannel methodChannel;
  String methodChannelName;
  EventChannel eventChannel;
  String eventChannelName;
  PlatformLevelLocationIssueHandler(this.methodChannel, this.methodChannelName,
      this.eventChannel, this.eventChannelName);

  Future<bool> requestLocationPermission() async {
    // First Call it and check whether location permission is available or not
    bool result;
    try {
      await methodChannel
          .invokeMethod('requestLocationPermission')
          .then((dynamic value) {
        result = value == 1;
      });
    } on PlatformException {
      // doing nothing useful yet
      result = false;
    }
    return result;
  }

  Future<bool> requestToEnableLocation() async {
    // After that you may call it to request user for enabling location
    bool result;
    try {
      await methodChannel.invokeMethod('enableLocation').then((dynamic value) {
        result = value == 1;
      });
    } on PlatformException {
      result = false;
    }
    return result;
  }
}
