import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'MyLocation.dart';
import 'PlatformLevelLocationIssueHandler.dart';
import 'FeatureHolder.dart';
import 'dart:async';

class NewFeatureEntryMaker extends StatefulWidget {
  final MyLocation location;
  final PlatformLevelLocationIssueHandler platformLevelLocationIssueHandler;
  NewFeatureEntryMaker(
      {Key key,
      @required this.location,
      @required this.platformLevelLocationIssueHandler})
      : super(key: key);

  @override
  _NewFeatureEntryMakerState createState() => _NewFeatureEntryMakerState();
}

class _NewFeatureEntryMakerState extends State<NewFeatureEntryMaker> {
  // for featureName
  TextEditingController featureNameController;
  FocusNode featureNameNode;
  String errorTextFeatureName;
  // for featureDescription
  TextEditingController featureDescriptionController;
  FocusNode featureDescriptionNode;
  String errorTextFeatureDescription;
  // for longitude
  TextEditingController longitudeController;
  FocusNode longitudeNode;
  String errorTextLongitude;
  // for latitude
  TextEditingController latitudeController;
  FocusNode latitudeNode;
  String errorTextLatitude;
  // for altitude
  TextEditingController altitudeController;
  FocusNode altitudeNode;
  String errorTextAltitude;
  // for timeStamp
  TextEditingController timeStampController;
  FocusNode timeStampNode;
  String errorTextTimeStamp;
  bool _areWeGettingLocationUpdates;
  bool _isSaveButtonEnabled;
  FeatureHolder _featureHolder;

  @override
  void initState() {
    super.initState();
    _isSaveButtonEnabled = false;
    _areWeGettingLocationUpdates = false;
    featureNameController = TextEditingController(text: '');
    featureNameNode = FocusNode();
    featureDescriptionController = TextEditingController(text: '');
    featureDescriptionNode = FocusNode();
    longitudeController = TextEditingController(
        text: widget.location.longitude != null
            ? widget.location.longitude.toString()
            : '');
    longitudeNode = FocusNode();
    latitudeController = TextEditingController(
        text: widget.location.latitude != null
            ? widget.location.latitude.toString()
            : '');
    latitudeNode = FocusNode();
    altitudeController = TextEditingController(
        text: widget.location.altitude != null
            ? widget.location.altitude.toString()
            : '');
    altitudeNode = FocusNode();
    timeStampController = TextEditingController(
        text: widget.location.time != null
            ? widget.location.getParsedTimeString()
            : '');
    timeStampNode = FocusNode();
    _featureHolder = FeatureHolder(null, null, null, null);
  }

  @override
  void dispose() {
    widget.platformLevelLocationIssueHandler.methodChannel
        .invokeMethod("stopLocationUpdate")
        .then((dynamic value) {
      if (value == 1)
        widget.platformLevelLocationIssueHandler.eventChannel = null;
    });
    featureNameNode.dispose();
    featureNameController.dispose();
    featureDescriptionNode.dispose();
    featureDescriptionController.dispose();
    longitudeNode.dispose();
    longitudeController.dispose();
    latitudeNode.dispose();
    latitudeController.dispose();
    altitudeNode.dispose();
    altitudeController.dispose();
    timeStampNode.dispose();
    timeStampController.dispose();
    super.dispose();
  }

  void extractLocationData(dynamic event, MyLocation currentLocator) {
    currentLocator.longitude = event['longitude'];
    currentLocator.latitude = event['latitude'];
    currentLocator.time =
        DateTime.fromMillisecondsSinceEpoch(event['time'], isUtc: true);
    currentLocator.altitude = event['altitude'];
    currentLocator.bearing = event['bearing'];
    currentLocator.speed = event['speed'];
    currentLocator.accuracy = event['accuracy'];
    currentLocator.verticalAccuracy = event['verticalAccuracy'];
    currentLocator.bearingAccuracy = event['bearingAccuracy'];
    currentLocator.speedAccuracy = event['speedAccuracy'];
    currentLocator.provider = event['provider'];
    currentLocator.satelliteCount = event['satelliteCount'];
    return;
  }

  void _onData(dynamic event) {
    extractLocationData(event, widget.location);
    setState(() {
      longitudeController.text = widget.location.longitude.toString();
      latitudeController.text = widget.location.latitude.toString();
      altitudeController.text = widget.location.altitude.toString();
      timeStampController.text = widget.location.getParsedTimeString();
    });
  }

  void _onError(dynamic error) {
    setState(() {
      _areWeGettingLocationUpdates = false;
    });
    // doing nothing useful yet
  }

  Future<bool> requestLocationUpdate() async {
    bool retVal = false;
    await widget.platformLevelLocationIssueHandler
        .requestLocationPermission()
        .then((bool result) async {
      if (result) {
        await widget.platformLevelLocationIssueHandler
            .requestToEnableLocation()
            .then((bool resp) async {
          if (resp) {
            widget.platformLevelLocationIssueHandler.eventChannel =
                EventChannel(
                    widget.platformLevelLocationIssueHandler.eventChannelName);
            await widget.platformLevelLocationIssueHandler.methodChannel
                .invokeMethod("startLocationUpdate", <String, String>{
              "id": "0"
            }) // 0 -> google play service based location update request
                // 1 -> android platform based location update, from android.hardware.gps
                .then((dynamic value) {
              if (value == 1) {
                retVal = true;
                widget.platformLevelLocationIssueHandler.eventChannel
                    .receiveBroadcastStream()
                    .listen(_onData, onError: _onError);
                setState(() {
                  _areWeGettingLocationUpdates = true;
                });
              }
            });
          }
        });
      }
    });
    return retVal;
  }

  Future<void> stopLocationUpdate() async {
    await widget.platformLevelLocationIssueHandler.methodChannel
        .invokeMethod("stopLocationUpdate")
        .then((dynamic value) {
      if (value == 1) {
        widget.platformLevelLocationIssueHandler.eventChannel = null;
        setState(() {
          _areWeGettingLocationUpdates = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feature Saver',
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.cyanAccent,
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: <Widget>[
          Card(
            elevation: 6.0,
            color: Colors.black,
            margin:
                EdgeInsets.only(top: 8.0, bottom: 8.0, left: 4.0, right: 4.0),
            child: Container(
              margin: EdgeInsets.all(3.0),
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                  color: Colors.white54,
                  style: BorderStyle.solid,
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Feature Entry Maker",
                        style: TextStyle(
                            letterSpacing: 3.0,
                            color: Colors.cyanAccent,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.white30,
                    height: 20,
                  ),
                  TextField(
                    cursorWidth: 0.5,
                    cursorColor: Colors.cyanAccent,
                    focusNode: featureNameNode,
                    controller: featureNameController,
                    autofocus: false,
                    onTap: () {
                      if (errorTextFeatureName != null &&
                          errorTextFeatureName.isNotEmpty)
                        setState(() {
                          errorTextFeatureName = null;
                        });
                    },
                    onChanged: (String val) {
                      if (errorTextFeatureName != null &&
                          errorTextFeatureName.isNotEmpty)
                        setState(() {
                          errorTextFeatureName = null;
                        });
                    },
                    onEditingComplete: () {
                      if (featureNameController.text.isEmpty) {
                        setState(() {
                          errorTextFeatureName = "Feature Name can't be blank";
                        });
                        FocusScope.of(context).requestFocus(featureNameNode);
                      } else
                        FocusScope.of(context)
                            .requestFocus(featureDescriptionNode);
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.tealAccent,
                            style: BorderStyle.solid,
                            width: 0.3,
                          )),
                      errorText: errorTextFeatureName,
                      contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                      labelText: "Feature Name",
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    height: 20,
                  ),
                  TextField(
                    cursorWidth: 0.5,
                    maxLength: 200,
                    maxLengthEnforced: true,
                    autofocus: false,
                    cursorColor: Colors.cyanAccent,
                    focusNode: featureDescriptionNode,
                    controller: featureDescriptionController,
                    onTap: () {
                      if (featureNameController.text.isEmpty) {
                        setState(() {
                          errorTextFeatureName = "Fill up in order";
                        });
                        FocusScope.of(context).requestFocus(featureNameNode);
                      }
                      if (errorTextFeatureDescription != null &&
                          errorTextFeatureDescription.isNotEmpty)
                        setState(() {
                          errorTextFeatureDescription = null;
                        });
                    },
                    onChanged: (String val) {
                      if (featureNameController.text.isEmpty) {
                        setState(() {
                          errorTextFeatureName = "Fill up in order";
                        });
                        featureDescriptionController.text = '';
                        FocusScope.of(context).requestFocus(featureNameNode);
                      }
                      if (errorTextFeatureDescription != null &&
                          errorTextFeatureDescription.isNotEmpty)
                        setState(() {
                          errorTextFeatureDescription = null;
                        });
                    },
                    onEditingComplete: () {
                      if (featureDescriptionController.text.isEmpty) {
                        setState(() {
                          errorTextFeatureDescription =
                              "Feature Description can't be blank";
                        });
                        FocusScope.of(context)
                            .requestFocus(featureDescriptionNode);
                      } else
                        FocusScope.of(context).requestFocus(longitudeNode);
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.tealAccent,
                            style: BorderStyle.solid,
                            width: 0.3,
                          )),
                      errorText: errorTextFeatureDescription,
                      contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                      labelText: "Feature Description",
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    height: 20,
                  ),
                  TextField(
                    cursorWidth: 0.5,
                    cursorColor: Colors.cyanAccent,
                    autofocus: false,
                    focusNode: longitudeNode,
                    controller: longitudeController,
                    onTap: () {
                      if (featureDescriptionController.text.isEmpty) {
                        setState(() {
                          errorTextFeatureDescription = "Fill up in order";
                        });
                        FocusScope.of(context)
                            .requestFocus(featureDescriptionNode);
                      }
                      if (errorTextLongitude != null &&
                          errorTextLongitude.isNotEmpty)
                        setState(() {
                          errorTextLongitude = null;
                        });
                    },
                    onChanged: (String val) {
                      if (errorTextLongitude != null &&
                          errorTextLongitude.isNotEmpty)
                        setState(() {
                          errorTextLongitude = null;
                        });
                    },
                    onEditingComplete: () {
                      if (longitudeController.text.isEmpty) {
                        setState(() {
                          errorTextLongitude = "Longitude can't be blank";
                        });
                        FocusScope.of(context).requestFocus(longitudeNode);
                      } else
                        FocusScope.of(context).requestFocus(latitudeNode);
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.tealAccent,
                            style: BorderStyle.solid,
                            width: 0.3,
                          )),
                      errorText: errorTextLongitude,
                      contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                      labelText: "Longitude",
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    height: 20,
                  ),
                  TextField(
                    cursorWidth: 0.5,
                    autofocus: false,
                    cursorColor: Colors.cyanAccent,
                    focusNode: latitudeNode,
                    controller: latitudeController,
                    onTap: () {
                      if (longitudeController.text.isEmpty) {
                        setState(() {
                          errorTextLongitude = "Fill up in order";
                        });
                        FocusScope.of(context).requestFocus(longitudeNode);
                      }
                      if (errorTextLatitude != null &&
                          errorTextLatitude.isNotEmpty)
                        setState(() {
                          errorTextLatitude = null;
                        });
                    },
                    onChanged: (String val) {
                      if (errorTextLatitude != null &&
                          errorTextLatitude.isNotEmpty)
                        setState(() {
                          errorTextLatitude = null;
                        });
                    },
                    onEditingComplete: () {
                      if (latitudeController.text.isEmpty) {
                        setState(() {
                          errorTextLatitude = "Latitude can't be blank";
                        });
                        FocusScope.of(context).requestFocus(latitudeNode);
                      } else
                        FocusScope.of(context).requestFocus(altitudeNode);
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.tealAccent,
                            style: BorderStyle.solid,
                            width: 0.3,
                          )),
                      errorText: errorTextLatitude,
                      contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                      labelText: "Latitude",
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    height: 20,
                  ),
                  TextField(
                    cursorWidth: 0.5,
                    autofocus: false,
                    cursorColor: Colors.cyanAccent,
                    focusNode: altitudeNode,
                    controller: altitudeController,
                    onTap: () {
                      if (latitudeController.text.isEmpty) {
                        setState(() {
                          errorTextLatitude = "Fill up in order";
                        });
                        FocusScope.of(context).requestFocus(latitudeNode);
                      }
                      if (errorTextAltitude != null &&
                          errorTextAltitude.isNotEmpty)
                        setState(() {
                          errorTextAltitude = null;
                        });
                    },
                    onChanged: (String val) {
                      if (errorTextAltitude != null &&
                          errorTextAltitude.isNotEmpty)
                        setState(() {
                          errorTextAltitude = null;
                        });
                    },
                    onEditingComplete: () {
                      if (altitudeController.text.isEmpty) {
                        setState(() {
                          errorTextAltitude = "Altitude can't be blank";
                        });
                        FocusScope.of(context).requestFocus(altitudeNode);
                      } else
                        FocusScope.of(context).requestFocus(timeStampNode);
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.tealAccent,
                            style: BorderStyle.solid,
                            width: 0.3,
                          )),
                      errorText: errorTextAltitude,
                      contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                      labelText: "Altitude",
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    height: 20,
                  ),
                  TextField(
                    cursorWidth: 0.5,
                    autofocus: false,
                    cursorColor: Colors.cyanAccent,
                    focusNode: timeStampNode,
                    controller: timeStampController,
                    onTap: () {
                      if (altitudeController.text.isEmpty) {
                        setState(() {
                          errorTextAltitude = "Fill up in order";
                        });
                        FocusScope.of(context).requestFocus(altitudeNode);
                      }
                      if (errorTextTimeStamp != null &&
                          errorTextTimeStamp.isNotEmpty)
                        setState(() {
                          errorTextTimeStamp = null;
                        });
                    },
                    onChanged: (String val) {
                      if (errorTextTimeStamp != null &&
                          errorTextTimeStamp.isNotEmpty)
                        setState(() {
                          errorTextTimeStamp = null;
                        });
                    },
                    onEditingComplete: () {
                      if (timeStampController.text.isEmpty) {
                        setState(() {
                          errorTextTimeStamp = "Time Stamp can't be blank";
                        });
                        FocusScope.of(context).requestFocus(timeStampNode);
                      } else{
                        timeStampNode.unfocus();
                        setState(() {
                          _isSaveButtonEnabled = true;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            color: Colors.tealAccent,
                            style: BorderStyle.solid,
                            width: 0.3,
                          )),
                      errorText: errorTextTimeStamp,
                      contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                      labelText: "Time Stamp",
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Builder(
                        builder: (BuildContext ctx) {
                          return RaisedButton(
                            onPressed: _isSaveButtonEnabled
                                ? () {
                                    if (featureNameController.text.isEmpty) {
                                      setState(() {
                                        errorTextFeatureName =
                                            "Feature Name can't be blank";
                                      });
                                      FocusScope.of(context)
                                          .requestFocus(featureNameNode);
                                    } else {
                                      if (featureDescriptionController
                                          .text.isEmpty) {
                                        setState(() {
                                          errorTextFeatureDescription =
                                              "Feature Description can't be blank";
                                        });
                                        FocusScope.of(context).requestFocus(
                                            featureDescriptionNode);
                                      } else {
                                        if (longitudeController.text.isEmpty) {
                                          setState(() {
                                            errorTextLongitude =
                                                "Longitude can't be blank";
                                          });
                                          FocusScope.of(context)
                                              .requestFocus(longitudeNode);
                                        } else {
                                          if (latitudeController.text.isEmpty) {
                                            setState(() {
                                              errorTextLatitude =
                                                  "Latitude can't be blank";
                                            });
                                            FocusScope.of(context)
                                                .requestFocus(latitudeNode);
                                          } else {
                                            if (altitudeController
                                                .text.isEmpty) {
                                              setState(() {
                                                errorTextAltitude =
                                                    "Altitude can't be blank";
                                              });
                                              FocusScope.of(context)
                                                  .requestFocus(altitudeNode);
                                            } else {
                                              if (timeStampController
                                                  .text.isEmpty) {
                                                setState(() {
                                                  errorTextTimeStamp =
                                                      "Time Stamp can't be blank";
                                                });
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        timeStampNode);
                                              } else {
                                                _featureHolder.featureName =
                                                    featureNameController
                                                        .text;
                                                _featureHolder
                                                    .moreInfoOnFeature =
                                                    featureDescriptionController
                                                        .text;
                                                _featureHolder.featureType =
                                                '0'; // because these are point geometry
                                                _featureHolder
                                                    .featureLocation = [
                                                  FeatureLocation(
                                                      longitudeController
                                                          .text,
                                                      latitudeController.text,
                                                      altitudeController.text,
                                                      timeStampController
                                                          .text)
                                                ];
                                                widget
                                                    .platformLevelLocationIssueHandler
                                                    .methodChannel
                                                    .invokeMethod(
                                                    "getLastUsedFeatureId")
                                                    .then((dynamic value) {
                                                  int featureId =
                                                  value as int;
                                                  widget
                                                      .platformLevelLocationIssueHandler
                                                      .methodChannel
                                                      .invokeMethod(
                                                      "storeFeature", <
                                                      String,
                                                      dynamic>{
                                                    "featureId":
                                                    featureId + 1,
                                                    "feature": _featureHolder
                                                        .featureLocation
                                                        .map((FeatureLocation
                                                    fL) {
                                                      return <String, String>{
                                                        "featureName":
                                                        _featureHolder
                                                            .featureName,
                                                        "featureDescription":
                                                        _featureHolder
                                                            .moreInfoOnFeature,
                                                        "featureType":
                                                        _featureHolder
                                                            .featureType,
                                                        "longitude":
                                                        fL.longitude,
                                                        "latitude":
                                                        fL.latitude,
                                                        "altitude":
                                                        fL.altitude,
                                                        "timeStamp":
                                                        fL.timeStamp,
                                                      };
                                                    }).toList(),
                                                  }).then((dynamic val) {
                                                    val == 1
                                                        ? Scaffold.of(ctx)
                                                        .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "Saved Feature",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          duration:
                                                          Duration(
                                                              seconds:
                                                              2),
                                                          backgroundColor:
                                                          Colors.green,
                                                        ))
                                                        : Scaffold.of(ctx)
                                                        .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "Failed to save Feature",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          duration:
                                                          Duration(
                                                              seconds:
                                                              2),
                                                          backgroundColor:
                                                          Colors.red,
                                                        ));
                                                  });
                                                });
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                : null,
                            elevation: 12.0,
                            child: Text("Save"),
                            color: Colors.cyanAccent,
                            textColor: Colors.white,
                            disabledColor: Colors.grey,
                            disabledTextColor: Colors.white54,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (BuildContext ctx) {
          return FloatingActionButton(
            highlightElevation: 4.0,
            onPressed: !_areWeGettingLocationUpdates
                ? () {
                    requestLocationUpdate().then((bool val) {
                      if (val)
                        Scaffold.of(ctx).showSnackBar(SnackBar(
                          content: Text(
                            "I'll keep updating newly appeared fields for you",
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ));
                    });
                  }
                : stopLocationUpdate,
            tooltip: !_areWeGettingLocationUpdates
                ? 'Request Current Location'
                : 'Stop Getting Location Update',
            child: !_areWeGettingLocationUpdates
                ? Icon(
                    Icons.my_location,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.stop,
                    color: Colors.white,
                  ),
            backgroundColor:
                !_areWeGettingLocationUpdates ? Colors.cyanAccent : Colors.red,
          );
        },
      ),
    );
  }
}
