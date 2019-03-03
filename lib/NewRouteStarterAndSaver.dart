import 'package:flutter/material.dart';
import 'MyLocation.dart';
import 'PlatformLevelLocationIssueHandler.dart';
import 'RouteInfoHolder.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'FeatureHolder.dart';

class NewRouteStarterAndSaver extends StatefulWidget {
  final MyLocation location;
  final PlatformLevelLocationIssueHandler platformLevelLocationIssueHandler;

  NewRouteStarterAndSaver(
      {Key key,
      @required this.location,
      @required this.platformLevelLocationIssueHandler})
      : super(key: key);

  @override
  _NewRouteStarterAndSaverState createState() =>
      _NewRouteStarterAndSaverState();
}

class _NewRouteStarterAndSaverState extends State<NewRouteStarterAndSaver> {
  RouteInfoHolder _routeInfoHolder;
  List<Widget> _locationTraceWidgets;
  bool _isAlreadySaved;
  FeatureHolder _featureHolder;

  @override
  void initState() {
    super.initState();
    _isAlreadySaved = false;
    _locationTraceWidgets = [];
    _routeInfoHolder = RouteInfoHolder(
        LocationDataChunk(
            widget.location.longitude,
            widget.location.latitude,
            widget.location.time,
            widget.location.altitude,
            widget.location.accuracy,
            widget.location.speed != null
                ? widget.location.getSpeedInKiloMetersPerHour()
                : 0.0),
        [
          LocationDataChunk(
              widget.location.longitude,
              widget.location.latitude,
              widget.location.time,
              widget.location.altitude,
              widget.location.accuracy,
              widget.location.speed != null
                  ? widget.location.getSpeedInKiloMetersPerHour()
                  : 0.0)
        ]);
    _routeInfoHolder.avgSpeed = 0.0;
    _routeInfoHolder.duration = 0;
    _routeInfoHolder.distanceCovered = 0.0;
    requestLocationUpdate();
    _featureHolder = FeatureHolder(null, null, null, null);
  }

  @override
  void dispose() {
    stopLocationUpdate();
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
    if (event['provider'] == 'network') return;
    if (event['longitude'] ==
            _routeInfoHolder
                .locationTrace[_routeInfoHolder.locationTrace.length - 1]
                .longitude &&
        event['latitude'] ==
            _routeInfoHolder
                .locationTrace[_routeInfoHolder.locationTrace.length - 1]
                .latitude) return;
    setState(() {
      extractLocationData(event, widget.location);
      if (_routeInfoHolder.startLocation.longitude == null ||
          _routeInfoHolder.startLocation.latitude == null) {
        _routeInfoHolder.startLocation = LocationDataChunk(
            widget.location.longitude,
            widget.location.latitude,
            widget.location.time,
            widget.location.altitude,
            widget.location.accuracy,
            widget.location.getSpeedInKiloMetersPerHour());
        _routeInfoHolder.locationTrace = [_routeInfoHolder.startLocation];
        _routeInfoHolder.duration = 0; // as start location got changed
      } else {
        _routeInfoHolder.addNewLocationData(LocationDataChunk(
            widget.location.longitude,
            widget.location.latitude,
            widget.location.time,
            widget.location.altitude,
            widget.location.accuracy,
            widget.location.getSpeedInKiloMetersPerHour()));
        _routeInfoHolder.duration = (_routeInfoHolder
                    .locationTrace[_routeInfoHolder.locationTrace.length - 1]
                    .time
                    .millisecondsSinceEpoch -
                _routeInfoHolder.startLocation.time.millisecondsSinceEpoch) ~/
            1000; // converting duration into seconds
      }
      _routeInfoHolder.distanceCovered = _routeInfoHolder.getDistance();
      _routeInfoHolder.avgSpeed = _routeInfoHolder.getAverageSpeed();
      _locationTraceWidgets = [];
      _routeInfoHolder.locationTrace.forEach((LocationDataChunk data) {
        _locationTraceWidgets.add(Container(
          margin:
              EdgeInsets.only(left: 10.0, right: 10.0, top: 6.0, bottom: 6.0),
          padding:
              EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Colors.white,
                width: 0.15,
                style: BorderStyle.solid,
              )),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Longitude'),
                  Text('${data.longitude}'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Latitude'),
                  Text('${data.latitude}'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('TimeStamp'),
                  Text('${data.getParsedTimeString()}'),
                ],
              ),
            ],
          ),
        ));
      });
    });
    _isAlreadySaved = false;
  }

  void _onError(dynamic error) {}

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
                .invokeMethod("fetchLocationDataSourcePreference")
                .then((dynamic id) async {
              await widget.platformLevelLocationIssueHandler.methodChannel
                  .invokeMethod("startLocationUpdate", <String, String>{
                "id": id.toString().isNotEmpty ? id.toString() : "1"
              }) // 0 -> google play service based location update request
                  // 1 -> android platform based location update, from android.hardware.gps
                  .then((dynamic value) {
                if (value == 1) {
                  widget.platformLevelLocationIssueHandler.eventChannel
                      .receiveBroadcastStream()
                      .listen(_onData, onError: _onError);
                } else {
                  stopLocationUpdate();
                  Navigator.of(context)
                      .pop(); // location access request denied, takes back to previous screen
                }
              });
            });
          } else {
            Navigator.pop(
                context); // takes back to previous screen, as location not enabled by user
          }
        });
      } else {
        Navigator.pop(
            context); // takes back to previous screen, as location access permission not granted
      }
    });
  }

  void stopLocationUpdate() {
    widget.platformLevelLocationIssueHandler.methodChannel
        .invokeMethod("stopLocationUpdate")
        .then((dynamic value) {
      if (value == 1) {
        widget.platformLevelLocationIssueHandler.eventChannel = null;
      }
    });
  }

  Future<bool> _onWillPop() async {
    // handles issues while popping this Page off, asks for user preferences depending upon arrival of GPS Trace.
    return !_isAlreadySaved
        ? await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Route Saver"),
                    content: Text("Do you want me to save this Route ?"),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text("Yes")),
                      FlatButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text("No")),
                    ],
                  );
                }) ??
            false
        : false;
  }

  Future<int> storeRoute(int routeId) async {
    if (_routeInfoHolder.locationTrace.length < 2) return 2;
    List<Map<String, String>> route = [];
    _routeInfoHolder.locationTrace.forEach((LocationDataChunk element) {
      route.add({
        "longitude": element.longitude.toString(),
        "latitude": element.latitude.toString(),
        "timeStamp": element.getParsedTimeString(),
        "altitude": element.altitude.toString(),
      });
    });
    return await widget.platformLevelLocationIssueHandler.methodChannel
        .invokeMethod("storeRoute", <String, dynamic>{
      "routeId": routeId,
      "route": route
    }).then((dynamic value) {
      return value as int;
    });
  }

  Future<int> getLastUsedRouteId() async {
    int resp = 0;
    await widget.platformLevelLocationIssueHandler.methodChannel
        .invokeMethod("getLastUsedRouteId")
        .then((dynamic value) {
      resp = value;
    });
    return resp;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.cyanAccent,
            title: Text(
              'Current Route',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            elevation: 14.0,
            actions: <Widget>[
              Builder(builder: (BuildContext ctx) {
                return IconButton(
                    icon: Icon(
                      Icons.save,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (_routeInfoHolder.locationTrace.length < 2) {
                        Scaffold.of(ctx).showSnackBar(SnackBar(
                          content: Text(
                            'Atleast two datapoints required :/',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.redAccent,
                          duration: Duration(seconds: 1),
                        ));
                      } else {
                        TextEditingController featureName =
                            TextEditingController(text: '');
                        String errorTextFeatureName;
                        FocusNode featureNameFocus = FocusNode();
                        TextEditingController featureDescription =
                            TextEditingController(text: '');
                        String errorTextFeatureDescription;
                        FocusNode featureDescriptionFocus = FocusNode();
                        int featureType;
                        await showDialog(
                            context: ctx,
                            barrierDismissible: false,
                            builder: (BuildContext ctxNew) {
                              return Dialog(
                                elevation: 20.0,
                                child: StatefulBuilder(
                                    builder: (ctxNew, setState) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        color: Colors.black,
                                        border: Border.all(
                                          color: Colors.white,
                                          style: BorderStyle.solid,
                                          width: 0.25,
                                        )),
                                    margin: EdgeInsets.all(10.0),
                                    padding: EdgeInsets.all(8.0),
                                    child: Card(
                                      elevation: 12.0,
                                      color: Colors.black38,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                'Feature Saver',
                                                style: TextStyle(
                                                    color: Colors.tealAccent,
                                                    letterSpacing: 2.0),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            color: Colors.white24,
                                            height: 16,
                                          ),
                                          TextField(
                                            autocorrect: true,
                                            focusNode: featureNameFocus,
                                            controller: featureName,
                                            decoration: InputDecoration(
                                              labelText: 'Feature Name',
                                              errorText: errorTextFeatureName,
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.tealAccent,
                                                    width: 0.75,
                                                    style: BorderStyle.solid),
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              contentPadding: EdgeInsets.only(
                                                  left: 8.0, right: 8.0),
                                            ),
                                            textInputAction:
                                                TextInputAction.next,
                                            onChanged: (String val) {
                                              if (errorTextFeatureName !=
                                                      null &&
                                                  errorTextFeatureName
                                                      .isNotEmpty) {
                                                setState(() {
                                                  errorTextFeatureName = null;
                                                });
                                              }
                                            },
                                            onEditingComplete: () {
                                              if (featureName.text.isEmpty) {
                                                setState(() {
                                                  errorTextFeatureName =
                                                      'Feature Name can\'t be blank';
                                                });
                                                FocusScope.of(ctxNew)
                                                    .requestFocus(
                                                        featureNameFocus);
                                              } else {
                                                FocusScope.of(ctxNew)
                                                    .requestFocus(
                                                        featureDescriptionFocus);
                                              }
                                            },
                                          ),
                                          Divider(
                                            color: Colors.black,
                                            height: 20,
                                          ),
                                          TextField(
                                            focusNode: featureDescriptionFocus,
                                            controller: featureDescription,
                                            maxLengthEnforced: true,
                                            maxLength: 200,
                                            autocorrect: true,
                                            decoration: InputDecoration(
                                              labelText: 'Feature Description',
                                              errorText:
                                                  errorTextFeatureDescription,
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.tealAccent,
                                                    width: 0.75,
                                                    style: BorderStyle.solid),
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              contentPadding: EdgeInsets.only(
                                                  left: 8.0, right: 8.0),
                                            ),
                                            textInputAction:
                                                TextInputAction.done,
                                            onTap: () {
                                              if (featureName.text.isEmpty) {
                                                setState(() {
                                                  errorTextFeatureName =
                                                      'Feature Name can\'t be blank';
                                                });
                                                FocusScope.of(ctxNew)
                                                    .requestFocus(
                                                        featureNameFocus);
                                              }
                                              if (errorTextFeatureDescription !=
                                                      null &&
                                                  errorTextFeatureDescription
                                                      .isNotEmpty) {
                                                setState(() {
                                                  errorTextFeatureDescription =
                                                      null;
                                                });
                                              }
                                            },
                                            onChanged: (String val) {
                                              if (errorTextFeatureDescription !=
                                                      null &&
                                                  errorTextFeatureDescription
                                                      .isNotEmpty) {
                                                setState(() {
                                                  errorTextFeatureDescription =
                                                      null;
                                                });
                                              }
                                            },
                                            onSubmitted: (String val) {
                                              if (featureDescription
                                                  .text.isEmpty) {
                                                setState(() {
                                                  errorTextFeatureDescription =
                                                      'Feature Description can\'t be blank';
                                                });
                                                FocusScope.of(ctxNew)
                                                    .requestFocus(
                                                        featureDescriptionFocus);
                                              } else {
                                                featureDescriptionFocus
                                                    .unfocus();
                                              }
                                            },
                                          ),
                                          Divider(
                                            color: Colors.black,
                                            height: 12,
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Radio(
                                                  value: 1,
                                                  groupValue: featureType,
                                                  onChanged: (int value) {
                                                    setState(() {
                                                      featureType = value;
                                                    });
                                                  }),
                                              Text('Line'),
                                              Radio(
                                                  value: 2,
                                                  groupValue: featureType,
                                                  onChanged: (int value) {
                                                    setState(() {
                                                      featureType = value;
                                                    });
                                                  }),
                                              Text('Polygon'),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              RaisedButton(
                                                onPressed: () =>
                                                    Navigator.of(ctxNew)
                                                        .pop(<String, String>{
                                                      'featureName': '',
                                                      'featureDescription': '',
                                                      'featureType': ''
                                                    }),
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                      color: Colors.white70),
                                                ),
                                                color: Colors.white24,
                                                elevation: 10.0,
                                                padding: EdgeInsets.all(4.0),
                                              ),
                                              RaisedButton(
                                                onPressed: () =>
                                                    Navigator.of(ctxNew)
                                                        .pop(<String, String>{
                                                      'featureName':
                                                          featureName.text,
                                                      'featureDescription':
                                                          featureDescription
                                                              .text,
                                                      'featureType':
                                                          featureType == null
                                                              ? ''
                                                              : featureType
                                                                  .toString()
                                                    }),
                                                child: Text(
                                                  'Save',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                color: Colors.tealAccent,
                                                elevation: 10.0,
                                                padding: EdgeInsets.all(4.0),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              );
                            }).then((dynamic myVal) {
                          Map<String, String> tmp =
                              Map<String, String>.from(myVal);
                          if (tmp["featureName"].isNotEmpty &&
                              tmp["featureDescription"].isNotEmpty &&
                              tmp["featureType"].isNotEmpty) {
                            _featureHolder.featureName = tmp["featureName"];
                            _featureHolder.moreInfoOnFeature =
                                tmp["featureDescription"];
                            _featureHolder.featureType = tmp["featureType"];
                            _featureHolder.featureLocation = _routeInfoHolder
                                .locationTrace
                                .map((LocationDataChunk ld) {
                              return FeatureLocation(
                                  ld.longitude.toString(),
                                  ld.latitude.toString(),
                                  ld.altitude.toString(),
                                  ld.getParsedTimeString());
                            }).toList();
                            widget
                                .platformLevelLocationIssueHandler.methodChannel
                                .invokeMethod("getLastUsedFeatureId")
                                .then((dynamic value) {
                              int featureId = value as int;
                              widget.platformLevelLocationIssueHandler
                                  .methodChannel
                                  .invokeMethod(
                                      "storeFeature", <String, dynamic>{
                                "featureId": featureId + 1,
                                "feature": _featureHolder.featureLocation
                                    .map((FeatureLocation fL) {
                                  return <String, String>{
                                    "featureName": _featureHolder.featureName,
                                    "featureDescription":
                                        _featureHolder.moreInfoOnFeature,
                                    "featureType": _featureHolder.featureType,
                                    "longitude": fL.longitude,
                                    "latitude": fL.latitude,
                                    "altitude": fL.altitude,
                                    "timeStamp": fL.timeStamp,
                                  };
                                }).toList(),
                              }).then((dynamic val) {
                                val == 1
                                    ? Scaffold.of(ctx).showSnackBar(SnackBar(
                                        content: Text(
                                          "Saved Route as Feature",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        duration: Duration(seconds: 2),
                                        backgroundColor: Colors.green,
                                      ))
                                    : Scaffold.of(ctx).showSnackBar(SnackBar(
                                        content: Text(
                                          "Failed to save Feature",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        duration: Duration(seconds: 2),
                                        backgroundColor: Colors.red,
                                      ));
                              });
                            });
                          }
                        });
                      }
                    });
              }),
            ]),
        body: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Colors.white,
                    width: 0.1,
                    style: BorderStyle.solid,
                  )),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Card(
                    color: Colors.black12,
                    margin: EdgeInsets.only(
                        top: 8.0, left: 6.0, right: 6.0, bottom: 12),
                    elevation: 12.0,
                    child: Container(
                      margin: EdgeInsets.all(4.0),
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.white70,
                            width: 0.5,
                            style: BorderStyle.solid,
                          )),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Start Point ::",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  letterSpacing: 3.0,
                                ),
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _routeInfoHolder.startLocation.longitude =
                                          widget.location.longitude;
                                      _routeInfoHolder.startLocation.latitude =
                                          widget.location.latitude;
                                      _routeInfoHolder.startLocation.time =
                                          widget.location.time;
                                      _routeInfoHolder.startLocation.altitude =
                                          widget.location.altitude;
                                      _routeInfoHolder.startLocation.accuracy =
                                          widget.location.accuracy;
                                      _routeInfoHolder.startLocation.speed =
                                          widget.location
                                              .getSpeedInKiloMetersPerHour();
                                      _routeInfoHolder.locationTrace = [
                                        _routeInfoHolder.startLocation
                                      ];
                                      _routeInfoHolder.distanceCovered = 0.0;
                                      _routeInfoHolder.duration =
                                          0; // as start location got changed
                                      _routeInfoHolder.avgSpeed =
                                          _routeInfoHolder.getAverageSpeed();
                                      _locationTraceWidgets = [];
                                      _routeInfoHolder.locationTrace
                                          .forEach((LocationDataChunk data) {
                                        _locationTraceWidgets.add(Container(
                                          margin: EdgeInsets.only(
                                              left: 10.0,
                                              right: 10.0,
                                              top: 6.0,
                                              bottom: 6.0),
                                          padding: EdgeInsets.only(
                                              left: 12.0,
                                              right: 12.0,
                                              top: 8.0,
                                              bottom: 8.0),
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 0.15,
                                                style: BorderStyle.solid,
                                              )),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text('Longitude'),
                                                  Text('${data.longitude}'),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text('Latitude'),
                                                  Text('${data.latitude}'),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text('TimeStamp'),
                                                  Text(
                                                      '${data.getParsedTimeString()}'),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ));
                                      });
                                    });
                                    _isAlreadySaved = false;
                                  }),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Longitude",
                                    ),
                                    Text(
                                      _routeInfoHolder
                                                  .startLocation.longitude !=
                                              null
                                          ? _routeInfoHolder
                                              .startLocation.longitude
                                              .toString()
                                          : 'NA',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Latitude",
                                    ),
                                    Text(
                                      _routeInfoHolder.startLocation.latitude !=
                                              null
                                          ? _routeInfoHolder
                                              .startLocation.latitude
                                              .toString()
                                          : 'NA',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Altitude",
                                    ),
                                    Text(
                                      _routeInfoHolder.startLocation.altitude !=
                                              null
                                          ? _routeInfoHolder
                                                  .startLocation.altitude
                                                  .toString() +
                                              ' m'
                                          : 'NA',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Accuracy",
                                    ),
                                    Text(
                                      _routeInfoHolder.startLocation.accuracy !=
                                              null
                                          ? _routeInfoHolder
                                                  .startLocation.accuracy
                                                  .toString() +
                                              ' m'
                                          : 'NA',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Start Time ::",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      _routeInfoHolder.startLocation.time !=
                                              null
                                          ? _routeInfoHolder.startLocation
                                              .getParsedTimeString()
                                          : 'NA',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Current Point ::",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Longitude",
                                    ),
                                    Text(
                                      widget.location.longitude != null
                                          ? widget.location.longitude.toString()
                                          : 'NA',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Latitude",
                                    ),
                                    Text(
                                      widget.location.latitude != null
                                          ? widget.location.latitude.toString()
                                          : 'NA',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Altitude",
                                    ),
                                    Text(
                                      widget.location.altitude != null
                                          ? widget.location.altitude
                                                  .toString() +
                                              ' m'
                                          : 'NA',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Accuracy",
                                    ),
                                    Text(
                                      widget.location.accuracy != null
                                          ? widget.location.accuracy
                                                  .toString() +
                                              ' m'
                                          : 'NA',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Current Time ::",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      widget.location.time != null
                                          ? widget.location
                                              .getParsedTimeString()
                                          : 'NA',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Distance Covered ::",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      _routeInfoHolder.distanceCovered > 1
                                          ? '${_routeInfoHolder.distanceCovered} km'
                                          : '${_routeInfoHolder.distanceCovered * 1000} m',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Time Spent on Route ::",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      _routeInfoHolder.getTimeSpentOnRoute(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Average Speed ::",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '${_routeInfoHolder.avgSpeed} km/h',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Direction of Movement ::",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
                            padding: EdgeInsets.only(
                                left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 0.5,
                                  style: BorderStyle.solid,
                                )),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      widget.location.bearingToDirectionName(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "GPS Traces",
                        style: TextStyle(
                          color: Colors.tealAccent,
                          letterSpacing: 4.0,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.white12,
                    height: 20,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _locationTraceWidgets,
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Builder(
            builder: (BuildContext context) => FloatingActionButton(
                  onPressed: () {
                    !_isAlreadySaved
                        ? getLastUsedRouteId().then((int routeId) {
                            storeRoute(routeId + 1).then((int value) {
                              value == 0
                                  ? Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                        "Couldn't saved Route",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      duration: Duration(seconds: 2),
                                      backgroundColor: Colors.red,
                                    ))
                                  : value == 1
                                      ? Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                          content: Text(
                                            // ignore: unnecessary_statements
                                            'Saved Route',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          duration: Duration(seconds: 2),
                                          backgroundColor: Colors.green,
                                        ))
                                      : Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                          content: Text(
                                            'Not enough Data for saving a Route :/',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          duration: Duration(seconds: 2),
                                          backgroundColor: Colors.red,
                                        ));
                              _isAlreadySaved = value == 0 ? true : false;
                            });
                          })
                        : Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(
                              'Already saved Route',
                              style: TextStyle(color: Colors.white),
                            ),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ));
                  },
                  child: Icon(
                    Icons.save_alt,
                    color: Colors.white,
                  ),
                  elevation: 12.0,
                  tooltip: "Save this Route",
                  backgroundColor: Colors.cyanAccent,
                  highlightElevation: 20.0,
                )),
      ),
      onWillPop: _onWillPop,
    );
  }
}
