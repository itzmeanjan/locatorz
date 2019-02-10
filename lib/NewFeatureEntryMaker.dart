import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'MyLocation.dart';
import 'PlatformLevelLocationIssueHandler.dart';

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
  TextEditingController featureNameController;
  FocusNode featureNameNode;
  String errorTextFeatureName;
  TextEditingController featureDescriptionController;
  FocusNode featureDescriptionNode;
  String errorTextFeatureDescription;
  TextEditingController longitudeController;
  FocusNode longitudeNode;
  String errorTextLongitude;
  TextEditingController latitudeController;
  FocusNode latitudeNode;
  String errorTextLatitude;
  int featureTypeValue;
  bool _areWeGettingLocationUpdates;
  bool _isSaveButtonEnabled;

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
  }

  @override
  void dispose() {
    featureNameNode.dispose();
    featureDescriptionNode.dispose();
    longitudeNode.dispose();
    latitudeNode.dispose();
    super.dispose();
  }

  void saveEntry() {}

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
    });
  }

  void _onError(dynamic error) {
    setState(() {
      _areWeGettingLocationUpdates = false;
    });
    // doing nothing useful yet
  }

  void requestLocationUpdate() {
    widget.platformLevelLocationIssueHandler
        .requestLocationPermission()
        .then((bool result) {
      if (result) {
        widget.platformLevelLocationIssueHandler
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
  }

  void stopLocationUpdate() {
    widget.platformLevelLocationIssueHandler.methodChannel
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
          'Feature Collector',
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
                    maxLines: 1,
                    cursorColor: Colors.cyanAccent,
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
                    focusNode: featureNameNode,
                    controller: featureNameController,
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
                  ),
                  Divider(
                    color: Colors.black,
                    height: 20,
                  ),
                  TextField(
                    cursorWidth: 0.5,
                    maxLength: 200,
                    maxLengthEnforced: true,
                    cursorColor: Colors.cyanAccent,
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
                  ),
                  Divider(
                    color: Colors.black,
                    height: 20,
                  ),
                  TextField(
                    cursorWidth: 0.5,
                    maxLines: 1,
                    cursorColor: Colors.cyanAccent,
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
                  ),
                  Divider(
                    color: Colors.black,
                    height: 20,
                  ),
                  TextField(
                    cursorWidth: 0.5,
                    maxLines: 1,
                    cursorColor: Colors.cyanAccent,
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
                        latitudeNode.unfocus();
                    },
                  ),
                  Divider(
                    color: Colors.black,
                    height: 20,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Radio<int>(
                          value: 0,
                          groupValue: featureTypeValue,
                          onChanged: (int val) {
                            if (featureDescriptionController.text.isEmpty) {
                              setState(() {
                                errorTextFeatureDescription =
                                    "Fill up in order";
                              });
                              FocusScope.of(context)
                                  .requestFocus(featureDescriptionNode);
                            } else {
                              setState(() {
                                featureTypeValue = val;
                                _isSaveButtonEnabled = true;
                              });
                            }
                          }),
                      Text("Point"),
                      Radio(
                          value: 1,
                          groupValue: featureTypeValue,
                          onChanged: (int val) {
                            if (featureDescriptionController.text.isEmpty) {
                              setState(() {
                                errorTextFeatureDescription =
                                    "Fill up in order";
                              });
                              FocusScope.of(context)
                                  .requestFocus(featureDescriptionNode);
                            } else {
                              setState(() {
                                featureTypeValue = val;
                                _isSaveButtonEnabled = true;
                              });
                            }
                          }),
                      Text("Line"),
                      Radio(
                          value: 2,
                          groupValue: featureTypeValue,
                          onChanged: (int val) {
                            if (featureDescriptionController.text.isEmpty) {
                              setState(() {
                                errorTextFeatureDescription =
                                    "Fill up in order";
                              });
                              FocusScope.of(context)
                                  .requestFocus(featureDescriptionNode);
                            } else {
                              setState(() {
                                featureTypeValue = val;
                                _isSaveButtonEnabled = true;
                              });
                            }
                          }),
                      Text("Polygon"),
                    ],
                  ),
                  Divider(
                    color: Colors.black,
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: _isSaveButtonEnabled ? saveEntry : null,
                        elevation: 12.0,
                        child: Text("Save"),
                        color: Colors.cyanAccent,
                        textColor: Colors.white,
                        disabledColor: Colors.grey,
                        disabledTextColor: Colors.white54,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        highlightElevation: 4.0,
        onPressed: !_areWeGettingLocationUpdates
            ? requestLocationUpdate
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
      ),
    );
  }
}
